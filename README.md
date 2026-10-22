# Seekho Jeeto — Flutter app

A quiz app for Indian students with **Science**, **Maths** and
**Values & Religion** questions, all available in **13 languages**
(en, hi, bn, mr, te, ta, gu, ur, kn, or, ml, pa, as).

The question bank lives in one place — the `questions.json` file in the
`SeekhoJeeto/seekhojeeto.github.io` repo — which a daily job keeps updating.
This app reads that file at launch, so **new questions appear automatically**
without shipping a new APK. A bundled copy (`assets/questions.json`) is used
when the phone is offline.

## How the pieces fit

| Piece | Role |
| --- | --- |
| `SeekhoJeeto/seekhojeeto.github.io` | Source of truth for `questions.json` (updated daily) |
| This repo | Flutter app source + build automation |
| GitHub Actions | Builds the APK and attaches it as a downloadable artifact |
| Firebase Auth | Login / account creation (optional, see below) |

## Building the APK

You do **not** need Android Studio on your own machine — GitHub Actions does
the build.

1. Push to `main` (or open **Actions → Build APK → Run workflow**).
2. When the run finishes, open it and download the **seekhojeeto-apk** artifact.
3. Install `app-release.apk` on an Android phone.

The app id is `com.seekhojeeto.app`.

### Building locally (optional)

```bash
flutter create --org com.seekhojeeto --project-name seekhojeeto --platforms=android .
flutter pub get
flutter build apk --release
```

If `flutter pub get` complains about versions, run
`flutter pub upgrade --major-versions` and try again.

## Enabling login (Firebase Auth)

The app runs fine without Firebase (guest mode). To turn on accounts:

1. Create a project at <https://console.firebase.google.com>.
2. Add an **Android app** with package name `com.seekhojeeto.app`.
3. In **Authentication → Sign-in method**, enable **Email/Password**.
4. Download `google-services.json`.
5. In this GitHub repo, open **Settings → Secrets and variables → Actions**,
   add a secret named `GOOGLE_SERVICES_JSON_B64` whose value is your
   `google-services.json` encoded as Base64:

   ```bash
   base64 -w0 google-services.json      # macOS: base64 -i google-services.json
   ```

6. Re-run the **Build APK** workflow. The build now includes Firebase and the
   login screen becomes active.

> Note: `google-services.json` contains a client API key. It ends up inside the
> app either way, but keep it in the secret store rather than committing it.

## Adding more questions

Nothing to change here. The daily job appends new questions to
`questions.json` in the content repo; the app fetches the latest file on each
launch. Just rebuild if you also want the offline bundled copy refreshed.
