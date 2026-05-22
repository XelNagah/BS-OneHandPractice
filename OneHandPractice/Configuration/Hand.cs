using OneHandPractice.Services;

namespace OneHandPractice.Configuration
{
    public enum Hand { Off = 0, Left = 1, Right = 2 }

    public static class HandExtensions
    {
        public static ColorTag? ToColorTag(this Hand hand) => hand switch
        {
            Hand.Left  => ColorTag.ColorA,
            Hand.Right => ColorTag.ColorB,
            _          => null,
        };
    }
}
