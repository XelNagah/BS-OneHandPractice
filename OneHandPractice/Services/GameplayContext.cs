using BS_Utils.Gameplay;

namespace OneHandPractice.Services
{
    // Decides whether the filter should run for the current play. Uses BS_Utils' tracked Mode
    // so we don't duplicate its Init-prefix patches. Standard covers Solo and Party — both are
    // gameplay-identical and filtering in Party is the same standard-practice as PracticePlugin
    // (the user can switch the filter off in the One Hand tab before a Party round if they want
    // to play normally).
    public static class GameplayContext
    {
        public static bool ShouldFilter() => BS_Utils.Plugin.LevelData.Mode == Mode.Standard;
    }
}
