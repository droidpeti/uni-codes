#nullable enable
namespace Minesweeper;

partial class MainForm
{
    private System.ComponentModel.IContainer? components = null;
    private MenuStrip _menuStrip = null!;
    private ToolStripMenuItem _fileMenuItem = null!;
    private ToolStripMenuItem _newGame6MenuItem = null!;
    private ToolStripMenuItem _newGame10MenuItem = null!;
    private ToolStripMenuItem _newGame16MenuItem = null!;
    private ToolStripSeparator _separator1 = null!;
    private ToolStripMenuItem _saveMenuItem = null!;
    private ToolStripMenuItem _loadMenuItem = null!;
    private ToolStripSeparator _separator2 = null!;
    private ToolStripMenuItem _exitMenuItem = null!;
    private StatusStrip _statusStrip = null!;
    private ToolStripStatusLabel _turnLabel = null!;
    private ToolStripStatusLabel _remainingLabel = null!;
    private Panel _boardPanel = null!;

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
        _menuStrip = new MenuStrip();
        _fileMenuItem = new ToolStripMenuItem();
        _newGame6MenuItem = new ToolStripMenuItem();
        _newGame10MenuItem = new ToolStripMenuItem();
        _newGame16MenuItem = new ToolStripMenuItem();
        _separator1 = new ToolStripSeparator();
        _saveMenuItem = new ToolStripMenuItem();
        _loadMenuItem = new ToolStripMenuItem();
        _separator2 = new ToolStripSeparator();
        _exitMenuItem = new ToolStripMenuItem();
        _statusStrip = new StatusStrip();
        _turnLabel = new ToolStripStatusLabel();
        _remainingLabel = new ToolStripStatusLabel();
        _boardPanel = new Panel();
        _menuStrip.SuspendLayout();
        _statusStrip.SuspendLayout();
        SuspendLayout();

        _menuStrip.Items.AddRange(new ToolStripItem[] { _fileMenuItem });
        _menuStrip.Location = new Point(0, 0);
        _menuStrip.Name = "_menuStrip";
        _menuStrip.Size = new Size(500, 24);
        _menuStrip.TabIndex = 0;
        _menuStrip.Text = "Menu";

        _fileMenuItem.DropDownItems.AddRange(new ToolStripItem[]
        {
            _newGame6MenuItem,
            _newGame10MenuItem,
            _newGame16MenuItem,
            _separator1,
            _saveMenuItem,
            _loadMenuItem,
            _separator2,
            _exitMenuItem
        });
        _fileMenuItem.Name = "_fileMenuItem";
        _fileMenuItem.Size = new Size(37, 20);
        _fileMenuItem.Text = "&File";

        _newGame6MenuItem.Name = "_newGame6MenuItem";
        _newGame6MenuItem.Size = new Size(180, 22);
        _newGame6MenuItem.Text = "New Game (6x6)";
        _newGame6MenuItem.Click += OnNewGame6Click;

        _newGame10MenuItem.Name = "_newGame10MenuItem";
        _newGame10MenuItem.Size = new Size(180, 22);
        _newGame10MenuItem.Text = "New Game (10x10)";
        _newGame10MenuItem.Click += OnNewGame10Click;

        _newGame16MenuItem.Name = "_newGame16MenuItem";
        _newGame16MenuItem.Size = new Size(180, 22);
        _newGame16MenuItem.Text = "New Game (16x16)";
        _newGame16MenuItem.Click += OnNewGame16Click;

        _separator1.Name = "_separator1";
        _separator1.Size = new Size(177, 6);

        _saveMenuItem.Name = "_saveMenuItem";
        _saveMenuItem.Size = new Size(180, 22);
        _saveMenuItem.Text = "&Save Game...";
        _saveMenuItem.Click += OnSaveGameClick;

        _loadMenuItem.Name = "_loadMenuItem";
        _loadMenuItem.Size = new Size(180, 22);
        _loadMenuItem.Text = "&Load Game...";
        _loadMenuItem.Click += OnLoadGameClick;

        _separator2.Name = "_separator2";
        _separator2.Size = new Size(177, 6);

        _exitMenuItem.Name = "_exitMenuItem";
        _exitMenuItem.Size = new Size(180, 22);
        _exitMenuItem.Text = "E&xit";
        _exitMenuItem.Click += OnExitClick;

        _statusStrip.Items.AddRange(new ToolStripItem[] { _turnLabel, _remainingLabel });
        _statusStrip.Location = new Point(0, 478);
        _statusStrip.Name = "_statusStrip";
        _statusStrip.Size = new Size(500, 22);
        _statusStrip.TabIndex = 1;
        _statusStrip.Text = "Status";

        _turnLabel.Name = "_turnLabel";
        _turnLabel.Size = new Size(110, 17);
        _turnLabel.Text = "Turn: Player 1";

        _remainingLabel.Name = "_remainingLabel";
        _remainingLabel.Size = new Size(160, 17);
        _remainingLabel.Text = "| Safe cells left: 30";

        _boardPanel.Location = new Point(10, 34);
        _boardPanel.Name = "_boardPanel";
        _boardPanel.Size = new Size(300, 300);
        _boardPanel.TabIndex = 2;

        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(500, 500);
        Controls.Add(_boardPanel);
        Controls.Add(_statusStrip);
        Controls.Add(_menuStrip);
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MainMenuStrip = _menuStrip;
        MaximizeBox = false;
        Name = "MainForm";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "Two-Player Minesweeper";
        _menuStrip.ResumeLayout(false);
        _menuStrip.PerformLayout();
        _statusStrip.ResumeLayout(false);
        _statusStrip.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }
}
