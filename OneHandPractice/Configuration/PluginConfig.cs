namespace OneHandPractice.Configuration
{
    // BSIPA generates a tracked subclass at runtime; properties must be virtual.
    public class PluginConfig
    {
        public static PluginConfig Instance { get; set; }

        public virtual Hand SelectedHand { get; set; } = Hand.Off;

        public virtual void OnReload() => HandSelection.Current = SelectedHand;
        public virtual void Changed()  => HandSelection.Current = SelectedHand;
    }
}
