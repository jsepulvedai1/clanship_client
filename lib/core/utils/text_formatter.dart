/// Utility to clean up and format unstructured user-provided text such as bios and descriptions.
/// Fixes accidental line breaks, missing/extra spaces around punctuation, and capitalizes sentences.
String formatBioText(String? input) {
  if (input == null || input.trim().isEmpty) return '';

  String text = input.trim();

  // 1. Unify newline representations (\r\n -> \n, \r -> \n)
  text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  // 2. Specific fix for hyphenated or broken words across newlines:
  // e.g. "re-\nmodelación" -> "remodelación", "remo\ndelación" -> "remodelación"
  text = text.replaceAllMapped(
    RegExp(r'(\w+)-\s*\n\s*(\w+)'),
    (m) => '${m[1]}${m[2]}',
  );
  text = text.replaceAllMapped(
    RegExp(r'\bremo\s*\n\s*delaci([oó])n\b', caseSensitive: false),
    (m) => 'remodelaci${m[1]}n',
  );

  // 3. Remove whitespace before punctuation marks:
  // e.g. "pasto   ,cierre" -> "pasto,cierre", "hola  ." -> "hola."
  text = text.replaceAllMapped(
    RegExp(r'[ \t]+([,.:;?!])'),
    (m) => m[1]!,
  );

  // 4. Normalize "etc.." or "etc." with improper punctuation
  text = text.replaceAll(
    RegExp(r'\betc\.{2,}\s*', caseSensitive: false),
    'etc., ',
  );

  // 5. Ensure space after commas, semicolons, and colons (without breaking numbers like 3,5 or 12:30 or URLs like https://):
  text = text.replaceAllMapped(
    RegExp(r'([,;])([^\s\d])'),
    (m) => '${m[1]} ${m[2]}',
  );
  text = text.replaceAllMapped(
    RegExp(r':([^\s\d/])'),
    (m) => ': ${m[1]}',
  );

  // 6. Ensure space after multiple periods when immediately followed by a letter (e.g. "...palabra" -> "... palabra")
  text = text.replaceAllMapped(
    RegExp(r'(\.{2,})([a-zA-ZáéíóúüñÁÉÍÓÚÜÑ])'),
    (m) => '${m[1]} ${m[2]}',
  );

  // 7. Handle line breaks intelligently:
  // Preserve intentional paragraphs (\n\n) and bulleted/numbered lists.
  // Split into paragraphs by 2 or more newlines.
  final paragraphs = text.split(RegExp(r'\n{2,}'));

  final formattedParagraphs = paragraphs.map((paragraph) {
    final lines = paragraph.split('\n');
    final processedLines = <String>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final isListOrHeader =
          RegExp(r'^([-*•+–]|\d+[\.)]|[a-zA-Z][\.)])\s+').hasMatch(line);

      if (processedLines.isEmpty) {
        processedLines.add(line);
      } else {
        final prevLine = processedLines.last;
        final prevEndsWithColon = prevLine.endsWith(':');

        // If this line is a list item, or previous line ended with colon, keep newline
        if (isListOrHeader || prevEndsWithColon) {
          processedLines.add(line);
        } else {
          // Continuous running sentence broken by an accidental line break: join with space
          processedLines[processedLines.length - 1] = '$prevLine $line';
        }
      }
    }

    return processedLines.join('\n');
  }).toList();

  text = formattedParagraphs.join('\n\n');

  // 8. Normalize multiple commas or punctuation: e.g. ",," -> ","
  text = text.replaceAll(RegExp(r',\s*,'), ',');

  // 9. Collapse redundant spaces and tabs within lines
  text = text.replaceAll(RegExp(r'[ \t]{2,}'), ' ');

  // 10. Capitalize the first letter if it starts with lowercase
  if (text.isNotEmpty) {
    final firstChar = text[0];
    if (RegExp(r'[a-záéíóúüñ]').hasMatch(firstChar)) {
      text = firstChar.toUpperCase() + text.substring(1);
    }
  }

  // 11. Capitalize letter after single terminal period followed by space (e.g. ". servicio" -> ". Servicio")
  // (Negative lookbehind ensures we don't match ellipsis like "...")
  text = text.replaceAllMapped(
    RegExp(r'(?<!\.)(\.\s+)([a-záéíóúüñ])'),
    (match) => '${match.group(1)}${match.group(2)!.toUpperCase()}',
  );

  return text.trim();
}
