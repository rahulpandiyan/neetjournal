# NEET Journal — Product Requirements Document (PRD)

**Version:** 1.0
**Target Exam:** NEET 2027
**Preparation Period:** August 2026 – April 2027
**Platform:** Android + Windows Desktop
**Framework:** Flutter + Dart

---

## 1. Product Overview

NEET Journal is a simple personal study companion for a NEET aspirant.

The app converts the student's timetable into an interactive daily routine.

The app should answer:

> **What should I study now?**

Then help the student:

**Start → Focus → Take a break → Complete → Record what was learned → Continue**

The app should guide the student but **never force him to follow the timetable**.

The timetable provided for the project is the default timetable. The student can customize it later.

---

## 2. Main Objectives

The app should:

* Show what the student needs to study at a particular time.
* Provide a default NEET preparation timetable.
* Allow timetable customization.
* Start a Pomodoro/focus timer directly from each study session.
* Notify the student when it is time to study.
* Notify the student when it is time to stop and rest.
* Encourage adequate breaks and sleep.
* Reduce distractions while studying.
* Track what the student learned.
* Track unfinished/pending work.
* Show days remaining until NEET 2027.
* Provide simple preparation progress.
* Provide revision reminders.
* Maintain a daily NEET journal.
* Make Sunday a dedicated recovery day.

---

## 3. Core Product Philosophy

The app is a **coach, not a controller**.

It can:

* Recommend
* Remind
* Encourage
* Warn
* Reschedule
* Suggest breaks

It should not:

* Punish the student for missing sessions.
* Force the student to study.
* Create guilt around missed tasks.
* Encourage sacrificing sleep.
* Encourage excessive study hours.
* Turn preparation into a competition.

If a student misses a session, the app should simply help him decide what to do next.

Example:

> You missed your Physics session.

Options:

**Study Now**

**Move to Later**

**Move to Tomorrow**

**Skip**

---

## 4. Default Weekly Structure

## Monday–Saturday

The original timetable and subject rotation should remain unchanged.

The student follows the regular NEET preparation schedule:

* Physics
* Chemistry
* Biology
* Revision
* MCQs
* PYQs
* College
* Breaks
* Sleep

The app should automatically show the appropriate activity according to the timetable.

---

## 5. Default Daily Timetable

### Monday–Saturday

| Time            | Activity              |
| --------------- | --------------------- |
| 3:00 AM         | Wake up               |
| 3:15–4:15 AM    | Physics               |
| 4:15–5:15 AM    | Chemistry             |
| 5:15–5:30 AM    | Break                 |
| 5:30–6:30 AM    | Biology               |
| 6:30–7:15 AM    | Breakfast + Get Ready |
| 7:30 AM         | Leave for College     |
| 7:30 AM–8:00 PM | College + Travel      |
| 8:00–8:45 PM    | Dinner + Freshen Up   |
| 8:45–9:00 PM    | Reset                 |
| 9:00–9:30 PM    | Revision              |
| 9:30–10:00 PM   | Revision              |
| 10:00 PM        | Sleep                 |

This is the **default timetable**, not a mandatory schedule.

---

## 6. Weekly Subject Rotation

The original weekly subject rotation should be preloaded.

### Monday

* Physics — New Concept
* Chemistry — New Concept
* Biology — NCERT
* Physics — MCQs/PYQs
* Biology — NCERT Recall

### Tuesday

* Physics — New Concept
* Chemistry — Questions
* Biology — NCERT + MCQs
* Chemistry — PYQs
* Biology — Revision

### Wednesday

* Chemistry — New Concept
* Physics — Questions
* Biology — NCERT
* Physics — PYQs
* Chemistry — Formula/Reactions

### Thursday

* Physics — New Concept
* Chemistry — New Concept
* Biology — NCERT + MCQs
* Biology — NCERT Recall
* Physics — Error Log

### Friday

* Chemistry — New Concept
* Physics — Questions
* Biology — NCERT
* Chemistry — PYQs
* Biology — MCQs

### Saturday

* Physics — Weekly Revision
* Chemistry — Weekly Revision
* Biology — Weekly NCERT
* Physics — Weekly PYQs
* Weakest Area

---

## 7. Sunday — Recovery Day

Sunday is intentionally different.

It is a **recovery and reset day**, not a missed study day.

### Sunday

* Wake up around **4:30 AM**
* Light optional revision
* No heavy new chapters
* No compulsory full mock test
* More breaks
* Relaxation
* Exercise/walking if desired
* Family/personal time
* Weekly reflection
* Review pending work
* Prepare the next week's timetable
* Normal bedtime

Sunday should help prevent burnout and allow the student to start Monday refreshed.

---

## 8. Sunday Example

```text
4:30 AM
Wake Up

4:45–5:30
Light Biology / NCERT Revision

5:30–6:00
Break

6:00–6:45
Light Physics / Chemistry Revision

Morning
Breakfast + Rest

Afternoon
Free / Recovery

Evening
Optional 30–45 min Weak Topic Revision

Night
Weekly Journal + Next Week Planning

10:00 PM
Sleep
```

All Sunday study should be optional except the weekly reflection/planning.

---

## 9. Home Screen — Today

The Home screen is the most important screen.

Example:

```text
Good Morning 👋

NEET 2027
287 DAYS LEFT

────────────────────

NOW

3:15 – 4:15 AM

PHYSICS

Current Electricity

Revise concept
+ Solve 20 MCQs

[ START STUDY ]

────────────────────

NEXT

4:15 – 5:15 AM
CHEMISTRY

Chemical Bonding

────────────────────

TODAY

✓ Physics
○ Chemistry
○ Biology
○ Revision
○ Revision
```

The student should immediately know what he needs to do.

---

## 10. NEET Countdown

Display prominently:

```text
NEET 2027

287
DAYS LEFT
```

The exam date should be configurable.

The countdown should appear on the Home screen.

---

## 11. Start Study

Every timetable item should contain:

**START STUDY**

Example:

```text
PHYSICS

Current Electricity

Today's Target:

• Revise Ohm's Law
• Study Resistance
• Study Resistivity
• Solve 20 MCQs

[ START STUDY ]
```

Pressing Start Study immediately starts the focus session.

---

## 12. Pomodoro / Focus Timer

Pomodoro is integrated into the timetable.

It should **not be a separate complicated feature**.

Flow:

```text
Timetable
↓
Start Study
↓
Focus Timer
↓
Study
↓
Break
↓
Next Session
```

Default:

**50 minutes Focus → 10 minutes Break**

Allow the student to customize:

* 25/5
* 50/10
* 60/10
* 90/15
* Custom

---

## 13. Focus Mode

When the student starts studying, the app should enter a distraction-free mode.

Show only:

```text
PHYSICS

Current Electricity

42:31

[ PAUSE ]    [ FINISH ]

Stay focused.
Your break is coming soon.
```

Hide unnecessary application features during focus.

Do not show:

* Social feed
* Excessive analytics
* Other tasks
* Unnecessary navigation
* Random content
* Excessive animations

---

## 14. Break System

When a focus session finishes:

```text
🎉 Session Complete

Physics is done.

Take a 10-minute break.

Drink water.
Stretch.
Rest your eyes.

[ START BREAK ]
```

Then start the break timer.

At the end:

```text
🔔 Break Complete

Chemistry is next.

[ START NEXT SESSION ]
```

---

## 15. Rest Notifications

The app should notify the student when:

### Study is about to start

> Physics starts in 10 minutes.

### Study starts

> 🔵 Time to study Physics.

### Study ends

> ⏰ Physics session complete. Take a break.

### Break ends

> 🔔 Break over. Chemistry is next.

### Student has been studying too long

> 🧠 You've been studying for a long time. Your timetable planned a break now.

The app should encourage recovery instead of encouraging continuous studying.

---

## 16. Sleep Reminder

Sleep is part of the preparation system.

Before bedtime:

> 🌙 Your study day is almost complete.

> Finish your journal and prepare for tomorrow.

At bedtime:

> 😴 Time to sleep.

The app should not encourage the student to stay awake late just to finish pending work.

---

## 17. "I'm Tired" Feature

During a study session:

```text
Feeling tired?

[ I'M TIRED ]
```

When selected:

```text
What would you like to do?

[ Take 10 min Break ]

[ Take 20 min Break ]

[ End Session ]

[ Continue ]
```

The student remains in control.

---

## 18. Bad Day Mode

If the student is tired or has had a difficult day:

### Bad Day Mode

The app can reduce the day's workload.

Example:

```text
Today's Minimum

Physics — 30 min
Chemistry — 30 min
Biology — 30 min

Everything else can move.
```

Message:

> Don't try to recover everything tonight. Do what you can and reset tomorrow.

---

## 19. Missed Session Handling

If a student misses a session:

Do not punish him.

Show:

> Physics was missed.

Options:

* Study Now
* Move Later
* Move Tomorrow
* Move to Saturday
* Skip

The app should avoid creating a huge backlog by automatically adding every missed task to the next day.

---

## 20. Daily Journal

At the end of the day:

## Today's Journal

### What did I study?

Automatically show completed sessions.

### What did I learn?

Text input:

> Write what you learned today...

### What is pending?

Automatically show incomplete tasks.

### How was today?

* Difficult
* Okay
* Good
* Excellent

The journal should take **less than a few minutes** to complete.

---

## 21. Session Completion

After every study session:

```text
Session Complete ✓

Did you complete your target?

[ Completed ]

[ Partially Completed ]

[ Not Completed ]

What did you learn?

[ Write something... ]

Anything pending?

[ Add pending... ]

[ SAVE ]
```

---

## 22. Pending Work

If the student does not complete a task:

```text
PENDING

Physics
10 PYQs
```

Next day:

> Yesterday's pending work

Options:

**Do Today**

**Move to Tomorrow**

**Skip**

The system should remain simple.

---

## 23. Subjects

The app contains:

### Physics

Learn → Questions → PYQs → Revision → Test

### Chemistry

Learn → Questions → PYQs → NCERT → Revision

Rotate:

* Physical Chemistry
* Organic Chemistry
* Inorganic Chemistry

### Biology

NCERT → Recall → MCQs → PYQs → Revision

---

## 24. Revision

The app should automatically remind the student about revision.

Suggested revision cycle:

```text
Day 0
Learn

Day 1
Quick Revision

Day 3
Questions + PYQs

Day 7
Weekly Revision

Day 14
Second Revision

Day 30
Monthly Revision
```

The student should not have to manually calculate revision dates.

---

## 25. Simple Progress

The app should not become an advanced analytics system.

Show:

```text
PREPARATION

Physics
███████░░░ 70%

Chemistry
██████░░░░ 60%

Biology
████████░░ 80%
```

And:

### This Week

* Study sessions completed
* Questions solved
* Chapters completed
* Revision sessions completed
* Basic study time

The focus should be on **consistency and learning**, not maximizing hours.

---

## 26. Test Tracking

The student can record test results.

Example:

```text
NEET TEST #01

Physics      110
Chemistry    132
Biology      298

TOTAL        540
```

Record mistakes:

* Concept not known
* Forgot concept
* Calculation mistake
* Misread question
* Silly mistake
* Guess

Mistakes can later become revision items.

---

## 27. Customizable Timetable

The default timetable should be editable.

The student can:

* Change time
* Change subject
* Change topic
* Change activity
* Add a session
* Delete a session
* Move a session
* Change break duration
* Change sleep time

---

## 28. Edit Today vs Weekly Schedule

Provide:

### Edit Today

Changes only today's timetable.

### Edit Weekly Schedule

Changes the recurring schedule.

Also provide:

### Restore Default Timetable

Returns to the original timetable.

---

## 29. Distraction-Free Design

The app itself must not become a distraction.

Avoid:

* Social feeds
* Chat
* Leaderboards
* Excessive gamification
* Unnecessary animations
* Excessive motivational messages
* Unnecessary notifications
* Complex productivity systems

Focus on:

**Study → Rest → Journal → Sleep**

---

## 30. Desktop Focus Mode

Windows should support a distraction-free study window.

Example:

```text
┌───────────────────────────┐
│                           │
│          PHYSICS          │
│     Current Electricity   │
│                           │
│          42:31            │
│                           │
│        [ PAUSE ]          │
│                           │
│      Stay focused.        │
│                           │
└───────────────────────────┘
```

Optional full-screen focus mode.

---

## 31. Notifications

### Morning

> ☀️ Good morning.

> NEET 2027 — 287 days left.

### Study reminder

> 🔔 Physics starts in 10 minutes.

### Session start

> 🔵 Time to study Physics.

### Session end

> ⏰ Physics complete. Take a break.

### Break end

> 🔔 Break complete. Chemistry is next.

### Revision

> 🔁 Biology revision is due today.

### Night

> 🌙 Finish your journal and prepare for tomorrow.

### Sleep

> 😴 Time to sleep.

Notifications should be configurable.

---

## 32. Navigation

## Mobile

```text
Today
Timetable
Journal
Progress
```

## Desktop

```text
🏠 Today

📅 Timetable

📔 Journal

📊 Progress

────────────

⚙ Settings
```

Pomodoro is **not a separate navigation tab**.

It starts from a timetable activity.

---

## 33. Technology Stack

### Framework

Flutter

### Language

Dart

### Platforms

* Android
* Windows

Architecture should remain compatible with:

* macOS
* Linux

### State Management

Riverpod

### Local Database

SQLite + Drift

### Notifications

Flutter local notification system

### Scheduling

Platform-supported alarm/scheduling functionality

### UI

Material 3

---

## 34. Offline-First

The following should work without internet:

* Timetable
* Pomodoro
* Break timer
* Notifications
* Journal
* Pending work
* Revision
* Countdown
* Progress
* Settings

Cloud features are not required for the first version.

---

## 35. Basic Data Model

Keep the database simple.

```text
User
Exam

Subject
Chapter

Timetable
TimetableSlot

StudySession
JournalEntry

PendingTask
Revision

Test
Mistake

AppSettings
```

---

## 36. MVP Features

## P0 — Required

* Flutter Android + Windows
* Default timetable
* Monday–Saturday subject rotation
* Sunday recovery day
* Customizable timetable
* Today screen
* NEET countdown
* Study sessions
* Pomodoro timer
* Break timer
* Study notifications
* Rest notifications
* Sleep reminder
* Distraction-free focus mode
* Daily journal
* Learned-today section
* Pending work
* Simple progress
* Revision reminders

## P1 — Later

* Test tracking
* Mistake tracking
* PYQ tracking
* Weekly reports
* Desktop tray
* Widgets
* Backup

## P2 — Future

* Cloud sync
* AI planning
* AI journal summaries
* Advanced analytics
* Advanced mock-test analysis

---

## 37. Core User Flow

```text
OPEN APP
    ↓
TODAY
    ↓
WHAT SHOULD I STUDY?
    ↓
START STUDY
    ↓
FOCUS MODE
    ↓
POMODORO
    ↓
SESSION COMPLETE
    ↓
TAKE BREAK
    ↓
NEXT SESSION
    ↓
WHAT DID I LEARN?
    ↓
WHAT IS PENDING?
    ↓
DAILY JOURNAL
    ↓
SLEEP
    ↓
NEXT DAY
```

Sunday:

```text
SUNDAY
   ↓
RECOVERY
   ↓
OPTIONAL LIGHT REVISION
   ↓
REST
   ↓
WEEKLY REFLECTION
   ↓
PLAN NEXT WEEK
   ↓
SLEEP
   ↓
MONDAY
```

---

## 38. Product Rules

### Rule 1

**The timetable guides; it does not force.**

### Rule 2

**Sleep and recovery are part of NEET preparation.**

### Rule 3

**Sunday is a protected recovery day.**

### Rule 4

**Pomodoro starts directly from the timetable.**

### Rule 5

**Every study session should end with an opportunity to record learning and pending work.**

### Rule 6

**The app should minimize distractions.**

### Rule 7

**Never shame the student for missing a session.**

### Rule 8

**Don't optimize for maximum study hours. Optimize for sustainable consistency.**

---

## 39. Final Product Definition

> **NEET Journal is a simple Flutter-based NEET preparation companion that turns a student's timetable into a daily guided routine. It tells him what to study, starts a focus timer when he begins, reminds him to take breaks, records what he learned and what remains pending, tracks his NEET countdown and preparation progress, and gives him Sunday as a dedicated recovery day.**

The goal is not to make him study every possible hour.

The goal is:

> **Study consistently. Focus properly. Rest properly. Learn every day. Recover every week. Keep moving toward NEET 2027.**
