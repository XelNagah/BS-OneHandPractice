using OneHandPractice.Configuration;
using OneHandPractice.Services;
using Xunit;

namespace OneHandPractice.Tests
{
    public class NoteFilterServiceTests
    {
        private readonly NoteFilterService _sut = new();

        // Filter disabled: everything kept regardless of color.
        [Theory]
        [InlineData(BeatmapItemKind.Note, ColorTag.ColorA)]
        [InlineData(BeatmapItemKind.Note, ColorTag.ColorB)]
        [InlineData(BeatmapItemKind.Note, ColorTag.None)]
        [InlineData(BeatmapItemKind.Slider, ColorTag.ColorA)]
        [InlineData(BeatmapItemKind.Slider, ColorTag.ColorB)]
        [InlineData(BeatmapItemKind.Other, ColorTag.ColorA)]
        public void Off_KeepsEverything(BeatmapItemKind kind, ColorTag color)
        {
            Assert.True(_sut.ShouldKeep(kind, color, Hand.Off));
        }

        // Left active = ColorA: only ColorA notes/sliders survive; bombs (None) survive; ColorB drops.
        [Theory]
        [InlineData(BeatmapItemKind.Note, ColorTag.ColorA, true)]   // left note kept
        [InlineData(BeatmapItemKind.Note, ColorTag.ColorB, false)]  // right note dropped
        [InlineData(BeatmapItemKind.Note, ColorTag.None, true)]     // bomb kept
        [InlineData(BeatmapItemKind.Slider, ColorTag.ColorA, true)] // left slider kept
        [InlineData(BeatmapItemKind.Slider, ColorTag.ColorB, false)]// right slider dropped
        [InlineData(BeatmapItemKind.Other, ColorTag.ColorA, true)]  // wall kept regardless of color
        [InlineData(BeatmapItemKind.Other, ColorTag.ColorB, true)]
        public void Left_KeepsLeftAndBombsAndOthers(BeatmapItemKind kind, ColorTag color, bool expected)
        {
            Assert.Equal(expected, _sut.ShouldKeep(kind, color, Hand.Left));
        }

        // Right active = ColorB: symmetric to Left.
        [Theory]
        [InlineData(BeatmapItemKind.Note, ColorTag.ColorB, true)]
        [InlineData(BeatmapItemKind.Note, ColorTag.ColorA, false)]
        [InlineData(BeatmapItemKind.Note, ColorTag.None, true)]
        [InlineData(BeatmapItemKind.Slider, ColorTag.ColorB, true)]
        [InlineData(BeatmapItemKind.Slider, ColorTag.ColorA, false)]
        [InlineData(BeatmapItemKind.Other, ColorTag.ColorA, true)]
        [InlineData(BeatmapItemKind.Other, ColorTag.ColorB, true)]
        public void Right_KeepsRightAndBombsAndOthers(BeatmapItemKind kind, ColorTag color, bool expected)
        {
            Assert.Equal(expected, _sut.ShouldKeep(kind, color, Hand.Right));
        }

        [Fact]
        public void HandExtensions_OffMapsToNull()
        {
            Assert.Null(Hand.Off.ToColorTag());
        }

        [Fact]
        public void HandExtensions_LeftMapsToColorA()
        {
            Assert.Equal(ColorTag.ColorA, Hand.Left.ToColorTag());
        }

        [Fact]
        public void HandExtensions_RightMapsToColorB()
        {
            Assert.Equal(ColorTag.ColorB, Hand.Right.ToColorTag());
        }
    }
}
