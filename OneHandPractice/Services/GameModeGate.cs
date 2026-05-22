namespace OneHandPractice.Services
{
    /// <summary>
    /// Tracks the active gameplay mode (Solo / Party / Multiplayer / Mission) so the filter
    /// can opt out of modes where altering the beatmap is unsafe (multiplayer desync,
    /// campaign objectives broken by missing notes).
    ///
    /// Populated by Harmony prefix patches on the various <c>*LevelScenesTransitionSetupDataSO.Init</c>
    /// overloads — see <see cref="HarmonyPatches.GameModeCapturePatch"/>.
    /// </summary>
    public static class GameModeGate
    {
        /// <summary>
        /// Sentinel for "Solo" coming from <c>StandardLevelScenesTransitionSetupDataSO.Init</c>.
        /// Stock value used by Beat Saber itself; mirror here so we don't allocate per call.
        /// </summary>
        public const string SoloMode = "Solo";

        public const string PartyMode = "Party";
        public const string MultiplayerMode = "Multiplayer";
        public const string MissionMode = "Mission";

        /// <summary>Mode string of the most-recently-initialized gameplay session.</summary>
        public static string CurrentMode { get; private set; } = SoloMode;

        /// <summary>True when the one-hand filter is allowed to apply.</summary>
        public static bool FilterAllowed => CurrentMode == SoloMode;

        public static void Set(string mode)
        {
            if (string.IsNullOrEmpty(mode)) return;
            if (CurrentMode == mode) return;
            CurrentMode = mode;
            Plugin.Log?.Info($"GameModeGate: mode={mode}, filterAllowed={FilterAllowed}");
        }
    }
}
