# Accounts and cloud progress

## Implemented in this branch
- Local pilot identity generated on first launch and stored in `user://player_identity.json`.
- Display-name validation (1–24 characters).
- Offline mode remains available.
- Settings persistence with audio sliders, language, subtitles, camera sensitivity, touch preference, reduced-motion and analytics opt-in (default off).
- Cloud sync state interface and a deliberate fail-closed stub: it does not upload anything until a backend and provider SDK are configured.
- Account manager contains an integration seam for a verified Google provider identity; it does not handle passwords or pretend OAuth succeeded.

## Google sign-in is NOT yet live
For Google authentication, configure a trusted OAuth provider (Supabase Auth or platform Google/Play Games SDK), registered callback/redirect URI, consent screen, server-side identity verification and a platform-specific Godot integration. Google credentials and access tokens must never be entered in chat, committed to Git, or stored in the game save. Do not put service-role secrets in the client.

## Cloud save requirements before enabling
- Server verifies identity and ownership for every profile.
- Row-level security denies access to other players' data.
- Versioned schema migrations and validated payloads.
- Conflict resolution: server revision + updated timestamp; retain local backup, never overwrite local progress with an invalid or older payload.
- Explicit opt-in for cloud sync and account unlinking.
- HTTPS, deletion/export path, rate limits and server logs without secrets.
- Online community features disabled until moderation/report/block and privacy controls are implemented.

## Release gate
This is architecture groundwork, not a working Google OAuth integration or cloud backend. Verify on desktop and Android after selecting/configuring the provider SDK and backend. A trusted adult should help with account/provider setup and age/consent requirements.
