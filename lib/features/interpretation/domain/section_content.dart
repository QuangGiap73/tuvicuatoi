enum ContentSource {
  savedInterpretation,
  generatedInterpretation,
  chartGeneralReading,
  chartPalace,
  catalogSummary,
  topicLibrary,
  unavailable,
}

class SectionContent {
  const SectionContent({
    required this.preview,
    required this.fullContent,
    required this.source,
    required this.isFallback,
  });

  final String preview;
  final String? fullContent;
  final ContentSource source;
  final bool isFallback;

  String get displayContent => fullContent?.trim().isNotEmpty == true
      ? fullContent!.trim()
      : preview.trim();
}
