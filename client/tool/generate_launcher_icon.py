"""Generate matching Android and iOS launcher icons from simple vector shapes."""

from pathlib import Path
import json
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[1]
SIZE = 1024
image = Image.new("RGB", (SIZE, SIZE), "#0F1B2C")
draw = ImageDraw.Draw(image)

# Wallet silhouette and a short journey across its clasp.
draw.rounded_rectangle((150, 265, 874, 795), radius=130, fill="#FF6B4A")
draw.rounded_rectangle((150, 245, 735, 670), radius=110, fill="#F4EFE4")
draw.rounded_rectangle((150, 335, 874, 795), radius=115, fill="#FF6B4A")
draw.rounded_rectangle((552, 454, 916, 647), radius=80, fill="#0F1B2C")
draw.arc((252, 449, 614, 681), 207, 333, fill="#F4EFE4", width=36)
draw.ellipse((277, 584, 333, 640), fill="#F4EFE4")
draw.ellipse((667, 527, 735, 595), fill="#F4EFE4")

for density, pixels in {"mdpi": 48, "hdpi": 72, "xhdpi": 96,
                        "xxhdpi": 144, "xxxhdpi": 192}.items():
    destination = ROOT / "android/app/src/main/res" / f"mipmap-{density}" / "ic_launcher.png"
    image.resize((pixels, pixels), Image.Resampling.LANCZOS).save(destination)

ios = ROOT / "ios/Runner/Assets.xcassets/AppIcon.appiconset"
contents = json.loads((ios / "Contents.json").read_text())
for entry in contents["images"]:
    side = int(float(entry["size"].split("x")[0]) * float(entry["scale"].removesuffix("x")))
    image.resize((side, side), Image.Resampling.LANCZOS).save(ios / entry["filename"])
