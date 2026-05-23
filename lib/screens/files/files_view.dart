import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/files_state.dart';
import '../../widgets/status_bar.dart';

/// Files app — list of N.'s investigation documents.
class FilesView extends StatelessWidget {
  const FilesView({super.key});

  @override
  Widget build(BuildContext context) {
    final files = context.watch<FilesState>();

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
                    'Pliki',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Section label.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Na tym iPhone',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    '${files.files.length} elementów',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: files.files.length,
                separatorBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(left: 56),
                  child: Divider(height: 1, color: Color(0xFF1C1C1E)),
                ),
                itemBuilder: (context, i) {
                  final file = files.files[i];
                  return _FileTile(
                    file: file,
                    isUnread: !files.hasOpened(file.id),
                    onTap: () {
                      files.markOpened(file.id);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _FileReaderScreen(fileId: file.id),
                      ));
                    },
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

class _FileTile extends StatelessWidget {
  const _FileTile({
    required this.file,
    required this.isUnread,
    required this.onTap,
  });

  final GameFile file;
  final bool isUnread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: file.iconColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: file.iconColor.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Icon(file.icon, color: file.iconColor, size: 20),
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
                          file.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight:
                                isUnread ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
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
                    '${file.subtitle} · ${file.dateString}',
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FileReaderScreen extends StatelessWidget {
  const _FileReaderScreen({required this.fileId});

  final String fileId;

  @override
  Widget build(BuildContext context) {
    final file = context.read<FilesState>().fileById(fileId);
    if (file == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child:
              Text('Brak pliku', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final textStyle = TextStyle(
      color: const Color(0xFFE0E0E0),
      fontSize: 13,
      height: 1.45,
      fontFamily: file.isMonospace ? 'Courier' : null,
    );

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
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          file.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          file.dateString,
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF1C1C1E)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: _AnnotatedFileBody(body: file.body, style: textStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders file body with N.'s annotations highlighted in yellow/orange.
/// Annotations are lines matching `[ N.: ... ]` pattern.
class _AnnotatedFileBody extends StatelessWidget {
  const _AnnotatedFileBody({required this.body, required this.style});

  final String body;
  final TextStyle style;

  static final _annotationRegex = RegExp(r'\[ N\.:.*?\]', dotAll: true);

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var lastEnd = 0;

    for (final match in _annotationRegex.allMatches(body)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: body.substring(lastEnd, match.start),
          style: style,
        ));
      }
      spans.add(WidgetSpan(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFFFCC00).withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.edit_note,
                  color: Color(0xFFFFCC00), size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  match.group(0)!,
                  style: style.copyWith(
                    color: const Color(0xFFFFCC00),
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
      lastEnd = match.end;
    }

    if (lastEnd < body.length) {
      spans.add(TextSpan(
        text: body.substring(lastEnd),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
