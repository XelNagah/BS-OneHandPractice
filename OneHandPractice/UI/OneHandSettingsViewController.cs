using System.Collections.Generic;
using BeatSaberMarkupLanguage.Attributes;
using OneHandPractice.Configuration;

namespace OneHandPractice.UI
{
    /// <summary>
    /// Host for <c>OneHandSettings.bsml</c>. Backs the dropdown in the Gameplay Setup tab and
    /// writes the selection to <see cref="HandSelection.Current"/> so the filter patch sees it
    /// on the next gameplay session.
    /// </summary>
    public class OneHandSettingsViewController
    {
        public const string TabName = "One Hand";
        public const string BsmlResource = "OneHandPractice.UI.OneHandSettings.bsml";

        private const string ChoiceOff = "Off";
        private const string ChoiceLeft = "Left";
        private const string ChoiceRight = "Right";

        [UIValue("hand-choices")]
        public List<object> HandChoices { get; } = new() { ChoiceOff, ChoiceLeft, ChoiceRight };

        [UIValue("selected-hand")]
        public string SelectedHand
        {
            get => ToChoice(HandSelection.Current);
            set
            {
                var hand = FromChoice(value);
                HandSelection.Current = hand;
                if (PluginConfig.Instance != null)
                {
                    PluginConfig.Instance.SelectedHand = hand;
                }
                Plugin.Log?.Info($"UI: hand selection -> {hand}");
            }
        }

        private static string ToChoice(Hand hand) => hand switch
        {
            Hand.Left => ChoiceLeft,
            Hand.Right => ChoiceRight,
            _ => ChoiceOff,
        };

        private static Hand FromChoice(string choice) => choice switch
        {
            ChoiceLeft => Hand.Left,
            ChoiceRight => Hand.Right,
            _ => Hand.Off,
        };
    }
}
