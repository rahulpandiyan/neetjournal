/// A single motivational line with attribution.
class Motivation {
  const Motivation(this.text, this.author, {this.source});

  final String text;
  final String author;

  /// Optional origin label (e.g. `'zenquotes'`) shown as a small credit when
  /// the line came from a remote service instead of the local list.
  final String? source;
}

/// Curated motivational lines for study, discipline and exam prep.
///
/// Rotation logic:
/// - [daily] shows the line for a given calendar day (changes every day).
/// - [nextForSession] shows a fresh line per focus session (one per screen
///   instance, combined with the day index so it never repeats the daily one).
class Motivations {
  Motivations._();

  static const List<Motivation> _all = [
    Motivation(
      'Success is the sum of small efforts, repeated day in and day out.',
      'Robert Collier',
    ),
    Motivation('The secret of getting ahead is getting started.', 'Mark Twain'),
    Motivation(
      'Don\'t watch the clock; do what it does. Keep going.',
      'Sam Levenson',
    ),
    Motivation('Fall seven times, stand up eight.', 'Japanese proverb'),
    Motivation('Nothing will work unless you do.', 'Maya Angelou'),
    Motivation(
      'It\'s not that I\'m so smart, it\'s just that I stay with problems '
          'longer.',
      'Albert Einstein',
    ),
    Motivation(
      'Education is the passport to the future, for tomorrow belongs to '
          'those who prepare for it today.',
      'Malcolm X',
    ),
    Motivation(
      'Success is not final, failure is not fatal: it is the courage to '
          'continue that counts.',
      'Winston Churchill',
    ),
    Motivation('Don\'t wish it were easier. Wish you were better.', 'Jim Rohn'),
    Motivation(
      'You don\'t have to be great to start, but you have to start to be '
          'great.',
      'Zig Ziglar',
    ),
    Motivation('The future depends on what you do today.', 'Mahatma Gandhi'),
    Motivation(
      'Discipline is the bridge between goals and accomplishment.',
      'Jim Rohn',
    ),
    Motivation(
      'The dictionary is the only place success comes before work.',
      'Vidal Sassoon',
    ),
    Motivation(
      'Believe you can and you\'re halfway there.',
      'Theodore Roosevelt',
    ),
    Motivation(
      'Hard work beats talent when talent doesn\'t work hard.',
      'Tim Notke',
    ),
    Motivation(
      'Discipline is choosing between what you want now and what you want '
          'most.',
      'Abraham Lincoln',
    ),
    Motivation(
      'There are no secrets to success. It is the result of preparation, '
          'hard work, and learning from failure.',
      'Colin Powell',
    ),
    Motivation(
      'The best way to predict the future is to create it.',
      'Peter Drucker',
    ),
    Motivation(
      'Action is the foundational key to all success.',
      'Pablo Picasso',
    ),
    Motivation(
      'Success is walking from failure to failure with no loss of '
          'enthusiasm.',
      'Winston Churchill',
    ),
    Motivation(
      'It always seems impossible until it\'s done.',
      'Nelson Mandela',
    ),
    Motivation(
      'We are what we repeatedly do. Excellence, then, is not an act, but '
          'a habit.',
      'Will Durant',
    ),
    Motivation(
      'Motivation gets you going, but discipline keeps you growing.',
      'John C. Maxwell',
    ),
    Motivation(
      'A year from now you may wish you had started today.',
      'Karen Lamb',
    ),
    Motivation(
      'The pain of discipline weighs ounces; the pain of regret weighs tons.',
      'Jim Rohn',
    ),
    Motivation(
      'Amateurs sit and wait for inspiration. The rest of us just get up and '
          'go to work.',
      'Stephen King',
    ),
    Motivation('Either you run the day, or the day runs you.', 'Jim Rohn'),
    Motivation(
      'Work hard in silence. Let your success make the noise.',
      'Frank Ocean',
    ),
    Motivation(
      'You don\'t get what you wish for. You get what you work for.',
      'Daniel Milstein',
    ),
    Motivation(
      'Skill is only developed by hours and hours of work.',
      'Usain Bolt',
    ),
    Motivation(
      'Do what you have to do until you can do what you want to do.',
      'Oprah Winfrey',
    ),
    Motivation(
      'The greatest glory in living lies not in never falling, but in '
          'rising every time we fall.',
      'Nelson Mandela',
    ),
    Motivation(
      'You have power over your mind, not outside events. Realize this, '
          'and you will find strength.',
      'Marcus Aurelius',
    ),
    Motivation(
      'Dream, dream, dream. Dreams transform into thoughts, and thoughts '
          'result in action.',
      'A. P. J. Abdul Kalam',
    ),
    Motivation(
      'Arise, awake, and stop not till the goal is reached.',
      'Swami Vivekananda',
    ),
    Motivation('Dream big. Start small. Act now.', 'Robin Sharma'),
    Motivation(
      'It is not the mountain we conquer, but ourselves.',
      'Edmund Hillary',
    ),
    Motivation(
      'Whether you think you can or you think you can\'t, you\'re right.',
      'Henry Ford',
    ),
    Motivation('Strive for progress, not perfection.', 'Anonymous'),
    Motivation(
      'One mark more than yesterday is still progress. Keep going.',
      'Anonymous',
    ),
    Motivation(
      'The exam doesn\'t test how smart you are. It tests how much you '
          'prepared. Show up for yourself today.',
      'Anonymous',
    ),
    Motivation(
      'Competition with yourself beats competition with others. Beat '
          'yesterday\'s you.',
      'Anonymous',
    ),
    Motivation(
      'Your rank is decided on the days you don\'t feel like studying but '
          'study anyway.',
      'Anonymous',
    ),
    Motivation(
      'This page, this topic, this hour — just do this one right. The '
          'dream takes care of itself.',
      'Anonymous',
    ),
  ];

  /// Day-of-year offset so every calendar day shows a different line.
  static Motivation daily(DateTime day) {
    final start = DateTime(day.year, 1, 1);
    final index = day.difference(start).inDays;
    return _all[index % _all.length];
  }

  static int _sessionCounter = 0;

  /// A fresh line per focus session, offset from the daily one so they never
  /// collide on the same day.
  static Motivation nextForSession() {
    final day = DateTime.now();
    final start = DateTime(day.year, 1, 1);
    final dayIndex = day.difference(start).inDays;
    _sessionCounter++;
    return _all[(dayIndex + _sessionCounter) % _all.length];
  }

  /// All lines, exposed for tests.
  static List<Motivation> get all => List.unmodifiable(_all);
}
