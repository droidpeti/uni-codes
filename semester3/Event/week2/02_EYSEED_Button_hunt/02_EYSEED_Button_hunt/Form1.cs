namespace _02_EYSEED_Button_hunt
{
    public partial class Form1 : Form
    {
        private int points = 0;
        private System.Random generator = new Random();
        private DateTime startTime = new DateTime();
        private System.Windows.Forms.Timer timer = new System.Windows.Forms.Timer();
        public Form1()
        {
            InitializeComponent();
            timer.Interval = 1000;
            timer.Tick += UpdateStatusBar;
        }

        private void pushButton_Click(object sender, EventArgs e)
        {
            int x = ClientSize.Width - pushButton.Width;
            int y = ClientSize.Height - pushButton.Height - statusLabel.Height;
            pushButton.Location = new Point(generator.Next(x), generator.Next(y));
            if (!timer.Enabled)
            {
                startTime = DateTime.Now;
                timer.Start();
            }
            else
            {
                ++points;
            }
            UpdateStatusBar(sender, e);
        }

        private void UpdateStatusBar(object sender, EventArgs e)
        {
            double elapsedSeconds = (DateTime.Now - startTime).TotalSeconds;
            toolStripStatusLabel1.Text = $"Points: {points} | Elapsed time: {elapsedSeconds:F0} sec";
        }

        private void GameClosing(object sender, FormClosingEventArgs e)
        {
            if (e.CloseReason == CloseReason.UserClosing && timer.Enabled)
            {
                double elapsedSeconds = (DateTime.Now - startTime).TotalSeconds;
                double pushPerSeconds = points / elapsedSeconds;
                MessageBox.Show($"Pushes per seconds: {pushPerSeconds:F2}", "Results",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }
    }
}
