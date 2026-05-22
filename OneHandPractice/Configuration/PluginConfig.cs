using IPA.Config.Stores.Attributes;

namespace OneHandPractice.Configuration
{
    /// <summary>
    /// BSIPA-generated persistent config. Backs <see cref="HandSelection"/> so the last-used
    /// hand survives across sessions. Properties must be <c>virtual</c> so BSIPA can generate
    /// the change-tracking proxy at runtime.
    /// </summary>
    public class PluginConfig
    {
        public static PluginConfig Instance { get; set; }

        /// <summary>Persisted hand selection. Defaults to <see cref="Hand.Off"/> for first-run users.</summary>
        public virtual Hand SelectedHand { get; set; } = Hand.Off;

        /// <summary>BSIPA invokes this after the config object is populated from disk.</summary>
        public virtual void OnReload()
        {
            HandSelection.Current = SelectedHand;
            Plugin.Log?.Info($"Config loaded: SelectedHand={SelectedHand}");
        }

        /// <summary>BSIPA invokes this when a write to a property is detected.</summary>
        public virtual void Changed()
        {
            HandSelection.Current = SelectedHand;
        }
    }
}
