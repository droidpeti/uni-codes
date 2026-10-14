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

            // splitContainerMain
            splitContainerMain.Dock = DockStyle.Fill;
            splitContainerMain.FixedPanel = FixedPanel.Panel2;
            splitContainerMain.Location = new System.Drawing.Point(0, 0);
            splitContainerMain.Name = "splitContainerMain";
            splitContainerMain.Orientation = Orientation.Horizontal;
            splitContainerMain.Panel1.Controls.Add(splitContainerTop);
            splitContainerMain.Panel2.Controls.Add(panelParameters);
            splitContainerMain.Size = new System.Drawing.Size(800, 500);
            splitContainerMain.SplitterDistance = 360;

            // splitContainerTop
            splitContainerTop.Dock = DockStyle.Fill;
            splitContainerTop.Location = new System.Drawing.Point(0, 0);
            splitContainerTop.Name = "splitContainerTop";
            splitContainerTop.Panel1.Controls.Add(textBox);
            splitContainerTop.Panel2.Controls.Add(listBoxCounter);
            splitContainerTop.Size = new System.Drawing.Size(800, 360);
            splitContainerTop.SplitterDistance = 400;

            // textBox
            textBox.Dock = DockStyle.Fill;
            textBox.Multiline = true;
            textBox.ReadOnly = true;
            textBox.ScrollBars = ScrollBars.Vertical;
            textBox.WordWrap = false;
            textBox.Name = "textBox";

            // listBoxCounter
            listBoxCounter.Dock = DockStyle.Fill;
            listBoxCounter.FormattingEnabled = true;
            listBoxCounter.Name = "listBoxCounter";

            // panelParameters
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

            // Labels & Inputs
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

            // DocuStatControl
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
