import os
import re
from PIL import Image

# Directories
posts_dir = "/home/ahmad/Documents/blog/content/posts/"
assets_dir = os.path.join(posts_dir, "assets")

# Regex to fix image links missing leading slash
fix_link_pattern = re.compile(r'!\[\]\((?!/)(posts/assets/[^)]+)\)')

# Regex to find image links with extensions to change (.jpg → .webp)
img_ext_pattern = re.compile(r'(!\[\]\(/posts/assets/[^)]+)\.(png|jpg|jpeg)\)')

print("🔧 Fixing image paths in Markdown files...\n")

# First pass: Fix links with missing leading slash
for filename in os.listdir(posts_dir):
    if filename.endswith(".md"):
        filepath = os.path.join(posts_dir, filename)

        with open(filepath, "r") as file:
            content = file.read()

        # Add leading slash
        content = fix_link_pattern.sub(r"![](/\1)", content)

        # Replace image extensions with .webp
        updated_content = img_ext_pattern.sub(r"\1.webp)", content)

        if updated_content != content:
            with open(filepath, "w") as file:
                file.write(updated_content)
            print(f"✅ Updated Markdown: {filename}")

print("\n🖼️ Converting and cleaning up images...\n")

# Supported image formats
supported_formats = ('.png', '.jpg', '.jpeg')

# Convert and clean images
for root, _, files in os.walk(assets_dir):
    for file in files:
        if file.lower().endswith(supported_formats):
            full_path = os.path.join(root, file)
            base_name, _ = os.path.splitext(file)
            webp_path = os.path.join(root, base_name + ".webp")

            if not os.path.exists(webp_path):
                try:
                    with Image.open(full_path) as img:
                        img.save(webp_path, "webp")
                    print(f"🟢 Converted: {file} ➜ {base_name}.webp")

                    # Delete original file
                    os.remove(full_path)
                    print(f"🗑️ Deleted original: {file}")

                except Exception as e:
                    print(f"❌ Failed to convert {file}: {e}")

print("\n🎉 All markdowns updated and images converted.")
