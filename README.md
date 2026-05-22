# One Hand Practice

Practice **any Beat Saber map** with only **one hand**. Filters out the opposite-color notes, keeps bombs and walls in place, hides the off-hand saber, and recalculates your percentage over the notes that actually played. Submission to leaderboards is disabled automatically while the filter is active so your real ranks stay clean.

<p align="center">
  <img src="docs/screenshots/gameplay-setup-tab.png" alt="One Hand tab in Gameplay Setup" width="640" />
</p>

---

## Why use this?

If a hard pattern fails because your weaker hand is off-sync with the stronger one, drilling that hand alone over a real map (instead of mentally ignoring half the notes) makes the practice clean:

- The other hand's cubes don't get in the way of your active saber.
- The opposite saber is hidden — you can't accidentally bomb-hit yourself with it.
- Percentage at the end reflects what you actually played, not score / total-notes-in-map.

---

## Requirements

- **Beat Saber 1.39.1** (Steam or Oculus PC).
- These mods (BSManager installs them automatically as dependencies):
  - BSIPA 4.3.6+
  - BeatSaberMarkupLanguage (BSML) 1.12.4+
  - SiraUtil 3.1.14+
  - BS Utils 1.14.2+

Newer Beat Saber versions are not supported in this release. 1.40 → 1.43 support is planned.

---

## Install

### Easiest — via BSManager *(once approved on Lunar Mods / BeatMods)*

1. Open **BSManager**.
2. Pick your Beat Saber 1.39.1 install.
3. Go to **Mods** → search **One Hand Practice** → click **Install**.
4. Launch the game.

That's it. BSManager pulls dependencies automatically.

> **Status:** pending approval on Lunar Mods. Until then, use the manual install below.

### Manual install

1. Make sure the dependencies above are installed (use BSManager to install them if you don't have them).
2. Download `OneHandPractice-0.1.0-bs1.39.1.zip` from the [latest release](../../releases/latest).
3. Extract the zip **into your Beat Saber folder** (the one with `Beat Saber.exe`). The zip is structured so it drops `OneHandPractice.dll` straight into your `Plugins\` folder.
4. Launch the game.

If extraction didn't put the file in the right place, you can manually copy `OneHandPractice.dll` into `<Beat Saber>\Plugins\`.

---

## Usage

1. Launch Beat Saber, enter **Solo**.
2. In the panel on the left side of the song list, switch the top tab to **Mods**.
3. Find the **One Hand** tab. Mod tabs paginate three at a time — use the **left / right arrows** to find it (its position depends on how many mods you have installed).

   <p align="center">
     <img src="docs/screenshots/gameplay-setup-tab.png" alt="One Hand tab in Gameplay Setup" width="520" />
   </p>

4. Pick **Left**, **Right** or **Off** from the dropdown.

   <p align="center">
     <img src="docs/screenshots/dropdown-open.png" alt="Hand dropdown open" width="520" />
   </p>

5. Pick a song and play. Only the selected hand's notes will spawn, and the other saber disappears.

Your choice persists between sessions.

---

## What gets filtered, what doesn't

| Item | Filter behavior |
|---|---|
| Notes of the active hand | Kept |
| Notes of the opposite hand | Removed |
| Arcs / chains starting on the active hand | Kept |
| Arcs / chains starting on the opposite hand | Removed |
| Bombs | **Kept** — keep training avoidance |
| Walls / obstacles | **Kept** |
| Lights, BPM changes, color events | Untouched |

Modes where the filter is **always off** (so nothing breaks):

- Multiplayer
- Campaign (official + Custom Campaigns)
- Party mode

Solo standard play is the only place the filter applies.

---

## Troubleshooting

**I don't see the One Hand tab in the gameplay setup panel.**
- Make sure all dependencies (BSML, SiraUtil, BS Utils) are installed and at the right version.
- Confirm `OneHandPractice.dll` is in `<Beat Saber>\Plugins\`.
- Check `<Beat Saber>\Logs\_latest.log` for a line like `[One Hand Practice] OneHandPractice loaded`. If it isn't there, the plugin failed to load — usually a missing dependency or wrong game version.

**Score percentage looks wrong.**
- It isn't: it's calculated over the notes that actually spawned. If you cleared all the filtered notes, you should see ~100% (cut quality permitting).
- The PP shown by mods like PP Predictor / PPCounter will look inflated because they don't know about the filter. Since submission is disabled, those PP numbers never leave your machine.

**BeatSaviorUI shows "Default Text" on its results panel (often for both hands).**
- BeatSaviorUI's post-play stats binding gives up when the chart it sees doesn't match what it expected — and our filtered chart triggers that. Not a bug in this mod and nothing here can fix it cleanly without patching BSU itself.
- Your in-game score / rank / percentage on the standard results screen are still correct.

**My run wasn't submitted to ScoreSaber / BeatLeader / official leaderboard.**
- Correct, that's the point. The filter changes the chart from what was ranked, so submitting would create false scores. Turn the filter to **Off** to play normally.

**Combo ramps to x8 multiplier faster than usual.**
- Expected. With half the notes, fewer hits are needed to reach the multiplier ceiling.

---

## For developers

Want to build from source, contribute, or fork this for another Beat Saber version?

### Building

Requires **.NET SDK 8 or 9** and a Beat Saber 1.39.1 install.

```powershell
$env:BeatSaberDir = "D:\path\to\Beat Saber"
dotnet build OneHandPractice.sln -c Release
```

`BeatSaberModdingTools.Tasks` resolves game references via the `BeatSaberDir` env var and drops the built DLL into `<Beat Saber>\Plugins\` automatically.

### Tests

```powershell
dotnet test OneHandPractice.Tests/OneHandPractice.Tests.csproj
```

The filter logic is pure-function and fully unit tested — no Beat Saber DLLs needed to run the test suite.

### Building a release artifact

```powershell
pwsh release.ps1
```

Produces `dist\OneHandPractice-<version>-bs1.39.1.zip` ready to attach to a GitHub Release.

### Architecture sketch

- `Configuration/Hand.cs`, `HandSelection.cs`, `PluginConfig.cs` — typed enum, in-memory state, BSIPA-persisted config.
- `Services/NoteFilterService.cs` — pure filter predicate, no game dependency.
- `Services/ScoreSubmissionGate.cs` — wraps BS_Utils `ScoreSubmission.DisableSubmission`.
- `Services/GameModeGate.cs` — tracks active scene mode (Solo / Party / Multiplayer / Mission).
- `HarmonyPatches/BeatmapDataFilterPatch.cs` — postfix on `BeatmapDataTransformHelper.CreateTransformedBeatmapData`. Filters via `IReadonlyBeatmapData.GetFilteredCopy`.
- `HarmonyPatches/SaberHidePatch.cs` — postfix on `SaberManager.Start` — disables the off-hand saber GameObject.
- `HarmonyPatches/GameModeCapturePatch.cs` — prefix on every `*LevelScenesTransitionSetupDataSO.Init` to capture the active mode.
- `UI/OneHandSettings.bsml` + `OneHandSettingsViewController.cs` — Gameplay Setup tab.

### Translation / localization

All user-visible strings live in `Resources/Strings.cs`. To add another language, duplicate that class behind a switch on `CultureInfo.CurrentUICulture` or wire up [SiraLocalizer](https://github.com/Auros/SiraLocalizer) — both paths are designed for.

---

## License

[MIT](LICENSE) — do whatever, attribution appreciated.
