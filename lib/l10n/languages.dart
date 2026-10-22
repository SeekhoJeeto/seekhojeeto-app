class Lang {
  final String code;
  final String name;
  const Lang(this.code, this.name);
}

/// The 13 languages the question bank is available in.
const List<Lang> kLanguages = [
  Lang('en', 'English'),
  Lang('hi', 'हिन्दी'),
  Lang('bn', 'বাংলা'),
  Lang('mr', 'मराठी'),
  Lang('te', 'తెలుగు'),
  Lang('ta', 'தமிழ்'),
  Lang('gu', 'ગુજરાતી'),
  Lang('ur', 'اردو'),
  Lang('kn', 'ಕನ್ನಡ'),
  Lang('or', 'ଓଡ଼ିଆ'),
  Lang('ml', 'മലയാളം'),
  Lang('pa', 'ਪੰਜਾਬੀ'),
  Lang('as', 'অসমীয়া'),
];

String languageName(String code) {
  for (final l in kLanguages) {
    if (l.code == code) return l.name;
  }
  return 'English';
}
