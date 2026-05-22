using HarmonyLib;
using OneHandPractice.Configuration;
using OneHandPractice.Services;

namespace OneHandPractice.HarmonyPatches
{
    /// <summary>
    /// Disables the GameObject of the saber that matches the filtered-out hand. Killing the
    /// GameObject takes the visual model, the collider and the per-frame Update with it, so
    /// the off-hand saber can't accidentally trigger bomb hits or interact with the scene.
    ///
    /// Runs as a postfix on <c>SaberManager.Start()</c> with low priority so other mods (like
    /// CustomSabersLite) finish replacing the model before we hide it.
    /// </summary>
    [HarmonyPatch(typeof(SaberManager), "Start")]
    public static class SaberHidePatch
    {
        [HarmonyPostfix]
        [HarmonyPriority(Priority.Low)]
        public static void Postfix(SaberManager __instance)
        {
            var hand = HandSelection.Current;
            if (hand == Hand.Off || !GameModeGate.FilterAllowed)
            {
                return;
            }

            var oppositeSaberType = hand == Hand.Left ? SaberType.SaberB : SaberType.SaberA;
            var opposite = __instance.SaberForType(oppositeSaberType);
            if (opposite == null)
            {
                Plugin.Log?.Warn($"SaberHidePatch: no saber found for {oppositeSaberType}");
                return;
            }

            opposite.gameObject.SetActive(false);
            Plugin.Log?.Info($"SaberHidePatch: hid opposite saber (type={oppositeSaberType}, hand-active={hand})");
        }
    }
}
