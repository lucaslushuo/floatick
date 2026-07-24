import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';
import '../../../updates/presentation/update_view_model.dart';

class UpdateSettingsSection extends StatelessWidget {
  const UpdateSettingsSection({required this.viewModel, super.key});

  final UpdateViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, _) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final localizations = context.l10n;
        final errorMessage = switch (viewModel.error) {
          UpdateFailureKind.loadSettings =>
            localizations.updateSettingsLoadError,
          UpdateFailureKind.saveSettings =>
            localizations.updateSettingsSaveError,
          UpdateFailureKind.check => localizations.updateCheckError,
          null => null,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    localizations.updatesSectionTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  localizations.currentVersionLabel(viewModel.currentVersion),
                  key: const Key('current-version'),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        localizations.automaticUpdateChecksLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        localizations.automaticUpdateChecksDescription,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  label: localizations.automaticUpdateChecksLabel,
                  toggled: viewModel.automaticallyChecksForUpdates,
                  child: ExcludeSemantics(
                    child: Switch.adaptive(
                      key: const Key('automatic-update-checks'),
                      value: viewModel.automaticallyChecksForUpdates,
                      onChanged: viewModel.isLoading || viewModel.isSaving
                          ? null
                          : (enabled) {
                              unawaited(
                                viewModel.setAutomaticallyChecksForUpdates(
                                  enabled,
                                ),
                              );
                            },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              key: const Key('check-for-updates'),
              onPressed: viewModel.isLoading || viewModel.isChecking
                  ? null
                  : () {
                      unawaited(viewModel.checkForUpdates());
                    },
              icon: viewModel.isChecking
                  ? SizedBox.square(
                      dimension: 15,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.8,
                        color: colorScheme.primary,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                viewModel.isChecking
                    ? localizations.checkingForUpdatesButton
                    : localizations.checkForUpdatesButton,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              _UpdateSettingsError(
                message: errorMessage,
                onDismiss: viewModel.dismissError,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _UpdateSettingsError extends StatelessWidget {
  const _UpdateSettingsError({required this.message, required this.onDismiss});

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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.dismissErrorTooltip,
              onPressed: onDismiss,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                Icons.close_rounded,
                size: 16,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
