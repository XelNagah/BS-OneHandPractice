namespace OneHandPractice.Services
{
    // Reads the active scene-transition setup data exposed by BS_Utils to decide whether the
    // filter should run for the current play. One source of truth: the strongly-typed setup
    // data tells us Multiplayer/Mission directly, and StandardLevelScenesTransitionSetupDataSO
    // exposes gameMode = "Solo" or "Party" via its public string property.
    public static class GameplayContext
    {
        public static bool ShouldFilter()
        {
            var setup = BS_Utils.Plugin.scenesTransitionSetupData;
            if (setup == null) return false;

            switch (setup)
            {
                case MultiplayerLevelScenesTransitionSetupDataSO _:
                case MissionLevelScenesTransitionSetupDataSO _:
                    return false;

                case StandardLevelScenesTransitionSetupDataSO std:
                    return std.gameMode == "Solo";

                default:
                    // Tutorial, sandbox, anything custom we don't recognize — leave alone.
                    return false;
            }
        }
    }
}
