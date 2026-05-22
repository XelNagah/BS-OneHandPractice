using HarmonyLib;
using OneHandPractice.Configuration;
using OneHandPractice.Services;

namespace OneHandPractice.HarmonyPatches
{
    // Hides the GameObject of the off-hand saber so its visual, collider and Update loop are all gone.
    // Postfix on SaberManager.Start with Low priority so other saber-replacing mods finish first.
    [HarmonyPatch(typeof(SaberManager), "Start")]
    public static class SaberHidePatch
    {
        [HarmonyPostfix]
        [HarmonyPriority(Priority.Low)]
        public static void Postfix(SaberManager __instance)
        {
            var hand = HandSelection.Current;
            if (hand == Hand.Off) return;
            if (!GameplayContext.ShouldFilter()) return;

            var oppositeType = hand == Hand.Left ? SaberType.SaberB : SaberType.SaberA;
            __instance.SaberForType(oppositeType)?.gameObject.SetActive(false);
        }
    }
}
