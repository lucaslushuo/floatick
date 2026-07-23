import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';
import '../../../l10n/storage_failure_localizations.dart';
import '../domain/app_settings.dart';
import 'settings_view_model.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    required this.viewModel,
    required this.workingDirectoryPath,
    required this.onClose,
    required this.closeFocusNode,
    super.key,
  });

  final SettingsViewModel viewModel;
  final String workingDirectoryPath;
  final VoidCallback onClose;
  final FocusNode closeFocusNode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      key: const Key('settings-drawer'),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF202A2E) : const Color(0xFFF9FBFA),
        border: Border(
          left: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.07),
          ),
        ),
      ),
      child: AnimatedBuilder(
        animation: viewModel,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _SettingsHeader(onClose: onClose, closeFocusNode: closeFocusNode),
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      context.l10n.appearanceSectionTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ThemePreferencePicker(viewModel: viewModel),
                    const SizedBox(height: 28),
                    Text(
                      context.l10n.workingDirectorySectionTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 7),
                    SelectableText(
                      workingDirectoryPath,
                      key: const Key('storage-directory-path'),
                      semanticsLabel: context.l10n.workingDirectorySemantics(
                        workingDirectoryPath,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.62,
                        ),
                        fontFamily: 'SF Mono',
                        height: 1.4,
                      ),
                    ),
                    if (viewModel.error != null) ...[
                      const SizedBox(height: 12),
                      _SettingsError(
                        message: context.l10n.messageForStorageFailure(
                          viewModel.error!,
                        ),
                        onDismiss: viewModel.dismissError,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader({required this.onClose, required this.closeFocusNode});

  final VoidCallback onClose;
  final FocusNode closeFocusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 10, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              context.l10n.settingsTitle,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            key: const Key('settings-close'),
            focusNode: closeFocusNode,
            tooltip: context.l10n.closeSettingsTooltip,
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _ThemePreferencePicker extends StatelessWidget {
  const _ThemePreferencePicker({required this.viewModel});

  final SettingsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        for (final preference in AppThemePreference.values)
          _ThemeIconButton(
            preference: preference,
            selected: viewModel.themePreference == preference,
            enabled: !viewModel.isSaving,
            onSelected: () {
              unawaited(viewModel.setThemePreference(preference));
            },
          ),
      ],
    );
  }
}

class _ThemeIconButton extends StatelessWidget {
  const _ThemeIconButton({
    required this.preference,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  final AppThemePreference preference;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = context.l10n;
    final (tooltip, icon) = switch (preference) {
      AppThemePreference.system => (
        localizations.themeSystemTooltip,
        Icons.brightness_auto_rounded,
      ),
      AppThemePreference.light => (
        localizations.themeLightTooltip,
        Icons.light_mode_rounded,
      ),
      AppThemePreference.dark => (
        localizations.themeDarkTooltip,
        Icons.dark_mode_rounded,
      ),
    };

    return Semantics(
      button: true,
      selected: selected,
      label: tooltip,
      child: IconButton(
        key: Key('theme-${preference.storageValue}'),
        tooltip: tooltip,
        isSelected: selected,
        onPressed: enabled ? onSelected : null,
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          hoverColor: theme.colorScheme.primary.withValues(alpha: 0.08),
          highlightColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          minimumSize: const Size.square(48),
          padding: const EdgeInsets.all(10),
          shape: const CircleBorder(),
        ),
        icon: Icon(
          icon,
          size: 22,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
        ),
        selectedIcon: Icon(icon, size: 24, color: theme.colorScheme.primary),
      ),
    );
  }
}

class _SettingsError extends StatelessWidget {
  const _SettingsError({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 4, 7),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: colorScheme.onErrorContainer,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colorScheme.onErrorContainer,
                  fontSize: 11,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.dismissErrorTooltip,
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.close_rounded, size: 15),
            ),
          ],
        ),
      ),
    );
  }
}
