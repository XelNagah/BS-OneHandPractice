# API drift across BS versions
Generated: 2026-05-22 10:02

## Type: BeatmapDataTransformHelper

- **BS 1.39.1**: found (DataModels.dll)
- **BS 1.40.8**: found (DataModels.dll)
- **BS 1.43.0**: found (DataModels.dll)

  - 1.39.1: 8 lines      - 1.40.8: 8 lines      - 1.43.0: 8 lines    

## Type: BeatmapData

- **BS 1.39.1**: found (DataModels.dll)
- **BS 1.40.8**: found (DataModels.dll)
- **BS 1.43.0**: found (DataModels.dll)

  - 1.39.1: 8 lines      - 1.40.8: 8 lines      - 1.43.0: 8 lines    

## Type: IReadonlyBeatmapData

- **BS 1.39.1**: found (DataModels.dll)
- **BS 1.40.8**: found (DataModels.dll)
- **BS 1.43.0**: found (DataModels.dll)

  - 1.39.1: 18 lines      - 1.40.8: 18 lines      - 1.43.0: 19 lines    

## Type: NoteData

- **BS 1.39.1**: found (BeatmapCore.dll)
- **BS 1.40.8**: found (BeatmapCore.dll)
- **BS 1.43.0**: found (BeatmapCore.dll)

  - 1.39.1: 77 lines      - 1.40.8: 77 lines      - 1.43.0: 78 lines    

## Type: SliderData

- **BS 1.39.1**: found (BeatmapCore.dll)
- **BS 1.40.8**: found (BeatmapCore.dll)
- **BS 1.43.0**: found (BeatmapCore.dll)

  - 1.39.1: 112 lines      - 1.40.8: 112 lines      - 1.43.0: 114 lines    

## Type: ColorType

- **BS 1.39.1**: found (BeatmapCore.dll)
- **BS 1.40.8**: found (BeatmapCore.dll)
- **BS 1.43.0**: found (BeatmapCore.dll)

  - 1.39.1: 18 lines      - 1.40.8: 18 lines      - 1.43.0: 18 lines    

## Type: ScoreModel

- **BS 1.39.1**: found (DataModels.dll)
- **BS 1.40.8**: found (DataModels.dll)
- **BS 1.43.0**: found (DataModels.dll)

  - 1.39.1: 20 lines      - 1.40.8: 20 lines      - 1.43.0: 20 lines    

## Type: GameplayCoreSceneSetupData

- **BS 1.39.1**: found (Main.dll)
- **BS 1.40.8**: found (Main.dll)
- **BS 1.43.0**: found (Main.dll)

  - 1.39.1: 38 lines      - 1.40.8: 38 lines      - 1.43.0: 35 lines    

## Type: BeatmapDataItem

- **BS 1.39.1**: found (BeatmapCore.dll)
- **BS 1.40.8**: found (BeatmapCore.dll)
- **BS 1.43.0**: found (BeatmapCore.dll)

  - 1.39.1: 22 lines      - 1.40.8: 22 lines      - 1.43.0: 22 lines    

---
## Specific method/field hits per version

### SaberManager.SaberForType

**BS 1.39.1** (0 hits):

**BS 1.40.8** (0 hits):

**BS 1.43.0** (0 hits):

### GetFilteredCopy

**BS 1.39.1** (4 hits):
```
- public BeatmapData GetFilteredCopy(System.Func`2<BeatmapDataItem,BeatmapDataItem> processDataItem)
```
```
- public BeatmapData GetFilteredCopy(System.Func`2<BeatmapDataItem,BeatmapDataItem> processDataItem)
```
```
BeatmapData.GetFilteredCopy(...) -> BeatmapData [DataModels.dll]
```
```
IReadonlyBeatmapData.GetFilteredCopy(...) -> BeatmapData [DataModels.dll]
```

**BS 1.40.8** (4 hits):
```
- public BeatmapData GetFilteredCopy(System.Func`2<BeatmapDataItem,BeatmapDataItem> processDataItem)
```
```
- public BeatmapData GetFilteredCopy(System.Func`2<BeatmapDataItem,BeatmapDataItem> processDataItem)
```
```
BeatmapData.GetFilteredCopy(...) -> BeatmapData [DataModels.dll]
```
```
IReadonlyBeatmapData.GetFilteredCopy(...) -> BeatmapData [DataModels.dll]
```

**BS 1.43.0** (4 hits):
```
- public BeatmapData GetFilteredCopy(System.Func`2<BeatmapDataItem,BeatmapDataItem> processDataItem)
```
```
- public BeatmapData GetFilteredCopy(System.Func`2<BeatmapDataItem,BeatmapDataItem> processDataItem)
```
```
BeatmapData.GetFilteredCopy(...) -> BeatmapData [DataModels.dll]
```
```
IReadonlyBeatmapData.GetFilteredCopy(...) -> BeatmapData [DataModels.dll]
```

### CreateTransformedBeatmapData

**BS 1.39.1** (2 hits):
```
- public static IReadonlyBeatmapData CreateTransformedBeatmapData(IReadonlyBeatmapData beatmapData, BeatmapLevel beatmapLevel, GameplayModifiers gameplayModifiers, System.Boolean leftHanded, EnvironmentEffectsFilterPreset environmentEffectsFilterPreset, EnvironmentIntensityReductionOptions environmentIntensityReductionOptions, BeatSaber.Settings.Settings& settings)
```
```
static BeatmapDataTransformHelper.CreateTransformedBeatmapData(...) -> IReadonlyBeatmapData [DataModels.dll]
```

**BS 1.40.8** (2 hits):
```
- public static IReadonlyBeatmapData CreateTransformedBeatmapData(IReadonlyBeatmapData beatmapData, BeatmapLevel beatmapLevel, GameplayModifiers gameplayModifiers, System.Boolean leftHanded, EnvironmentEffectsFilterPreset environmentEffectsFilterPreset, EnvironmentIntensityReductionOptions environmentIntensityReductionOptions, BeatSaber.Settings.Settings& settings)
```
```
static BeatmapDataTransformHelper.CreateTransformedBeatmapData(...) -> IReadonlyBeatmapData [DataModels.dll]
```

**BS 1.43.0** (2 hits):
```
- public static IReadonlyBeatmapData CreateTransformedBeatmapData(IReadonlyBeatmapData beatmapData, BeatmapLevel beatmapLevel, GameplayModifiers gameplayModifiers, System.Boolean leftHanded, EnvironmentEffectsFilterPreset environmentEffectsFilterPreset, EnvironmentIntensityReductionOptions environmentIntensityReductionOptions, BeatSaber.Settings.Settings& settings)
```
```
static BeatmapDataTransformHelper.CreateTransformedBeatmapData(...) -> IReadonlyBeatmapData [DataModels.dll]
```

### ComputeMaxMultipliedScoreForBeatmap

**BS 1.39.1** (3 hits):
```
- public static System.Int32 ComputeMaxMultipliedScoreForBeatmap(IReadonlyBeatmapData beatmapData)
```
```
- public static System.Int32 ComputeMaxMultipliedScoreForBeatmap(IReadonlyBeatmapData beatmapData)
```
```
static ScoreModel.ComputeMaxMultipliedScoreForBeatmap(...) -> System.Int32 [DataModels.dll]
```

**BS 1.40.8** (3 hits):
```
- public static System.Int32 ComputeMaxMultipliedScoreForBeatmap(IReadonlyBeatmapData beatmapData)
```
```
- public static System.Int32 ComputeMaxMultipliedScoreForBeatmap(IReadonlyBeatmapData beatmapData)
```
```
static ScoreModel.ComputeMaxMultipliedScoreForBeatmap(...) -> System.Int32 [DataModels.dll]
```

**BS 1.43.0** (3 hits):
```
- public static System.Int32 ComputeMaxMultipliedScoreForBeatmap(IReadonlyBeatmapData beatmapData)
```
```
- public static System.Int32 ComputeMaxMultipliedScoreForBeatmap(IReadonlyBeatmapData beatmapData)
```
```
static ScoreModel.ComputeMaxMultipliedScoreForBeatmap(...) -> System.Int32 [DataModels.dll]
```


