using HarmonyLib;
using OneHandPractice.Configuration;
using OneHandPractice.Services;

namespace OneHandPractice.HarmonyPatches
{
    // Postfix on BeatmapDataTransformHelper.CreateTransformedBeatmapData. Replaces the result
    // with a filtered copy that drops opposite-hand notes and sliders.
    //
    // Priority Low so we run after other beatmap-data transforms (PracticePlugin etc).
    [HarmonyPatch(typeof(BeatmapDataTransformHelper), nameof(BeatmapDataTransformHelper.CreateTransformedBeatmapData))]
    public static class BeatmapDataFilterPatch
    {
        private static readonly NoteFilterService _filter = new();

        [HarmonyPostfix]
        [HarmonyPriority(Priority.Low)]
        public static void Postfix(ref IReadonlyBeatmapData __result)
        {
            var activeHand = HandSelection.Current;
            if (activeHand == Hand.Off || __result == null) return;

            // Standard scene with gameMode == "Solo" only. Skip Party, Multiplayer, Mission/Campaign.
            if (!GameplayContext.ShouldFilter()) return;

            __result = __result.GetFilteredCopy(item =>
            {
                var (kind, color) = Classify(item);
                return _filter.ShouldKeep(kind, color, activeHand) ? item : null;
            });

            ScoreSubmissionGate.DisableForCurrentPlay();
            Plugin.Log?.Info($"Filter applied (hand={activeHand})");
        }

        private static (BeatmapItemKind, ColorTag) Classify(BeatmapDataItem item) => item switch
        {
            NoteData n   => (BeatmapItemKind.Note,   ToColorTag(n.colorType)),
            SliderData s => (BeatmapItemKind.Slider, ToColorTag(s.colorType)),
            _            => (BeatmapItemKind.Other,  ColorTag.None),
        };

        private static ColorTag ToColorTag(ColorType c) => c switch
        {
            ColorType.ColorA => ColorTag.ColorA,
            ColorType.ColorB => ColorTag.ColorB,
            _                => ColorTag.None,
        };
    }
}
