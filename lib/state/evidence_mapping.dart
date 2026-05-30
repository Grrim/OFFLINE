/// Maps content IDs (photo, file, browser entry, recording, ...) to the
/// evidence IDs they award when first inspected.
///
/// Centralised here so [EvidenceState] doesn't need to know about content
/// schemas, and [PhotosState]/[FilesState]/etc don't need to know about
/// the score system. The wiring lives in the phone shell.
class EvidenceMapping {
  static const Map<String, String> photoToEvidence = {
    'forest_night': 'photo_forest_night',
    'parking': 'photo_parking',
    'document': 'photo_document',
  };

  static const Map<String, String> fileToEvidence = {
    'faktura_2026_05': 'file_invoice_05',
    'faktura_2026_04': 'file_invoice_04',
    'transkrypcja': 'file_transcript',
    'koperty': 'file_envelopes',
    'mapa_wycinek': 'file_map',
  };

  static const Map<String, String> recordingToEvidence = {
    'rec_001': 'recording_001',
    'rec_002': 'recording_002',
    'rec_003': 'recording_003',
    'voicemail_threat': 'voicemail_threat',
  };

  static const Map<String, String> browserToEvidence = {
    'krs_helion': 'browser_krs',
    'centralna': 'browser_centralna',
  };

  static const Map<String, String> emailToEvidence = {
    'anita_pilne': 'email_anita',
    'strazn_lasu': 'email_strazn_lasu',
  };
}
