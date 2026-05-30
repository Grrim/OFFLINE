import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../state/maps_state.dart';
import '../../widgets/fragment_hotspot.dart';
import '../../widgets/status_bar.dart';

/// Maps app — list of significant locations + drag-reorder route
/// reconstruction puzzle. The puzzle starts collapsed; player taps
/// "Zrekonstruuj trasę" to expand it, then drags pins into chronological
/// order.
class MapsView extends StatelessWidget {
  const MapsView({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<MapsState>();
    final pins = state.pins;
    final solved = state.isPuzzleSolved;

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
                    'Ważne miejsca',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (solved)
                    const Icon(Icons.verified,
                        color: Color(0xFF34C759), size: 22),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF453A).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFFF453A).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber,
                        color: Color(0xFFFF453A), size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Ostatnia znana lokalizacja: '
                        'Las Kabacki, 17.05.2026 23:45',
                        style: TextStyle(
                          color: Color(0xFFFF453A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                children: [
                  for (final p in pins)
                    if (p.id == 'las_kabacki')
                      FragmentHotspot(
                        fragmentId: 'frag_warning',
                        child: _LocationEntry(pin: p),
                      )
                    else
                      _LocationEntry(pin: p),
                  const SizedBox(height: 12),
                  _RouteReconstructionCard(state: state),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationEntry extends StatelessWidget {
  const _LocationEntry({required this.pin});
  final MapPin pin;

  @override
  Widget build(BuildContext context) {
    final isAlert = pin.isAlert;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAlert
            ? const Color(0xFFFF453A).withValues(alpha: 0.06)
            : const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: isAlert
            ? Border.all(
                color: const Color(0xFFFF453A).withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0A84FF).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isAlert ? Icons.warning_amber : Icons.place,
              color: isAlert
                  ? const Color(0xFFFF453A)
                  : const Color(0xFF0A84FF),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pin.name,
                    style: TextStyle(
                      color: isAlert
                          ? const Color(0xFFFF453A)
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: isAlert
                          ? FontWeight.w700
                          : FontWeight.w500,
                    )),
                const SizedBox(height: 2),
                Text(pin.address,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 2),
                Text('${pin.visitsLabel} · Ostatnio: ${pin.lastVisit}',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteReconstructionCard extends StatefulWidget {
  const _RouteReconstructionCard({required this.state});
  final MapsState state;

  @override
  State<_RouteReconstructionCard> createState() =>
      _RouteReconstructionCardState();
}

class _RouteReconstructionCardState extends State<_RouteReconstructionCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand if puzzle was solved earlier or partial progress exists.
    if (widget.state.playerOrder.isNotEmpty ||
        widget.state.isPuzzleSolved) {
      _expanded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: state.isPuzzleSolved
              ? const Color(0xFF34C759).withValues(alpha: 0.4)
              : const Color(0xFF2C2C2E),
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: state.isPuzzleSolved
                          ? const Color(0xFF34C759)
                              .withValues(alpha: 0.2)
                          : const Color(0xFF0A84FF)
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      state.isPuzzleSolved
                          ? Icons.verified
                          : Icons.alt_route,
                      color: state.isPuzzleSolved
                          ? const Color(0xFF34C759)
                          : const Color(0xFF0A84FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.isPuzzleSolved
                              ? 'Trasa zrekonstruowana'
                              : 'Zrekonstruuj ostatni dzień',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          state.isPuzzleSolved
                              ? 'Ułożona poprawnie. 17.05.2026.'
                              : 'Przeciągnij ${state.routePins.length} '
                                  'lokalizacji w kolejności chronologicznej.',
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _expanded
                ? Padding(
                    padding:
                        const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: _RouteReorderList(state: state),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _RouteReorderList extends StatelessWidget {
  const _RouteReorderList({required this.state});
  final MapsState state;

  @override
  Widget build(BuildContext context) {
    final ordered = state.playerOrder;
    final remaining = state.shuffledRemainingPins;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (ordered.isEmpty && remaining.isNotEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Stuknij lokalizację poniżej, aby dodać ją do trasy.',
              style: TextStyle(
                  color: Colors.white54, fontSize: 12),
            ),
          ),

        if (ordered.isNotEmpty)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: true,
            // `onReorderItem` is the recommended replacement, but only
            // landed in pre-release after Flutter 3.41 — keeping
            // `onReorder` until our minimum Flutter SDK requires it.
            // ignore: deprecated_member_use
            onReorder: (oldIdx, newIdx) {
              HapticFeedback.lightImpact();
              final newList = List<String>.from(ordered);
              final id = newList.removeAt(oldIdx);
              final clamped =
                  newIdx > oldIdx ? newIdx - 1 : newIdx;
              newList.insert(clamped, id);
              state.setPlayerOrder(newList);
            },
            children: [
              for (var i = 0; i < ordered.length; i++)
                _OrderedTile(
                  key: ValueKey(ordered[i]),
                  index: i + 1,
                  pinId: ordered[i],
                  state: state,
                ),
            ],
          ),

        if (remaining.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 12, 0, 6),
            child: Text(
              'POZOSTAŁE',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
              ),
            ),
          ),
          for (final p in remaining)
            _AddPinTile(pin: p, onAdd: () => state.togglePin(p.id)),
        ],

        if (state.isPuzzleSolved) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF34C759).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle,
                    color: Color(0xFF34C759), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trasa zgadza się ze stempletami GPS i timestampami '
                    'z Kalendarza.',
                    style: TextStyle(
                        color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OrderedTile extends StatelessWidget {
  const _OrderedTile({
    super.key,
    required this.index,
    required this.pinId,
    required this.state,
  });

  final int index;
  final String pinId;
  final MapsState state;

  @override
  Widget build(BuildContext context) {
    final pin = state.pins.firstWhere((p) => p.id == pinId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: Color(0xFF0A84FF),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(pin.name,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 13)),
            ),
            IconButton(
              icon: const Icon(Icons.close,
                  color: Colors.white38, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => state.togglePin(pinId),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.drag_handle, color: Colors.white38, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AddPinTile extends StatelessWidget {
  const _AddPinTile({required this.pin, required this.onAdd});
  final MapPin pin;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: const Color(0xFF2C2C2E).withValues(alpha: 0.7)),
          ),
          child: Row(
            children: [
              const Icon(Icons.add_circle_outline,
                  color: Color(0xFF0A84FF), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(pin.name,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
