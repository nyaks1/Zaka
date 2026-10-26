/// Public support details.
///
/// A monitored email alias is supplied at build time with
/// `--dart-define=FEEDBACK_EMAIL=...` (see `build.local.example.json`). If it
/// is not set, the app points people at the public GitHub Issues page instead
/// of shipping a dead or personal address.
const String feedbackEmail = String.fromEnvironment('FEEDBACK_EMAIL');

const String feedbackIssueUrl = 'https://github.com/nyaks1/Zaka/issues';
const String feedbackNewIssueUrl = 'https://github.com/nyaks1/Zaka/issues/new';
const String feedbackIssueLabel = 'github.com/nyaks1/Zaka/issues';

String get feedbackContact =>
    feedbackEmail.isEmpty ? feedbackIssueUrl : feedbackEmail;

String get feedbackContactLabel =>
    feedbackEmail.isEmpty ? feedbackIssueLabel : feedbackEmail;

/// Kept in one place so the About screen and a bug report agree. Bump this with
/// `pubspec.yaml` when a release is built.
const String appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '0.1.0+1',
);

const String privacyPolicyUrl =
    'https://github.com/nyaks1/Zaka/blob/main/PRIVACY.md';
