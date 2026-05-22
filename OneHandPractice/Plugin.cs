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
            PluginConfig.Instance = conf.Generated<PluginConfig>();
            HandSelection.Current = PluginConfig.Instance.SelectedHand;
            Log.Info($"OneHandPractice loaded (hand={HandSelection.Current})");
        }

        [OnEnable]
        public void OnEnable()
        {
            _harmony.PatchAll(Assembly.GetExecutingAssembly());
            BSEvents.lateMenuSceneLoadedFresh += OnMenuSceneLoadedFresh;
        }

        [OnDisable]
        public void OnDisable()
        {
            BSEvents.lateMenuSceneLoadedFresh -= OnMenuSceneLoadedFresh;
            if (_tabRegistered)
            {
                GameplaySetup.Instance.RemoveTab(OneHandSettingsViewController.TabName);
                _tabRegistered = false;
            }
            _harmony.UnpatchSelf();
        }

        private static void OnMenuSceneLoadedFresh(ScenesTransitionSetupDataSO _)
        {
            if (_tabRegistered) return;
            GameplaySetup.Instance.AddTab(
                OneHandSettingsViewController.TabName,
                OneHandSettingsViewController.BsmlResource,
                _settingsHost);
            _tabRegistered = true;
        }
    }
}
