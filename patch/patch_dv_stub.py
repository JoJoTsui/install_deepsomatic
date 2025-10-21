#!/usr/bin/env python3
import argparse
import io
import re
import tempfile
import zipfile
from pathlib import Path

def patch_stub(zip_path: Path, python_path: str):
    with zipfile.ZipFile(zip_path, "r") as zin, tempfile.NamedTemporaryFile(delete=False) as tmp:
        with zipfile.ZipFile(tmp.name, "w", zipfile.ZIP_DEFLATED) as zout:
            for item in zin.infolist():
                data = zin.read(item.filename)
                if item.filename == "__main__.py":
                    text = data.decode("utf-8")
                    new_text, count = re.subn(
                        r"PYTHON_BINARY\s*=\s*['\"]([^'\"]+)['\"]",
                        f"PYTHON_BINARY = '{python_path}'",
                        text,
                        count=1,
                    )
                    if count == 0:
                        raise RuntimeError("PYTHON_BINARY definition not found")
                    data = new_text.encode("utf-8")
                zout.writestr(item, data)
    Path(tmp.name).replace(zip_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--zip", required=True, help="Path to Bazel stub zip")
    parser.add_argument("--python", required=True, help="Interpreter to embed")
    args = parser.parse_args()
    patch_stub(Path(args.zip), args.python)

