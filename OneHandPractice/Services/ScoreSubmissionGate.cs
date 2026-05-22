using BS_Utils.Gameplay;

namespace OneHandPractice.Services
{
    // Per-play submission block. BS_Utils auto-resets the disable flag on level finish, so we
    // simply re-arm it every time the filter actually runs.
    public static class ScoreSubmissionGate
    {
        private const string ModName = "OneHandPractice";

        public static void DisableForCurrentPlay() => ScoreSubmission.DisableSubmission(ModName);
    }
}
