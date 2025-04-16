#!/usr/bin/env python3
import json
import os

def main():
    """
    Parses the EntireBible-DR.json file, removes asterisks from all verses,
    and saves the result back to the file.
    """
    # Define the file path
    file_path = "assets/EntireBible-DR.json"
    
    # Check if the file exists
    if not os.path.exists(file_path):
        print(f"Error: File '{file_path}' not found.")
        return
    
    try:
        # Read the JSON file
        print(f"Reading {file_path}...")
        with open(file_path, 'r', encoding='utf-8') as f:
            bible_data = json.load(f)
        
        # Count the total asterisks
        total_asterisks = 0
        
        # Process each book
        print("Removing asterisks from verses...")
        for book_name, book_data in bible_data.items():
            # Process each chapter
            for chapter_num, chapter_data in book_data.items():
                # Process each verse
                for verse_num, verse_text in chapter_data.items():
                    # Count asterisks in this verse
                    asterisks_in_verse = verse_text.count('*')
                    total_asterisks += asterisks_in_verse
                    
                    # Remove asterisks
                    new_verse_text = verse_text.replace('*', '')
                    
                    # Update the verse text
                    chapter_data[verse_num] = new_verse_text
        
        # Create a backup of the original file
        backup_path = f"{file_path}.backup"
        print(f"Creating backup at {backup_path}...")
        with open(backup_path, 'w', encoding='utf-8') as f:
            # Use indent for readability in the backup
            json.dump(bible_data, f, ensure_ascii=False, indent=2)
        
        # Write the modified data back to the original file
        print(f"Writing modified data back to {file_path}...")
        with open(file_path, 'w', encoding='utf-8') as f:
            # No indent in the original to keep file size down
            json.dump(bible_data, f, ensure_ascii=False)
        
        print(f"Done! Removed {total_asterisks} asterisks from the Bible text.")
        print(f"Original file backed up to {backup_path}")
        
    except json.JSONDecodeError:
        print("Error: Invalid JSON format in the file.")
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    main() 