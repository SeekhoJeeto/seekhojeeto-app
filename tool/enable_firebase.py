"""Enable the Google Services Gradle plugin for Firebase.

Run after android/app/google-services.json has been placed. Works with both the
Groovy and the Kotlin DSL Android Gradle files that `flutter create` produces.
Safe to run more than once.
"""

import pathlib
import sys

ANDROID = pathlib.Path("android")
GS_VERSION = "4.4.2"
MARKER = "com.google.gms.google-services"


def find(*names):
    for n in names:
        p = ANDROID / n
        if p.exists():
            return p
    return None


def insert_into_plugins(path: pathlib.Path, line: str) -> None:
    text = path.read_text()
    if MARKER in text:
        print(f"{path.name}: already enabled")
        return
    idx = text.find("plugins {")
    if idx != -1:
        at = text.find("\n", idx) + 1
        text = text[:at] + "    " + line + "\n" + text[at:]
    else:
        text = line + "\n" + text
    path.write_text(text)
    print(f"{path.name}: patched")


def main() -> int:
    settings = find("settings.gradle.kts", "settings.gradle")
    app = find("app/build.gradle.kts", "app/build.gradle")
    if not settings or not app:
        print("Android Gradle files not found - skipping Firebase plugin patch.")
        return 0

    kts = settings.name.endswith(".kts")
    if kts:
        insert_into_plugins(
            settings,
            f'id("{MARKER}") version "{GS_VERSION}" apply false',
        )
        insert_into_plugins(app, f'id("{MARKER}")')
    else:
        insert_into_plugins(
            settings,
            f"id '{MARKER}' version '{GS_VERSION}' apply false",
        )
        insert_into_plugins(app, f"id '{MARKER}'")

    print("Firebase plugin enabled.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
