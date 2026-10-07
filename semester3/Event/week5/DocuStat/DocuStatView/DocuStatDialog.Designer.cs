namespace DocuStatView
{
    partial class DocuStatDialog
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            menuStrip1 = new MenuStrip();
            fileMenu = new ToolStripMenuItem();
            openFileDialogMenuItem = new ToolStripMenuItem();
            countWordsMenuItem = new ToolStripMenuItem();
            textBox = new TextBox();
            listBoxCounter = new ListBox();
            label1 = new Label();
            label2 = new Label();
            label3 = new Label();
            labelFleschReadingEase = new Label();
            labelColemanLieuIndex = new Label();
            labelProperNouns = new Label();
            labelSentences = new Label();
            labelNonWhitespaceCharacters = new Label();
            labelCharacters = new Label();
            spinBoxMinLength = new NumericUpDown();
            spinBoxMinOccurrence = new NumericUpDown();
            textBoxIgnoredWords = new TextBox();
            menuStrip1.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)spinBoxMinLength).BeginInit();
            ((System.ComponentModel.ISupportInitialize)spinBoxMinOccurrence).BeginInit();
            SuspendLayout();
            // 
            // menuStrip1
            // 
            menuStrip1.Items.AddRange(new ToolStripItem[] { fileMenu });
            menuStrip1.Location = new Point(0, 0);
            menuStrip1.Name = "menuStrip1";
            menuStrip1.Size = new Size(800, 24);
            menuStrip1.TabIndex = 0;
            menuStrip1.Text = "menuStrip1";
            // 
            // fileMenu
            // 
            fileMenu.DropDownItems.AddRange(new ToolStripItem[] { openFileDialogMenuItem, countWordsMenuItem });
            fileMenu.ImageScaling = ToolStripItemImageScaling.None;
            fileMenu.Name = "fileMenu";
            fileMenu.Size = new Size(37, 20);
            fileMenu.Text = "File";
            // 
            // openFileDialogMenuItem
            // 
            openFileDialogMenuItem.Name = "openFileDialogMenuItem";
            openFileDialogMenuItem.Size = new Size(158, 22);
            openFileDialogMenuItem.Text = "Open file dialog";
            openFileDialogMenuItem.Click += OpenDialog;
            // 
            // countWordsMenuItem
            // 
            countWordsMenuItem.Name = "countWordsMenuItem";
            countWordsMenuItem.Size = new Size(158, 22);
            countWordsMenuItem.Text = "Count words";
            countWordsMenuItem.Click += CountWords;
            // 
            // textBox
            // 
            textBox.Location = new Point(0, 27);
            textBox.Multiline = true;
            textBox.Name = "textBox";
            textBox.ReadOnly = true;
            textBox.ScrollBars = ScrollBars.Vertical;
            textBox.Size = new Size(389, 302);
            textBox.TabIndex = 1;
            // 
            // listBoxCounter
            // 
            listBoxCounter.FormattingEnabled = true;
            listBoxCounter.Location = new Point(395, 27);
            listBoxCounter.Name = "listBoxCounter";
            listBoxCounter.Size = new Size(405, 274);
            listBoxCounter.TabIndex = 2;
            // 
            // label1
            // 
            label1.AutoSize = true;
            label1.Location = new Point(499, 316);
            label1.Name = "label1";
            label1.Size = new Size(130, 15);
            label1.TabIndex = 3;
            label1.Text = "Minimum word length:";
            // 
            // label2
            // 
            label2.AutoSize = true;
            label2.Location = new Point(499, 366);
            label2.Name = "label2";
            label2.Size = new Size(155, 15);
            label2.TabIndex = 4;
            label2.Text = "Minimum word occurrence:";
            // 
            // label3
            // 
            label3.AutoSize = true;
            label3.Location = new Point(499, 410);
            label3.Name = "label3";
            label3.Size = new Size(86, 15);
            label3.TabIndex = 5;
            label3.Text = "Ignored words:";
            // 
            // labelFleschReadingEase
            // 
            labelFleschReadingEase.AutoSize = true;
            labelFleschReadingEase.Location = new Point(194, 410);
            labelFleschReadingEase.Name = "labelFleschReadingEase";
            labelFleschReadingEase.Size = new Size(118, 15);
            labelFleschReadingEase.TabIndex = 6;
            labelFleschReadingEase.Text = " Flesch Reading Ease:";
            // 
            // labelColemanLieuIndex
            // 
            labelColemanLieuIndex.AutoSize = true;
            labelColemanLieuIndex.Location = new Point(194, 366);
            labelColemanLieuIndex.Name = "labelColemanLieuIndex";
            labelColemanLieuIndex.Size = new Size(114, 15);
            labelColemanLieuIndex.TabIndex = 7;
            labelColemanLieuIndex.Text = " Coleman Lieu Index";
            // 
            // labelProperNouns
            // 
            labelProperNouns.AutoSize = true;
            labelProperNouns.Location = new Point(194, 332);
            labelProperNouns.Name = "labelProperNouns";
            labelProperNouns.Size = new Size(110, 15);
            labelProperNouns.TabIndex = 8;
            labelProperNouns.Text = "Proper noun count:";
            // 
            // labelSentences
            // 
            labelSentences.AutoSize = true;
            labelSentences.Location = new Point(12, 410);
            labelSentences.Name = "labelSentences";
            labelSentences.Size = new Size(95, 15);
            labelSentences.TabIndex = 9;
            labelSentences.Text = " Sentence count:";
            // 
            // labelNonWhitespaceCharacters
            // 
            labelNonWhitespaceCharacters.AutoSize = true;
            labelNonWhitespaceCharacters.Location = new Point(12, 366);
            labelNonWhitespaceCharacters.Name = "labelNonWhitespaceCharacters";
            labelNonWhitespaceCharacters.Size = new Size(154, 15);
            labelNonWhitespaceCharacters.TabIndex = 10;
            labelNonWhitespaceCharacters.Text = "Non-whitespace characters:";
            // 
            // labelCharacters
            // 
            labelCharacters.AutoSize = true;
            labelCharacters.Location = new Point(12, 332);
            labelCharacters.Name = "labelCharacters";
            labelCharacters.Size = new Size(95, 15);
            labelCharacters.TabIndex = 11;
            labelCharacters.Text = "Character count:";
            // 
            // spinBoxMinLength
            // 
            spinBoxMinLength.Location = new Point(635, 314);
            spinBoxMinLength.Minimum = new decimal(new int[] { 1, 0, 0, 0 });
            spinBoxMinLength.Name = "spinBoxMinLength";
            spinBoxMinLength.Size = new Size(120, 23);
            spinBoxMinLength.TabIndex = 12;
            spinBoxMinLength.Value = new decimal(new int[] { 1, 0, 0, 0 });
            // 
            // spinBoxMinOccurrence
            // 
            spinBoxMinOccurrence.Location = new Point(660, 364);
            spinBoxMinOccurrence.Maximum = new decimal(new int[] { 500, 0, 0, 0 });
            spinBoxMinOccurrence.Minimum = new decimal(new int[] { 1, 0, 0, 0 });
            spinBoxMinOccurrence.Name = "spinBoxMinOccurrence";
            spinBoxMinOccurrence.Size = new Size(120, 23);
            spinBoxMinOccurrence.TabIndex = 13;
            spinBoxMinOccurrence.Value = new decimal(new int[] { 1, 0, 0, 0 });
            // 
            // textBoxIgnoredWords
            // 
            textBoxIgnoredWords.Location = new Point(591, 407);
            textBoxIgnoredWords.Name = "textBoxIgnoredWords";
            textBoxIgnoredWords.Size = new Size(100, 23);
            textBoxIgnoredWords.TabIndex = 14;
            // 
            // DocuStatDialog
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(textBoxIgnoredWords);
            Controls.Add(spinBoxMinOccurrence);
            Controls.Add(spinBoxMinLength);
            Controls.Add(labelCharacters);
            Controls.Add(labelNonWhitespaceCharacters);
            Controls.Add(labelSentences);
            Controls.Add(labelProperNouns);
            Controls.Add(labelColemanLieuIndex);
            Controls.Add(labelFleschReadingEase);
            Controls.Add(label3);
            Controls.Add(label2);
            Controls.Add(label1);
            Controls.Add(listBoxCounter);
            Controls.Add(textBox);
            Controls.Add(menuStrip1);
            FormBorderStyle = FormBorderStyle.FixedSingle;
            MainMenuStrip = menuStrip1;
            MaximizeBox = false;
            Name = "DocuStatDialog";
            Text = "Document statistics";
            menuStrip1.ResumeLayout(false);
            menuStrip1.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)spinBoxMinLength).EndInit();
            ((System.ComponentModel.ISupportInitialize)spinBoxMinOccurrence).EndInit();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private MenuStrip menuStrip1;
        private ToolStripMenuItem fileMenu;
        private ToolStripMenuItem openFileDialogMenuItem;
        private ToolStripMenuItem countWordsMenuItem;
        private TextBox textBox;
        private ListBox listBoxCounter;
        private Label label1;
        private Label label2;
        private Label label3;
        private Label labelFleschReadingEase;
        private Label labelColemanLieuIndex;
        private Label labelProperNouns;
        private Label labelSentences;
        private Label labelNonWhitespaceCharacters;
        private Label labelCharacters;
        private NumericUpDown spinBoxMinLength;
        private NumericUpDown spinBoxMinOccurrence;
        private TextBox textBoxIgnoredWords;
    }
}
