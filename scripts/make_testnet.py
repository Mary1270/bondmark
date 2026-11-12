import pathlib
import re

root = pathlib.Path(__file__).resolve().parent.parent
src = (root / "contracts" / "bondmark.py").read_text()
out, n = re.subn(r"^UNIT = 3600$", "UNIT = 5", src, flags=re.M)
if n != 1:
    raise SystemExit("UNIT constant not found")
(root / "contracts" / "bondmark_testnet.py").write_text(out)
print("wrote contracts/bondmark_testnet.py")
