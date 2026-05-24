import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/status_bar.dart';

/// Contacts app — N.'s phone book with personal notes on each contact.
/// Some contacts have hidden info that helps solve puzzles.
class ContactsView extends StatelessWidget {
  const ContactsView({super.key});

  static const _contacts = [
    _Contact(
      name: 'Mama',
      phone: '+48 601 *** ***',
      note: '❤️',
      color: 0xFFE08AB0,
    ),
    _Contact(
      name: 'Anita Z. (Gazeta)',
      phone: '+48 512 *** ***',
      note: 'Signal! Nie SMS. Dziennikarka śledcza, Gazeta Wyborcza lokalna.',
      color: 0xFFFFCC00,
    ),
    _Contact(
      name: 'T.W. (sąsiad)',
      phone: '+48 *** *** ***',
      note: 'Tomasz. Nr 14, 2 piętro. Były pracownik HB. '
          'Hasło: "drzewo, które padło na dachu". UFAM MU.',
      color: 0xFF5AC8FA,
      isImportant: true,
    ),
    _Contact(
      name: 'Praca (biuro)',
      phone: '+48 22 555 ** **',
      note: 'Agencja Medialna Horyzont. Recepcja.',
      color: 0xFF8E8E93,
    ),
    _Contact(
      name: 'Kasia (IT, praca)',
      phone: '+48 *** *** ***',
      note: 'Hasło do Wi-Fi w biurze — zapytać ją.',
      color: 0xFF8E8E93,
    ),
    _Contact(
      name: 'Cafe Relaks',
      phone: '+48 22 *** ** **',
      note: 'Rezerwacja stolika. Wi-Fi: gosc.relaks',
      color: 0xFFFF9F0A,
    ),
    _Contact(
      name: 'Weterynarz (Mruczek)',
      phone: '+48 22 *** ** **',
      note: 'Szczepienie — czerwiec!',
      color: 0xFF34C759,
    ),
    _Contact(
      name: 'Tata',
      phone: '+48 *** *** ***',
      note: '',
      color: 0xFF0A84FF,
    ),
    _Contact(
      name: 'Szeryf ⚠️',
      phone: '+48 *** *** ***',
      note: 'Komendant K. NIE ODBIERAĆ. NIE ODDZWANIAĆ. '
          'Wie kim jestem. Wie co mam.',
      color: 0xFF6E0F0F,
      isImportant: true,
      isDanger: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                  const Text(
                    'Kontakty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_contacts.length} kontaktów',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _contacts.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 56),
                  child: Divider(height: 1, color: Color(0xFF1C1C1E)),
                ),
                itemBuilder: (context, i) {
                  final c = _contacts[i];
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
    required this.name,
    required this.phone,
    required this.note,
    required this.color,
    this.isImportant = false,
    this.isDanger = false,
  });

  final String name;
  final String phone;
  final String note;
  final int color;
  final bool isImportant;
  final bool isDanger;
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.contact});
  final _Contact contact;

  @override
  Widget build(BuildContext context) {
    final color = Color(contact.color);
    final initial = contact.name.isNotEmpty
        ? contact.name[0].toUpperCase()
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
                  Text(contact.name, style: TextStyle(
                    color: contact.isDanger
                        ? const Color(0xFFFF453A)
                        : Colors.white,
                    fontSize: 15,
                    fontWeight: contact.isImportant
                        ? FontWeight.w700
                        : FontWeight.w500,
                  )),
                  if (contact.note.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: contact.isDanger
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
              onPressed: () {
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.signal_cellular_off,
                            color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text('Brak zasięgu'),
                      ],
                    ),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ));
              },
              icon: const Icon(Icons.phone, color: Color(0xFF34C759), size: 20),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
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
                backgroundColor: Color(contact.color),
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(contact.name, style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 4),
              Text(contact.phone, style: const TextStyle(
                color: Color(0xFF0A84FF), fontSize: 15,
              )),
              if (contact.note.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: contact.isDanger
                        ? const Color(0xFFFF453A).withValues(alpha: 0.08)
                        : const Color(0xFF2C2C2E),
                    borderRadius: BorderRadius.circular(10),
                    border: contact.isDanger
                        ? Border.all(
                            color: const Color(0xFFFF453A).withValues(alpha: 0.3))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Notatka:', style: TextStyle(
                        color: Colors.white54, fontSize: 11,
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 4),
                      Text(contact.note, style: TextStyle(
                        color: contact.isDanger
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
