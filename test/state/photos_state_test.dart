import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaginiona/services/persistence_service.dart';
import 'package:zaginiona/state/photos_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await PersistenceService.initForTesting();
  });

  group('PhotosState', () {
    test('seeded with photos including the forest_night clue', () {
      final s = PhotosState(persistence: PersistenceService.instance);
      expect(s.photos, isNotEmpty);
      final clue = s.photos.firstWhere((p) => p.id == 'forest_night');
      expect(clue.isCluePhoto, isTrue);
      expect(clue.hiddenNote, isNotNull);
    });

    test('selectPhoto / clearSelection toggle selectedPhoto', () {
      final s = PhotosState(persistence: PersistenceService.instance);
      s.selectPhoto('forest_night');
      expect(s.selectedPhoto?.id, 'forest_night');
      s.clearSelection();
      expect(s.selectedPhoto, isNull);
    });

    test('markInspected only fires for clue photos', () {
      final s = PhotosState(persistence: PersistenceService.instance);
      String? inspectedId;
      s.onClueInspected = (id) => inspectedId = id;

      // Non-clue photo — no callback.
      s.markInspected('cat');
      expect(inspectedId, isNull);
      expect(s.hasInspected('cat'), isFalse);

      // Clue photo — callback fires.
      s.markInspected('forest_night');
      expect(inspectedId, 'forest_night');
      expect(s.hasInspected('forest_night'), isTrue);
    });

    test('markInspected fires only once per clue photo', () {
      final s = PhotosState(persistence: PersistenceService.instance);
      var fireCount = 0;
      s.onClueInspected = (_) => fireCount++;

      s.markInspected('forest_night');
      s.markInspected('forest_night');
      s.markInspected('forest_night');
      expect(fireCount, 1);
    });

    test('cold-load preserves inspected clue ids', () {
      final s1 = PhotosState(persistence: PersistenceService.instance);
      s1.markInspected('forest_night');
      s1.markInspected('parking');

      final s2 = PhotosState(persistence: PersistenceService.instance);
      expect(s2.hasInspected('forest_night'), isTrue);
      expect(s2.hasInspected('parking'), isTrue);
    });

    test('reset wipes inspected ids and selection', () {
      final s = PhotosState(persistence: PersistenceService.instance);
      s.markInspected('forest_night');
      s.selectPhoto('forest_night');

      s.reset();
      expect(s.hasInspected('forest_night'), isFalse);
      expect(s.selectedPhoto, isNull);
    });

    test('markInspected on unknown photo id is a no-op', () {
      final s = PhotosState(persistence: PersistenceService.instance);
      var fired = false;
      s.onClueInspected = (_) => fired = true;
      s.markInspected('does_not_exist');
      expect(fired, isFalse);
    });
  });
}
