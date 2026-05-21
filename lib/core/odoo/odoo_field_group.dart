class OdooFieldGroup {
  const OdooFieldGroup({
    required this.title,
    required this.fieldNames,
  });

  final String title;
  final List<String> fieldNames;

  OdooFieldGroup copyWith({
    String? title,
    List<String>? fieldNames,
  }) =>
      OdooFieldGroup(
        title: title ?? this.title,
        fieldNames: fieldNames ?? this.fieldNames,
      );
}
