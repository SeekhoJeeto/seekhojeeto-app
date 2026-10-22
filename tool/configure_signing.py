"""Patch the generated Android Gradle files to sign release builds with the
keystore described in android/key.properties.

Run after android/ has been scaffolded and android/key.properties written.
Works with both the Groovy and the Kotlin DSL files that `flutter create`
produces. Safe to run more than once.
"""

import pathlib
import sys

ANDROID = pathlib.Path("android")

KTS_HEADER = """import java.util.Properties
import java.io.FileInputStream

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

"""

KTS_SIGNING = """    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

"""

GROOVY_HEADER = """def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

"""

GROOVY_SIGNING = """    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

"""


def find(*names):
    for n in names:
        p = ANDROID / n
        if p.exists():
            return p
    return None


def patch(path, header, signing, debug_ref, release_ref):
    text = path.read_text()

    if "keystoreProperties" not in text:
        text = header + text
        print(f"{path.name}: header added")

    if "signingConfigs {" not in text:
        marker = "buildTypes {"
        idx = text.find(marker)
        if idx == -1:
            print(f"{path.name}: could not find buildTypes block", file=sys.stderr)
            return False
        # Keep the indentation of the buildTypes line.
        line_start = text.rfind("\n", 0, idx) + 1
        text = text[:line_start] + signing + text[line_start:]
        print(f"{path.name}: signingConfigs added")

    if debug_ref in text:
        text = text.replace(debug_ref, release_ref)
        print(f"{path.name}: release build now uses the release signing config")
    elif release_ref in text:
        print(f"{path.name}: release signing already configured")
    else:
        print(f"{path.name}: could not find the signingConfig line", file=sys.stderr)
        return False

    path.write_text(text)
    return True


def main() -> int:
    kts = find("app/build.gradle.kts")
    groovy = find("app/build.gradle")

    ok = True
    if kts:
        ok = patch(
            kts, KTS_HEADER, KTS_SIGNING,
            'signingConfig = signingConfigs.getByName("debug")',
            'signingConfig = signingConfigs.getByName("release")',
        )
    elif groovy:
        ok = patch(
            groovy, GROOVY_HEADER, GROOVY_SIGNING,
            "signingConfig signingConfigs.debug",
            "signingConfig signingConfigs.release",
        )
    else:
        print("No android app Gradle file found.", file=sys.stderr)
        return 1

    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
