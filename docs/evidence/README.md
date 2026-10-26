# Evidence index

These files are the raw outputs behind the claims in the top-level README. The
snapshot was generated on 25–26 October 2026 for this working tree. It is
evidence of one run, not a CI gate.

| File | What it proves | Notes |
|---|---|---|
| `flutter_analyze.txt` | `flutter analyze` found no issues. | Final two lines of the run. |
| `flutter_test.txt` | `flutter test` passed all 77 tests. | Ends with `+77: All tests passed!`. |
| `gitleaks.txt`, `gitleaks.json` | `gitleaks detect` scanned 17 commits and found no leaks. | History scan for this revision. |
| `osv_scanner.txt` | OSV scanned 126 packages from `pubspec.lock`; no known vulnerabilities. | Run through the `/home/nyaks/src/github/Zaka` symlink to this checkout. |
| `proxy_tests.txt` | The Cloudflare Worker test suite passed 11/11. | Includes allowlist, install token, rate limit, body cap and content-type checks. |
| `curl_checks.txt` | Live requests to a temporary Worker returned `405`, `401`, `400`, `415`, `413` and `500` as expected. | Host is redacted. The `500` is the keyless build saying the Gemini secret is not configured, not a successful tip. |
| `apk_build.txt` | `flutter build apk --release` produced a 60.3 MB APK. | Includes Gradle/DWARF warnings, not failures. |
| `apk_manifest.txt` | Release manifest: package `za.co.zaka.zaka`, `INTERNET`, `allowBackup=false`, target SDK 36. | Also shows the launcher activity and supported ABIs. |
| `apk_signing.txt` | The release APK is signed with the Android debug certificate. | This is a demo build, not a Play Store signing key. |
| `apk_sha256.txt` | SHA-256 of the built APK: `03c564fd7435a09036e76f8c9b4172bfecd16440076714d5aa6ad95b00ca60c6`. | Hash is for the APK from `apk_build.txt`. |
| `logcat_clean.txt` | On-device flow: launch, sample data, R100 add, R35 taxi spend, Ask Zaka card, creator sign-up, Users console. | Filtered to the Zaka package. ADB/IME input lines were removed, so no email, password or device account appears. |
| `device_screenshot.png` | Portrait dashboard with the sample statement: R625 total and a five-day runway. | Light theme, 1220×2712. |
| `device_light.png` | The same build after adding R100 and logging a R35 taxi: R690 total, five-day runway. | Light theme. |
| `device_dark.png` | The same state as `device_light.png` in dark theme. | Confirms the theme switch on the phone. |

Device: Xiaomi 24115RA8EG, Android 16, 1220×2712 at density 480. The app was
installed with `adb install -r`; app data was cleared before the smoke test.

Not in this folder: a web build, a production-signed APK, a real Google OAuth
login, a central user directory, or a paid checkout. Those are Roadmap items in
the README and are not claimed as verified.
