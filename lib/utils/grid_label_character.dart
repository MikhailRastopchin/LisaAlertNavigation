const _characters = [
  'A',
  'B',
  'C',
  'D',
  'E',
  'F',
  'G',
  'H',
  'I',
  'J',
  'K',
  'L',
  'M',
  'N',
  'O',
  'P',
  'Q',
  'R',
  'S',
  'T',
  'U',
  'V'
  'W',
  'X',
  'Y',
  'Z',
];


String _getLetter(final int index) => _characters[index - 1];


String getColumnLabel(final int index)
{
  assert(index > 0);
  final wholeAlphabets = index ~/ _characters.length;
  final fractionalPart = index % _characters.length;
  if (wholeAlphabets == 0) return _getLetter(fractionalPart);
  if (wholeAlphabets <= _characters.length) {
    final firstCharacter = _getLetter(wholeAlphabets);
    final secondCharacter = _getLetter(fractionalPart);
    return '$firstCharacter$secondCharacter';
  } else {
    final firstCharacter = (wholeAlphabets ~/ _characters.length);
    final secondCharacter = _getLetter(wholeAlphabets % _characters.length);
    final thirdCharacter = _getLetter(fractionalPart);
    return '$firstCharacter$secondCharacter$thirdCharacter';
  }
}