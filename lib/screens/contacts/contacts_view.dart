import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/gen/app_localizations.dart';
import '../../services/l10n_service.dart';
import '../../widgets/status_bar.dart';

/// Contacts app — N.'s phone book with personal notes on each contact.
/// Some contacts have hidden info that helps solve puzzles.
class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dialogues = L10nService.instance.dialogues['contacts'] as Map<String, dynamic>? ?? {};

    final contacts = [
      _Contact(
        id: 'mama',
        name: 'Mama',
        phone: '+48 601 *** ***',
        note: dialogues['mama'] ?? '',
        color: 0xFFE08AB0,
      ),
      _Contact(
        id: 'anita',
        name: 'Anita Z. (Gazeta)',
        phone: '+48 512 *** ***',
        note: dialogues['anita'] ?? '',
        color: 0xFFFFCC00,
      ),
      _Contact(
        id: 'tomasz',
        name: 'T.W. (sąsiad)',
        phone: '+48 *** *** ***',
        note: dialogues['tomasz'] ?? '',
        color: 0xFF5AC8FA,
        isImportant: true,
      ),
      _Contact(
        id: 'praca',
        name: 'Praca (biuro)',
        phone: '+48 22 555 ** **',
        note: dialogues['praca'] ?? '',
        color: 0xFF8E8E93,
      ),
      _Contact(
        id: 'kasia',
        name: 'Kasia (IT, praca)',
        phone: '+48 *** *** ***',
        note: dialogues['kasia'] ?? '',
        color: 0xFF8E8E93,
      ),
      _Contact(
        id: 'cafe',
        name: 'Cafe Relaks',
        phone: '+48 22 *** ** **',
        note: dialogues['cafe'] ?? '',
        color: 0xFFFF9F0A,
      ),
      _Contact(
        id: 'wet',
        name: 'Weterynarz (Mruczek)',
        phone: '+48 22 *** ** **',
        note: dialogues['wet'] ?? '',
        color: 0xFF34C759,
      ),
      _Contact(
        id: 'tata',
        name: 'Tata',
        phone: '+48 *** *** ***',
        note: dialogues['tata'] ?? '',
        color: 0xFF0A84FF,
      ),
      _Contact(
        id: 'szeryf',
        name: 'Szeryf ⚠️',
        phone: '+48 *** *** ***',
        note: dialogues['szeryf'] ?? '',
        color: 0xFF6E0F0F,
        isImportant: true,
        isDanger: true,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const StatusBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    l10n.contactsTitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.contactsCount(contacts.length),
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: contacts.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 56),
                  child: Divider(height: 1, color: Color(0xFF1C1C1E)),
                ),
                itemBuilder: (context, i) {
                  final c = contacts[i];
                  return _ContactTile(contact: c);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Contact {
  const _Contact({
    required this.id,
    required this.name,
    required this.phone,
    required this.note,
    required this.color,
    this.isImportant = false,
    this.isDanger = false,
  });

  final String id;
  final String name;
  final String phone;
  final String note;
  final int color;
  final bool isImportant;
  final bool isDanger;
}

class _ContactTile extends StatefulWidget {
  const _ContactTile({required this.contact});
  final _Contact contact;

  @override
  State<_ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<_ContactTile> {
  bool _isCalling = false;

  Future<void> _handleCall(BuildContext context) async {
    if (_isCalling) return;
    setState(() => _isCalling = true);
    await _showNoSignal(context);
    if (mounted) {
      setState(() => _isCalling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = Color(widget.contact.color);
    final initial = widget.contact.name.isNotEmpty
        ? widget.contact.name[0].toUpperCase()
        : '?';

    return InkWell(
      onTap: () => _showDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color,
              child: Text(initial, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16,
              )),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.contact.name, style: TextStyle(
                    color: widget.contact.isDanger
                        ? const Color(0xFFFF453A)
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: widget.contact.isImportant
                        ? FontWeight.w700
                        : FontWeight.w500,
                  )),
                  if (widget.contact.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.contact.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: widget.contact.isDanger
                            ? const Color(0xFFFF453A).withValues(alpha: 0.7)
                            : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              onPressed: () => _handleCall(context),
              icon: const Icon(Icons.phone, color: Color(0xFF34C759), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNoSignal(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    HapticFeedback.heavyImpact();
    await showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Row(
          children: [
            const Icon(Icons.signal_cellular_off, color: Colors.white70, size: 22),
            const SizedBox(width: 10),
            Text(l10n.phoneNoSignal,
                style: const TextStyle(color: Colors.white, fontSize: 17)),
          ],
        ),
        content: Text(
          l10n.phoneNoSignalBody,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.commonOk,
                style: const TextStyle(color: Color(0xFF0A84FF))),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              CircleAvatar(
                radius: 36,
                backgroundColor: Color(widget.contact.color),
                child: Text(
                  widget.contact.name.isNotEmpty ? widget.contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.contact.name, style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 4),
              Text(widget.contact.phone, style: const TextStyle(
                color: Color(0xFF0A84FF), fontSize: 15,
              )),
              if (widget.contact.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: widget.contact.isDanger
                        ? const Color(0xFFFF453A).withValues(alpha: 0.08)
                        : const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(10),
                    border: widget.contact.isDanger
                        ? Border.all(
                            color: const Color(0xFFFF453A).withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.contactsNoteLabel, style: const TextStyle(
                        color: Colors.white54, fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 4),
                      Text(widget.contact.note, style: TextStyle(
                        color: widget.contact.isDanger
                            ? const Color(0xFFFFB1AC)
                            : Colors.white,
                        fontSize: 13,
                        height: 1.4,
                      )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
