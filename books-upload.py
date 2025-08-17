import os
import time
import json
import requests
import fitz  # PyMuPDF
from ebooklib import epub
from PIL import Image
from io import BytesIO

WEBHOOK_URL = "web-hook-url"
BOOKS_FOLDER = "/home/ahmad/eBooks/Maths/"
MAX_FILE_SIZE = 10 * 1024 * 1024
SUPPORTED_EXTENSIONS = (".pdf", ".epub")


def extract_pdf_cover(pdf_path):
    try:
        doc = fitz.open(pdf_path)
        page = doc.load_page(0)
        pix = page.get_pixmap(dpi=150)
        image_bytes = pix.tobytes("png")
        return image_bytes
    except Exception as e:
        print(f"❌ Error extracting PDF cover: {e}")
        return None


def extract_epub_cover(epub_path):
    try:
        book = epub.read_epub(epub_path)

        # Try to find the cover id from metadata
        cover_id = None
        for item in book.get_metadata('http://www.idpf.org/2007/opf', 'meta'):
            if 'name' in item[1] and item[1]['name'].lower() == 'cover':
                cover_id = item[1]['content']
                break

        if cover_id:
            for item in book.get_items():
                if item.get_id() == cover_id and item.media_type.startswith('image/'):
                    return item.get_content()

        # fallback: first image
        for item in book.get_items():
            if item.media_type and item.media_type.startswith('image/'):
                return item.get_content()

    except Exception as e:
        print(f"❌ Error extracting EPUB cover: {e}")
    return None

def upload_book_with_cover(book_title, book_filename, book_bytes, cover_bytes, webhook_url):
    """Upload book and cover in a single Discord message with embed"""
    files = {}
    
    # Add the main book file
    files["file1"] = (book_filename, book_bytes)
    
    # Add cover if available
    cover_filename = None
    if cover_bytes:
        cover_filename = f"{os.path.splitext(book_filename)[0]}_cover.png"
        files["file2"] = (cover_filename, cover_bytes)
    
    # Create embed with book title and cover
    embed = {
        "title": f"📚 {book_title}",
        "color": 0x5865F2,  # Discord blurple color
        "fields": [
            {
                "name": "File",
                "value": book_filename,
                "inline": True
            },
            {
                "name": "Size",
                "value": f"{len(book_bytes) / (1024 * 1024):.2f} MB",
                "inline": True
            }
        ]
    }
    
    # Set cover as embed image if available
    if cover_filename:
        embed["image"] = {"url": f"attachment://{cover_filename}"}
    
    payload = {
        "embeds": [embed]
    }
    
    try:
        response = requests.post(webhook_url, data={"payload_json": json.dumps(payload)}, files=files)
        if response.status_code not in [200, 204]:
            print(f"❌ Discord API error: {response.status_code} - {response.text}")
        return response.status_code in [200, 204]
    except Exception as e:
        print(f"❌ Error uploading to Discord: {e}")
        return False


def get_book_title(filename):
    """Extract book title from filename by removing extension and cleaning up"""
    title = os.path.splitext(filename)[0]
    # Replace underscores and hyphens with spaces, capitalize words
    title = title.replace('_', ' ').replace('-', ' ')
    return ' '.join(word.capitalize() for word in title.split())


book_files = [
    f for f in os.listdir(BOOKS_FOLDER)
    if f.lower().endswith(SUPPORTED_EXTENSIONS)
]

for book in book_files:
    book_path = os.path.join(BOOKS_FOLDER, book)
    file_size = os.path.getsize(book_path)

    if file_size > MAX_FILE_SIZE:
        print(f"⏭️ Skipping {book} (size: {file_size / (1024 * 1024):.2f} MB)")
        continue

    print(f"📚 Processing: {book}")

    # Extract cover
    cover_bytes = None
    if book.lower().endswith(".pdf"):
        cover_bytes = extract_pdf_cover(book_path)
    elif book.lower().endswith(".epub"):
        cover_bytes = extract_epub_cover(book_path)

    # Read book file
    with open(book_path, "rb") as f:
        book_bytes = f.read()

    # Get book title from filename
    book_title = get_book_title(book)

    # Upload book and cover together in one message
    success = upload_book_with_cover(book_title, book, book_bytes, cover_bytes, WEBHOOK_URL)

    if success:
        print(f"✅ Uploaded book with cover: {book}")
    else:
        print(f"❌ Failed to upload book: {book}")

    time.sleep(3)
