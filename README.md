# Catholic Bible App (CBA) 📖✝️

A completely **free**, **offline**, and **ad-free** Catholic Bible app using the Douay-Rheims translation.

## 🙏 Why I Built This

After searching the Google Play Store for a decent Catholic Bible app, I was frustrated to discover that **every single one** was either:
- Filled with intrusive **ads**,
- Locked behind **in-app purchases**, or
- Missing essential Catholic books.

As a developer and practicing Catholic, I knew I could do better. So I built **CBA** — the **Catholic Bible App** — a humble, minimalist app for anyone who simply wants to **read the Word of God** in peace.

## 📜 Translation Used

This app uses the **Douay-Rheims Bible**, translated from the Latin Vulgate by St. Jerome. It includes all 73 books of the Bible, including the **Deuterocanonical books** used in Catholic tradition.

The text is sourced from a clean, public domain version of the Douay-Rheims Bible, which respects both the historical and spiritual depth of the Catholic faith.

## ✨ Features

- 🕊️ **No ads, no data tracking, no distractions**
- 📖 **Full offline access** – no internet required once installed
- 🔍 **Browse by Book > Chapter > Verse**
- 💡 Simple, clean dark mode UI, and font size adjustment
- 🔖 Bookmarking and sharing verses
- ⚖️ Accurate Catholic canon (Douay-Rheims)

## 🚀 Built With

- **Flutter** for cross-platform development (Android/iOS)
- JSON-based local storage of Bible data
- Custom UI inspired by the principles of simplicity and reverence

## 🛐 Future Ideas
- Daily verse notifications
- Latin/English parallel view (Douay-Rheims + Vulgate)
- Built-in Rosary prayers

## 🔓 License & Usage

The text of the Douay-Rheims Bible is in the **public domain**, and this app is offered completely **free and open source** for others to improve, share, and use.

---

> *"Ignorance of Scripture is ignorance of Christ."*  
> — *St. Jerome*

---

## 🙌 Contributions Welcome

Want to help build a better spiritual tool? Feel free to open a PR or fork the repo!

## 🚀 Automated Releases

This project uses GitHub Actions to automatically build and release the APK when a new version tag is pushed. To create a new release:

1. Make your changes and ensure the app builds correctly
2. Update the version in `pubspec.yaml`
3. Commit your changes
4. Create and push a new tag:
   ```
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```
5. GitHub Actions will automatically build the APK and create a release with the APK attached

The workflow configuration can be found in `.github/workflows/release.yml`.

