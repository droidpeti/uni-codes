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

            // menuStrip
            menuStrip.Items.AddRange(new ToolStripItem[] { fileToolStripMenuItem, countWordsMenuItem });
            menuStrip.Location = new System.Drawing.Point(0, 0);
            menuStrip.Name = "menuStrip";
            menuStrip.Size = new System.Drawing.Size(820, 24);

            // fileToolStripMenuItem
            fileToolStripMenuItem.DropDownItems.AddRange(new ToolStripItem[] { openFileDialogMenuItem });
            fileToolStripMenuItem.Name = "fileToolStripMenuItem";
            fileToolStripMenuItem.Text = "&File";

            // openFileDialogMenuItem
            openFileDialogMenuItem.Name = "openFileDialogMenuItem";
            openFileDialogMenuItem.Text = "&Open file...";
            openFileDialogMenuItem.Click += OpenDialog;

            // countWordsMenuItem
            countWordsMenuItem.Name = "countWordsMenuItem";
            countWordsMenuItem.Text = "&Count words";
            countWordsMenuItem.Click += CalculateStatistics;

            // tabControl
            tabControl.Dock = DockStyle.Fill;
            tabControl.Location = new System.Drawing.Point(0, 24);
            tabControl.Name = "tabControl";
            tabControl.Size = new System.Drawing.Size(820, 526);

            // DocuStatDialog
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
