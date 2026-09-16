namespace Win_Forms_Eyseed
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            quitButton.Click += new EventHandler(quitButton_Click);
        }

        private void quitButton_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }
    }
}
