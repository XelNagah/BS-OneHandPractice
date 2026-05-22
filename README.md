# One Hand Practice

Beat Saber mod that filters a beatmap down to a single hand (left or right) so you can drill that hand's patterns in isolation. Submission to leaderboards is automatically disabled while the filter is active to avoid polluting your ranks with half-played maps.

## Why

Some patterns only fail because of synchronisation — the dominant hand carries the timing while the off hand never catches up. Playing the off hand alone over a real map (instead of ignoring half the notes manually) makes that practice clean: no blue cubes in the way of your red saber, no friendly fire from notes you didn't intend to hit, and the percentage at the end of the song reflects what you actually played.

## Features

- Drop one hand's notes, sliders (arcs) and burst sliders (chains) from any beatmap.
- Bombs and walls are kept — you still train avoidance.
- Percentage and score recalculate over the remaining notes so 100% means 100% of what was on screen.
- Submission to ScoreSaber, BeatLeader and the in-game leaderboard is disabled automatically while the filter is active. Re-enables itself per play once you turn the filter off.
- Active only in Solo. Party / Multiplayer / Campaign / Custom Campaigns leave the beatmap untouched.

## Requirements

- Beat Saber **1.39.1**
- BSIPA `^4.3.6`
- BeatSaberMarkupLanguage (BSML) `^1.12.4`
- SiraUtil `^3.1.14`
- BS Utils `^1.14.2`

Older or newer Beat Saber versions are not supported in this release. Migration to 1.40+ and 1.43 is on the roadmap.

## Install

### BSManager (recommended once published)

Will be available under BS 1.39.1 mods. Pick `One Hand Practice`, click install.

### Manual

1. Download `OneHandPractice.dll` from the latest [Release](../../releases).
2. Drop it into `Beat Saber/Plugins/`.
3. Make sure the required dependencies above are also installed.

## Usage

1. Launch Beat Saber, go to song select.
2. Open the gameplay setup panel (gear icon next to the song info).
3. Switch to the `One Hand` tab.
4. Pick `Left`, `Right`, or `Off`.
5. Play. Only the selected hand's notes will spawn.

The choice persists between sessions.

## Behaviour notes

- The blue saber stays visible when filtering to Left — it has nothing to do, but Beat Saber keeps tracking both controllers either way. Purely cosmetic.
- BeatSaviorUI's per-hand accuracy panel will show "Default Text" for the missing hand. Not a bug in this mod, just BSU not finding any cuts to summarise on that side.
- Combo ramps to x8 multiplier slightly faster because there are fewer notes — expected, just a side-effect of cutting half the chart.
- Filter is skipped entirely in Multiplayer, Campaign and Custom Campaigns. Scores there submit normally.

## Building from source

Requires .NET SDK 8 or 9 and a Beat Saber 1.39.1 install.

```powershell
$env:BeatSaberDir = "D:\path\to\Beat Saber"
dotnet build OneHandPractice.sln -c Release
```

`BeatSaberModdingTools.Tasks` will resolve dependencies via the `BeatSaberDir` env var and drop the built DLL into your `Beat Saber/Plugins` folder.

Run unit tests:

```powershell
dotnet test OneHandPractice.Tests/OneHandPractice.Tests.csproj
```

## License

MIT — see [LICENSE](LICENSE).
