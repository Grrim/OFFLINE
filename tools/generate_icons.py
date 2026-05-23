"""Generate Android launcher icons from a source image.

Usage: python tools/generate_icons.py <source_image_path>

Requires Pillow: pip install Pillow
"""

import sys
from pathlib import Path

try:
    from PIL import Image
except ImportError:
    print("Installing Pillow...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "Pillow", "-q"])
    from PIL import Image

# Android mipmap sizes
SIZES = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

def main():
    if len(sys.argv) < 2:
        # Try to find the icon in common locations
        candidates = [
            Path(__file__).parent.parent / 'assets' / 'icon.png',
            Path(__file__).parent.parent / 'icon.png',
        ]
        source = None
        for c in candidates:
            if c.exists():
                source = c
                break
        if source is None:
            print("Usage: python tools/generate_icons.py <source_image.png>")
            sys.exit(1)
    else:
        source = Path(sys.argv[1])

    if not source.exists():
        print(f"File not found: {source}")
        sys.exit(1)

    img = Image.open(source).convert('RGBA')
    print(f"Source: {source} ({img.width}x{img.height})")

    res_dir = Path(__file__).parent.parent / 'android' / 'app' / 'src' / 'main' / 'res'

    for folder, size in SIZES.items():
        out_dir = res_dir / folder
        out_dir.mkdir(parents=True, exist_ok=True)
        resized = img.resize((size, size), Image.LANCZOS)
        out_path = out_dir / 'ic_launcher.png'
        resized.save(out_path, 'PNG')
        print(f"  ✓ {folder}/ic_launcher.png ({size}x{size})")

    print("\nDone.")


if __name__ == '__main__':
    main()
