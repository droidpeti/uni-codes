namespace _02_EYSEED_Button_hunt
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
            pushButton = new Button();
            statusLabel = new StatusStrip();
            toolStripStatusLabel1 = new ToolStripStatusLabel();
            statusLabel.SuspendLayout();
            SuspendLayout();
            // 
            // pushButton
            // 
            pushButton.Font = new Font("Segoe UI", 15.75F, FontStyle.Bold, GraphicsUnit.Point, 238);
            pushButton.Location = new Point(177, 138);
            pushButton.Name = "pushButton";
            pushButton.Size = new Size(162, 72);
            pushButton.TabIndex = 0;
            pushButton.Text = "PUSH ME";
            pushButton.UseVisualStyleBackColor = true;
            pushButton.Click += pushButton_Click;
            // 
            // statusLabel
            // 
            statusLabel.Items.AddRange(new ToolStripItem[] { toolStripStatusLabel1 });
            statusLabel.Location = new Point(0, 428);
            statusLabel.Name = "statusLabel";
            statusLabel.Size = new Size(800, 22);
            statusLabel.TabIndex = 1;
            statusLabel.Text = "Click the button to start the game!";
            // 
            // toolStripStatusLabel1
            // 
            toolStripStatusLabel1.Name = "toolStripStatusLabel1";
            toolStripStatusLabel1.Size = new Size(188, 17);
            toolStripStatusLabel1.Text = "Click the button to start the game!";
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(statusLabel);
            Controls.Add(pushButton);
            MinimumSize = new Size(300, 300);
            Name = "Form1";
            Text = "ButtonHunter";
            FormClosing += GameClosing;
            statusLabel.ResumeLayout(false);
            statusLabel.PerformLayout();
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button pushButton;
        private StatusStrip statusLabel;
        private ToolStripStatusLabel toolStripStatusLabel1;
    }
}
