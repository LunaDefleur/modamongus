# AmongUsMod ESign build notes (V4)

## V4 change
The GitHub Actions build invokes Theos with `TARGET_CODESIGN=/usr/bin/true`.
This makes Theos skip its local signing command so the generated dylib can be
signed later as part of the IPA signing workflow in ESign. It avoids requiring
`ldid` on the macOS GitHub Actions runner.

The build still needs to compile and link successfully; this change only fixes
the post-link signing step. It does not validate runtime compatibility with a
particular Among Us version.
