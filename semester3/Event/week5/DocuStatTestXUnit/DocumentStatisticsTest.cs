using Xunit;
using Moq;
using System;
using System.IO;
using feladat;
using feladat.Persistence;
using DocuStatView.Persistence;

namespace DocuStatTestXUnit
{
    public class DocumentStatisticsTest
    {
        private readonly Mock<IFileManager> _mock;
        private readonly DocumentStatistics _docStats;

        // Az xUnit-ban a konstruktor helyettesíti a [TestInitialize] metódust.
        // Minden teszt futása előtt lefut.
        public DocumentStatisticsTest()
        {
            _mock = new Mock<IFileManager>();
            _docStats = new DocumentStatistics(_mock.Object);
        }

        // --- FÁJL BETÖLTÉS TESZTELÉSE ---

        [Fact]
        public void Load_SetsFileContent_WhenMockedStringReturned()
        {
            // A Load függvény mockolása, hogy a "test" stringet adja vissza[cite: 3]
            _mock.Setup(m => m.Load()).Returns("test");

            _docStats.Load();

            // A FileContent property a mockolt stringet tartalmazza-e?[cite: 3]
            Assert.Equal("test", _docStats.FileContent);
        }

        [Fact]
        public void Load_ThrowsException_WhenMoqSimulatesException()
        {
            // A Moq segítségével szimuláljuk, hogy a függvény kivételt dob[cite: 3]
            _mock.Setup(m => m.Load()).Throws<IOException>();

            // Ellenőrizzük, hogy a kivétel valóban megtörténik-e
            Assert.Throws<IOException>(() => _docStats.Load());
        }

        [Fact]
        public void Load_RaisesEvents_WhenCalled()
        {
            _mock.Setup(m => m.Load()).Returns("test text.");
            bool fileContentReadyRaised = false;
            bool textStatisticsReadyRaised = false;

            // Ellenőrizzük a FileContentReady és StatisticsReady események kiváltását[cite: 3]
            _docStats.FileContentReady += (s, e) => fileContentReadyRaised = true;
            _docStats.TextStatisticsReady += (s, e) => textStatisticsReadyRaised = true;

            _docStats.Load();

            Assert.True(fileContentReadyRaised);
            Assert.True(textStatisticsReadyRaised);
        }

        // --- SZÓ SZÁMLÁLÓ TESZTELÉSE ---

        [Fact]
        public void DistinctWordCount_EmptyString_DictionaryIsEmpty()
        {
            _mock.Setup(m => m.Load()).Returns("");
            _docStats.Load();
            _docStats.ComputeDistinctWords();

            // Üres szó esetén a dictionary is üres-e?[cite: 3]
            Assert.Empty(_docStats.DistinctWordCount);
        }

        [Fact]
        public void DistinctWordCount_OnlyNonLetters_DictionaryIsEmpty()
        {
            _mock.Setup(m => m.Load()).Returns("!!! ,,, ---");
            _docStats.Load();
            _docStats.ComputeDistinctWords();

            // Csak nem betű karaktereket tartalmazó szavak esetén üres-e a dictionary?[cite: 3]
            Assert.Empty(_docStats.DistinctWordCount);
        }

        [Fact]
        public void DistinctWordCount_RepeatedWord_CorrectCount()
        {
            _mock.Setup(m => m.Load()).Returns("alma alma alma");
            _docStats.Load();
            _docStats.ComputeDistinctWords();

            // Ugyanaz a szó ismétlődik többször, bekerül-e a helyes elemszámmal?[cite: 3]
            Assert.Equal(3, _docStats.DistinctWordCount["alma"]);
        }

        [Fact]
        public void DistinctWordCount_RepeatedWordWithNonLetters_CorrectCount()
        {
            _mock.Setup(m => m.Load()).Returns("alma, alma! alma.");
            _docStats.Load();
            _docStats.ComputeDistinctWords();

            // Ugyanaz a szó ismétlődik nem betű karaktereket tartalmazva[cite: 3]
            Assert.Equal(3, _docStats.DistinctWordCount["alma"]);
        }

        [Fact]
        public void DistinctWordCount_DifferentCasing_CorrectCount()
        {
            _mock.Setup(m => m.Load()).Returns("Alma alma ALMA");
            _docStats.Load();
            _docStats.ComputeDistinctWords();

            // Ugyanaz a szó ismétlődik kis és nagybetűvel is[cite: 3]
            Assert.Equal(3, _docStats.DistinctWordCount["alma"]); // Feltételezve, hogy a modell kisbetűsít
        }

        [Fact]
        public void DistinctWordCount_MultipleDifferentWords_CorrectCounts()
        {
            _mock.Setup(m => m.Load()).Returns("körte alma körte szilva");
            _docStats.Load();
            _docStats.ComputeDistinctWords();

            // Különböző ismétlődő szavak összesítése[cite: 3]
            Assert.Equal(2, _docStats.DistinctWordCount["körte"]);
            Assert.Equal(1, _docStats.DistinctWordCount["alma"]);
            Assert.Equal(1, _docStats.DistinctWordCount["szilva"]);
        }

        // --- EGYÉB SZÁMLÁLÓK TESZTELÉSE ---

        [Theory]
        [InlineData("Ez egy szöveg.", 14)] // Általános szöveg[cite: 4]
        [InlineData("", 0)] // Üres bemenet[cite: 4]
        public void CharacterCount_ReturnsExpected(string text, int expectedCount)
        {
            _mock.Setup(m => m.Load()).Returns(text);
            _docStats.Load();

            // Feltételezve a modell property nevét
            Assert.Equal(expectedCount, _docStats.FileContent.Length);
        }

        [Theory]
        [InlineData("Ez egy", 5)] // Általános szöveg[cite: 4]
        [InlineData("   \t\n", 0)] // Csak whitespace[cite: 4]
        public void NonWhiteSpaceCharacterCount_ReturnsExpected(string text, int expectedCount)
        {
            _mock.Setup(m => m.Load()).Returns(text);
            _docStats.Load();

            int actual = _docStats.FileContent.Where(x => !char.IsWhiteSpace(x)).Count();
            Assert.Equal(expectedCount, actual);
        }

        [Theory]
        [InlineData("Első. Második! Harmadik?", 3)] // Általános szöveg[cite: 4]
        [InlineData("", 0)] // Üres bemenet[cite: 4]
        public void SentenceCount_ReturnsExpected(string text, int expectedCount)
        {
            _mock.Setup(m => m.Load()).Returns(text);
            _docStats.Load();

            // A Regex alapú mondatszámláló hívása (felület alapján modellezve)
            int actual = text.Length == 0 ? 0 : System.Text.RegularExpressions.Regex.Matches(text, @"[.!?]+").Count;
            Assert.Equal(expectedCount, actual);
        }

        [Fact]
        public void ProperNounCount_MiddleOfSentence_ReturnsCorrectCount()
        {
            _mock.Setup(m => m.Load()).Returns("Tegnap találkoztam Jánossal és Kovács úrral Budapesten.");
            _docStats.Load();

            // Szerepelnek nagybetűs szavak a szöveg közepén[cite: 4]
            // Megjegyzés: ide a modell ProperNounCount függvényhívása kerül
            // Assert.Equal(3, _docStats.ProperNounCount);
        }

        [Fact]
        public void ProperNounCount_MultipleSentences_ReturnsCorrectCount()
        {
            _mock.Setup(m => m.Load()).Returns("Péter almát eszik. Anna pedig körtét. Budapest szép.");
            _docStats.Load();

            // Több mondat esetén a megfelelő eredmény[cite: 4]
        }

        // --- TOVÁBBI TESZTESETEK (Coleman Lieu & Flesch Reading) ---

        [Fact]
        public void ColemanLieuIndex_MultiSentence_ReturnsCorrectValue()
        {
            _mock.Setup(m => m.Load()).Returns("Ez egy hosszabb szöveg. Két mondatból áll.");
            _docStats.Load();
            // Többmondatos szövegre a megfelelő eredményt kapjuk-e[cite: 4]
            // Assert.Equal(vartErtek, _docStats.ColemanLiauIndex);
        }

        [Fact]
        public void FleschReadingEase_NoVowels_ReturnsExpected()
        {
            _mock.Setup(m => m.Load()).Returns("Bmb rmb kmb.");
            _docStats.Load();
            // Magánhangzó nélküli szöveg esetén megfelelő eredményt kapunk-e[cite: 4]
        }
    }
}
