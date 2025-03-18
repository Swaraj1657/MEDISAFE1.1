class MedicationError implements Exception {
  final String message;
  final String code;

  MedicationError(this.code, this.message);

  @override
  String toString() => message;

  // Error codes
  static const String INVALID_DATE = 'INVALID_DATE';
  static const String ALREADY_TAKEN = 'ALREADY_TAKEN';
  static const String FUTURE_DATE = 'FUTURE_DATE';
  static const String PAST_DATE = 'PAST_DATE';
  static const String INVALID_TIME_SLOT = 'INVALID_TIME_SLOT';
  static const String MEDICINE_NOT_FOUND = 'MEDICINE_NOT_FOUND';
  static const String DUPLICATE_MEDICINE = 'DUPLICATE_MEDICINE';
}
