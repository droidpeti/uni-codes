namespace _03_EYSEED_Clock
{
    partial class Form1
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
            flowLayoutPanel1 = new FlowLayoutPanel();
            clock1 = new Clock();
            clock2 = new Clock();
            clock3 = new Clock();
            clock4 = new Clock();
            flowLayoutPanel1.SuspendLayout();
            SuspendLayout();
            // 
            // flowLayoutPanel1
            // 
            flowLayoutPanel1.Controls.Add(clock1);
            flowLayoutPanel1.Controls.Add(clock2);
            flowLayoutPanel1.Controls.Add(clock3);
            flowLayoutPanel1.Controls.Add(clock4);
            flowLayoutPanel1.Dock = DockStyle.Fill;
            flowLayoutPanel1.Location = new Point(0, 0);
            flowLayoutPanel1.Name = "flowLayoutPanel1";
            flowLayoutPanel1.Size = new Size(405, 287);
            flowLayoutPanel1.TabIndex = 0;
            // 
            // clock1
            // 
            clock1.BorderStyle = BorderStyle.FixedSingle;
            clock1.City = "Budapest";
            clock1.Location = new Point(3, 3);
            clock1.Name = "clock1";
            clock1.Size = new Size(190, 129);
            clock1.TabIndex = 0;
            clock1.TimeZone = 0;
            // 
            // clock2
            // 
            clock2.BorderStyle = BorderStyle.FixedSingle;
            clock2.City = "London";
            clock2.Location = new Point(199, 3);
            clock2.Name = "clock2";
            clock2.Size = new Size(190, 129);
            clock2.TabIndex = 1;
            clock2.TimeZone = -1;
            // 
            // clock3
            // 
            clock3.BorderStyle = BorderStyle.FixedSingle;
            clock3.City = "Tokyo";
            clock3.Location = new Point(3, 138);
            clock3.Name = "clock3";
            clock3.Size = new Size(190, 129);
            clock3.TabIndex = 2;
            clock3.TimeZone = 8;
            // 
            // clock4
            // 
            clock4.BorderStyle = BorderStyle.FixedSingle;
            clock4.City = "Wellington";
            clock4.Location = new Point(199, 138);
            clock4.Name = "clock4";
            clock4.Size = new Size(190, 129);
            clock4.TabIndex = 3;
            clock4.TimeZone = 11;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(405, 287);
            Controls.Add(flowLayoutPanel1);
            Name = "Form1";
            Text = "Form1";
            flowLayoutPanel1.ResumeLayout(false);
            ResumeLayout(false);
        }

        #endregion

        private FlowLayoutPanel flowLayoutPanel1;
        private Clock clock1;
        private Clock clock2;
        private Clock clock3;
        private Clock clock4;
    }
}
