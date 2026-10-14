#!/usr/bin/env bash
set -e

echo "=== DocuStat (6. gyakorlat) projekt letrehozasa ==="

rm -rf DocuStatComplete
mkdir -p DocuStatComplete/DocuStat/Persistence
mkdir -p DocuStatComplete/DocuStat/Model
mkdir -p DocuStatComplete/DocuStatView
cd DocuStatComplete

dotnet new sln -n DocuStat

# 1. DocuStat.csproj
cat << 'EOF' > DocuStat/DocuStat.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="itext7" Version="8.0.5" />
  </ItemGroup>

</Project>
EOF

# 2. FileManagerException.cs
cat << 'EOF' > DocuStat/Persistence/FileManagerException.cs
using System;

namespace ELTE.DocuStat.Persistence
{
    public class FileManagerException : Exception
    {
        public FileManagerException(string message) : base(message) { }
        public FileManagerException(string message, Exception innerException) : base(message, innerException) { }
    }
}
EOF

# 3. IFileManager.cs
cat << 'EOF' > DocuStat/Persistence/IFileManager.cs
using System.Threading.Tasks;

namespace ELTE.DocuStat.Persistence
{
    public interface IFileManager
    {
        Task<string> LoadAsync();
    }
}
EOF

# 4. TxtFileManager.cs
cat << 'EOF' > DocuStat/Persistence/TxtFileManager.cs
using System;
using System.IO;
using System.Threading.Tasks;

namespace ELTE.DocuStat.Persistence
{
    public class TxtFileManager : IFileManager
    {
        private readonly string _path;

        public TxtFileManager(string path)
        {
            _path = path;
        }

        public async Task<string> LoadAsync()
        {
            try
            {
                return await File.ReadAllTextAsync(_path);
            }
            catch (Exception ex)
            {
                throw new FileManagerException("Error during reading TXT file: " + ex.Message, ex);
            }
        }
    }
}
EOF

# 5. PdfFileManager.cs
cat << 'EOF' > DocuStat/Persistence/PdfFileManager.cs
using System;
using System.Text;
using System.Threading.Tasks;
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas.Parser;

namespace ELTE.DocuStat.Persistence
{
    public class PdfFileManager : IFileManager
    {
        private readonly string _path;

        public PdfFileManager(string path)
        {
            _path = path;
        }

        public async Task<string> LoadAsync()
        {
            try
            {
                using PdfReader reader = new PdfReader(_path);
                using PdfDocument document = new PdfDocument(reader);

                return await Task.Run(() =>
                {
                    StringBuilder text = new StringBuilder();
                    for (int i = 1; i <= document.GetNumberOfPages(); i++)
                    {
                        PdfPage page = document.GetPage(i);
                        text.Append(PdfTextExtractor.GetTextFromPage(page));
                    }
                    return text.ToString();
                });
            }
            catch (Exception ex)
            {
                throw new FileManagerException("Error during reading PDF file: " + ex.Message, ex);
            }
        }
    }
}
EOF

# 6. FileManagerFactory.cs
cat << 'EOF' > DocuStat/Persistence/FileManagerFactory.cs
using System.IO;

namespace ELTE.DocuStat.Persistence
{
    public static class FileManagerFactory
    {
        public static IFileManager? CreateForPath(string path)
        {
            return Path.GetExtension(path).ToLower() switch
            {
                ".txt" => new TxtFileManager(path),
                ".pdf" => new PdfFileManager(path),
                _ => null
            };
        }
    }
}
EOF

# 7. IDocumentStatistics.cs
cat << 'EOF' > DocuStat/Model/IDocumentStatistics.cs
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace ELTE.DocuStat.Model
{
    public interface IDocumentStatistics
    {
        string FileContent { get; }
        IDictionary<string, int> DistinctWordCount { get; }
        int CharacterCount { get; }
        int NonWhiteSpaceCharacterCount { get; }
        int SentenceCount { get; }
        int ProperNounCount { get; }
        double ColemanLieuIndex { get; }
        double FleschReadingEase { get; }

        event EventHandler? FileContentReady;
        event EventHandler? TextStatisticsReady;

        Task LoadAsync();
    }
}
EOF

# 8. DocumentStatistics.cs
cat << 'EOF' > DocuStat/Model/DocumentStatistics.cs
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
            char[] endChars = new char[] { '.', '!', '?' };
            int count = 0;
            for (int i = 0; i < FileContent.Length; i++)
            {
                if (endChars.Contains(FileContent[i]) && (i == FileContent.Length - 1 || char.IsWhiteSpace(FileContent[i + 1])))
                {
                    count++;
                }
            }
            return Math.Max(1, count);
        }

        public int ComputeProperNounCount()
        {
            if (string.IsNullOrWhiteSpace(FileContent)) return 0;
            int count = 0;
            string[] tokens = FileContent.Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries);

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
            int count = Regex.Matches(word, "[aeiouy]+", RegexOptions.IgnoreCase).Count;
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
EOF

# 9. DocuStatView.csproj
cat << 'EOF' > DocuStatView/DocuStatView.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net8.0-windows</TargetFramework>
    <Nullable>enable</Nullable>
    <UseWindowsForms>true</UseWindowsForms>
    <ImplicitUsings>enable</ImplicitUsings>
    <EnableWindowsTargeting>true</EnableWindowsTargeting>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\DocuStat\DocuStat.csproj" />
  </ItemGroup>

</Project>
EOF

# 10. DocuStatControl.cs
cat << 'EOF' > DocuStatView/DocuStatControl.cs
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Threading.Tasks;
using System.Windows.Forms;
using ELTE.DocuStat.Model;
using ELTE.DocuStat.Persistence;

namespace ELTE.DocuStat.View
{
    public partial class DocuStatControl : UserControl
    {
        private IDocumentStatistics? _documentStatistics;
        private readonly string _prefixCharacters;
        private readonly string _prefixNonWhitespaceCharacters;
        private readonly string _prefixSentences;
        private readonly string _prefixProperNouns;
        private readonly string _prefixColemanLieuIndex;
        private readonly string _prefixFleschReadingEase;

        public DocuStatControl()
        {
            InitializeComponent();

            _prefixCharacters = labelCharacters.Text;
            _prefixNonWhitespaceCharacters = labelNonWhitespaceCharacters.Text;
            _prefixSentences = labelSentences.Text;
            _prefixProperNouns = labelProperNouns.Text;
            _prefixColemanLieuIndex = labelColemanLieuIndex.Text;
            _prefixFleschReadingEase = labelFleschReadingEase.Text;
        }

        public async Task LoadFileAsync(IFileManager fileManager)
        {
            _documentStatistics = new DocumentStatistics(fileManager);
            _documentStatistics.FileContentReady += UpdateFileContent;
            _documentStatistics.TextStatisticsReady += UpdateTextStatistics;
            await _documentStatistics.LoadAsync();
        }

        private void UpdateFileContent(object? sender, EventArgs e)
        {
            if (InvokeRequired)
            {
                BeginInvoke(() => UpdateFileContent(sender, e));
                return;
            }

            if (_documentStatistics != null)
            {
                textBox.Text = _documentStatistics.FileContent;
            }
        }

        private void UpdateTextStatistics(object? sender, EventArgs e)
        {
            if (InvokeRequired)
            {
                BeginInvoke(() => UpdateTextStatistics(sender, e));
                return;
            }

            if (_documentStatistics != null)
            {
                labelCharacters.Text = $"{_prefixCharacters} {_documentStatistics.CharacterCount}";
                labelNonWhitespaceCharacters.Text = $"{_prefixNonWhitespaceCharacters} {_documentStatistics.NonWhiteSpaceCharacterCount}";
                labelSentences.Text = $"{_prefixSentences} {_documentStatistics.SentenceCount}";
                labelProperNouns.Text = $"{_prefixProperNouns} {_documentStatistics.ProperNounCount}";
                labelColemanLieuIndex.Text = $"{_prefixColemanLieuIndex} {_documentStatistics.ColemanLieuIndex:F2}";
                labelFleschReadingEase.Text = $"{_prefixFleschReadingEase} {_documentStatistics.FleschReadingEase:F2}";
            }
        }

        public void CalculateStatistics()
        {
            if (_documentStatistics == null || string.IsNullOrEmpty(_documentStatistics.FileContent))
            {
                return;
            }

            int minLength = Convert.ToInt32(numericUpDownLength.Value);
            int minOccurrence = Convert.ToInt32(numericUpDownOccurrences.Value);

            var ignoredWords = textBoxIgnoredWords.Text.Split(',', StringSplitOptions.RemoveEmptyEntries)
                .Select(w => w.Trim().ToLower())
                .ToHashSet();

            var pairs = _documentStatistics.DistinctWordCount
                .Where(p => p.Value >= minOccurrence)
                .Where(p => p.Key.Length >= minLength)
                .Where(p => !ignoredWords.Contains(p.Key))
                .OrderByDescending(p => p.Value);

            listBoxCounter.Items.Clear();
            listBoxCounter.BeginUpdate();
            foreach (var pair in pairs)
            {
                listBoxCounter.Items.Add($"{pair.Key}: {pair.Value}");
            }
            listBoxCounter.EndUpdate();
        }
    }
}
EOF

# 11. DocuStatControl.Designer.cs
cat << 'EOF' > DocuStatView/DocuStatControl.Designer.cs
namespace ELTE.DocuStat.View
{
    partial class DocuStatControl
    {
        private System.ComponentModel.IContainer? components = null;

        private SplitContainer splitContainerMain = null!;
        private SplitContainer splitContainerTop = null!;
        private TextBox textBox = null!;
        private ListBox listBoxCounter = null!;
        private Panel panelParameters = null!;
        private Label labelCharacters = null!;
        private Label labelNonWhitespaceCharacters = null!;
        private Label labelSentences = null!;
        private Label labelProperNouns = null!;
        private Label labelColemanLieuIndex = null!;
        private Label labelFleschReadingEase = null!;
        private Label labelMinLength = null!;
        private Label labelMinOccurrence = null!;
        private Label labelIgnoredWords = null!;
        private NumericUpDown numericUpDownLength = null!;
        private NumericUpDown numericUpDownOccurrences = null!;
        private TextBox textBoxIgnoredWords = null!;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            splitContainerMain = new SplitContainer();
            splitContainerTop = new SplitContainer();
            textBox = new TextBox();
            listBoxCounter = new ListBox();
            panelParameters = new Panel();
            labelCharacters = new Label();
            labelNonWhitespaceCharacters = new Label();
            labelSentences = new Label();
            labelProperNouns = new Label();
            labelColemanLieuIndex = new Label();
            labelFleschReadingEase = new Label();
            labelMinLength = new Label();
            labelMinOccurrence = new Label();
            labelIgnoredWords = new Label();
            numericUpDownLength = new NumericUpDown();
            numericUpDownOccurrences = new NumericUpDown();
            textBoxIgnoredWords = new TextBox();

            ((System.ComponentModel.ISupportInitialize)splitContainerMain).BeginInit();
            splitContainerMain.Panel1.SuspendLayout();
            splitContainerMain.Panel2.SuspendLayout();
            splitContainerMain.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)splitContainerTop).BeginInit();
            splitContainerTop.Panel1.SuspendLayout();
            splitContainerTop.Panel2.SuspendLayout();
            splitContainerTop.SuspendLayout();
            panelParameters.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)numericUpDownLength).BeginInit();
            ((System.ComponentModel.ISupportInitialize)numericUpDownOccurrences).BeginInit();
            SuspendLayout();

            splitContainerMain.Dock = DockStyle.Fill;
            splitContainerMain.FixedPanel = FixedPanel.Panel2;
            splitContainerMain.Location = new System.Drawing.Point(0, 0);
            splitContainerMain.Name = "splitContainerMain";
            splitContainerMain.Orientation = Orientation.Horizontal;
            splitContainerMain.Panel1.Controls.Add(splitContainerTop);
            splitContainerMain.Panel2.Controls.Add(panelParameters);
            splitContainerMain.Size = new System.Drawing.Size(800, 500);
            splitContainerMain.SplitterDistance = 360;

            splitContainerTop.Dock = DockStyle.Fill;
            splitContainerTop.Location = new System.Drawing.Point(0, 0);
            splitContainerTop.Name = "splitContainerTop";
            splitContainerTop.Panel1.Controls.Add(textBox);
            splitContainerTop.Panel2.Controls.Add(listBoxCounter);
            splitContainerTop.Size = new System.Drawing.Size(800, 360);
            splitContainerTop.SplitterDistance = 400;

            textBox.Dock = DockStyle.Fill;
            textBox.Multiline = true;
            textBox.ReadOnly = true;
            textBox.ScrollBars = ScrollBars.Vertical;
            textBox.WordWrap = false;
            textBox.Name = "textBox";

            listBoxCounter.Dock = DockStyle.Fill;
            listBoxCounter.FormattingEnabled = true;
            listBoxCounter.Name = "listBoxCounter";

            panelParameters.Dock = DockStyle.Fill;
            panelParameters.Controls.Add(labelCharacters);
            panelParameters.Controls.Add(labelNonWhitespaceCharacters);
            panelParameters.Controls.Add(labelSentences);
            panelParameters.Controls.Add(labelProperNouns);
            panelParameters.Controls.Add(labelColemanLieuIndex);
            panelParameters.Controls.Add(labelFleschReadingEase);
            panelParameters.Controls.Add(labelMinLength);
            panelParameters.Controls.Add(labelMinOccurrence);
            panelParameters.Controls.Add(labelIgnoredWords);
            panelParameters.Controls.Add(numericUpDownLength);
            panelParameters.Controls.Add(numericUpDownOccurrences);
            panelParameters.Controls.Add(textBoxIgnoredWords);

            labelCharacters.AutoSize = true;
            labelCharacters.Location = new System.Drawing.Point(15, 20);
            labelCharacters.Text = "Character count:";

            labelNonWhitespaceCharacters.AutoSize = true;
            labelNonWhitespaceCharacters.Location = new System.Drawing.Point(15, 60);
            labelNonWhitespaceCharacters.Text = "Non-whitespace characters:";

            labelSentences.AutoSize = true;
            labelSentences.Location = new System.Drawing.Point(15, 100);
            labelSentences.Text = "Sentence count:";

            labelProperNouns.AutoSize = true;
            labelProperNouns.Location = new System.Drawing.Point(230, 20);
            labelProperNouns.Text = "Proper noun count:";

            labelColemanLieuIndex.AutoSize = true;
            labelColemanLieuIndex.Location = new System.Drawing.Point(230, 60);
            labelColemanLieuIndex.Text = "Coleman Lieu Index:";

            labelFleschReadingEase.AutoSize = true;
            labelFleschReadingEase.Location = new System.Drawing.Point(230, 100);
            labelFleschReadingEase.Text = "Flesch Reading Ease:";

            labelMinLength.AutoSize = true;
            labelMinLength.Location = new System.Drawing.Point(460, 20);
            labelMinLength.Text = "Minimum word length:";

            numericUpDownLength.Location = new System.Drawing.Point(630, 18);
            numericUpDownLength.Minimum = 1;
            numericUpDownLength.Value = 1;

            labelMinOccurrence.AutoSize = true;
            labelMinOccurrence.Location = new System.Drawing.Point(460, 60);
            labelMinOccurrence.Text = "Minimum word occurrence:";

            numericUpDownOccurrences.Location = new System.Drawing.Point(630, 58);
            numericUpDownOccurrences.Minimum = 1;
            numericUpDownOccurrences.Value = 1;

            labelIgnoredWords.AutoSize = true;
            labelIgnoredWords.Location = new System.Drawing.Point(460, 100);
            labelIgnoredWords.Text = "Ignored words:";

            textBoxIgnoredWords.Location = new System.Drawing.Point(560, 97);
            textBoxIgnoredWords.Size = new System.Drawing.Size(190, 23);

            AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            Controls.Add(splitContainerMain);
            Dock = DockStyle.Fill;
            Name = "DocuStatControl";
            Size = new System.Drawing.Size(800, 500);

            splitContainerMain.Panel1.ResumeLayout(false);
            splitContainerMain.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)splitContainerMain).EndInit();
            splitContainerMain.ResumeLayout(false);
            splitContainerTop.Panel1.ResumeLayout(false);
            splitContainerTop.Panel1.PerformLayout();
            splitContainerTop.Panel2.ResumeLayout(false);
            ((System.ComponentModel.ISupportInitialize)splitContainerTop).EndInit();
            splitContainerTop.ResumeLayout(false);
            panelParameters.ResumeLayout(false);
            panelParameters.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)numericUpDownLength).EndInit();
            ((System.ComponentModel.ISupportInitialize)numericUpDownOccurrences).EndInit();
            ResumeLayout(false);
        }
    }
}
EOF

# 12. DocuStatDialog.cs
cat << 'EOF' > DocuStatView/DocuStatDialog.cs
using System;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;
using ELTE.DocuStat.Persistence;

namespace ELTE.DocuStat.View
{
    public partial class DocuStatDialog : Form
    {
        public DocuStatDialog()
        {
            InitializeComponent();
        }

        private async void OpenDialog(object? sender, EventArgs e)
        {
            using OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
            openFileDialog.Filter = "Text files (*.txt)|*.txt|PDF files (*.pdf)|*.pdf|All files (*.*)|*.*";
            openFileDialog.RestoreDirectory = true;
            openFileDialog.Multiselect = true;

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                openFileDialogMenuItem.Enabled = false;
                countWordsMenuItem.Enabled = false;

                tabControl.TabPages.Clear();
                List<Task> tasks = new List<Task>();

                foreach (string fileName in openFileDialog.FileNames)
                {
                    tasks.Add(AddTabPageAsync(fileName));
                }

                await Task.WhenAll(tasks);

                openFileDialogMenuItem.Enabled = true;
                countWordsMenuItem.Enabled = true;
            }
        }

        private async Task AddTabPageAsync(string fileName)
        {
            IFileManager? fileManager = FileManagerFactory.CreateForPath(fileName);
            if (fileManager == null)
            {
                MessageBox.Show($"File reading is unsuccessful!{Environment.NewLine}Unsupported file format for: {fileName}",
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }

            TabPage? tabPage = null;
            try
            {
                DocuStatControl control = new DocuStatControl();
                Task loadTask = control.LoadFileAsync(fileManager);

                tabPage = new TabPage("Loading...");
                tabPage.Controls.Add(control);
                tabControl.TabPages.Add(tabPage);

                await loadTask;

                tabPage.Text = Path.GetFileName(fileName);
            }
            catch (FileManagerException ex)
            {
                if (tabPage != null && tabControl.TabPages.Contains(tabPage))
                {
                    tabControl.TabPages.Remove(tabPage);
                }
                MessageBox.Show($"File reading is unsuccessful!{Environment.NewLine}{ex.Message}",
                    "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return;
            }
        }

        private void CalculateStatistics(object? sender, EventArgs e)
        {
            if (tabControl.SelectedTab == null)
            {
                return;
            }

            (tabControl.SelectedTab.Controls[0] as DocuStatControl)!.CalculateStatistics();
        }
    }
}
EOF

# 13. DocuStatDialog.Designer.cs
cat << 'EOF' > DocuStatView/DocuStatDialog.Designer.cs
namespace ELTE.DocuStat.View
{
    partial class DocuStatDialog
    {
        private System.ComponentModel.IContainer? components = null;

        private MenuStrip menuStrip = null!;
        private ToolStripMenuItem fileToolStripMenuItem = null!;
        private ToolStripMenuItem openFileDialogMenuItem = null!;
        private ToolStripMenuItem countWordsMenuItem = null!;
        private TabControl tabControl = null!;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        private void InitializeComponent()
        {
            menuStrip = new MenuStrip();
            fileToolStripMenuItem = new ToolStripMenuItem();
            openFileDialogMenuItem = new ToolStripMenuItem();
            countWordsMenuItem = new ToolStripMenuItem();
            tabControl = new TabControl();

            menuStrip.SuspendLayout();
            SuspendLayout();

            menuStrip.Items.AddRange(new ToolStripItem[] { fileToolStripMenuItem, countWordsMenuItem });
            menuStrip.Location = new System.Drawing.Point(0, 0);
            menuStrip.Name = "menuStrip";
            menuStrip.Size = new System.Drawing.Size(820, 24);

            fileToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { openFileDialogMenuItem });
            fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            fileToolStripMenuItem.Text = "&File";

            openFileDialogMenuItem.Name = "openFileDialogMenuItem";
            openFileDialogMenuItem.Text = "&Open file...";
            openFileDialogMenuItem.Click += OpenDialog;

            countWordsMenuItem.Name = "countWordsMenuItem";
            countWordsMenuItem.Text = "&Count words";
            countWordsMenuItem.Click += CalculateStatistics;

            tabControl.Dock = DockStyle.Fill;
            tabControl.Location = new System.Drawing.Point(0, 24);
            tabControl.Name = "tabControl";
            tabControl.Size = new System.Drawing.Size(820, 526);

            AutoScaleDimensions = new System.Drawing.SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new System.Drawing.Size(820, 550);
            Controls.Add(tabControl);
            Controls.Add(menuStrip);
            MainMenuStrip = menuStrip;
            Name = "DocuStatDialog";
            Text = "Document Statistics";

            menuStrip.ResumeLayout(false);
            menuStrip.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }
    }
}
EOF

# 14. Program.cs
cat << 'EOF' > DocuStatView/Program.cs
using System;
using System.Windows.Forms;

namespace ELTE.DocuStat.View
{
    internal static class Program
    {
        [STAThread]
        static void Main()
        {
            ApplicationConfiguration.Initialize();
            Application.Run(new DocuStatDialog());
        }
    }
}
EOF

echo "=== Projektek hozzaadasa a Solution-hoz ==="
dotnet sln add DocuStat/DocuStat.csproj
dotnet sln add DocuStatView/DocuStatView.csproj

echo "=== Projekt forditasa (dotnet build) ==="
dotnet build

echo "=== KESZ! A teljes megoldas hibamentesen lefordult a DocuStatComplete mappaban. ==="
