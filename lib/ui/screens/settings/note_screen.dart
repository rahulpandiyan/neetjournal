import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../widgets/widgets.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  static const _sections = <_NoteSection>[
    _NoteSection(null, [
      _NoteBlock.p("Bro,"),
      _NoteBlock.p("I know you're working hard."),
      _NoteBlock.p(
        "And I also know that sometimes it hurts when the effort you put in "
        "doesn't seem to be noticed — especially when the marks become the "
        "only thing people see.",
      ),
      _NoteBlock.p("You know how many hours you've sat with those books."),
      _NoteBlock.p("You know the days you were tired but still studied."),
      _NoteBlock.p(
        "You know the things you've sacrificed that nobody else saw.",
      ),
      _NoteBlock.callout(
        "And I know it hurts when all of that gets reduced to a number on a paper.",
      ),
      _NoteBlock.p(
        "But bro, don't let that number make you forget what you've "
        "actually put into this.",
      ),
    ]),
    _NoteSection('Mom ❤️', [
      _NoteBlock.p("I know Mom doesn't always see all of that."),
      _NoteBlock.p("She sees the marks."),
      _NoteBlock.p("And yes… **I know that hurts.**"),
      _NoteBlock.p(
        "Sometimes you probably wish she could see the hours behind "
        "those marks, the stress behind them, and how hard you're actually "
        "trying.",
      ),
      _NoteBlock.p("But there's something else we have to understand too."),
      _NoteBlock.p("Mom is carrying a lot."),
      _NoteBlock.p(
        "She's trying to hold our family together, worry about "
        "everyone, take care of everything, and still think about your future.",
      ),
      _NoteBlock.callout(
        "And honestly, **being a woman carrying that kind of responsibility isn't easy.**",
      ),
      _NoteBlock.p("Maybe sometimes her worry comes out as pressure."),
      _NoteBlock.p(
        "Maybe sometimes she looks at the marks before she looks at "
        "the effort.",
      ),
      _NoteBlock.p(
        "But I don't think that means she doesn't care about your "
        "struggle.",
      ),
      _NoteBlock.p("I think she's scared."),
      _NoteBlock.p("Scared that you'll struggle."),
      _NoteBlock.p(
        "Scared that you'll miss the opportunity you're working so "
        "hard for.",
      ),
      _NoteBlock.p(
        "Scared because she wants to know that all your hard work "
        "will lead somewhere.",
      ),
      _NoteBlock.p("She may not always know how to show that fear gently."),
      _NoteBlock.p(
        "But underneath it is a mother who wants her son to be okay.",
      ),
      _NoteBlock.p("And bro…"),
      _NoteBlock.callout(
        "you don't have to prove your worth through one exam or one mark.",
      ),
    ]),
    _NoteSection('Dad ❤️', [
      _NoteBlock.p("Dad doesn't show much either."),
      _NoteBlock.p("That's just Dad."),
      _NoteBlock.p("He's not going to sit down and say everything he feels."),
      _NoteBlock.p("But look at what he does instead."),
      _NoteBlock.p("He talks about you."),
      _NoteBlock.p("He tells people about you."),
      _NoteBlock.p(
        "He talks about what you're studying and what you're trying "
        "to become.",
      ),
      _NoteBlock.p(
        "And sometimes you can hear the pride in his voice even when "
        "he never actually says the words.",
      ),
      _NoteBlock.callout("He's proud of you, bro."),
      _NoteBlock.p("Maybe quietly."),
      _NoteBlock.p("Maybe in his own way."),
      _NoteBlock.p("But he is."),
      _NoteBlock.p("And someday, I hope you understand how much that means."),
    ]),
    _NoteSection("And then there's me. 😂", [
      _NoteBlock.p(
        "I'm not going to pretend I'm the most emotional person in "
        "the family.",
      ),
      _NoteBlock.p("I have much more important responsibilities."),
      _NoteBlock.p(
        "Like making sure you actually get into medical college so I "
        "can come to your hostel and **annoy you in person.** 😂",
      ),
      _NoteBlock.p("Because apparently your NEET goals are:"),
      _NoteBlock.callout(
        "**1. Become a doctor. 🩺\n"
        "2. Get a beautiful girl in medical college. 😂\n"
        "3. Somehow survive everything else.**",
      ),
      _NoteBlock.p("Bro really has the entire career plan figured out. 😭😂"),
      _NoteBlock.p("So first…"),
      _NoteBlock.callout("**CRACK NEET.**"),
      _NoteBlock.p("Get that seat."),
      _NoteBlock.p("Get that white coat."),
      _NoteBlock.p(
        "Then you can start your search for the future doctor madam. 😂",
      ),
      _NoteBlock.p("And don't worry about the rest."),
      _NoteBlock.p("Gadgets?"),
      _NoteBlock.p("**We'll see what I can do. 😎**"),
      _NoteBlock.p("Pocket money?"),
      _NoteBlock.p("**Application under review. 😂**"),
      _NoteBlock.p("Hostel visit?"),
      _NoteBlock.p("**Approved. Unfortunately for you. 😂**"),
    ]),
    _NoteSection(null, [
      _NoteBlock.p("But jokes aside, bro…"),
      _NoteBlock.p("I want you to remember something when things get heavy."),
      _NoteBlock.p("You are allowed to have bad days."),
      _NoteBlock.p("You are allowed to get disappointing marks."),
      _NoteBlock.p("You are allowed to feel tired."),
      _NoteBlock.p(
        "You are allowed to feel like you're not doing enough "
        "sometimes.",
      ),
      _NoteBlock.callout(
        "Just don't let one bad day convince you that you can't "
        "reach where you want to go.",
      ),
      _NoteBlock.p("Because one day, this whole chapter will be behind you."),
      _NoteBlock.p(
        "And when Result Day finally comes, I don't want you sitting "
        "there thinking about every mistake you made.",
      ),
      _NoteBlock.p("I want you to smile."),
      _NoteBlock.p("Because that smile will tell us everything."),
      _NoteBlock.p("It will tell Mom that her son made it."),
      _NoteBlock.p(
        "It will tell Dad that all those quiet conversations about "
        "you were worth it.",
      ),
      _NoteBlock.p("And it will tell me that…"),
      _NoteBlock.callout(
        "finally, my Tharkuri brother is going to medical college. 😂❤️",
      ),
      _NoteBlock.p("And then I'll probably look at you and say:"),
      _NoteBlock.p("**“Okay Doctor, where's my hostel invitation?” 😂🩺**"),
      _NoteBlock.p("So keep going, bro."),
      _NoteBlock.p("Not because you have to make everyone proud."),
      _NoteBlock.p("Not because one mark decides your future."),
      _NoteBlock.callout(
        "But because there's a version of you waiting on the "
        "other side of this struggle that you're going to be really proud of.",
      ),
      _NoteBlock.p("And when you finally get there…"),
      _NoteBlock.callout("we'll be right there with you. ❤️"),
      _NoteBlock.p("Now go study."),
      _NoteBlock.p(
        "Your future doctor madam isn't going to find herself. 😂🩺❤️",
      ),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScreenHeader(
              title: 'A Note for You',
              subtitle: 'From Rahul, with love',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HeroCard(),
                    const SizedBox(height: 20),
                    for (final section in _sections) ...[
                      _SectionCard(section: section),
                      const SizedBox(height: 16),
                    ],
                    const _Signature(),
                    const SizedBox(height: 28),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient hero panel: kicker, letter title, and a floating filled heart.
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Reveal(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.primary.withValues(alpha: 0.82)],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.32),
              offset: const Offset(0, 10),
              blurRadius: 24,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1.4,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const HugeIcon(
                    icon: filledHeart,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'A LETTER FOR YOU',
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 1.6,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'From Rahul, for the days that feel heavy.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.78),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              '# For My Brother ❤️',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.12,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Because this was never really about marks.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimary.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One chapter of the letter: optional heading + body blocks.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _NoteSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Reveal(
      delay: const Duration(milliseconds: 60),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (section.heading != null) ...[
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      section.heading!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
            for (final block in section.blocks) ..._buildBlock(context, block),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBlock(BuildContext context, _NoteBlock block) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (block.kind == _NoteKind.callout) {
      return [
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: scheme.primaryContainer.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(16),
            border: Border(left: BorderSide(color: scheme.primary, width: 3)),
          ),
          child: _RichText(
            text: block.text,
            baseStyle: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.5,
              color: scheme.onPrimaryContainer,
            ),
          ),
        ),
      ];
    }
    return [
      const SizedBox(height: 12),
      _RichText(
        text: block.text,
        baseStyle: theme.textTheme.bodyLarge?.copyWith(
          height: 1.6,
          color: scheme.onSurface.withValues(alpha: 0.9),
        ),
      ),
    ];
  }
}

/// Renders a paragraph, honouring **bold** spans inline.
class _RichText extends StatelessWidget {
  const _RichText({required this.text, required this.baseStyle});

  final String text;
  final TextStyle? baseStyle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bold = (baseStyle ?? const TextStyle()).copyWith(
      fontWeight: FontWeight.w800,
      color: scheme.onSurface,
    );
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          for (var i = 0; i < parts.length; i++)
            if (parts[i].isNotEmpty)
              TextSpan(text: parts[i], style: i.isOdd ? bold : null),
        ],
      ),
    );
  }
}

/// Ornamental sign-off: — Rahul, framed by hairlines and a filled heart.
class _Signature extends StatelessWidget {
  const _Signature();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Row(
            children: [
              Expanded(child: Divider(color: scheme.outlineVariant)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: HugeIcon(
                  icon: filledHeart,
                  color: scheme.primary,
                  size: 14,
                ),
              ),
              Expanded(child: Divider(color: scheme.outlineVariant)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '— Rahul',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HugeIcon(
          icon: filledHeart,
          color: scheme.primary.withValues(alpha: 0.7),
          size: 15,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            'Made with ❤️ by Rahul — Bro, I\'ll see you at the finish line.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

enum _NoteKind { paragraph, callout }

class _NoteSection {
  const _NoteSection(this.heading, this.blocks);

  final String? heading;
  final List<_NoteBlock> blocks;
}

class _NoteBlock {
  const _NoteBlock.p(this.text) : kind = _NoteKind.paragraph;
  const _NoteBlock.callout(this.text) : kind = _NoteKind.callout;

  final String text;
  final _NoteKind kind;
}
