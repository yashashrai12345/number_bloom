# Master Game PRD — Number Bloom

**Document type:** Product Requirements Document (Master PRD)  
**Working title:** Number Bloom: Merge Puzzle  
**Product category:** Casual number puzzle  
**Target platform:** Android  
**Technology:** Flutter / Dart  
**Game mode:** Single-player, offline-first  
**Monetization:** Google AdMob ads  
**Target audience:** General audience; content and ad treatment must be suitable for the declared audience and applicable store/policy requirements  
**Build target:** Android release build for Google Play  
**Implementation agent:** Google Antigravity  
**Document status:** Ready for implementation planning; working title and visual identity may be refined before release

---

## 1. Product concept and requirements baseline

### 1.1 Concept statement

**Number Bloom** is a polished, relaxing number-merging puzzle. Players swipe a 4×4 board in four directions to move numbered tiles. Equal tiles merge into a tile with their combined value. The main milestone is to create a **2048** tile, after which players can continue for a higher score or start a new run. Sessions are short, controls are intuitive, progress is saved locally, and the core game remains playable without a network connection.

The product takes broad inspiration from the 2048-style merge puzzle genre. It must have its **own app name, icon, color system, animations, layout, and code**; do not copy another game's branding, artwork, text, or proprietary assets.

### 1.2 Primary player promise

“Pick up in seconds, make satisfying merges, and beat your best score—anywhere, even offline.”

### 1.3 Core loop

1. Open or resume a saved game.
2. Swipe up, down, left, or right.
3. All eligible tiles slide as far as possible in that direction.
4. Each pair of equal tiles can merge at most once in that move.
5. If the board changed, a new tile spawns in an empty cell.
6. The score updates, the move is saved locally, and the player plans the next move.
7. When the board has no valid moves, show the result and offer a new game.
8. When 2048 is reached for the first time, celebrate and allow the player either to continue or to start a new game.

### 1.4 Product assumptions (locked for v1 unless explicitly changed)

- The intended game is a **swipe-to-slide number tile game**, not a drag-and-drop block-placement game.
- The board is 4 columns × 4 rows.
- The main target tile is 2048. The player may continue beyond 2048.
- The game is endless/high-score based rather than a level-select campaign.
- A valid move means the board state changes after applying the requested direction.
- A new tile is spawned only after a valid move.
- New tiles are 2 (90% chance) or 4 (10% chance).
- The core game requires no login, account, server, or network connection.
- Ads need internet access and may not load offline. Ad failure must never block gameplay.
- The first version prioritizes reliable rules, smooth input, a premium visual finish, local save/resume, and safe ad placement over extra game modes.
- The app should be appropriate for a broad audience. Before release, the publisher must correctly declare the intended audience and configure ad treatment, consent, content rating, and store disclosures accordingly.

### 1.5 Product goals

1. Deliver a complete, easy-to-understand number-merging puzzle for Android.
2. Make every legal move deterministic and testable apart from randomized tile spawning.
3. Provide responsive controls and clean merge/movement animations.
4. Preserve the current run and best score across app restarts and device rotation/lifecycle changes where applicable.
5. Keep gameplay functional with airplane mode enabled.
6. Integrate AdMob without covering tiles, intercepting gestures, or interrupting an active move.
7. Produce maintainable Flutter code with clear separation between game rules, UI, local storage, and ads.

### 1.6 Success measures for v1

- 100% of core game-rule unit tests pass.
- 100% of defined acceptance criteria pass before release.
- No known blocker/critical defects at release candidate sign-off.
- No crash or unhandled exception when ads fail to load, the app is offline, or saved data is missing/corrupt.
- On the agreed reference Android device, target 60 FPS during ordinary board movement and transitions; no sustained jank during standard four-direction play.
- A returning player can resume the last active board without losing a completed valid move.
- New players can make their first move without a network connection or account setup.

---

## 2. Scope

### 2.1 Must-have for v1 (P0)

- Flutter Android app with an original visual identity.
- First-launch home screen and a brief swipe tutorial.
- 4×4 board and four-direction swipe controls.
- Correct slide, merge, score, spawn, win, and game-over rules.
- New game, resume game, restart confirmation, and post-win continue option.
- Best score and current run saved locally.
- Settings for sound effects, haptics, theme, and reduced motion (where practical).
- Responsive layout across common Android screen sizes and system display scaling.
- Accessible labels and sufficient contrast for key controls and tile values.
- Banner and interstitial ads integrated using Google Mobile Ads Flutter plugin, with test IDs during development and configuration via a single ads service.
- Graceful behavior if the network, ad SDK, or ad inventory is unavailable.
- Automated unit tests, widget tests, and a release checklist.

### 2.2 Should-have for v1 (P1)

- Light, dark, and system theme options.
- Subtle haptics on merge, respecting the settings toggle and device support.
- Local stats: games played, total merges, highest tile, and best score.
- Small, polished tile-merge and win animations.
- An optional sound toggle; no audio asset may be required to play.

### 2.3 Explicitly out of scope for v1

- Online multiplayer, leaderboards, accounts, cloud saves, or server APIs.
- Daily challenges that require a server.
- Purchases, subscriptions, premium currency, loot boxes, or paid power-ups.
- Multiple game modes, large level campaigns, or user-created levels.
- Push notifications.
- Mandatory sign-in or a network-based tutorial.
- Custom analytics backend. The MVP should not add a separate analytics SDK unless later approved.
- Guaranteed ad display. Ad availability and fill are outside the app's control.

### 2.4 Release scope interpretation

“Offline” applies to the playable puzzle, local state, settings, and stats. Ads are a network-dependent monetization layer. The app must remain usable when offline, with ad placements hidden or empty and no repeated error dialogs.

---

## 3. Target users and use cases

### 3.1 Audience

Casual players of varied ages who want an easy-to-learn, low-pressure puzzle. The game must not depend on fast reflexes, reading long instructions, or constant connectivity.

### 3.2 Primary use cases

- **UC-01 — Start quickly:** A new player launches the app and reaches a playable board in one or two taps.
- **UC-02 — Learn by doing:** A first-run hint demonstrates a swipe; the player can dismiss it.
- **UC-03 — Play offline:** A player starts, continues, finishes, and restarts games in airplane mode.
- **UC-04 — Resume safely:** A player closes or backgrounds the app and later resumes the same board and score.
- **UC-05 — Beat a record:** The game retains the best score even after a new game begins.
- **UC-06 — Reach 2048:** A first 2048 tile triggers a clear win moment, then permits continued play.
- **UC-07 — Recover from game over:** The player sees the final score and can immediately start another run.
- **UC-08 — Configure comfort:** The player can disable haptics/sounds, choose a supported theme, and reduce motion.

---

## 4. Gameplay specification

### 4.1 Board representation

- Board size: 4 rows × 4 columns, exactly 16 cells.
- Each cell contains either no tile or a positive power-of-two tile value.
- The initial board has two tiles in two distinct randomly selected empty cells.
- Initial tile values use the same distribution as normal spawns: 2 with 90% probability, 4 with 10% probability.
- The board must never contain more than 16 tiles.
- The core engine must use a testable random-number provider so tests can reproduce tile placements and values.

### 4.2 Directional movement

The player may swipe left, right, up, or down. Tapping a direction control is not required in the standard UI, but the movement engine must expose all four directions for unit tests.

For every move:

1. Take a snapshot of the current board.
2. Process each row or column toward the chosen edge.
3. Remove empty cells from each line while preserving the relative order of non-empty tiles.
4. Merge equal adjacent values in the movement direction, starting from the destination edge.
5. A tile created by a merge cannot merge again during that same move.
6. Pad the remaining line with empty cells on the far edge.
7. Compare the resulting board with the snapshot.
8. If the board did not change, reject the move: do not spawn a tile, change score, increment the move count, or create a save checkpoint.
9. If the board changed, apply the new board and merge score, then spawn exactly one tile in a random empty cell unless the game is in a terminal state that prevents further moves.

### 4.3 Merge rules and examples

- Two tiles of value `n` merge into one tile of value `2n`.
- A tile may participate in at most one merge per move.
- A merge adds the resulting tile value to the score.
- The same move may produce multiple merges in different cells/lines.
- Merging does not happen across rows or columns.

Expected examples (empty cells are shown as `.`):

| Before, moving left | After slide/merge, before spawn | Score added |
|---|---|---:|
| `[2, 2, ., .]` | `[4, ., ., .]` | 4 |
| `[2, 2, 2, 2]` | `[4, 4, ., .]` | 8 |
| `[2, 2, 4, .]` | `[4, 4, ., .]` | 4 |
| `[4, 4, 8, .]` | `[8, 8, ., .]` | 8 |
| `[2, ., 2, 4]` | `[4, 4, ., .]` | 4 |
| `[2, 4, 8, 16]` | unchanged | 0; move invalid if whole board is unchanged |

Implementation detail: The result in the table is the deterministic movement/merge result before the new random tile is spawned. Use such pre-spawn results for unit tests.

### 4.4 Tile spawning

- Spawn one tile after every valid move.
- Never spawn after an invalid move.
- Choose uniformly from the currently empty cells.
- Spawn value: 2 with probability 90%; 4 with probability 10%.
- Never overwrite an occupied cell.
- If there is no empty cell after a valid movement, do not spawn; evaluate win/game-over state against the resulting board.
- Random selection must be injected into the engine and replaceable by a deterministic fake in tests.

### 4.5 Score and statistics

- Initial current score: 0.
- Current score increases by the value of each newly created merged tile.
- Score never decreases during ordinary play.
- Best score is the maximum of all saved run scores and current run score.
- Starting a new game resets current score and move count but never resets best score.
- Persist `gamesPlayed`, `totalMerges`, and `highestTile` if stats are implemented; stats must never block gameplay if unavailable.
- Integer types must be used for tile values and score. Guard against overflow with a documented safe maximum or an integer-safe design.

### 4.6 Win condition

- The first time any tile reaches 2048, set `hasWon` and show a celebratory overlay.
- The overlay offers **Continue Playing** and **New Game**.
- Continue Playing dismisses the overlay and preserves the board, current score, and best score. Higher merges remain possible.
- Do not display the initial win overlay again in the same run after the player chooses Continue Playing.
- Reaching 2048 must not automatically end the session.

### 4.7 Game-over condition

The game is over only when:

- all 16 cells are occupied; and
- no two horizontally or vertically adjacent tiles have the same value.

A full board with any valid same-value adjacent pair is not game over, because a merge may still be possible.

At game over:
- Disable directional input.
- Preserve the final board and score.
- Display a result overlay with current score, best score, and a **Play Again** button.
- The interstitial ad system may offer an ad only at a natural transition after the game is finished and only if frequency rules allow it. The ad must never appear while a move is being processed.

### 4.8 New game and restart

- **New Game** starts a board with two tiles and score 0.
- If a non-empty active game would be discarded, ask for confirmation before starting a new game.
- Confirmation buttons must be unambiguous: “Keep Playing” and “Start New Game”.
- After confirmation, clear the old run snapshot and save the new board promptly.
- Best score and long-term stats remain intact.

### 4.9 Input handling

- Use a thresholded horizontal/vertical gesture detector; select the dominant axis to avoid accidental diagonal moves.
- A gesture must map to exactly one move.
- Ignore gestures during an active board transition, modal overlay, game over, or ad overlay.
- Avoid a long press or tiny finger movement triggering a move.
- Provide a fallback input mechanism suitable for accessibility if feasible, such as optional directional buttons in an accessibility-focused control mode; swipes remain the default.
- An invalid swipe should not show an error popup. Optionally use a subtle board feedback effect, but keep the board and score unchanged.

---

## 5. Information architecture and screen requirements

### 5.1 Navigation map

- Launch → Home (or resume prompt for an active saved run).
- Home → New Game → Game.
- Home → Continue → Game, when an active save exists.
- Home → Settings.
- Game → Pause overlay → Resume / Restart / Home.
- Game → Win overlay → Continue Playing / New Game.
- Game → Game Over overlay → Play Again / Home.
- Home, Settings, and result screens may contain a reserved banner-ad area. Ads may not cover gameplay or primary controls.

### 5.2 Splash / startup

Requirements:
- Show a lightweight branded launch state, then Home or Game promptly.
- Do not wait for an ad to load before showing the home screen or making gameplay available.
- Initialize local storage and ads without making ad initialization a hard dependency for starting a run.
- Handle first-launch, saved-game, and corrupt-save paths without a crash.

### 5.3 First-launch tutorial

- One short, skippable overlay explaining: “Swipe to move. Match equal numbers to merge them. Reach 2048.”
- Optionally show one animated directional hint without changing the board.
- Do not force a multi-screen tutorial or account setup.
- Remember that the hint has been dismissed/completed in local settings.
- The tutorial must not cover the board in a way that blocks its dismissal control.

### 5.4 Home screen

Required elements:
- Original app title/logo or wordmark.
- Primary action: **New Game**.
- Secondary action: **Continue** when a resumable active game exists; otherwise hide or disable it clearly.
- Best score.
- Settings button.
- Optional small stats summary.
- Reserved banner slot only if it does not crowd the primary action or appear adjacent to a tappable game button.

Acceptance requirements:
- A new player can start a game in no more than two taps from Home.
- The main action remains visible on common phone heights without scrolling.
- Buttons have accessible labels and touch targets of approximately 48 dp or larger.

### 5.5 Game screen

Required elements:
- Current score and best score in clearly distinct, readable cards.
- A 4×4 square board with consistent spacing and visible tile values.
- Restart and pause/home controls, visually secondary to the board.
- Optional sound/haptics state indicator if useful; avoid HUD clutter.
- Optional banner is **not required during active play**. If later enabled, it must occupy a reserved area outside the board and all controls, and the board must remain fully visible.

Interaction requirements:
- The board responds to swipe input only when input is enabled.
- Tile values remain readable at supported display sizes and system text scaling.
- No board cell is clipped or overlapped by system bars, ads, or overlays.
- The on-screen board remains square and centered within the available safe area.

### 5.6 Pause overlay

- Opens through the pause control and Android Back while a game is active.
- Provides Resume, Restart, and Home.
- Restart and Home must confirm before discarding a meaningful active run.
- Resume closes the overlay without modifying board, score, or move count.
- An app background/resume event must not itself cause the run to restart.

### 5.7 Win overlay

- Shows a celebratory but restrained animation, “2048 reached”, and current score.
- Offers Continue Playing and New Game.
- Does not force an ad before the player can choose Continue Playing.
- Respect reduced-motion settings.

### 5.8 Game-over overlay

- Shows “No moves left” or equivalent clear message.
- Shows final score and best score.
- Offers Play Again as the most prominent action, and Home as a secondary action.
- If an eligible interstitial is shown, it must occur only after the result is already settled and the user has chosen a natural next step; do not mislabel an ad close control as a game button.

### 5.9 Settings screen

Required settings:
- Theme: System / Light / Dark.
- Sound effects: On / Off, if sound is implemented.
- Haptics: On / Off.
- Reduced motion: On / Off.
- Privacy policy link or placeholder configured by the publisher before release.
- App version/build number.

Rules:
- Save each changed setting immediately.
- Defaults must be usable without configuration: System theme, sound on if implemented, haptics on if supported, reduced motion off.
- Theme changes take effect immediately.
- If sound is omitted from v1, do not display a non-functional sound toggle.

---

## 6. Visual and interaction design

### 6.1 Art direction

Use a premium, calm, contemporary mobile-puzzle style. The interface should feel intentional rather than like a default template: generous spacing, rounded but consistent surfaces, restrained shadows, clear hierarchy, smooth tile motion, and a coherent number palette.

The working brand **Number Bloom** may use a subtle “growth/bloom” concept in its logo or merge effects, but visual flourishes must not reduce number readability.

### 6.2 Design tokens

Define tokens centrally; do not scatter raw colors and spacing values through widgets.

- Surface background: warm off-white in light mode; deep charcoal in dark mode.
- Board background: visually distinct from the page surface, with 16 equal cell slots.
- Tile colors: a deliberate palette that increases in visual intensity with tile magnitude.
- Primary action: one strong accent color used consistently for New Game / Play Again.
- Text: high-contrast primary and secondary colors.
- Spacing: use a small consistent scale, for example 4, 8, 12, 16, 24, and 32 logical pixels.
- Corners: one consistent family of medium/large radii rather than arbitrary rounding on every widget.
- Motion: short, purposeful movement and merge-pop transitions; no continuously looping distraction.

Exact hex codes may be chosen by the implementation agent, but must be defined as named design tokens and reviewed consistently across light and dark themes.

### 6.3 Tile palette

Create explicit theme tokens for common values (2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, and above 2048). Values greater than 2048 must still be readable even if they use a fallback palette.

Requirements:
- Tile value must remain legible on its background.
- Do not rely on hue alone to distinguish tiles; the numeric value is always displayed.
- Adjust font size by digit count to prevent clipping.
- Use a consistent fallback for high-value tiles.

### 6.4 Animation requirements

- Movement animation target: approximately 100–180 ms per move.
- Merge emphasis: approximately 100–200 ms, with a subtle scale/fade/highlight effect.
- Win animation: short and dismissible; must not block the buttons.
- Animation must not alter game logic or score timing.
- Lock new swipes during the committed animation or queue only one safe next move; the recommended v1 behavior is to ignore additional swipes until the current animation completes.
- Reduced-motion mode shortens or removes non-essential animations while preserving immediate visual feedback.

### 6.5 Haptics and sound

- Haptic feedback on successful merge is optional but recommended.
- Respect the haptics setting and device capability.
- Haptics are feedback only; they must not be required to understand state.
- Keep sound assets bundled locally if used. No streaming audio.

### 6.6 Accessibility and layout

- Support Android portrait orientation as the primary layout. Landscape may be supported, but must not be required for v1.
- Use safe areas and account for status/navigation bars and display cutouts.
- Avoid overflow on small screens and at 1.3× system font scale; for 4×4 tile values, maintain number legibility and adjust overall layout if necessary.
- Buttons must expose semantic labels and roles.
- Maintain sufficient contrast, including tile-number contrast and disabled states.
- Avoid color-only instructions; all tiles show a number.
- Perform a basic Android Accessibility Scanner pass and manual talkback checks on core navigation and buttons before release.

---

## 7. Offline behavior and local persistence

### 7.1 Offline contract

The following must work without a network connection:
- Launch and navigate to Home.
- Start a new run.
- Play all moves and complete/win/lose a run.
- Resume the current run.
- View and retain best score and local stats.
- Change and retain settings.
- Restart or reset the current run.

Ads are network-dependent. If offline, ad areas may be empty/collapsed or show a neutral placeholder that does not resemble an ad. No blocking retry loops, modal network alerts, or loading screen waiting for ads are allowed.

### 7.2 Persistence requirements

Persist locally:
- Current board values.
- Current score and move count.
- Whether 2048 has already been celebrated in this run and whether Continue Playing was chosen.
- Whether the current run is active/over.
- Best score.
- Games played, total merges, and highest tile if stats are implemented.
- Theme, sound, haptics, reduced motion, and tutorial-dismissed flags.
- Save schema version and last-updated timestamp.

Save after every valid move and after meaningful state changes (new game, win decision, game over, settings change). A debounce of a few hundred milliseconds is acceptable for non-game settings, but game-state commits must not be delayed such that a completed move can be lost on immediate process termination.

### 7.3 Corrupt or incompatible save

- Validate stored schema version and required fields on load.
- If corrupted or unsupported, recover to a safe new game/home state and preserve any independently valid best-score/settings values where possible.
- Never crash or enter an infinite loading state because a save is invalid.
- Do not silently create impossible boards from partial data.
- Add a unit test for missing, malformed, and older-version save data.

### 7.4 Lifecycle handling

- Persist a valid move before or during its completion in a way that cannot save a half-applied logical state.
- On app background/inactive/paused lifecycle events, ensure current committed state is saved.
- On resume, restore the saved board and score. Never spawn a tile solely because the app resumed.

---

## 8. AdMob monetization requirements

### 8.1 Principles

- Ads are supplemental and must not impair the puzzle experience.
- The playable game must work when ads are unavailable.
- Never use real production ad unit IDs during local development or QA; use official test ad IDs.
- Centralize ad configuration and ad lifecycle management in one service. Do not load/display ads directly from board cells or core game logic.
- Use the current supported Google Mobile Ads Flutter plugin and follow its official setup guidance at implementation time.

### 8.2 v1 ad formats

**Banner ads — required**
- Preferred placement: Home and selected non-interactive result/settings surfaces.
- If shown on a game-related screen, use a fixed reserved region separate from the board and controls; never overlay or cover content.
- Use an adaptive banner size appropriate to the available width and screen orientation.
- Dispose of the ad object when its widget is removed or the screen is disposed.
- A failed banner load must leave a clean layout; no endless spinner.

**Interstitial ads — required with frequency limits**
- Only request/display at natural breaks, such as after a completed game when the player chooses to start another run.
- Never show on app launch, during an active run, while a move is animating, or immediately after a merge.
- V1 frequency policy: at most one interstitial per 180 seconds and only after at least one game has ended since the last interstitial. If no ad is loaded or the network is unavailable, continue immediately.
- Avoid a surprise ad between the win overlay and the player's decision to continue playing.
- Interstitial flow must have no effect on score, tile generation, or game state.

**Rewarded ads — not required for v1**
- Do not implement unless it has a specific, transparent player benefit and the product owner approves the additional scope.

### 8.3 Ad lifecycle and failure rules

- Initialize the ads SDK without blocking Home or game creation.
- Track states such as not initialized, loading, loaded, showing, failed, and disposed.
- Prevent multiple full-screen ads from showing simultaneously.
- Dispose of ads correctly and reload when appropriate after dismissal/failure.
- Never claim that an ad was watched or reward the player if rewarded ads are added later and the reward callback did not fire.
- If an ad fails to load or show, log a safe debug message in debug builds, clear the loading state, and continue without an ad.
- Do not use ad failure to reset a run or return the player to Home.

### 8.4 Test configuration and release configuration

- Keep `AdConfig` separate from screen code.
- Debug/test flavor must use official Google test ad unit IDs.
- Release build must use publisher-owned app/ad IDs from configuration, never hardcoded test IDs.
- Before release, verify AdMob app setup, app-ads.txt where applicable, consent/privacy setup, and current Play Console requirements.
- Do not click live ads during testing.

### 8.5 Audience, consent, and privacy

Because the desired audience is broad and may include children:
- The publisher must accurately declare intended audience/age group in Play Console and AdMob.
- Determine whether child-directed, mixed-audience, or general-audience treatment applies and configure SDK/ad requests accordingly; do not guess on the publisher's behalf.
- Use the appropriate consent-management flow for the regions in which the app is distributed and honor the user’s consent/privacy choices where required.
- Ensure the privacy policy and Google Play Data safety answers accurately reflect the SDKs and data practices actually shipped.
- Do not claim “no data collected” merely because the game itself has no account system; ad SDK data practices must be reviewed.
- Ads must be age-appropriate for the declared audience and configured policy requirements.

---

## 9. Technical specification

### 9.1 Required stack

- Flutter stable channel and Dart version compatible with the Flutter release selected at project creation.
- Android-only first release.
- Flutter Material 3 as a foundation, with a custom theme/token layer.
- `flutter_riverpod` (or an equivalent simple, consistently applied state solution) for UI/game state composition. Do not mix multiple competing state-management approaches.
- `shared_preferences` for modest local key-value persistence, with a versioned JSON snapshot for the active game. If complexity grows beyond key-value needs, propose a documented local database migration rather than adding it prematurely.
- `google_mobile_ads` for AdMob, configured through a dedicated ads service.
- Prefer platform APIs and built-in Flutter features before adding new dependencies.
- Select compatible package versions at implementation time; do not blindly copy obsolete version numbers from an old tutorial.

### 9.2 Architecture rules

Separate the app into four main concerns:

1. **Domain/game engine:** pure Dart board operations, move calculation, merge/scoring, random spawn selection, win/game-over detection. Must not import Flutter UI or ads packages.
2. **Application/state:** orchestrates new game, valid moves, save checkpoints, settings, and screen-facing state.
3. **Data/persistence:** owns local save/load, schema validation, and migration/recovery.
4. **Presentation/integrations:** Flutter widgets, animations, haptics, sound, lifecycle hooks, and ads.

The board engine must be testable with unit tests without launching a widget or contacting the network.

### 9.3 Suggested project structure

```text
lib/
  main.dart
  app/
    app.dart
    app_theme.dart
    app_routes.dart
  core/
    constants.dart
    design_tokens.dart
    accessibility.dart
  features/
    home/
      presentation/home_screen.dart
    game/
      domain/
        tile.dart
        board.dart
        move_direction.dart
        move_result.dart
        game_rules.dart
      application/game_controller.dart
      data/game_repository.dart
      presentation/game_screen.dart
      presentation/widgets/game_board.dart
      presentation/widgets/tile_widget.dart
      presentation/widgets/score_card.dart
      presentation/widgets/game_over_overlay.dart
      presentation/widgets/win_overlay.dart
      presentation/widgets/pause_overlay.dart
    settings/
      presentation/settings_screen.dart
      application/settings_controller.dart
      data/settings_repository.dart
    stats/
      presentation/stats_panel.dart
  services/
    ads/ads_service.dart
    persistence/local_store.dart
    lifecycle/app_lifecycle_service.dart
  shared/
    widgets/primary_button.dart
    widgets/confirm_dialog.dart
    widgets/empty_ad_slot.dart
 test/
  unit/
    game_rules_test.dart
    spawn_test.dart
    game_over_test.dart
    persistence_test.dart
  widget/
    home_screen_test.dart
    game_screen_test.dart
    settings_screen_test.dart
    ads_failure_test.dart
 integration_test/
  offline_game_flow_test.dart
```

The implementation agent may adjust this layout if there is a clear reason, but must preserve the separation of concerns.

### 9.4 Domain models

The precise Dart types can be chosen by the implementation agent. At minimum, model the following concepts:

- `Tile`: unique ID for presentation/animation, integer value, logical row and column.
- `Board`: 4×4 logical values, with an immutable or safely copied representation.
- `MoveDirection`: up, down, left, right.
- `MoveResult`: resulting board, whether it changed, score gained, merge count, merged tile positions/values for feedback.
- `GameState`: board, score, best score, move count, `hasWon`, `winOverlayDismissed` or equivalent, `isGameOver`, input lock/animation status, and current run identifier if needed.
- `GameStats`: games played, total merges, highest tile.
- `PlayerSettings`: theme, haptics, sound, reduced motion, tutorial state.
- `SavedGameSnapshot`: schema version, game state, stats and settings as separate concerns where useful, timestamp.

Do not persist transient animation progress. Persist the last committed logical board state.

### 9.5 Game state machine

Supported states:
- `home`
- `playing`
- `animatingMove`
- `wonOverlay`
- `paused`
- `gameOver`

State rules:
- `playing` accepts gestures.
- On a valid move, calculate and commit the logical move, update score and spawn, persist, then animate the transition; do not allow concurrent move calculation to race.
- `animatingMove` ignores extra gestures in v1.
- If the committed result reaches 2048 for the first time, transition to `wonOverlay` after the movement presentation is settled.
- Continue Playing transitions from `wonOverlay` back to `playing` and records that the first-win overlay has been dismissed.
- If no legal move remains, transition to `gameOver`.
- `paused` preserves the run unchanged.
- A new game resets the run-level state but not best score/preferences.

Game-state transitions must be explicit rather than inferred from widget visibility alone.

### 9.6 Local save format

Use a versioned JSON-compatible payload or equivalent. Example conceptual schema (not a required literal wire format):

```json
{
  "schemaVersion": 1,
  "currentGame": {
    "board": [[0, 2, 0, 0], [0, 0, 4, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
    "score": 12,
    "moveCount": 5,
    "hasWon": false,
    "winOverlayDismissed": false,
    "isGameOver": false
  },
  "bestScore": 160,
  "stats": {
    "gamesPlayed": 4,
    "totalMerges": 17,
    "highestTile": 128
  },
  "settings": {
    "theme": "system",
    "hapticsEnabled": true,
    "soundEnabled": true,
    "reducedMotion": false,
    "tutorialSeen": true
  },
  "updatedAt": "ISO-8601 timestamp"
}
```

The example is illustrative. The implementation must ensure that a value of `0` means an empty cell and that the actual schema is validated before use. Do not store ad response objects or SDK state in the game snapshot.

### 9.7 Android configuration

- Use a stable, unique application ID selected by the publisher.
- Set the display name to the chosen release name after branding approval.
- Configure the AdMob application ID correctly in Android manifest metadata according to the official plugin guide.
- Request only permissions that are necessary for the chosen SDK integrations; do not add unrelated permissions.
- Select the current Android target SDK and Gradle configuration required by the current Google Play submission policy and installed Flutter toolchain at release time.
- Test Android Back, app pause/resume, status/navigation bars, and app termination recovery.
- Ensure the release build is signed with the publisher’s release key and document secure key backup; never commit signing secrets to Git.

---

## 10. Non-functional requirements

### 10.1 Performance

- Target 60 FPS during ordinary board motion on a defined reference mid-range Android phone.
- Target movement animation duration: 100–180 ms; merge emphasis: 100–200 ms.
- Target game-engine calculation under 16 ms for a normal 4×4 move on reference hardware.
- Ads must load asynchronously and must not delay board calculation or input initialization.
- Avoid repeated full-screen widget rebuilds when only one tile or score changes; use focused state updates where useful.

### 10.2 Reliability

- No crash on offline startup, failed ad load, failed ad show, missing save, malformed save, app pause/resume, or repeated New Game taps.
- A committed valid move must not be duplicated by rapid gestures.
- App must not spawn a tile on invalid moves or lifecycle resume.
- No tile can visually or logically occupy the same cell as another tile.

### 10.3 Compatibility

- Android phones in portrait orientation.
- Small phones, common modern Android devices, and larger screens.
- Support the minimum Android SDK level chosen by the selected Flutter/plugin versions; document the final minimum before release.
- Work with system light/dark setting and reasonable accessibility font scaling.

### 10.4 Maintainability

- Keep domain logic free of widget dependencies.
- Use meaningful names and small testable methods.
- Avoid giant single-file implementations.
- Add comments for non-obvious merge ordering and game-over logic, not for every line.
- Centralize theme, ad-unit configuration, persistence keys, and game constants.
- Do not suppress analyzer warnings just to obtain a clean build; resolve or explain each suppression.

### 10.5 Privacy and security

- No user account or personal profile is needed.
- Do not add user tracking or analytics beyond SDK behavior without approval.
- Review all dependencies and permissions before release.
- Never place AdMob secrets, signing credentials, or private keys in source control. Ad unit IDs are not secrets, but should still be managed centrally by build configuration.
- Privacy-policy and Data safety disclosures must match the actual shipped SDKs and behavior.

---

## 11. Acceptance criteria (definition of done)

All P0 criteria below must pass before a release candidate is approved.

### 11.1 Game rules

| ID | Acceptance criterion | Verification |
|---|---|---|
| AC-GAME-01 | A new game creates a 4×4 board with exactly two non-empty tiles. | Unit test across deterministic initial-spawn fixtures. |
| AC-GAME-02 | Every tile is a positive power of two; empty cells are represented consistently. | Domain validation tests. |
| AC-GAME-03 | A left move on `[2, 2, 2, 2]` yields `[4, 4, 0, 0]` before spawn, with score gain 8. | Unit test. |
| AC-GAME-04 | A left move on `[2, 2, 4, 0]` yields `[4, 4, 0, 0]` before spawn, with score gain 4; the newly formed 4 does not merge again during that move. | Unit test. |
| AC-GAME-05 | A valid move spawns exactly one tile in an empty cell; an invalid move spawns none. | Injected-random unit tests. |
| AC-GAME-06 | A spawn is a 2 for the deterministic 90% test range and a 4 for the 10% range; production randomness follows the same intended distribution. | Unit test with fake RNG plus code review. |
| AC-GAME-07 | Score increases by each merged output value only; sliding a tile without merging adds no score. | Unit tests. |
| AC-GAME-08 | No tile can merge more than once in a single move. | Edge-case tests for all four directions. |
| AC-GAME-09 | A full board with any equal orthogonal neighbors is not game over. | Unit test. |
| AC-GAME-10 | A full board with no equal orthogonal neighbors is game over. | Unit test. |
| AC-GAME-11 | First reach of 2048 shows the win overlay once per run; Continue Playing allows further moves. | Widget/integration test. |
| AC-GAME-12 | Starting a new run resets current score and move count but preserves best score and settings. | Unit/widget test. |
| AC-GAME-13 | A diagonal gesture maps to one dominant direction or is ignored; it never triggers two moves. | Widget test/manual gesture test. |
| AC-GAME-14 | Rapid repeated gestures cannot commit concurrent or duplicated moves. | Widget/integration stress test. |

### 11.2 Persistence and offline operation

| ID | Acceptance criterion | Verification |
|---|---|---|
| AC-OFF-01 | Airplane mode does not block Home, New Game, movement, game over, or local settings. | Manual offline test. |
| AC-OFF-02 | After a valid move, closing and reopening restores the committed board and score. | Integration test with app restart. |
| AC-OFF-03 | The best score survives starting a new run and a cold restart. | Persistence test. |
| AC-OFF-04 | Returning from background does not reset the board or spawn a tile. | Lifecycle test on device. |
| AC-OFF-05 | Missing/corrupt/unsupported save data leads to a recoverable new state with no crash. | Repository unit tests. |
| AC-OFF-06 | Changing a setting is retained after app restart. | Persistence test. |

### 11.3 User interface and accessibility

| ID | Acceptance criterion | Verification |
|---|---|---|
| AC-UI-01 | A player can start a new game in no more than two taps from Home. | Manual usability check. |
| AC-UI-02 | All 16 cells and tile values fit without clipping on the smallest supported test phone. | Screenshot/manual layout test. |
| AC-UI-03 | Primary touch targets are approximately 48 dp or larger and have semantic labels. | Widget inspection and accessibility test. |
| AC-UI-04 | Light, dark, and system theme work without unreadable text or tiles. | Widget/manual theme tests. |
| AC-UI-05 | Reduced-motion mode disables or shortens non-essential effects without breaking game state. | Widget test. |
| AC-UI-06 | Android Back behaves correctly during play, pause, settings, and overlays. | Manual integration test. |
| AC-UI-07 | No board cell is covered by an ad, score card, or interactive control. | Manual layout test and screenshots. |

### 11.4 Ads

| ID | Acceptance criterion | Verification |
|---|---|---|
| AC-ADS-01 | Debug builds use official test ad unit IDs only. | Inspect configuration and run debug build. |
| AC-ADS-02 | Offline or failed ad requests do not block the app or show a blocking error dialog. | Disable network and run test. |
| AC-ADS-03 | No interstitial appears during active gameplay or while a move is animating. | Ad-service unit/integration test. |
| AC-ADS-04 | Interstitial frequency respects the 180-second cooldown and completed-game requirement. | Injected clock/ad-service tests. |
| AC-ADS-05 | Ads never overlay the board or primary controls. | Device test. |
| AC-ADS-06 | Ad objects are disposed appropriately; returning from an ad resumes the same game state. | Code review and lifecycle test. |
| AC-ADS-07 | Consent, audience treatment, privacy policy, and Data safety disclosures are reviewed before production. | Release checklist sign-off. |

### 11.5 Quality and release

| ID | Acceptance criterion | Verification |
|---|---|---|
| AC-REL-01 | `flutter analyze` completes without unresolved errors; warnings are fixed or documented. | CI/local build log. |
| AC-REL-02 | All unit and widget tests pass. | `flutter test` output. |
| AC-REL-03 | A signed Android App Bundle builds successfully using the selected production configuration. | Release build. |
| AC-REL-04 | No P0/P1 bugs remain open at release-candidate sign-off. | Defect tracker. |
| AC-REL-05 | Play Store assets, content rating, target audience, privacy policy, ads declaration, and Data safety form are complete and truthful. | Publisher checklist. |

---

## 12. Test strategy

### 12.1 Unit tests — mandatory

Prioritize the pure Dart engine. Cover:
- Each direction on empty, sparse, mixed, and full boards.
- Merge ordering and no-double-merge behavior.
- Multiple independent merges in one move.
- Invalid moves.
- Spawn selection and no-overwrite invariant.
- Score increments.
- Win detection on 2048 and tiles above 2048.
- Game-over detection with and without equal adjacent pairs.
- Best-score behavior.
- Serialization/deserialization, missing fields, schema versions, malformed payloads.
- Interstitial cooldown logic using an injected clock.

### 12.2 Widget tests — mandatory

- Home primary and secondary actions.
- Tutorial dismisses and persists completion.
- Board displays 16 cells and correct tile labels.
- Score updates after a known move fixture.
- Win, pause, and game-over overlays expose the correct actions.
- Theme and reduced-motion settings update the presentation.
- Ad placeholders behave correctly when ads are unavailable.

### 12.3 Device and integration tests — mandatory

Test on at least one physical Android phone and one emulator. Include:
- First launch with Wi-Fi/mobile data on and off.
- Play → background app → return → confirm board continuity.
- Play → force-stop → reopen → confirm most recent committed move was saved.
- Win overlay → continue playing → reach game over.
- Full board and no-moves logic.
- Ad load failure and ad dismissal.
- Small screen and larger system font size.
- Repeated restart/new-game taps.

### 12.4 Randomized gameplay soak test

Add a debug/test harness that performs many seeded random moves and validates after each move:
- board remains 4×4;
- every non-empty tile is a power of two;
- occupied count is at most 16;
- score never decreases;
- no invalid move creates a spawn;
- no crash occurs when the game reaches terminal state.

The soak test must be reproducible using a fixed seed when a failure occurs.

---

## 13. Implementation roadmap for Antigravity

Implement in small, verifiable milestones. Do not generate the entire app as one unreviewed code dump.

### Milestone 0 — Inspect and plan

1. Check the repository and existing Flutter installation before creating or replacing files.
2. Identify existing code, assets, package IDs, and unfinished work; do not delete working project files without a reason.
3. Write a short implementation plan and confirm the proposed dependency versions are compatible with the installed Flutter/Android toolchain.
4. Create or update a `README.md` with setup, run, test, and build instructions.

**Exit criteria:** Project structure and dependency choices are documented; no unrelated files are deleted.

### Milestone 1 — Pure game engine

1. Implement board representation and four-direction movement.
2. Implement one-merge-per-tile rules and score calculation.
3. Implement tile spawning with injected random provider.
4. Implement win/game-over checks and new-game generation.
5. Add comprehensive unit tests before building polished UI.

**Exit criteria:** All game-rule examples in this PRD pass as tests; `flutter test` passes.

### Milestone 2 — Playable UI

1. Build the responsive Home screen.
2. Build the 4×4 board and tile widgets.
3. Connect swipes to the tested domain engine.
4. Add score cards, pause, win, game-over, restart, and new-game flows.
5. Add first-run tutorial.

**Exit criteria:** The game is playable end-to-end with mock/no ads and no network.

### Milestone 3 — Persistence and settings

1. Save and load the current run and best score.
2. Add schema validation/recovery.
3. Add theme, haptics, reduced motion, and optional sound settings.
4. Test app lifecycle restore and force-stop/reopen.

**Exit criteria:** Offline save/resume and settings acceptance tests pass.

### Milestone 4 — Polish and accessibility

1. Apply the centralized visual theme and tile palette.
2. Add movement/merge/win animations with appropriate input locking.
3. Verify small screens, contrast, semantic labels, and reduced motion.
4. Tune performance using Flutter DevTools and a physical device.

**Exit criteria:** No overflow/clipped values on supported test devices; motion and input meet defined acceptance targets.

### Milestone 5 — AdMob integration

1. Add the supported Google Mobile Ads Flutter plugin.
2. Add app-ID manifest configuration and a centralized `AdsService`.
3. Implement banner loading/failure/disposal.
4. Implement interstitial eligibility and cooldown using an injectable clock.
5. Use official test IDs in debug/test builds; isolate production IDs in release configuration.
6. Verify the game works with airplane mode and failed ad loads.
7. Review applicable audience, consent, and privacy requirements.

**Exit criteria:** Ad tests pass; offline gameplay remains fully usable; no ad can interrupt active moves.

### Milestone 6 — QA and release build

1. Run `flutter analyze`, unit/widget/integration tests, and the random-move soak test.
2. Test on emulator and physical phone.
3. Build a signed Android App Bundle with release configuration.
4. Verify app name, icon, package ID, version, target SDK, signing, and release ad IDs.
5. Prepare Play Store screenshots, short description, full description, privacy policy, content rating, audience declaration, and Data safety answers.
6. Complete a final regression checklist before submission.

**Exit criteria:** All P0 acceptance criteria pass, no known blocker defects remain, and store disclosures are complete and truthful.

---

## 14. Definition of done and delivery artifacts

Antigravity must deliver:

1. A working Flutter Android project with the code structure described above or a documented equivalent.
2. A pure, tested game rules engine.
3. Home, Game, Settings, Pause, Win, and Game Over UI flows.
4. Local save/resume and best-score persistence.
5. AdMob banner/interstitial integration with debug test IDs and release configuration separated.
6. Automated unit and widget tests; integration tests for offline state continuity.
7. `README.md` with prerequisites, setup commands, run/test commands, ad configuration, and release build commands.
8. `CHANGELOG.md` or milestone notes describing significant implementation decisions.
9. A list of known issues and any acceptance criteria not yet met. Never report a feature as complete unless it is implemented and verified.
10. A signed `.aab` only after the publisher supplies/configures their own signing setup; never invent or embed secret credentials.

### Suggested local commands

Use commands appropriate for the actual project environment and report the outputs:

```bash
flutter doctor
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

The release build may require signing properties, production AdMob configuration, and current Google Play-required Android settings. Do not fabricate successful build/test results; show the real command result and fix errors before declaring completion.

---

## 15. Risk register

| Risk | Impact | Mitigation |
|---|---|---|
| Incorrect merge ordering | Critical gameplay bugs | Implement a pure engine first; use pre-spawn examples as unit tests. |
| Random tile generation makes tests flaky | Hard-to-reproduce defects | Inject a deterministic RNG and seeded soak tests. |
| UI and domain logic become tightly coupled | Slow fixes and regressions | Keep rules in pure Dart and test independently from widgets. |
| Ads block offline use or appear mid-move | Poor user experience | Non-blocking ad service, natural transition points, cooldown tests, offline QA. |
| Misconfigured audience/consent settings | Policy/privacy risk | Publisher review of actual audience, regions, SDK behavior, and current policy. |
| Save corruption loses a run or crashes app | User trust loss | Schema versioning, validation, graceful recovery, persistence tests. |
| Visual effects reduce number readability | Accessibility/usability problems | Contrast tests, adaptive tile type, reduced-motion setting. |
| Flutter or ad plugin versions change | Build/release failure | Select current compatible versions and verify official guidance at implementation time. |

---

## 16. Ready-to-use master prompt for Google Antigravity

Copy the prompt below into Antigravity together with this PRD. Treat the PRD as the source of truth.

> **Role:** Act as a senior Flutter game engineer, mobile UX designer, test engineer, and Android release engineer.
>
> **Task:** Build “Number Bloom: Merge Puzzle”, an original offline-first Android number-merging puzzle in Flutter, according to `Number_Bloom_Master_Game_PRD.md`.
>
> **Non-negotiable rules:**
> 1. Read the complete PRD before editing files. Inspect the existing repository and toolchain first. Preserve existing working code and assets unless a change is justified.
> 2. Implement the pure Dart game engine and its tests before connecting the UI. The domain layer must not import Flutter widgets or ad SDK APIs.
> 3. Follow the exact 4×4 move, merge, scoring, spawn, win, and game-over rules. A tile cannot merge twice in one move; invalid moves must not spawn tiles or change score.
> 4. Keep the game fully playable without internet or ad availability. No account, backend, or cloud service is required.
> 5. Use a polished original design. Do not copy another game's name, icon, assets, artwork, or proprietary code. Keep visual tokens centralized and tile numbers readable.
> 6. Add persistence, settings, lifecycle recovery, and save validation. Persist committed logical state, not animation progress.
> 7. Put AdMob behind one service. Use official test ad IDs in debug builds, never block startup or gameplay on ads, and do not display interstitials during active play. Follow current official Google Mobile Ads Flutter guidance and review audience/consent/privacy requirements before release.
> 8. Work milestone by milestone. After each milestone, run the relevant tests and `flutter analyze`, report actual results, and fix failures before continuing. Do not mark unimplemented features as complete.
> 9. Avoid giant single-file code dumps, placeholder buttons that appear functional, silent exception swallowing, and speculative dependency/version choices. Use compatible versions for the installed Flutter toolchain.
> 10. Before completion, test offline behavior, save/resume after force-stop, all four directions, merge edge cases, game-over logic, win/continue flow, ad failure, small-screen layout, and release configuration.
>
> **Expected outcome:** A maintainable Flutter project, passing automated tests, a clear README, documented ad setup and release steps, and a truthful report listing completed acceptance criteria, failed checks, and remaining risks. Build an Android App Bundle only when release configuration and signing are valid.

---

## 17. Official implementation references

Check these official resources at implementation and release time because package compatibility and platform policies can change:

- Google Mobile Ads Flutter quick start: https://developers.google.com/admob/flutter/quick-start
- Banner ads for Flutter: https://developers.google.com/admob/flutter/banner
- Interstitial ads for Flutter: https://developers.google.com/admob/flutter/interstitial
- Rewarded ads for Flutter (not in v1 scope): https://developers.google.com/admob/flutter/rewarded
- Flutter accessibility testing: https://docs.flutter.dev/ui/accessibility/accessibility-testing
- Flutter testing overview: https://docs.flutter.dev/testing/overview

**Release note:** This PRD is an implementation specification, not a guarantee of ad approval or Play Store approval. The publisher must verify current Flutter/plugin compatibility, Play Console requirements, content rating, ad settings, consent requirements, privacy disclosures, signing, and release assets before submission.
