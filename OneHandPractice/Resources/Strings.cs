namespace OneHandPractice.Resources
{
    /// <summary>
    /// Single home for user-facing strings. Keeps the rest of the code free of
    /// hard-coded text so future localization (manual file-based or via SiraLocalizer)
    /// only needs to change this class.
    /// </summary>
    public static class Strings
    {
        // Gameplay Setup tab
        public const string TabName = "One Hand";
        public const string Title = "One Hand Practice";
        public const string Description = "Filter beatmap to a single hand. Submission to leaderboards is disabled while active.";
        public const string HandLabel = "Hand";
        public const string HandHoverHint = "Off keeps the beatmap unchanged. Left or Right removes the opposite-color notes and disables score submission.";
        public const string Footer = "Note: combo ramps to x8 faster with fewer notes. Bombs and walls are kept.";

        // Hand choices (user-visible)
        public const string ChoiceOff = "Off";
        public const string ChoiceLeft = "Left";
        public const string ChoiceRight = "Right";
    }
}
