using System.Reflection;
using BeatSaberMarkupLanguage.GameplaySetup;
using BS_Utils.Utilities;
using HarmonyLib;
using IPA;
using IPA.Config.Stores;
using OneHandPractice.Configuration;
using OneHandPractice.UI;
using IPALogger = IPA.Logging.Logger;

namespace OneHandPractice
{
    [Plugin(RuntimeOptions.SingleStartInit)]
    public class Plugin
    {
        private const string HarmonyId = "com.xelnagah.OneHandPractice";
        private static readonly Harmony _harmony = new(HarmonyId);
        private static readonly OneHandSettingsViewController _settingsHost = new();
        private static bool _tabRegistered;

        internal static IPALogger Log { get; private set; }

        [Init]
        public Plugin(IPALogger logger, IPA.Config.Config conf)
        {
            Log = logger;

            // Wire BSIPA config. GeneratedStore creates a runtime subclass that tracks property writes
            // and serializes to OneHandPractice.json under UserData/.
            PluginConfig.Instance = conf.Generated<PluginConfig>();
            HandSelection.Current = PluginConfig.Instance.SelectedHand;

            Log.Info($"OneHandPractice loaded (hand={HandSelection.Current})");
        }

        [OnEnable]
        public void OnEnable()
        {
            try
            {
                _harmony.PatchAll(Assembly.GetExecutingAssembly());
                Log.Info("OneHandPractice enabled — Harmony patches applied");
            }
            catch (System.Exception ex)
            {
                Log.Error($"OneHandPractice patch failed during OnEnable: {ex}");
            }

            BSEvents.lateMenuSceneLoadedFresh += OnMenuSceneLoadedFresh;
        }

        [OnDisable]
        public void OnDisable()
        {
            BSEvents.lateMenuSceneLoadedFresh -= OnMenuSceneLoadedFresh;

            try
            {
                if (_tabRegistered)
                {
                    GameplaySetup.Instance.RemoveTab(OneHandSettingsViewController.TabName);
                    _tabRegistered = false;
                }
            }
            catch (System.Exception ex)
            {
                Log.Error($"Failed to remove Gameplay Setup tab: {ex}");
            }

            try
            {
                _harmony.UnpatchSelf();
                Log.Info("OneHandPractice disabled — Harmony patches removed");
            }
            catch (System.Exception ex)
            {
                Log.Error($"OneHandPractice unpatch failed during OnDisable: {ex}");
            }
        }

        private static void OnMenuSceneLoadedFresh(ScenesTransitionSetupDataSO _)
        {
            if (_tabRegistered) return;
            try
            {
                GameplaySetup.Instance.AddTab(
                    OneHandSettingsViewController.TabName,
                    OneHandSettingsViewController.BsmlResource,
                    _settingsHost);
                _tabRegistered = true;
                Log.Info("Gameplay Setup tab registered");
            }
            catch (System.Exception ex)
            {
                Log.Error($"Failed to register Gameplay Setup tab: {ex}");
            }
        }
    }
}
