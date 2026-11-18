# Account and settings integration status

## Wired into the game runtime
- AccountManager and SettingsManager autoloads are registered in project.godot.
- Account UI overlay is instantiated automatically from AccountUI autoload.
- A local pilot identity is created on first launch, persisted, and shown in the overlay.
- Display-name editing, offline continuation, and persistent settings controls are connected.
- Settings cover master/music/SFX levels, camera sensitivity, subtitles, touch controls and reduced motion.
- SaveManager profile snapshots include account identity and settings snapshots; load restores validated settings.

## Google registration/sign-in is not live yet
The primary button is present and calls AccountManager.begin_google_sign_in(), which clearly reports the provider is not configured. Real Google authentication requires provider setup, callback/deep-link registration, an OAuth-capable Godot platform integration, backend identity verification, and age/consent compliance. Do not put client secrets, service-role keys, passwords, or provider tokens in GitHub/chat. A parent/guardian should assist with provider account and consent configuration.

## Cloud sync
Cloud sync is not enabled; this build intentionally remains local-first. No button claims an upload or authentication occurred. Cloud sync must be added only after backend verification, privacy controls, and tested conflict handling.

## Verification limitation
This branch is source-integrated, but Godot 4.3 was not available to execute parser/runtime tests. Treat CI and device tests as required before merging.
