using DocuStatView.Persistence;
using feladat;
using feladat.Persistence;
using System.Net;
using System.Text.RegularExpressions;

namespace DocuStatView
{
    public partial class DocuStatDialog : Form
    {
        private DocumentStatistics? _documentStatistics;
        private static readonly Regex WordRegex = new(@"\b[\p{L}\p{N}]+\b", RegexOptions.Compiled);
        private static readonly Regex SentenceRegex = new(@"[.!?]+", RegexOptions.Compiled);
        private static readonly string Vowels = "aáeéiíoóöőuúüű";

        public DocuStatDialog()
        {
            InitializeComponent();
        }

        private void OpenDialog(object? sender, EventArgs e)
        {
            using (OpenFileDialog openFileDialog = new OpenFileDialog())
            {
                openFileDialog.InitialDirectory = "C:\\";
                openFileDialog.Filter = "Text files (*.txt)|*.txt|PDF files (*.pdf)|*.pdf";
                openFileDialog.RestoreDirectory = true;
                if (openFileDialog.ShowDialog() == DialogResult.OK)
                {
                    try
                    {

                        IFileManager? fileManager = FileManagerFactory.CreateForPath(openFileDialog.FileName);
                        if (fileManager == null)
                        {
                            MessageBox.Show(
                            "File reading is unsuccessful!\nUnsupported file format.",
                            "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }

                        _documentStatistics = new DocumentStatistics(fileManager);
                        _documentStatistics.FileContentReady += UpdateFileContent;
                        _documentStatistics.TextStatisticsReady += UpdateTextStatistics;
                        _documentStatistics.Load();
                    }
                    catch (System.IO.IOException ex)
                    {
                        MessageBox.Show("File reading is unsuccessful!\n" + ex.Message,
                        "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                }
            }
        }

        private void UpdateFileContent(object? sender, EventArgs e)
        {
            if (_documentStatistics?.FileContent == textBox.Text)
                return;
            textBox.Text = _documentStatistics?.FileContent;
            listBoxCounter.Items.Clear();
        }

        private void UpdateTextStatistics(object? sender, EventArgs e)
        {

            labelCharacters.Text = $"Character count: {_documentStatistics?.FileContent.Length}";
            labelNonWhitespaceCharacters.Text = $"Non-whitespace characters: {_documentStatistics?.FileContent.Where(x => !char.IsWhiteSpace(x)).ToArray().Length}";
            labelSentences.Text = $"Sentence count: {_documentStatistics?.FileContent.Count(x => x == '.')}";
            labelColemanLieuIndex.Text = $"Coleman Lieu Index: {ColemanLiauIndex(_documentStatistics?.FileContent)}";
            labelProperNouns.Text = $"Proper noun count: {ProperNounCount(_documentStatistics.FileContent)}";
            labelFleschReadingEase.Text = $"Flesch Reading Ease: {FleschReadingEase(_documentStatistics.FileContent)}";
        }

        private int ProperNounCount(string text)
        {
            return WordRegex.Matches(text)
                .Select(x => x.Value)
                .Count(word =>
                    word.Length > 0 &&
                    char.IsUpper(word[0]));
        }

        private double ColemanLiauIndex(string text)
        {
            var words = WordRegex.Matches(text)
                .Select(x => x.Value)
                .ToList();

            int wordCount = words.Count;

            if (wordCount == 0)
                return 0;

            int sentenceCount = Math.Max(
                1,
                SentenceRegex.Matches(text).Count);

            int letterCount = words.Sum(w =>
                w.Count(char.IsLetter));

            double L = (double)letterCount / wordCount * 100;
            double S = (double)sentenceCount / wordCount * 100;

            // Coleman-Liau Index
            return 0.0588 * L
                 - 0.296 * S
                 - 15.8;
        }

        private double FleschReadingEase(string text)
        {
            var words = WordRegex.Matches(text)
                .Select(x => x.Value)
                .ToList();

            int wordCount = words.Count;

            if (wordCount == 0)
                return 0;

            int sentenceCount = Math.Max(
                1,
                SentenceRegex.Matches(text).Count);

            return 206.835
                 - 1.015 * ((double)wordCount / sentenceCount)
                 - 84.6 * ((double)wordCount);
        }

        private void CountWords(object? sender, EventArgs e)
        {
            if (String.IsNullOrEmpty(_documentStatistics?.FileContent))
            {
                MessageBox.Show("Nincs beolvasott szöveg!");
                return;
            }

            int minLength = Convert.ToInt32(spinBoxMinLength.Value);
            int minOccurrence = Convert.ToInt32(spinBoxMinOccurrence.Value);
            string[] ignoredWords = textBoxIgnoredWords.Text.Split();

            _documentStatistics.ComputeDistinctWords();
            var pairs = _documentStatistics.DistinctWordCount
                .Where(p => p.Value >= minOccurrence)
                .Where(p => p.Key.Length >= minLength)
                .Where(p => !ignoredWords.Contains(p.Key))
                .OrderByDescending(p => p.Value);

            listBoxCounter.Items.Clear();
            listBoxCounter.BeginUpdate();
            foreach (var pair in pairs)
            {
                listBoxCounter.Items.Add(pair.Key + ": " + pair.Value);
            }
            listBoxCounter.EndUpdate();
        }
    }
}
