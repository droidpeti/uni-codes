using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using ELTE.DocuStat.Persistence;

namespace ELTE.DocuStat.Model
{
    public class DocumentStatistics : IDocumentStatistics
    {
        private readonly IFileManager _fileManager;

        public string FileContent { get; private set; } = string.Empty;
        public IDictionary<string, int> DistinctWordCount { get; private set; } = new Dictionary<string, int>();
        public int CharacterCount { get; private set; }
        public int NonWhiteSpaceCharacterCount { get; private set; }
        public int SentenceCount { get; private set; }
        public int ProperNounCount { get; private set; }
        public double ColemanLieuIndex { get; private set; }
        public double FleschReadingEase { get; private set; }

        public event EventHandler? FileContentReady;
        public event EventHandler? TextStatisticsReady;

        public DocumentStatistics(IFileManager fileManager)
        {
            _fileManager = fileManager;
        }

        public async Task LoadAsync()
        {
            FileContent = await _fileManager.LoadAsync();
            OnFileContentReady();

            await Task.Run(() =>
            {
                CharacterCount = FileContent.Length;
                NonWhiteSpaceCharacterCount = FileContent.Count(c => !char.IsWhiteSpace(c));
                SentenceCount = ComputeSentenceCount();
                ProperNounCount = ComputeProperNounCount();
                ComputeDistinctWords();
                ColemanLieuIndex = ComputeColemanLieuIndex();
                FleschReadingEase = ComputeFleschReadingEase();
                OnTextStatisticsReady();
            });
        }

        private void ComputeDistinctWords()
        {
            DistinctWordCount.Clear();
            string[] words = FileContent.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries);
            foreach (string rawWord in words)
            {
                string word = new string(rawWord.SkipWhile(c => !char.IsLetter(c)).Reverse().SkipWhile(c => !char.IsLetter(c)).Reverse().ToArray()).ToLower();
                if (!string.IsNullOrEmpty(word) && word.All(char.IsLetter))
                {
                    if (DistinctWordCount.ContainsKey(word))
                        DistinctWordCount[word]++;
                    else
                        DistinctWordCount[word] = 1;
                }
            }
        }

        public int ComputeSentenceCount()
        {
            if (string.IsNullOrWhiteSpace(FileContent)) return 0;
            var matches = Regex.Matches(FileContent, @"[\.!\?]+(\s|$)");
            return Math.Max(1, matches.Count);
        }

        public int ComputeProperNounCount()
        {
            if (string.IsNullOrWhiteSpace(FileContent)) return 0;
            int count = 0;
            string cleaned = Regex.Replace(FileContent, @"\s+", " ");
            string[] tokens = cleaned.Split(' ', StringSplitOptions.RemoveEmptyEntries);

            for (int i = 1; i < tokens.Length; i++)
            {
                string prev = tokens[i - 1];
                if (prev.EndsWith('.') || prev.EndsWith('!') || prev.EndsWith('?'))
                    continue;

                string current = new string(tokens[i].TakeWhile(char.IsLetter).ToArray());
                if (current.Length > 1 && char.IsUpper(current[0]) && current.Skip(1).All(char.IsLower))
                {
                    count++;
                }
            }
            return count;
        }

        public double ComputeColemanLieuIndex()
        {
            int totalWords = DistinctWordCount.Values.Sum();
            if (totalWords == 0 || SentenceCount == 0) return 0;

            double L = ((double)NonWhiteSpaceCharacterCount / totalWords) * 100.0;
            double S = ((double)SentenceCount / totalWords) * 100.0;
            return 0.0588 * L - 0.296 * S - 15.8;
        }

        public double ComputeFleschReadingEase()
        {
            int totalWords = DistinctWordCount.Values.Sum();
            if (totalWords == 0 || SentenceCount == 0) return 0;

            int totalSyllables = DistinctWordCount.Sum(kvp => CountSyllables(kvp.Key) * kvp.Value);
            return 206.835 - 1.015 * ((double)totalWords / SentenceCount) - 84.6 * ((double)totalSyllables / totalWords);
        }

        private int CountSyllables(string word)
        {
            if (string.IsNullOrEmpty(word)) return 0;
            int count = Regex.Matches(word, @"[aeiouy]+", RegexOptions.IgnoreCase).Count;
            return Math.Max(1, count);
        }

        private void OnFileContentReady()
        {
            FileContentReady?.Invoke(this, EventArgs.Empty);
        }

        private void OnTextStatisticsReady()
        {
            TextStatisticsReady?.Invoke(this, EventArgs.Empty);
        }
    }
}
