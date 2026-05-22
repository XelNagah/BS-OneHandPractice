using System.Collections.Generic;
using HarmonyLib;
using OneHandPractice.Configuration;
using OneHandPractice.Services;

namespace OneHandPractice.HarmonyPatches
{
    /// <summary>
    /// Postfix on <c>BeatmapDataTransformHelper.CreateTransformedBeatmapData</c>. Runs after every other
    /// beatmap data transform (priority Low, so PracticePlugin and similar mods have already mutated
    /// the data when we get it). Returns a filtered copy where notes and sliders matching the
    /// non-active hand are removed; bombs, walls and everything else pass through.
    ///
    /// MVP: hand selection is hard-coded to <see cref="Hand.Left"/>. Replaced by config + UI in later phases.
    /// </summary>
    [HarmonyPatch(typeof(BeatmapDataTransformHelper), nameof(BeatmapDataTransformHelper.CreateTransformedBeatmapData))]
    public static class BeatmapDataFilterPatch
    {
        private static readonly NoteFilterService _filter = new();

        [HarmonyPostfix]
        [HarmonyPriority(Priority.Low)]
        public static void Postfix(ref IReadonlyBeatmapData __result)
        {
            var activeHand = HandSelection.Current;
            if (activeHand == Hand.Off || __result == null)
            {
                return;
            }

            if (!GameModeGate.FilterAllowed)
            {
                Plugin.Log?.Info($"[Filter] skipped — mode={GameModeGate.CurrentMode}");
                return;
            }

            // Diagnostic counters.
            int inTotal = 0, inNotes = 0, inSliders = 0, inOther = 0;
            int outTotal = 0, outNotes = 0, outSliders = 0, outOther = 0;
            int droppedNotes = 0, droppedSliders = 0;
            var unknownTypes = new HashSet<string>();

            // Pre-count for diagnostics — iterate the input once.
            foreach (var item in __result.allBeatmapDataItems)
            {
                inTotal++;
                switch (item)
                {
                    case NoteData _: inNotes++; break;
                    case SliderData _: inSliders++; break;
                    default:
                        inOther++;
                        unknownTypes.Add(item.GetType().FullName);
                        break;
                }
            }

            try
            {
                __result = __result.GetFilteredCopy(ProcessItem);

                // Filter actually ran — block submission for this play.
                ScoreSubmissionGate.DisableForCurrentPlay();

                Plugin.Log?.Info(
                    $"[Filter hand={activeHand}] in: total={inTotal} notes={inNotes} sliders={inSliders} other={inOther} | " +
                    $"out: total={outTotal} notes={outNotes} sliders={outSliders} other={outOther} | " +
                    $"dropped: notes={droppedNotes} sliders={droppedSliders}");

                if (unknownTypes.Count > 0)
                {
                    Plugin.Log?.Info($"[Filter] non Note/Slider types in beatmap: {string.Join(", ", unknownTypes)}");
                }
            }
            catch (System.Exception ex)
            {
                Plugin.Log?.Error($"OneHandPractice filter failed: {ex}");
            }

            BeatmapDataItem ProcessItem(BeatmapDataItem item)
            {
                var (kind, color) = Classify(item);
                var keep = _filter.ShouldKeep(kind, color, activeHand);

                if (keep)
                {
                    outTotal++;
                    switch (kind)
                    {
                        case BeatmapItemKind.Note: outNotes++; break;
                        case BeatmapItemKind.Slider: outSliders++; break;
                        default: outOther++; break;
                    }
                    return item;
                }
                else
                {
                    if (kind == BeatmapItemKind.Note) droppedNotes++;
                    else if (kind == BeatmapItemKind.Slider) droppedSliders++;
                    return null;
                }
            }
        }

        private static (BeatmapItemKind, ColorTag) Classify(BeatmapDataItem item)
        {
            switch (item)
            {
                case NoteData note:
                    return (BeatmapItemKind.Note, ToColorTag(note.colorType));
                case SliderData slider:
                    return (BeatmapItemKind.Slider, ToColorTag(slider.colorType));
                default:
                    return (BeatmapItemKind.Other, ColorTag.None);
            }
        }

        private static ColorTag ToColorTag(ColorType c) => c switch
        {
            ColorType.ColorA => ColorTag.ColorA,
            ColorType.ColorB => ColorTag.ColorB,
            _ => ColorTag.None,
        };
    }
}
