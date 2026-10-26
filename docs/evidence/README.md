# Evidence index

These files are the raw outputs behind the claims in the top-level README. The
snapshot was generated on 26 October 2026 for this working tree. It is evidence
of one run, not a CI gate.

| File | What it proves | Notes |
|---|---|---|
| `flutter_analyze.txt` | `flutter analyze` found no issues. | Full output; ends with `No issues found!`. |
| `flutter_test.txt` | `flutter test` passed all 81 tests. | Ends with `+81: All tests passed!`. |
| `gitleaks.txt`, `gitleaks.json` | `gitleaks detect` scanned the git history and found no leaks. | History scan for this revision. |
| `osv_scanner.txt` | OSV scanned `pubspec.lock`; no known vulnerabilities. | Run from a neutral path outside the developer home directory. |
| `proxy_tests.txt` | The Cloudflare Worker test suite passed 22/22. | Includes allowlist, install token, rate limit, body cap, content-type checks, the product/provider output filter, the `systemInstruction`/`contents` split and the `/feedback` route. |
| `curl_checks.txt` | Live requests to a temporary Worker returned `405`, `401`, `400`, `415`, `413` and `500` as expected. | Host is redacted. The `500` is the keyless temporary build saying the Gemini secret is not configured, not a successful tip. |
| `apk_build.txt` | `flutter build apk --release` produced a 60.9 MB APK (63,899,920 bytes). | Includes Gradle/DWARF warnings, not failures. |
| `apk_manifest.txt` | Release manifest: package `za.co.zaka.zaka`, `INTERNET`, `allowBackup=false`, min SDK 24, target SDK 36. | Also shows the launcher activity and supported ABIs. |
| `apk_signing.txt` | The release APK is signed with the Android debug certificate. | This is a demo build, not a Play Store signing key. |
| `apk_sha256.txt` | SHA-256 of `release/zaka-0.1.0.apk`: `1c46a1683c81107ef40833a47e65fc8b710e9456c562af66f1a50a251fdb118c`. | Hash matches the file linked from the README. |
| `logcat_clean.txt` | On-device flow: launch, sample data, R100 add, R35 taxi spend, Activity, Accounts, Account screen, feedback form, Privacy policy, About/Licences, Privacy & Ask Zaka, background/re-lock and Delete everything. | Filtered to the Zaka package. Device/app-inventory lines and adbd/IME input lines were removed, so no email, password or installed-app list appears. |
| `device_screenshot.png` | Portrait dashboard with the sample statement: R625 total and a five-day runway. | Light theme, 1220×2712. |
| `device_light.png` | The same build after adding R100 and logging a R35 taxi: R690 total, five-day runway. | Light theme. |
| `device_dark.png` | The same state as `device_light.png` in dark theme. | Confirms the theme switch on the phone. |

The on-device run used a 1220×2712 Android 16 phone with the release APK,
installed with `adb install -r`, with app data cleared first. The run covered the
full smoke test including app-lock background re-lock, feedback form, privacy
screens and delete everything.

Not in this folder: a web build, a production-signed APK, a real Google OAuth
login, a central user directory, or a paid checkout. Those are Roadmap items in
the README and are not claimed as verified.
