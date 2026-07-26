# Onboarding & Profile

Post-signup wizard that collects a new user's skills, education, languages,
qualifications, and CV/portfolio, then saves it as their `Profile`. Runs once,
right after sign-up, before the user reaches the app shell.

## Where it lives

```
lib/features/onboarding/
├── presentation/
│   ├── screens/
│   │   ├── onboarding_screen.dart          # the 5-step wizard
│   │   └── onboarding_success_screen.dart  # shown after a successful submit
│   ├── widgets/
│   │   ├── selectable_chip.dart
│   │   └── step_progress_bar.dart
│   └── providers/
│       └── profile_providers.dart          # OnboardingDraft + submit logic
├── domain/
│   ├── entities/
│   │   ├── profile.dart
│   │   └── education_entry.dart
│   └── repositories/
│       └── profile_repository.dart
└── data/
    ├── models/profile_model.dart
    ├── datasources/profile_remote_data_source.dart
    └── repositories/profile_repository_impl.dart
```

The read side of a saved profile (viewing/editing after onboarding) lives
separately in `lib/features/profile/`.

## The wizard

`OnboardingScreen` renders 5 steps in an `IndexedStack`, driven by
`OnboardingDraftController.totalSteps`:

1. **Skills** — pick from a preset list or add custom free-text skills.
2. **Education** — institution name, degree/certificate, graduation year.
3. **Languages** — pick from a preset list.
4. **Qualifications** — "employment skills" that make the candidate
   attractive to employers.
5. **Upload** — attach a CV (PDF/DOC/DOCX) and/or portfolio files
   (PDF/PNG/JPG), or dictate a CV out loud via speech-to-text.

Each step has a `canContinue` gate (e.g. skills step requires at least one
selected skill) enforced by `_StepScaffold`, which also renders the
title/subtitle, the step body, and the Continue/Finish button.

### State: `OnboardingDraft`

All in-progress answers live in a single Riverpod `Notifier`,
`OnboardingDraftController` (`onboardingDraftProvider`), rather than
per-screen `setState`. This lets any step read or mutate the same draft and
lets the final step assemble a complete `Profile` without prop-drilling.

Key mutators: `nextStep`/`previousStep`, `toggleSkill`/`toggleLanguage`/
`toggleQualification`, `addCustomSkill`, `setEducationField`, `setCvFile`,
`addPortfolioFile`.

### Speak-your-CV

If a user has no CV file, the upload step offers a mic button
(`speech_to_text`) that records a spoken description of their experience.
The transcript is saved through the same `setCvFile` path as a picked file
(as a plain-text `.txt`), so downstream code only ever deals with
`cvFileId`/`cvFileName` — no separate data model for the spoken case.

### File size limit

Both CV and portfolio pickers reject files over
`AppConstants.maxUploadFileSizeBytes` client-side, showing an error snackbar
immediately. The same limit is re-enforced server-side in
`ProfileRemoteDataSource.uploadDocument`, since documents are stored
base64-encoded in Firestore rather than in object storage.

## Submitting

`OnboardingSubmitController` (`onboardingSubmitControllerProvider`) runs on
Finish:

1. Uploads the CV (if any) and each portfolio file via
   `ProfileRepository.uploadDocument`, collecting their generated file IDs.
2. Builds a `Profile` from the draft (skills, education, languages,
   qualifications, `cvFileId`, `portfolioFileIds`).
3. Saves it via `ProfileRepository.saveProfile`.
4. Marks `users/{uid}.onboardingCompleted = true` via
   `markOnboardingComplete` — this is what the router checks to let the user
   through to the app shell instead of bouncing them back to onboarding.
5. Sends a "Welcome to SomTalent!" notification.

On success the user is routed to `OnboardingSuccessScreen`; on failure the
error is surfaced as a snackbar and the draft is preserved so the user can
retry without re-entering everything.

## Data model

`Profile` (mirrors the `PROFILE` entity in `docs/ERD.md`, stored at
`profiles/{uid}`):

| Field              | Type                  | Notes                                   |
|---------------------|-----------------------|------------------------------------------|
| `uid`               | `String`              | doc ID                                    |
| `skills`            | `List<String>`        |                                            |
| `education`         | `List<EducationEntry>`| institution, degree, graduation year      |
| `languages`         | `List<String>`        |                                            |
| `qualifications`    | `List<String>`        |                                            |
| `cvFileId`          | `String?`             | ID into the `files` subcollection         |
| `portfolioFileIds`  | `List<String>`        | same                                       |
| `headline`          | `String?`             | set later, not part of onboarding         |
| `updatedAt`         | `DateTime?`           |                                            |

`Profile.completenessPercent` scores 20% each for skills, education,
languages, qualifications, and CV presence — this is what drives the
"profile strength" nudge on the dashboard.

Uploaded documents are stored separately, one per doc, under
`profiles/{uid}/files/{fileId}` as `{ fileName, base64Data, sizeBytes,
uploadedAt }`.

## Extending

- **New wizard step**: add a case to the `IndexedStack` in
  `OnboardingScreen`, bump `OnboardingDraftController.totalSteps`, add fields
  + a `canContinueFromX` getter to `OnboardingDraft`, and fold the new data
  into the `Profile` built in `OnboardingSubmitController.submit()`.
- **New preset option list** (skills/languages/qualifications): edit the
  `const` list at the top of `onboarding_screen.dart` — no other changes
  needed, since selection state is just a `Set<String>`.

