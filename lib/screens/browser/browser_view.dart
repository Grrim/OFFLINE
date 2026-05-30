import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../state/browser_state.dart';
import '../../widgets/fragment_hotspot.dart';
import '../../widgets/status_bar.dart';

/// Browser app — shows N.'s history. Public entries always visible;
/// private entries hidden behind a password prompt.
class BrowserView extends StatelessWidget {
  const BrowserView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final browser = context.watch<BrowserState>();
    final publicEntries = browser.publicEntries;
    final privateEntries = browser.privateEntries;
    final unlocked = browser.isPrivateUnlocked;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.browserHistory,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Decorative URL bar.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: Colors.white54, size: 14),
                    const SizedBox(width: 6),
                    Text(l10n.browserSearchHint,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 14)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Public section.
                  for (var i = 0; i < publicEntries.length; i++) ...[
                    _HistoryTile(
                      entry: publicEntries[i],
                      isUnread: !browser.hasVisited(publicEntries[i].id),
                      onTap: () => _openEntry(context, publicEntries[i].id),
                    ),
                    if (i != publicEntries.length - 1)
                      const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Divider(height: 1, color: Color(0xFF1C1C1E)),
                      ),
                  ],
                  const SizedBox(height: 24),

                  // Private mode section.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.shield,
                            color: Colors.white54, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          l10n.browserPrivateMode,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          unlocked
                              ? l10n.browserPrivateEntriesCount(privateEntries.length)
                              : l10n.browserPrivateLocked,
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  if (!unlocked)
                    _PrivateLockedCard(onTap: () => _promptPassword(context))
                  else
                    for (var i = 0; i < privateEntries.length; i++) ...[
                      if (privateEntries[i].id == 'sygnal')
                        FragmentHotspot(
                          fragmentId: 'frag_signal',
                          child: _HistoryTile(
                            entry: privateEntries[i],
                            isUnread:
                                !browser.hasVisited(privateEntries[i].id),
                            onTap: () =>
                                _openEntry(context, privateEntries[i].id),
                          ),
                        )
                      else
                        _HistoryTile(
                          entry: privateEntries[i],
                          isUnread:
                              !browser.hasVisited(privateEntries[i].id),
                          onTap: () =>
                              _openEntry(context, privateEntries[i].id),
                        ),
                      if (i != privateEntries.length - 1)
                        const Padding(
                          padding: EdgeInsets.only(left: 12),
                          child:
                              Divider(height: 1, color: Color(0xFF1C1C1E)),
                        ),
                    ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEntry(BuildContext context, String entryId) {
    context.read<BrowserState>().markVisited(entryId);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _BrowserReaderScreen(entryId: entryId),
      ),
    );
  }

  Future<void> _promptPassword(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Color(0xFF0A84FF), size: 22),
            const SizedBox(width: 10),
            Text(l10n.browserPrivatePasswordTitle,
                style: const TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.browserPrivatePasswordBody,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: l10n.browserPrivatePasswordHint,
                hintStyle: const TextStyle(color: Colors.white38),
                border: const OutlineInputBorder(),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF2C2C2E)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0A84FF)),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onSubmitted: (_) => Navigator.of(context).pop(true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel,
                style: const TextStyle(color: Color(0xFF0A84FF))),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.browserPrivateUnlock,
                style: const TextStyle(color: Color(0xFF0A84FF))),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    final ok = context.read<BrowserState>().tryUnlockPrivate(controller.text);
    if (!context.mounted) return;
    if (!ok) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(l10n.browserPrivateWrongPassword),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2C2C2E),
        ));
    } else {
      HapticFeedback.lightImpact();
    }
  }
}

class _PrivateLockedCard extends StatelessWidget {
  const _PrivateLockedCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_outline,
                color: Color(0xFF0A84FF), size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.browserPrivateLockedCardTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.browserPrivateLockedCardSub,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.entry,
    required this.isUnread,
    required this.onTap,
  });

  final BrowserEntry entry;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: entry.isPrivate
                    ? const Color(0xFF8E8E93).withValues(alpha: 0.2)
                    : const Color(0xFF0A84FF).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                entry.isPrivate ? Icons.shield : Icons.public,
                color: entry.isPrivate
                    ? Colors.white70
                    : const Color(0xFF0A84FF),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(left: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0A84FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.url,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0A84FF),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    entry.timestamp,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowserReaderScreen extends StatelessWidget {
  const _BrowserReaderScreen({required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context) {
    final entry = context
        .read<BrowserState>()
        .entries
        .firstWhere((e) => e.id == entryId);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Mini "URL bar" up top.
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  Expanded(
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            entry.isPrivate ? Icons.shield : Icons.lock,
                            size: 12,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1C1C1E)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${entry.url} · ${entry.timestamp}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      entry.preview,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
