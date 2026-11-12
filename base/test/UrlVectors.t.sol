// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BondMarkBase.sol";

contract UrlHarness is BondMarkBase {
    constructor(address a) BondMarkBase(a, 3600) {}

    function validUrl(string memory u) external pure returns (bool) {
        return _validUrl(u);
    }
}

contract UrlVectorsTest is Test {
    UrlHarness h;

    function setUp() public {
        h = new UrlHarness(makeAddr("arbiter"));
    }

    function test_valid_urls() public view {
        assertTrue(h.validUrl(""));
        assertTrue(h.validUrl("https://example.com"));
        assertTrue(h.validUrl("https://example.com/p/1?x=1#y"));
        assertTrue(h.validUrl("https://sub.example.co.uk/a"));
        assertTrue(h.validUrl("https://example.com:443/a"));
        assertTrue(h.validUrl("https://EXAMPLE.com/A"));
        assertTrue(h.validUrl("https://a-b.example.com/"));
        assertTrue(h.validUrl("https://example.com?x=1"));
        assertTrue(h.validUrl("https://instagram.com/p/Abc123/"));
        assertTrue(h.validUrl("https://example.com/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
    }

    function test_invalid_urls() public view {
        assertFalse(h.validUrl("http://example.com"));
        assertFalse(h.validUrl("ftp://example.com"));
        assertFalse(h.validUrl("HTTPS://example.com"));
        assertFalse(h.validUrl("https://"));
        assertFalse(h.validUrl("https:///path"));
        assertFalse(h.validUrl("https://user:pw@example.com"));
        assertFalse(h.validUrl("https://example.com@evil.com"));
        assertFalse(h.validUrl("https://example.com:8080/"));
        assertFalse(h.validUrl("https://example.com:/"));
        assertFalse(h.validUrl("https://example.com:443:80/"));
        assertFalse(h.validUrl("https://localhost/"));
        assertFalse(h.validUrl("https://127.0.0.1/"));
        assertFalse(h.validUrl("https://example"));
        assertFalse(h.validUrl("https://.example.com"));
        assertFalse(h.validUrl("https://example..com"));
        assertFalse(h.validUrl("https://example.com./"));
        assertFalse(h.validUrl("https://exa\x20mple.com"));
        assertFalse(h.validUrl("https://example.com/a\x20b"));
        assertFalse(h.validUrl("https://example.com/\\evil"));
        assertFalse(h.validUrl("https://[::1]/"));
        assertFalse(h.validUrl("https://example.com/\x0a"));
        assertFalse(h.validUrl("https://ex\xc3\xa4mple.com"));
        assertFalse(h.validUrl("https://example.com/\xc3\xa4"));
        assertFalse(h.validUrl("\x20https://example.com"));
        assertFalse(h.validUrl("example.com"));
        assertFalse(h.validUrl("javascript:alert(1)"));
        assertFalse(h.validUrl("https://exa_mple.com"));
        assertFalse(h.validUrl("https://example.c0m"));
        assertFalse(h.validUrl("https://example.c"));
        assertFalse(h.validUrl("https://a.b"));
        assertFalse(h.validUrl("https://example.com/aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"));
        assertFalse(h.validUrl("https://example.com/\x00"));
        assertFalse(h.validUrl("https://example.com/\x7f"));
    }
}
