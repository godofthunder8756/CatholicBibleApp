import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

// Global key to access the navigator state
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Create a global settings service for safe state access
class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  
  factory AppSettings() {
    return _instance;
  }
  
  AppSettings._internal();
  
  SharedPreferences? _prefs;
  final List<Function()> _listeners = [];
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  bool get isDarkMode => _prefs?.getBool('darkMode') ?? false;
  double get fontSize => _prefs?.getDouble('fontSize') ?? 16.0;
  
  Future<void> setDarkMode(bool value) async {
    await _prefs?.setBool('darkMode', value);
    _notifyListeners();
  }
  
  Future<void> setFontSize(double value) async {
    await _prefs?.setDouble('fontSize', value);
    _notifyListeners();
  }
  
  void addListener(Function() listener) {
    _listeners.add(listener);
  }
  
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }
  
  void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

// Global instance
final appSettings = AppSettings();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appSettings.init();
  runApp(CatholicBibleApp());
}

class CatholicBibleApp extends StatefulWidget {
  @override
  _CatholicBibleAppState createState() => _CatholicBibleAppState();
}

class _CatholicBibleAppState extends State<CatholicBibleApp> {
  bool _isDarkMode = false;
  double _fontSize = 16.0;
  late ThemeData _lightTheme;
  late ThemeData _darkTheme;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    appSettings.addListener(_updateFromSettings);
  }
  
  @override
  void dispose() {
    appSettings.removeListener(_updateFromSettings);
    super.dispose();
  }

  void _updateFromSettings() {
    setState(() {
      _isDarkMode = appSettings.isDarkMode;
      _fontSize = appSettings.fontSize;
      _updateThemes();
    });
  }

  void _loadSettings() {
    setState(() {
      _isDarkMode = appSettings.isDarkMode;
      _fontSize = appSettings.fontSize;
    });
    _updateThemes();
  }

  void _updateThemes() {
    final fontSizeFactor = _fontSize / 16.0;
    
    _lightTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF8B4513),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      textTheme: _applyFontSize(GoogleFonts.merriweatherTextTheme(), _fontSize),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    
    _darkTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF8B4513),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      useMaterial3: true,
      textTheme: _applyFontSize(GoogleFonts.merriweatherTextTheme(ThemeData.dark().textTheme), _fontSize),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Helper method to safely apply font size to a TextTheme
  TextTheme _applyFontSize(TextTheme theme, double fontSize) {
    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(fontSize: fontSize * 2.0),
      displayMedium: theme.displayMedium?.copyWith(fontSize: fontSize * 1.5),
      displaySmall: theme.displaySmall?.copyWith(fontSize: fontSize * 1.17),
      headlineLarge: theme.headlineLarge?.copyWith(fontSize: fontSize * 1.5),
      headlineMedium: theme.headlineMedium?.copyWith(fontSize: fontSize * 1.3),
      headlineSmall: theme.headlineSmall?.copyWith(fontSize: fontSize * 1.15),
      titleLarge: theme.titleLarge?.copyWith(fontSize: fontSize * 1.1),
      titleMedium: theme.titleMedium?.copyWith(fontSize: fontSize),
      titleSmall: theme.titleSmall?.copyWith(fontSize: fontSize * 0.9),
      bodyLarge: theme.bodyLarge?.copyWith(fontSize: fontSize),
      bodyMedium: theme.bodyMedium?.copyWith(fontSize: fontSize * 0.9),
      bodySmall: theme.bodySmall?.copyWith(fontSize: fontSize * 0.8),
      labelLarge: theme.labelLarge?.copyWith(fontSize: fontSize),
      labelMedium: theme.labelMedium?.copyWith(fontSize: fontSize * 0.9),
      labelSmall: theme.labelSmall?.copyWith(fontSize: fontSize * 0.8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Catholic Bible App',
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: BookListScreen(
        fontSize: _fontSize,
      ),
    );
  }
}

class BookListScreen extends StatefulWidget {
  final double fontSize;

  BookListScreen({required this.fontSize});

  @override
  _BookListScreenState createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  Map<String, dynamic> bible = {};
  bool isLoading = true;

  // Define the first book of the New Testament
  final String _firstNewTestamentBook = "Matthew";

  @override
  void initState() {
    super.initState();
    loadBible();
  }

  Future<void> loadBible() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/EntireBible-DR.json');
      final Map<String, dynamic> parsed = jsonDecode(jsonString);
      setState(() {
        bible = parsed;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catholic Bible App'),
        centerTitle: true,
      ),
      drawer: NavigationDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : bible.isEmpty
              ? Center(
                  child: Text(
                    'Unable to load Bible data',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Select a Book',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                    // Old Testament Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Text(
                              'OLD TESTAMENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildBookGrid(context, oldTestamentBooks()),
                    // New Testament Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Center(
                            child: Text(
                              'NEW TESTAMENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildBookGrid(context, newTestamentBooks()),
                  ],
                ),
    );
  }

  // Get Old Testament books
  List<String> oldTestamentBooks() {
    final allBooks = bible.keys.toList();
    final indexOfFirstNewTestament = allBooks.indexOf(_firstNewTestamentBook);
    if (indexOfFirstNewTestament == -1) return allBooks;
    return allBooks.sublist(0, indexOfFirstNewTestament);
  }

  // Get New Testament books
  List<String> newTestamentBooks() {
    final allBooks = bible.keys.toList();
    final indexOfFirstNewTestament = allBooks.indexOf(_firstNewTestamentBook);
    if (indexOfFirstNewTestament == -1) return [];
    return allBooks.sublist(indexOfFirstNewTestament);
  }

  // Build a grid for book sections
  Widget _buildBookGrid(BuildContext context, List<String> books) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final book = books[index];
            return Card(
              color: Color(0xFF2C1E13), // Darker brown for book cards
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChapterListScreen(
                        book: book,
                        chapters: bible[book],
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    book,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          },
          childCount: books.length,
        ),
      ),
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.book,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'Catholic Bible App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.search),
            title: Text('Search'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SearchScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.bookmark),
            title: Text('Bookmarks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BookmarksScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'Catholic Bible App',
                applicationVersion: '1.0.0',
                children: [
                  Text('A beautiful Catholic Bible app for daily reading and prayer.'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    // TODO: Implement actual search functionality
    setState(() {
      _searchResults = ['Search results for: $query'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search verses...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchResults[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookmarksScreen extends StatefulWidget {
  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getStringList('bookmarks') ?? [];
    
    // Parse bookmarks and ensure no duplicates
    final parsedBookmarks = bookmarksJson
        .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
        .toList();
    
    // Remove duplicates by constructing a new list with unique verses
    final uniqueBookmarks = <Map<String, dynamic>>[];
    final uniqueKeys = <String>{};
    
    for (final bookmark in parsedBookmarks) {
      final key = '${bookmark['book']}_${bookmark['chapter']}_${bookmark['verse']}';
      if (!uniqueKeys.contains(key)) {
        uniqueKeys.add(key);
        uniqueBookmarks.add(bookmark);
      }
    }
    
    setState(() {
      _bookmarks = uniqueBookmarks;
    });
    
    // Save the uniqueBookmarks back if different from original
    if (uniqueBookmarks.length != parsedBookmarks.length) {
      _saveBookmarks();
    }
  }

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = _bookmarks.map((bookmark) => jsonEncode(bookmark)).toList();
    await prefs.setStringList('bookmarks', bookmarksJson);
  }

  Future<void> _removeBookmark(int index) async {
    setState(() {
      _bookmarks.removeAt(index);
    });
    await _saveBookmarks();
  }

  void _navigateToVerse(Map<String, dynamic> bookmark) async {
    // Get the Bible data to navigate to the verse
    final jsonString = await rootBundle.loadString('assets/EntireBible-DR.json');
    final bible = jsonDecode(jsonString);
    
    if (bible.containsKey(bookmark['book']) && 
        bible[bookmark['book']].containsKey(bookmark['chapter'])) {
      
      // Navigate to chapter screen first
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => ChapterListScreen(
            book: bookmark['book'],
            chapters: bible[bookmark['book']],
          ),
        ),
      );
      
      // Then navigate to verse screen
      navigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (_) => VerseScreen(
            book: bookmark['book'],
            initialChapter: bookmark['chapter'],
            allChapters: bible[bookmark['book']],
            chapterNumbers: bible[bookmark['book']].keys.toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
        centerTitle: true,
      ),
      body: _bookmarks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bookmark_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Bookmark verses to see them here',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = _bookmarks[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () => _navigateToVerse(bookmark),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${bookmark['verse']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => _removeBookmark(index),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                splashRadius: 20,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '${bookmark['book']} ${bookmark['chapter']}:${bookmark['verse']}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          SizedBox(height: 8),
                          Text(
                            bookmark['text'] ?? 'No text available',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _darkMode = appSettings.isDarkMode;
      _fontSize = appSettings.fontSize;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) async {
                  await appSettings.setDarkMode(value);
                  setState(() {
                    _darkMode = value;
                  });
                },
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12,
                    max: 24,
                    divisions: 6,
                    label: _fontSize.round().toString(),
                    onChanged: (value) async {
                      await appSettings.setFontSize(value);
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              title: Text('Clear Bookmarks'),
              trailing: Icon(Icons.delete),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('bookmarks');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Bookmarks cleared')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterListScreen extends StatelessWidget {
  final String book;
  final Map<String, dynamic> chapters;

  ChapterListScreen({required this.book, required this.chapters});

  @override
  Widget build(BuildContext context) {
    final chapterNumbers = chapters.keys.toList();
    // Sort chapter numbers numerically
    chapterNumbers.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    return Scaffold(
      appBar: AppBar(
        title: Text(book),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Select a Chapter',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final chapter = chapterNumbers[index];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VerseScreen(
                              book: book,
                              initialChapter: chapter,
                              allChapters: chapters,
                              chapterNumbers: chapterNumbers,
                            ),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(
                          chapter,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  );
                },
                childCount: chapterNumbers.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VerseScreen extends StatefulWidget {
  final String book;
  final String initialChapter;
  final Map<String, dynamic> allChapters;
  final List<String> chapterNumbers;

  VerseScreen({
    required this.book, 
    required this.initialChapter, 
    required this.allChapters,
    required this.chapterNumbers,
  });

  @override
  _VerseScreenState createState() => _VerseScreenState();
}

class _VerseScreenState extends State<VerseScreen> {
  Set<String> selectedVerses = {};
  bool isSelectionMode = false;
  late PageController _pageController;
  late int _currentChapterIndex;
  
  @override
  void initState() {
    super.initState();
    _currentChapterIndex = widget.chapterNumbers.indexOf(widget.initialChapter);
    _pageController = PageController(initialPage: _currentChapterIndex);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String get _currentChapter => widget.chapterNumbers[_currentChapterIndex];
  
  Map<String, dynamic> get _currentVerses => widget.allChapters[_currentChapter];

  void _toggleVerseSelection(String verse) {
    setState(() {
      if (selectedVerses.contains(verse)) {
        selectedVerses.remove(verse);
        if (selectedVerses.isEmpty) {
          isSelectionMode = false;
        }
      } else {
        selectedVerses.add(verse);
        isSelectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      selectedVerses.clear();
      isSelectionMode = false;
    });
  }

  void _shareSelectedVerses() async {
    if (selectedVerses.isEmpty) return;
    
    final verses = selectedVerses.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final text = verses.map((v) => '${widget.book} $_currentChapter:$v ${_currentVerses[v]}').join('\n\n');
    
    await Share.share(
      text,
      subject: '${widget.book} $_currentChapter',
    );
  }

  void _copyToClipboard() {
    if (selectedVerses.isEmpty) return;
    
    final verses = selectedVerses.toList()..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    final text = verses.map((v) => '${widget.book} $_currentChapter:$v ${_currentVerses[v]}').join('\n\n');
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied to clipboard')),
    );
  }

  Future<void> _bookmarkSelectedVerses() async {
    if (selectedVerses.isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final existingBookmarksJson = prefs.getStringList('bookmarks') ?? [];
    
    // Parse existing bookmarks
    List<Map<String, dynamic>> existingBookmarks = existingBookmarksJson
        .map((json) => Map<String, dynamic>.from(jsonDecode(json)))
        .toList();
    
    int newBookmarks = 0;
    
    // Add only non-duplicate verses
    for (final verse in selectedVerses) {
      final newBookmark = {
        'book': widget.book,
        'chapter': _currentChapter,
        'verse': verse,
        'text': _currentVerses[verse],
      };
      
      // Check if this verse is already bookmarked
      bool isDuplicate = existingBookmarks.any((bookmark) => 
        bookmark['book'] == widget.book && 
        bookmark['chapter'] == _currentChapter && 
        bookmark['verse'] == verse
      );
      
      if (!isDuplicate) {
        existingBookmarks.add(newBookmark);
        newBookmarks++;
      }
    }
    
    // Save updated bookmarks list
    final updatedBookmarksJson = existingBookmarks
        .map((bookmark) => jsonEncode(bookmark))
        .toList();
    
    await prefs.setStringList('bookmarks', updatedBookmarksJson);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newBookmarks > 0 
            ? 'Bookmarked $newBookmarks ${newBookmarks == 1 ? 'verse' : 'verses'}' 
            : 'These verses are already bookmarked'
        ),
      ),
    );
    _clearSelection();
  }

  void _onPageChanged(int index) {
    if (isSelectionMode) {
      _clearSelection();
    }
    setState(() {
      _currentChapterIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.book} $_currentChapter'),
        centerTitle: true,
        actions: [
          if (isSelectionMode)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: _clearSelection,
            ),
        ],
      ),
      body: Column(
        children: [
          if (isSelectionMode)
            Container(
              padding: EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('${selectedVerses.length} selected'),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: _shareSelectedVerses,
                    tooltip: 'Share',
                  ),
                  IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: _copyToClipboard,
                    tooltip: 'Copy',
                  ),
                  IconButton(
                    icon: Icon(Icons.bookmark),
                    onPressed: _bookmarkSelectedVerses,
                    tooltip: 'Bookmark',
                  ),
                ],
              ),
            ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.chapterNumbers.length,
              itemBuilder: (context, index) {
                final chapterNumber = widget.chapterNumbers[index];
                final verses = widget.allChapters[chapterNumber];
                final verseNumbers = verses.keys.toList()
                  ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));
                
                return ChapterPage(
                  verseNumbers: verseNumbers,
                  verses: verses,
                  selectedVerses: selectedVerses,
                  isSelectionMode: isSelectionMode,
                  onToggleSelection: _toggleVerseSelection,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// New widget for displaying a chapter page
class ChapterPage extends StatelessWidget {
  final List<String> verseNumbers;
  final Map<String, dynamic> verses;
  final Set<String> selectedVerses;
  final bool isSelectionMode;
  final Function(String) onToggleSelection;
  
  const ChapterPage({
    Key? key,
    required this.verseNumbers,
    required this.verses,
    required this.selectedVerses,
    required this.isSelectionMode,
    required this.onToggleSelection,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: verseNumbers.length,
      itemBuilder: (context, index) {
        final verse = verseNumbers[index];
        final isSelected = selectedVerses.contains(verse);

        return GestureDetector(
          onLongPress: () => onToggleSelection(verse),
          onTap: () {
            if (isSelectionMode) {
              onToggleSelection(verse);
            }
          },
          child: Card(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: [
                    TextSpan(
                      text: '$verse ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    TextSpan(
                      text: verses[verse],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
