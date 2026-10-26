# Third-party notices

## Zaka code

The Zaka source code is released under the MIT licence in [`LICENSE`](LICENSE).

## Zaka name and logo

The **Zaka** name, the **Z logo** and the Android/iOS launcher icon are product
marks of the project author, Nyakallo Masiu. They are **not** covered by the MIT
licence and are not licensed for reuse in another product without written
permission. No trademark registration is claimed in this repository. Confirm
ownership or assignment of the artwork before a commercial launch.

The source artwork is in `assets/logo.png`, `assets/landing.png`,
`assets/launch_logo.png`, `assets/launch_image.png` and the Android mipmaps.
The synthetic demo statement is invented test data, not a real bank statement.

## flutter_boxicons

- Package: `flutter_boxicons` 3.2.0
- Licence: MIT
- Copyright: Copyright (c) 2020 Ahmad Rifa'i
- Upstream: <https://pub.dev/packages/flutter_boxicons>

The Boxicons artwork is also offered under the Boxicons licence; the Flutter
package ships the MIT text above. The app's About → Licences screen
(`showLicensePage`) includes the package's bundled licence text.

## Other packages

The app uses Flutter, Drift, Riverpod, `http`, `csv`, `pdf_document`,
`pdf_graphics`, `file_selector`, `shared_preferences`, `crypto`, `intl` and
their transitive dependencies. Their licence texts are available in the app at
**About → Licences** (`showLicensePage`) and in the pub cache used to build it.
The Cloudflare Worker uses Node's built-in modules only.

## Icons and fonts

The UI uses Boxicons through `flutter_boxicons`; no separate icon font is
bundled. Flutter's default Material fonts and the system font are used for text.
