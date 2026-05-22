using OneHandPractice.Configuration;

namespace OneHandPractice.Services
{
    // Tagged kinds of beatmap items the filter cares about. Decoupled from Beat Saber types
    // so the predicate can be unit-tested without referencing game DLLs.
    public enum BeatmapItemKind { Other = 0, Note = 1, Slider = 2 }

    // Mirror of BeatmapCore.ColorType — kept here so tests don't need a BS reference.
    public enum ColorTag { ColorA = 0, ColorB = 1, None = -1 }

    public class NoteFilterService
    {
        // Returns true to keep the item, false to drop it.
        // Drops only colored notes and sliders whose color is the opposite of the active hand.
        // Bombs (ColorTag.None), walls and everything else are always kept.
        public bool ShouldKeep(BeatmapItemKind kind, ColorTag color, Hand activeHand)
        {
            var activeColor = activeHand.ToColorTag();
            if (activeColor == null) return true;

            switch (kind)
            {
                case BeatmapItemKind.Note:
                    return color == ColorTag.None || color == activeColor.Value;
                case BeatmapItemKind.Slider:
                    return color == activeColor.Value;
                default:
                    return true;
            }
        }
    }
}
