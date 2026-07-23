# macOS release

Floatick is currently distributed outside the Mac App Store as an unsigned,
unnotarized universal DMG attached to a GitHub Release. The workflow runs
entirely on a GitHub-hosted macOS runner and does not require Apple secrets.

Release repository: `https://github.com/lucaslushuo/floatick`

## Publish a release

1. Update `version` in `pubspec.yaml`. The first public version is
   `0.1.0+1`.
2. Merge the release changes into `main`.
3. Create and push the matching tag:

   ```bash
   git tag -a v0.1.0 -m "Floatick 0.1.0"
   git push origin v0.1.0
   ```

The tag without its leading `v` must exactly match the public version before
the `+` in `pubspec.yaml`. Versions containing a pre-release suffix, such as
`0.2.0-beta.1`, are automatically published as GitHub pre-releases.

The release workflow:

1. runs Flutter tests;
2. builds the macOS release app;
3. verifies both `arm64` and `x86_64` architectures;
4. creates the DMG and its SHA-256 checksum;
5. publishes both files to GitHub Releases with an unsigned-build warning.

No Apple signing or notarization secrets are required for this workflow.

## Update strategy

The first public versions use GitHub Releases as a manual download channel.
When an Apple Developer Program membership is available, update the release
workflow to sign the app and DMG with a `Developer ID Application` certificate,
submit the DMG through `notarytool`, and staple the returned ticket before
publishing. Keep certificates, passwords, Team IDs, and App Store Connect API
credentials in GitHub Environment secrets, never in the repository.

After the app identity and signing certificate are stable, add Sparkle 2 to
the native AppKit shell for in-app updates. The notarized DMG can remain the
release asset; Sparkle adds an HTTPS appcast plus an independent EdDSA signature
for update verification.

Do not ship Sparkle until its private EdDSA key, appcast hosting, and key
rotation/recovery procedure are documented and tested. Changing the product
name, bundle identifier, Developer ID certificate, and update key at the same
time makes safe migration significantly harder.

## Local unsigned package

For layout testing only:

```bash
flutter build macos --release
tool/release/create_dmg.sh \
  build/macos/Build/Products/Release/Floatick.app \
  build/release/Floatick-local.dmg \
  Floatick
```

An unsigned local DMG is not suitable for public distribution.
