"""Verify the exact bundled PaddleOCR model files before building."""

import hashlib
import json
from pathlib import Path


def main():
    sdk = Path(__file__).resolve().parents[1] / "android" / "ppocr-sdk"
    for model in json.loads((sdk / "models.lock.json").read_text()):
        path = sdk / "src/main/assets/models" / model["path"]
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual != model["sha256"]:
            raise SystemExit(f"Model checksum mismatch: {model['path']}")
        print(f"Verified {model['path']}")


if __name__ == "__main__":
    main()
