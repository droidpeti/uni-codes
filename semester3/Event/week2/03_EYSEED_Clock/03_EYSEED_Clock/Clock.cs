using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;

namespace _03_EYSEED_Clock
{
    public partial class Clock : UserControl
    {
        private int timeZone;
        private System.Windows.Forms.Timer timer = new System.Windows.Forms.Timer();
        [Category("Appearance")]
        [Description("The City.")]
        public string City
        {
            get => cityLabel.Text;
            set => cityLabel.Text = value;
        }
        [Category("Appearance")]
        [Description("The hour offset of the timezone.")]
        public int TimeZone
        {
            get { return timeZone; }
            set
            {
                timeZone = value;
                RefreshTime(this, EventArgs.Empty);
            }
        }
        private void RefreshTime(object sender, EventArgs e)
        {
            DateTime time = DateTime.Now;
            timeLabel.Text = time
            .AddHours(TimeZone)
            .ToString(time.Second % 2 == 0 ? "HH:mm" : "HH mm");
        }
        public Clock()
        {
            InitializeComponent();
            timer.Interval = 1000;
            timer.Tick += RefreshTime;
        }

        
    }
}
