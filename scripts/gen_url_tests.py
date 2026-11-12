import json
import pathlib

root = pathlib.Path(__file__).resolve().parent.parent


def lit(s):
    out = []
    for b in s.encode("utf-8"):
        c = chr(b)
        if c == '"':
            out.append('\\"')
        elif c == "\\":
            out.append("\\\\")
        elif 0x21 <= b <= 0x7E:
            out.append(c)
        else:
            out.append("\\x%02x" % b)
    return '"' + "".join(out) + '"'


def render():
    vec = json.loads((root / "tests" / "url_vectors.json").read_text())
    lines = [
        "// SPDX-License-Identifier: MIT",
        "pragma solidity ^0.8.24;",
        "",
        'import "forge-std/Test.sol";',
        'import "../src/BondMarkBase.sol";',
        "",
        "contract UrlHarness is BondMarkBase {",
        "    constructor(address a) BondMarkBase(a, 3600) {}",
        "",
        "    function validUrl(string memory u) external pure returns (bool) {",
        "        return _validUrl(u);",
        "    }",
        "}",
        "",
        "contract UrlVectorsTest is Test {",
        "    UrlHarness h;",
        "",
        "    function setUp() public {",
        '        h = new UrlHarness(makeAddr("arbiter"));',
        "    }",
        "",
        "    function test_valid_urls() public view {",
    ]
    for u in vec["valid"]:
        lines.append("        assertTrue(h.validUrl(%s));" % lit(u))
    lines += ["    }", "", "    function test_invalid_urls() public view {"]
    for u in vec["invalid"]:
        lines.append("        assertFalse(h.validUrl(%s));" % lit(u))
    lines += ["    }", "}", ""]
    return "\n".join(lines)


if __name__ == "__main__":
    (root / "base" / "test" / "UrlVectors.t.sol").write_text(render())
    print("wrote base/test/UrlVectors.t.sol")
