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
