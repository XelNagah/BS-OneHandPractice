using BS_Utils.Gameplay;

namespace OneHandPractice.Services
{
    /// <summary>
    /// Blocks score submission to ScoreSaber / BeatLeader / official leaderboard for the
    /// current play. Uses BS_Utils' per-play <see cref="ScoreSubmission.DisableSubmission"/>,
    /// which is automatically reset by BS_Utils on the level-finish event — so we re-arm
    /// the gate every time the filter actually runs.
    /// </summary>
    public static class ScoreSubmissionGate
    {
        private const string ModName = "OneHandPractice";

        /// <summary>Mark the upcoming run as non-submittable. Idempotent within a single play.</summary>
        public static void DisableForCurrentPlay()
        {
            ScoreSubmission.DisableSubmission(ModName);
            Plugin.Log?.Info("Score submission disabled for current play (filter active)");
        }
    }
}
