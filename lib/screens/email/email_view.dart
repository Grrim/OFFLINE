import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/email_state.dart';
import '../../widgets/status_bar.dart';

/// Email app — N.'s inbox. Mix of work emails, personal, spam,
/// and critical messages from Anita that build the narrative.
class EmailView extends StatelessWidget {
  const EmailView({super.key});

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
                    'Poczta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '3 nieprzeczytane',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  final email = context.watch<EmailState>();
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // The reconstructed message appears at the very top
                      // once all 5 fragments have been recovered.
                      if (email.isFullyRecovered) ...[
                        _RecoveredEmailTile(body: email.recoveredMessage!),
                        const SizedBox(height: 4),
                      ],
                      // Trash / fragments progress card — visible from
                      // the moment any fragment is found.
                      if (email.recoveredCount > 0 &&
                          !email.isFullyRecovered) ...[
                        _TrashProgressCard(state: email),
                        const SizedBox(height: 4),
                      ],
                      const _EmailTile(
                    sender: 'Anita Z.',
                    subject: 'RE: materiały — PILNE',
                    preview: 'N., potrzebuję tych skanów do piątku. Redaktor '
                        'naczelny dał mi ultimatum...',
                    time: '16 maja, 09:14',
                    isUnread: true,
                    isImportant: true,
                    fullBody: 'Cześć N.,\n\n'
                        'Potrzebuję tych skanów do piątku. Redaktor naczelny '
                        'dał mi ultimatum — albo mamy twarde dowody na papierze, '
                        'albo tekst nie idzie.\n\n'
                        'Wiem że się boisz. Ja też. Ale to jest za ważne żeby '
                        'odpuścić. Ludzie muszą się dowiedzieć co się dzieje '
                        'w tym lesie.\n\n'
                        'Wyślij mi chociaż jedną fakturę. Jedną. To wystarczy '
                        'żeby przekonać redakcję.\n\n'
                        'Trzymaj się.\n'
                        'Anita',
                  ),
                  const _EmailTile(
                    sender: 'HR — Biuro',
                    subject: 'Nieobecność w pracy 16.05',
                    preview: 'Szanowna Pani, informujemy że Pani nieobecność '
                        'w dniu dzisiejszym...',
                    time: '16 maja, 10:30',
                    isUnread: true,
                    fullBody: 'Szanowna Pani,\n\n'
                        'Informujemy, że Pani nieobecność w dniu 16.05.2026 '
                        'została odnotowana jako nieusprawiedliwiona.\n\n'
                        'Prosimy o kontakt z działem HR w celu wyjaśnienia '
                        'sytuacji. W przypadku braku odpowiedzi do końca '
                        'dnia roboczego, sprawa zostanie przekazana do '
                        'przełożonego.\n\n'
                        'Z poważaniem,\n'
                        'Dział Kadr\n'
                        'Agencja Medialna "Horyzont"',
                  ),
                  const _EmailTile(
                    sender: 'Stowarzyszenie Strażnicy Lasu',
                    subject: 'Potwierdzenie zgłoszenia #2026-0847',
                    preview: 'Dziękujemy za przesłanie dokumentacji. '
                        'Nasz zespół prawny analizuje...',
                    time: '15 maja, 14:22',
                    isUnread: true,
                    isImportant: true,
                    fullBody: 'Szanowna Pani,\n\n'
                        'Potwierdzamy otrzymanie Pani zgłoszenia dotyczącego '
                        'nielegalnych wycinek w rezerwacie Las Kabacki.\n\n'
                        'Przesłana dokumentacja (3 pliki PDF, 1 plik audio) '
                        'została przekazana do naszego zespołu prawnego.\n\n'
                        'Ze względu na wagę sprawy i potencjalne zagrożenie '
                        'dla Pani bezpieczeństwa, zalecamy:\n'
                        '1. Zachowanie kopii wszystkich materiałów w bezpiecznym miejscu\n'
                        '2. Unikanie kontaktu z osobami wymienionymi w dokumentach\n'
                        '3. Rozważenie zgłoszenia sprawy do prokuratury\n\n'
                        'Będziemy w kontakcie.\n\n'
                        'Z poważaniem,\n'
                        'Zespół Prawny\n'
                        'Stowarzyszenie Strażnicy Lasu',
                  ),
                  const _EmailTile(
                    sender: 'Netflix',
                    subject: 'Nowe odcinki czekają na Ciebie!',
                    preview: 'Twoja lista: "Dark", "Mindhunter", '
                        '"Making a Murderer"...',
                    time: '15 maja, 08:00',
                    isUnread: false,
                    fullBody: 'Cześć!\n\n'
                        'Mamy nowe odcinki na Twojej liście:\n\n'
                        '• Dark — Sezon 4 (NOWOŚĆ)\n'
                        '• Mindhunter — Sezon 3\n'
                        '• Making a Murderer — Część 3\n\n'
                        'Oglądaj teraz →',
                  ),
                  const _EmailTile(
                    sender: 'Mama',
                    subject: 'Przepis na szarlotkę babci',
                    preview: 'Kochanie, przesyłam ci ten przepis co '
                        'prosiłaś. Babcia mówi żeby...',
                    time: '12 maja, 19:45',
                    isUnread: false,
                    fullBody: 'Kochanie,\n\n'
                        'Przesyłam ci ten przepis co prosiłaś. Babcia mówi '
                        'żeby jabłka były kwaśne (renety najlepsze) i żeby '
                        'ciasto odpoczęło minimum godzinę w lodówce.\n\n'
                        'Składniki:\n'
                        '- 3 szklanki mąki\n'
                        '- 1 kostka masła\n'
                        '- 3 żółtka\n'
                        '- 1 szklanka cukru pudru\n'
                        '- 1 kg jabłek\n'
                        '- cynamon, wanilia\n\n'
                        'Zadzwoń jak będziesz piec, pomogę przez telefon!\n\n'
                        'Buziaki,\n'
                        'Mama',
                  ),
                  const _EmailTile(
                    sender: 'Signal',
                    subject: 'Nowe urządzenie zalogowane',
                    preview: 'Twoje konto Signal zostało aktywowane na '
                        'nowym urządzeniu...',
                    time: '11 maja, 23:55',
                    isUnread: false,
                    isImportant: true,
                    fullBody: 'Twoje konto Signal zostało aktywowane na '
                        'nowym urządzeniu:\n\n'
                        'Urządzenie: iPhone 15 Pro\n'
                        'Lokalizacja: Warszawa, Polska\n'
                        'Data: 11.05.2026, 23:55\n\n'
                        'Jeśli to nie Ty, natychmiast zmień PIN zabezpieczający '
                        'i wyloguj wszystkie urządzenia.\n\n'
                        'Zespół Signal',
                  ),
                  const _EmailTile(
                    sender: 'Allegro',
                    subject: 'Twoja paczka została dostarczona',
                    preview: 'Zamówienie #ALG-9847221 — dyktafon cyfrowy '
                        'Sony ICD-UX570...',
                    time: '8 maja, 14:30',
                    isUnread: false,
                    fullBody: 'Twoja paczka została dostarczona!\n\n'
                        'Zamówienie: #ALG-9847221\n'
                        'Produkt: Dyktafon cyfrowy Sony ICD-UX570\n'
                        'Dostawa: Paczkomat WAW-MOK-47\n'
                        'Data dostawy: 08.05.2026\n\n'
                        'Dziękujemy za zakupy na Allegro!',
                  ),
                  const _EmailTile(
                    sender: 'PKP Intercity',
                    subject: 'Potwierdzenie rezerwacji',
                    preview: 'Bilet: Warszawa Centralna → Kraków Główny, '
                        '24.05.2026...',
                    time: '7 maja, 20:12',
                    isUnread: false,
                    fullBody: 'Potwierdzenie rezerwacji\n\n'
                        'Trasa: Warszawa Centralna → Kraków Główny\n'
                        'Data: 24.05.2026\n'
                        'Odjazd: 06:15 | Przyjazd: 08:45\n'
                        'Wagon: 7, Miejsce: 42\n'
                        'Klasa: 2\n\n'
                        'Bilet elektroniczny w załączniku.\n\n'
                        'Życzymy miłej podróży!\n'
                        'PKP Intercity',
                  ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecoveredEmailTile extends StatelessWidget {
  const _RecoveredEmailTile({required this.body});
  final String body;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _EmailReaderScreen(
            sender: 'N. (odzyskane)',
            subject: 'WIADOMOŚĆ ODZYSKANA — fragmenty z Kosza',
            time: 'Odzyskano przez Ciebie',
            body: body,
            isImportant: true,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFFCC00).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: const Color(0xFFFFCC00).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCC00).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.markunread_mailbox,
                  color: Color(0xFFFFCC00), size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WIADOMOŚĆ ODZYSKANA',
                    style: TextStyle(
                      color: Color(0xFFFFCC00),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'N. — fragmenty z Kosza złożone w całość',
                    style: TextStyle(
                        color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Stuknij, aby przeczytać.',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

class _TrashProgressCard extends StatelessWidget {
  const _TrashProgressCard({required this.state});
  final EmailState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        children: [
          const Icon(Icons.restore_from_trash,
              color: Color(0xFF0A84FF), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kosz — fragmenty wiadomości',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.recoveredCount}/${state.totalFragments} '
                  'odnalezionych. Szukaj fragmentów w innych aplikacjach.',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailTile extends StatelessWidget {
  const _EmailTile({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
    required this.isUnread,
    required this.fullBody,
    this.isImportant = false,
  });

  final String sender;
  final String subject;
  final String preview;
  final String time;
  final bool isUnread;
  final bool isImportant;
  final String fullBody;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _EmailReaderScreen(
            sender: sender,
            subject: subject,
            time: time,
            body: fullBody,
            isImportant: isImportant,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFF1C1C1E))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUnread)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0A84FF),
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sender,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isImportant)
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Icon(Icons.flag,
                              color: Color(0xFFFF9500), size: 14),
                        ),
                      Text(time.split(',').last.trim(),
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      height: 1.3,
                    ),
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

class _EmailReaderScreen extends StatelessWidget {
  const _EmailReaderScreen({
    required this.sender,
    required this.subject,
    required this.time,
    required this.body,
    required this.isImportant,
  });

  final String sender;
  final String subject;
  final String time;
  final String body;
  final bool isImportant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Color(0xFF0A84FF), size: 22),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(const SnackBar(
                          content: Text('Brak połączenia — nie można odpowiedzieć'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ));
                    },
                    icon: const Icon(Icons.reply,
                        color: Color(0xFF0A84FF), size: 22),
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
                      subject,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF2C2C2E),
                          child: Text(
                            sender.isNotEmpty
                                ? sender[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sender, style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                              Text(time, style: const TextStyle(
                                color: Colors.white54, fontSize: 12,
                              )),
                            ],
                          ),
                        ),
                        if (isImportant)
                          const Icon(Icons.flag,
                              color: Color(0xFFFF9500), size: 18),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      body,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.6,
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
