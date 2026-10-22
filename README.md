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

Because the app reads the JSON itself, the day-to-day "add questions / add a
subject" work needs **no APK at all**. The APK is only rebuilt when the app
itself changes.

## How the pieces fit

| Piece | Role |
| --- | --- |
| `SeekhoJeeto/seekhojeeto.github.io` | Source of truth for `questions.json` (updated daily) |
| This repo | Flutter app source + build automation |
| GitHub Actions | Builds the **release-signed** APK as a downloadable artifact |
| Firebase Auth | Login / account creation (optional) |

## Building the APK

GitHub Actions does the build — no Android Studio needed locally.

1. Push to `main`, or open **Actions → Build APK → Run workflow**.
2. When the run finishes, open it and download the **seekhojeeto-apk** artifact.
3. Install `app-release.apk` on the phone.

The app id is `com.seekhojeeto.app`.

## Release signing

The build is signed with a real release keystore, so **each new APK installs
straight over the previous one** — no uninstalling. Every build also gets a
fresh, increasing `versionCode` (taken from the workflow run number).

The keystore and its passwords are stored as repository **Actions secrets**:

- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

Keep a personal backup of the keystore file and its password. If the keystore
is ever lost you can no longer update the app on Play Store with the same
identity; if it leaks, someone else could sign as you. To rotate it, generate a
new keystore, replace the secrets, and re-run the build.

## Enabling login (Firebase Auth)

The app runs fine without Firebase (guest mode). To turn on accounts:

1. Create a project at <https://console.firebase.google.com>.
2. Add an **Android app** with package name `com.seekhojeeto.app`.
3. In **Authentication → Sign-in method**, enable **Email/Password**.
4. Download `google-services.json`, base64-encode it, and add it as the secret
   `GOOGLE_SERVICES_JSON_B64`.
5. Re-run the **Build APK** workflow.

## Adding questions or a new subject

Nothing to change in this repo.

- **Questions**: the daily job appends them to `questions.json`; the app picks
  them up on next launch.
- **New subject**: add a new top-level key to `questions.json`. The app shows
  any subject it finds. Two shapes are supported:

  ```jsonc
  // "classed" (like science / maths)
  "english": { "5": [ /* questions */ ], "6": [ /* questions */ ] }

  // "grouped" (like traditions) - each entry has name/icon/qs
  "gk": {
    "world": { "name": {"en": "World"}, "icon": "\ud83c\udf0d", "qs": [ /* questions */ ] }
  }
  ```
