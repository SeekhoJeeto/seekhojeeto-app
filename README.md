# Seekho Jeeto — Flutter app

A quiz app for Indian students with **Science**, **Maths** and
**Values & Religion** questions, all available in **13 languages**
(en, hi, bn, mr, te, ta, gu, ur, kn, or, ml, pa, as).

The question bank lives in one place — the `questions.json` file in the
`SeekhoJeeto/seekhojeeto.github.io` repo — which a daily job keeps updating.
This app reads that file at launch, so **new questions appear automatically**
without shipping a new APK. A bundled copy (`assets/questions.json`) is used
when the phone is offline.

## How updates reach the phone

| What changed | New APK needed? |
| --- | --- |
| New questions added to a subject/class | **No** — fetched on next app open |
| A brand new subject added to `questions.json` | **No** — the app lists whatever subjects the file contains |
| App code / UI / new features | Yes — rebuild, and it installs over the old one |

## Rewards and saved progress

- **Points**: +10 for every correct answer, +5 bonus for a perfect quiz.
- **Levels**: every 100 points is a level.
- **Streak**: counts the days played in a row.
- **Daily goal**: answer 20 questions a day.
- **Badges**: First Steps, Perfect 10, Century, On a Roll (3-day streak),
  Week Warrior (7-day streak), Explorer (all three subjects), Goal Getter.

Progress is saved **only for students who log in**, in their own private
document in Cloud Firestore (`users/{uid}`). A guest can play, but their
progress lasts only for that session — the app nudges them to create an
account.

### Privacy

`firestore.rules` lets a signed-in student read and write **only their own**
document, and denies everything else. Because this is enforced on the server,
nobody can see another student's data even if the app is modified. There is no
leaderboard — each student sees only their own points and badges. (A shared
leaderboard could be added later as an opt-in feature.)

## How the pieces fit

| Piece | Role |
| --- | --- |
| `SeekhoJeeto/seekhojeeto.github.io` | Source of truth for `questions.json` (updated daily) |
| This repo | Flutter app source + build automation |
| GitHub Actions | Builds the **release-signed** APK as a downloadable artifact |
| Firebase Auth | Student login / account creation |
| Cloud Firestore | Stores each student's own progress privately |

## Building the APK

GitHub Actions does the build — no Android Studio needed locally.

1. Push to `main`, or open **Actions → Build APK → Run workflow**.
2. When the run finishes, download the **seekhojeeto-apk** artifact.
3. Install `app-release.apk`. Each new build installs over the previous one.

The app id is `com.seekhojeeto.app`.

## Release signing

The build is signed with a real release keystore, so **each new APK installs
straight over the previous one** — no uninstalling. Every build also gets a
fresh, increasing `versionCode` (from the workflow run number).

Keystore and passwords are stored as repository **Actions secrets**:
`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
`ANDROID_KEY_PASSWORD`. Keep a personal backup of the keystore — if it is lost
you can no longer update the app under the same identity.

## Enabling accounts and progress (Firebase)

The app runs without Firebase (guest mode). To turn on accounts **and saved
progress**:

1. Create a project at <https://console.firebase.google.com>.
2. Add an **Android app** with package name `com.seekhojeeto.app`.
3. **Authentication → Sign-in method**: enable **Email/Password**.
4. **Firestore Database → Create database** (start in production mode).
5. Open the **Rules** tab, paste the contents of `firestore.rules`, and
   publish. This is what keeps every student's data private.
6. Download `google-services.json`, base64-encode it, and add it as the secret
   `GOOGLE_SERVICES_JSON_B64`.
7. Re-run the **Build APK** workflow.

## Adding questions or a new subject

Nothing to change in this repo.

- **Questions**: the daily job appends them to `questions.json`; the app picks
  them up on next launch.
- **New subject**: add a new top-level key to `questions.json`. Two shapes are
  supported:

  ```jsonc
  // "classed" (like science / maths)
  "english": { "5": [ /* questions */ ], "6": [ /* questions */ ] }

  // "grouped" (like traditions) - each entry has name/icon/qs
  "gk": {
    "world": { "name": {"en": "World"}, "icon": "\ud83c\udf0d", "qs": [ /* questions */ ] }
  }
  ```
