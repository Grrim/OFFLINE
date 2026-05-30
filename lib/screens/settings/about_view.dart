import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/l10n_service.dart';
import '../../widgets/status_bar.dart';

class AboutView extends StatefulWidget {
  const AboutView({super.key});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  String _version = '...';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _version = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _version = _l10n('unknown_version', fallback: 'Nieznana');
        });
      }
    }
  }

  String _l10n(String key, {Map<String, String>? params, String? fallback}) {
    final about = L10nService.instance.dialogues['about'] as Map<String, dynamic>? ?? {};
    String text = about[key] ?? fallback ?? key;
    if (params != null) {
      params.forEach((k, v) {
        text = text.replaceAll('{$k}', v);
      });
    }
    return text;
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_l10n('link_error', fallback: 'Nie można otworzyć linku'))),
        );
      }
    }
  }

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
                  Text(
                    _l10n('title', fallback: 'O grze'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'OFFLINE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _l10n('version', params: {'version': _version}, fallback: 'Wersja $_version'),
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    _Block(
                      title: _l10n('privacy_policy', fallback: 'Polityka prywatności'),
                      body: _l10n('privacy_body', fallback: 'OFFLINE to gra typu "found phone". Nie zbieramy żadnych danych osobowych, a cała rozgrywka odbywa się lokalnie na Twoim urządzeniu.'),
                      trailing: GestureDetector(
                        onTap: () => _launchURL('https://grrim.github.io/GrimOrigin/'),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _l10n('privacy_link', fallback: 'Pełna polityka prywatności'),
                            style: const TextStyle(
                              color: Color(0xFF0A84FF),
                              fontSize: 13,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _Block(
                      title: _l10n('age_rating', fallback: 'Wiek: 13+'),
                      body: _l10n('age_body', fallback: 'Gatunek: Found Phone / Detektywistyczna. Tematyka: zaginięcie, korupcja, stalking.'),
                    ),
                    _Block(
                      title: _l10n('open_source', fallback: 'Open source'),
                      body: _l10n('open_source_body', fallback: 'OFFLINE używa następujących bibliotek...'),
                    ),
                    _Block(
                      title: _l10n('audio_attribution', fallback: 'Atrybucje audio'),
                      body: _l10n('audio_body', fallback: 'Dźwięki używane w grze pochodzą z freesound.org...'),
                    ),
                    _Block(
                      title: _l10n('contact', fallback: 'Kontakt'),
                      body: _l10n('contact_body', params: {'year': DateTime.now().year.toString()}, fallback: '© ${DateTime.now().year} GRIM ORIGIN STUDIO'),
                    ),
                    if (kDebugMode)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton(
                          onPressed: () => throw Exception('Sentry Test Error: OFFLINE Debug'),
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          child: const Text('TESTUJ SENTRY (TYLKO DEBUG)'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          showLicensePage(
                            context: context,
                            applicationName: 'OFFLINE',
                            applicationVersion: _version,
                            applicationLegalese:
                                '© ${DateTime.now().year} GRIM ORIGIN STUDIO',
                          );
                        },
                        icon: const Icon(Icons.article_outlined,
                            color: Color(0xFF0A84FF)),
                        label: Text(_l10n('licenses_button', fallback: 'Licencje open-source'),
                            style: const TextStyle(color: Color(0xFF0A84FF))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
                        onLongPress: () {
                          // Easter-egg: copy the version to clipboard.
                          Clipboard.setData(
                              ClipboardData(text: _version));
                          final l10n = L10nService.instance.dialogues['meta']?['notifications'] ?? {};
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                              content: Text(l10n['version_copied'] ?? 'Wersja skopiowana'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ));
                        },
                        child: Text(
                          _l10n('footer', fallback: 'OFFLINE — Zaginiona'),
                          style: const TextStyle(
                              color: Colors.white24,
                              fontSize: 11,
                              letterSpacing: 0.8,
                              fontFeatures: [
                                FontFeature.tabularFigures()
                              ]),
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
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body, this.trailing});
  final String title;
  final String body;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFCC00),
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
