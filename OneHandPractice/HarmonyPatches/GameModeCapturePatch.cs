using System.Collections.Generic;
using System.Reflection;
using HarmonyLib;
using OneHandPractice.Services;

namespace OneHandPractice.HarmonyPatches
{
    /// <summary>
    /// Hooks every <c>*LevelScenesTransitionSetupDataSO.Init</c> overload to record the
    /// active game mode into <see cref="GameModeGate"/> before gameplay starts.
    /// </summary>
    [HarmonyPatch]
    public static class GameModeCapturePatch
    {
        // Solo + Party share StandardLevelScenesTransitionSetupDataSO; both overloads take
        // the gameMode string as first parameter, so we patch all Init overloads of that type.
        static IEnumerable<MethodBase> TargetMethods()
        {
            foreach (var m in AccessTools.GetDeclaredMethods(typeof(StandardLevelScenesTransitionSetupDataSO)))
            {
                if (m.Name == "Init") yield return m;
            }
            foreach (var m in AccessTools.GetDeclaredMethods(typeof(MultiplayerLevelScenesTransitionSetupDataSO)))
            {
                if (m.Name == "Init") yield return m;
            }
            foreach (var m in AccessTools.GetDeclaredMethods(typeof(MissionLevelScenesTransitionSetupDataSO)))
            {
                if (m.Name == "Init") yield return m;
            }
        }

        static void Prefix(MethodBase __originalMethod, object[] __args)
        {
            // Standard + Multiplayer Init overloads take `string gameMode` as first arg.
            // Mission Init takes `string missionId` as first arg — for our purposes we just
            // mark it as Mission so the filter stays off there.
            var declaringType = __originalMethod.DeclaringType;
            if (declaringType == typeof(MissionLevelScenesTransitionSetupDataSO))
            {
                GameModeGate.Set(GameModeGate.MissionMode);
                return;
            }

            if (__args.Length > 0 && __args[0] is string mode)
            {
                if (declaringType == typeof(MultiplayerLevelScenesTransitionSetupDataSO))
                {
                    // Always tag as Multiplayer regardless of the gameMode string the lobby sent.
                    GameModeGate.Set(GameModeGate.MultiplayerMode);
                }
                else
                {
                    GameModeGate.Set(mode);
                }
            }
        }
    }
}
