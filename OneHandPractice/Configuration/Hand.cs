using OneHandPractice.Services;

namespace OneHandPractice.Configuration
{
    /// <summary>
    /// Active filter selection. Off means the filter is not applied.
    /// </summary>
    public enum Hand
    {
        Off = 0,
        Left = 1,   // ColorTag.ColorA
        Right = 2   // ColorTag.ColorB
    }

    public static class HandExtensions
    {
        /// <summary>
        /// Maps the user-facing <see cref="Hand"/> selection to the underlying color tag.
        /// Returns <c>null</c> when the filter is off.
        /// </summary>
        public static ColorTag? ToColorTag(this Hand hand) => hand switch
        {
            Hand.Left => ColorTag.ColorA,
            Hand.Right => ColorTag.ColorB,
            _ => null,
        };
    }
}
