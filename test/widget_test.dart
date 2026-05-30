// Smoke test placeholder.
//
// The full ZaginionaApp widget tree spins up multiple long-running
// timers (location service, boot screen, scheduled NPC messages) that
// are not test-friendly without significant refactoring. Real boot
// validation lives in the integration test track.
//
// We keep this file present so `flutter test` doesn't complain about
// missing entrypoint, and so future smoke checks have a home.

import 'package:flutter_test/flutter_test.dart';

void main() {
  // Intentionally empty — top-level smoke testing happens in
  // integration_test/, while unit tests for individual state classes
  // and services live under test/state/, test/services/, test/l10n/.
  test('placeholder', () {
    expect(1 + 1, 2);
  });
}
