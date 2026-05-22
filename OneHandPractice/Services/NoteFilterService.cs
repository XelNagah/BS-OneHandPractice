using OneHandPractice.Configuration;

namespace OneHandPractice.Services
{
    /// <summary>
    /// Classifies the runtime type of a beatmap item for filter purposes.
    /// Independent of Beat Saber types so the service can be unit-tested without game references.
    /// </summary>
    public enum BeatmapItemKind
    {
        /// <summary>Walls, events, anything we never filter.</summary>
        Other = 0,
        /// <summary>A regular note (gameplay note or bomb). Bombs are identified by <see cref="ColorTag.None"/>.</summary>
        Note = 1,
        /// <summary>An arc or burst slider. Color taken from the head.</summary>
        Slider = 2,
    }

    /// <summary>
    /// Mirror of <c>ColorType</c> from BeatmapCore.dll. Decoupled from the BS assembly
    /// so the service stays free of game references.
    /// </summary>
    public enum ColorTag
    {
        ColorA = 0,   // left / red
        ColorB = 1,   // right / blue
        None = -1,    // bomb
    }

    /// <summary>
    /// Decides whether a single beatmap item survives the one-hand filter.
    /// Pure logic — no game state, no Unity, no Zenject. Unit-testable in isolation.
    /// </summary>
    public class NoteFilterService
    {
        /// <summary>
        /// Returns <c>true</c> when the item should remain in the playable beatmap, <c>false</c> when it should be removed.
        /// Predicate: drop only colored notes and sliders whose color is the *opposite* of the active hand.
        /// Bombs (<see cref="ColorTag.None"/>), walls and everything else are always kept.
        /// </summary>
        public bool ShouldKeep(BeatmapItemKind kind, ColorTag color, Hand activeHand)
        {
            var activeColor = activeHand.ToColorTag();
            if (activeColor == null)
            {
                return true; // filter disabled
            }

            switch (kind)
            {
                case BeatmapItemKind.Note:
                    // Bombs use ColorTag.None and must survive.
                    if (color == ColorTag.None)
                        return true;
                    return color == activeColor.Value;

                case BeatmapItemKind.Slider:
                    // Covers arcs and burst sliders.
                    return color == activeColor.Value;

                default:
                    return true;
            }
        }
    }
}
