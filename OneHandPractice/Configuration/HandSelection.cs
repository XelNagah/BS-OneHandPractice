namespace OneHandPractice.Configuration
{
    /// <summary>
    /// Process-wide source of truth for the active hand selection. Read by the filter patch,
    /// written by the UI view controller (Phase 7) and the persisted config (Phase 8).
    /// </summary>
    public static class HandSelection
    {
        /// <summary>Currently selected hand. Defaults to <see cref="Hand.Off"/> — user has to opt in.</summary>
        public static Hand Current { get; set; } = Hand.Off;
    }
}
