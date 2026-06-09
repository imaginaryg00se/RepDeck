# RepDeck

**A workout tracker built around a deck of cards — one set per card, swipe to advance.**

RepDeck turns a training session into a focused, tactile flow: instead of scrolling a spreadsheet of sets, you move through your workout one card at a time. It's a native iOS app I built to power [Continuum](https://sites.google.com/view/continuum-fitness/home), my 1:1 fitness coaching practice — a way to hand clients a structured program that feels less like data entry and more like just *training*.

<p align="center">
  <img src="screenshots/HOME.PNG" width="30%" alt="Today's workout home screen" />
  <img src="screenshots/EXECUTION.PNG" width="30%" alt="Card-based set execution" />
  <img src="screenshots/SUMMARY.PNG" width="30%" alt="Workout summary" />
</p>

---

## Why I built it

I coach clients 1:1, and I kept hitting the same problem: every workout app optimizes for *logging* (a wall of fields to fill in) when what an athlete actually needs mid-set is *focus* — one clear instruction, then the next. RepDeck is my answer. The whole interface collapses to a single card during a workout: the lift, the weight, the reps. Everything else gets out of the way until you're done.

It's also how I think about coaching generally — reduce the cognitive load on the client so the only thing left is the work itself.

## The signature: the deck

During a session, your workout is a stack of cards. Each card is one set. You complete it, swipe, and the next set is in front of you — with a progress bar up top and per-exercise segments filling in as you go. Haptics and animations (not captured in stills) reinforce each completed set.

<p align="center">
  <img src="screenshots/EXECUTION.PNG" width="30%" alt="Set in progress" />
  <img src="screenshots/COMPLETE.PNG" width="30%" alt="Set marked complete" />
</p>

## How it works

**Set up a week.** Build a workout for any day from a searchable exercise library, then configure sets, reps, and weight per exercise. Drag to reorder.

<p align="center">
  <img src="screenshots/SCHEDULE.PNG" width="30%" alt="Weekly schedule with reorderable exercises" />
  <img src="screenshots/ADD.PNG" width="30%" alt="Searchable exercise library" />
  <img src="screenshots/CONFIGURE.PNG" width="30%" alt="Configure sets, reps, and weight" />
</p>

**Train.** The home screen shows today's workout at a glance; slide to begin and you're in the deck.

**Track.** Completed sessions roll up into a summary and a history view filterable by week.

<p align="center">
  <img src="screenshots/HISTORY.PNG" width="30%" alt="Workout history by week" />
</p>

## Features

- Card-based set execution with swipe-to-advance and haptic feedback
- Per-day weekly programming with drag-to-reorder
- Searchable exercise library (barbell / dumbbell / cable / bodyweight variants)
- Per-exercise targets: sets, reps, weight, and notes
- Live workout progress tracking (overall and per-exercise)
- Post-workout summary and week-filterable history

## Tech
 
- **Language:** Swift
- **UI:** SwiftUI
- **Persistence:** SwiftData (local-only; `UUID`-keyed models preserve a CloudKit migration path)
- **Dependencies:** None — no third-party libraries
- **Architecture:** MV (Model-View) — SwiftUI views observe SwiftData models directly via `@Query`, with no separate ViewModel layer
## A few design decisions
 
- **Planned vs. actuals are separate models.** Scheduled targets are never mutated during a workout; completed sessions are logged independently. This keeps program integrity intact and makes intent-vs-actuals comparison possible later.
- **MV over MVVM, on purpose.** With SwiftData's `@Model` and SwiftUI's `@Query`, a ViewModel layer adds ceremony without payoff — views observe models directly, logic lives in the models and computed properties.
- **Built the gestures from scratch.** The slide-to-begin control and the swipe-to-complete card stack are custom — no gesture libraries.

---

*Built solo as the training engine behind Continuum. The card metaphor, the gesture model, and every screen here are mine end to end.*
