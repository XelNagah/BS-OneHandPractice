using System.Collections.Generic;
using BeatSaberMarkupLanguage.Attributes;
using OneHandPractice.Configuration;
using OneHandPractice.Resources;

namespace OneHandPractice.UI
{
    public class OneHandSettingsViewController
    {
        public const string BsmlResource = "OneHandPractice.UI.OneHandSettings.bsml";
        public static string TabName => Strings.TabName;

        [UIValue("title-text")]
        public string TitleText => Strings.Title;

        [UIValue("description-text")]
        public string DescriptionText => Strings.Description;

        [UIValue("hand-label")]
        public string HandLabel => Strings.HandLabel;

        [UIValue("hand-hover-hint")]
        public string HandHoverHint => Strings.HandHoverHint;

        [UIValue("footer-text")]
        public string FooterText => Strings.Footer;

        [UIValue("hand-choices")]
        public List<object> HandChoices { get; } = new() { Strings.ChoiceOff, Strings.ChoiceLeft, Strings.ChoiceRight };

        [UIValue("selected-hand")]
        public string SelectedHand
        {
            get => ToChoice(HandSelection.Current);
            set
            {
                var hand = FromChoice(value);
                HandSelection.Current = hand;
                if (PluginConfig.Instance != null) PluginConfig.Instance.SelectedHand = hand;
            }
        }

        private static string ToChoice(Hand hand) => hand switch
        {
            Hand.Left  => Strings.ChoiceLeft,
            Hand.Right => Strings.ChoiceRight,
            _          => Strings.ChoiceOff,
        };

        private static Hand FromChoice(string choice)
        {
            if (choice == Strings.ChoiceLeft)  return Hand.Left;
            if (choice == Strings.ChoiceRight) return Hand.Right;
            return Hand.Off;
        }
    }
}
