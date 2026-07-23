# Architecture

Floatick uses Flutter for product UI and state, and a small AppKit shell for
macOS-only window behavior.

## Dependency direction

```text
presentation -> domain
presentation -> data (injected through ViewModels)
data         -> domain
app          -> features + core
macOS shell  <-> core/platform through MethodChannel
```

Feature code must not import another feature's data layer. Cross-feature UI
composition belongs in `lib/app`, while reusable platform and visual primitives
belong in `lib/core`.

## Directory layout

```text
lib/
  app/
    floatick_app.dart
    theme/
  l10n/
    app_en.arb
    app_zh.arb
  core/
    platform/
    storage/
    ui/
  features/
    settings/
      data/
      domain/
      presentation/
    todos/
      data/
      domain/
      presentation/
        widgets/
test/
  app/
  features/
macos/
  Runner/
tool/
  release/
```

- `domain`: immutable app models and domain concepts.
- `data`: local persistence and serialization boundaries.
- `presentation`: Views and `ChangeNotifier` ViewModels.
- `core/platform`: typed wrappers around native platform channels.
- `core/storage`: shared storage failure types used at repository boundaries.
- `l10n`: English source copy, Simplified Chinese translations, and generated
  Flutter localization accessors.
- `macos/Runner`: transparent floating window behavior only; todo data does not
  cross the platform channel.

## State and persistence

`TodoViewModel` and `SettingsViewModel` own presentation state. Repositories
own file I/O and JSON compatibility. Repositories are constructor-injected so
state behavior can be tested without touching the user's home directory.

The only storage directory is `~/.floatick`. Repositories create it on first
load and never read or write another hidden application directory.

Writes are serialized by `TodoViewModel` to prevent overlapping mutations from
losing updates. A write failure leaves the last persisted in-memory state
unchanged and exposes a recoverable UI error.

## Testing

- Repository tests cover local JSON parsing, compatibility, and failure paths.
- ViewModel tests cover mutations, serialization order, filtering, and sorting.
- Widget tests cover the main interaction path and theme/settings behavior.
- AppKit window behavior remains a native integration boundary and should be
  smoke-tested on both Apple silicon and Intel macOS before a stable release.

## Architecture guardrails

- Keep platform-specific window code out of Flutter Views.
- Keep file I/O out of widgets and ViewModels.
- Add a package only when the standard library or existing platform bridge
  cannot meet the requirement cleanly.
- Split presentation widgets when they gain independent state, reuse, or test
  value; do not create one-file-per-widget ceremony.
- Preserve the local JSON contract or ship an explicit migration.
