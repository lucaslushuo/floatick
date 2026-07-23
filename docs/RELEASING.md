# macOS release

Floatick is distributed outside the Mac App Store as a signed, notarized,
universal DMG attached to a GitHub Release.

Release repository: `https://github.com/lucaslushuo/floatick`

## One-time Apple setup

An active Apple Developer Program membership is required.

1. Create and export a `Developer ID Application` certificate as a password
   protected `.p12`.
2. Create an App Store Connect API key with permission to submit for
   notarization.
3. Create a protected GitHub Environment named `release`.
4. Add these environment secrets:

| Secret | Value |
| --- | --- |
| `MACOS_CERTIFICATE_P12_BASE64` | Base64-encoded `.p12` |
| `MACOS_CERTIFICATE_PASSWORD` | Password used when exporting the `.p12` |
| `APPLE_TEAM_ID` | Apple Developer Team ID |
| `APPLE_API_KEY_ID` | App Store Connect API key ID |
| `APPLE_API_ISSUER_ID` | App Store Connect API issuer ID |
| `APPLE_API_PRIVATE_KEY_BASE64` | Base64-encoded `.p8` private key |

Restrict the `release` environment to the `main` branch and require manual
approval if more than one maintainer can push tags.

## Publish a release

1. Update `version` in `pubspec.yaml`, for example `1.1.0+1`.
2. Merge the release changes into `main`.
3. Create and push the matching tag:

   ```bash
   git tag -s v1.1.0 -m "Floatick 1.1.0"
   git push origin v1.1.0
   ```

The tag without its leading `v` must exactly match the public version before
the `+` in `pubspec.yaml`. Versions containing a pre-release suffix, such as
`1.1.0-beta.1`, are automatically published as GitHub pre-releases.

The release workflow:

1. runs Flutter tests;
2. imports the Developer ID certificate into an ephemeral keychain;
3. archives and exports the app through Xcode;
4. verifies both `arm64` and `x86_64` architectures;
5. creates and signs the DMG;
6. submits it to Apple's notary service and staples the ticket;
7. publishes the DMG and its SHA-256 checksum to GitHub Releases.

Never upload signing certificates or API keys to the repository.

## Update strategy

The first public versions use GitHub Releases as a manual download channel.
After the app identity and signing certificate are stable, add Sparkle 2 to the
native AppKit shell for in-app updates. The same notarized DMG can remain the
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
