namespace OneHandPractice.Configuration
{
    // Process-wide active hand. Filter reads this; UI and persisted config write to it.
    public static class HandSelection
    {
        public static Hand Current { get; set; } = Hand.Off;
    }
}
