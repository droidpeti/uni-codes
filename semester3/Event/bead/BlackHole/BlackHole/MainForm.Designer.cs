#nullable enable
namespace BlackHole;

partial class MainForm
{
    private System.ComponentModel.IContainer? components = null;
    private MenuStrip _menuStrip = null!;
    private ToolStripMenuItem _fileMenuItem = null!;
    private ToolStripMenuItem _newGame5MenuItem = null!;
    private ToolStripMenuItem _newGame7MenuItem = null!;
    private ToolStripMenuItem _newGame9MenuItem = null!;
    private ToolStripSeparator _separator1 = null!;
    private ToolStripMenuItem _saveMenuItem = null!;
    private ToolStripMenuItem _loadMenuItem = null!;
    private ToolStripSeparator _separator2 = null!;
    private ToolStripMenuItem _exitMenuItem = null!;
    private StatusStrip _statusStrip = null!;
    private ToolStripStatusLabel _turnLabel = null!;
    private ToolStripStatusLabel _scoreLabel = null!;
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
        _newGame5MenuItem = new ToolStripMenuItem();
        _newGame7MenuItem = new ToolStripMenuItem();
        _newGame9MenuItem = new ToolStripMenuItem();
        _separator1 = new ToolStripSeparator();
        _saveMenuItem = new ToolStripMenuItem();
        _loadMenuItem = new ToolStripMenuItem();
        _separator2 = new ToolStripSeparator();
        _exitMenuItem = new ToolStripMenuItem();
        _statusStrip = new StatusStrip();
        _turnLabel = new ToolStripStatusLabel();
        _scoreLabel = new ToolStripStatusLabel();
        _boardPanel = new Panel();
        _menuStrip.SuspendLayout();
        _statusStrip.SuspendLayout();
        SuspendLayout();

        _menuStrip.Items.AddRange(new ToolStripItem[] { _fileMenuItem });
        _menuStrip.Location = new Point(0, 0);
        _menuStrip.Name = "_menuStrip";
        _menuStrip.Size = new Size(600, 24);
        _menuStrip.TabIndex = 0;
        _menuStrip.Text = "Menu";

        _fileMenuItem.DropDownItems.AddRange(new ToolStripItem[]
        {
            _newGame5MenuItem,
            _newGame7MenuItem,
            _newGame9MenuItem,
            _separator1,
            _saveMenuItem,
            _loadMenuItem,
            _separator2,
            _exitMenuItem
        });
        _fileMenuItem.Name = "_fileMenuItem";
        _fileMenuItem.Size = new Size(37, 20);
        _fileMenuItem.Text = "&File";

        _newGame5MenuItem.Name = "_newGame5MenuItem";
        _newGame5MenuItem.Size = new Size(180, 22);
        _newGame5MenuItem.Text = "New Game (5x5)";
        _newGame5MenuItem.Click += OnNewGame5Click;

        _newGame7MenuItem.Name = "_newGame7MenuItem";
        _newGame7MenuItem.Size = new Size(180, 22);
        _newGame7MenuItem.Text = "New Game (7x7)";
        _newGame7MenuItem.Click += OnNewGame7Click;

        _newGame9MenuItem.Name = "_newGame9MenuItem";
        _newGame9MenuItem.Size = new Size(180, 22);
        _newGame9MenuItem.Text = "New Game (9x9)";
        _newGame9MenuItem.Click += OnNewGame9Click;

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

        _statusStrip.Items.AddRange(new ToolStripItem[] { _turnLabel, _scoreLabel });
        _statusStrip.Location = new Point(0, 578);
        _statusStrip.Name = "_statusStrip";
        _statusStrip.Size = new Size(600, 22);
        _statusStrip.TabIndex = 1;
        _statusStrip.Text = "Status";

        _turnLabel.Name = "_turnLabel";
        _turnLabel.Size = new Size(120, 17);
        _turnLabel.Text = "Turn: Player 1 (Red)";

        _scoreLabel.Name = "_scoreLabel";
        _scoreLabel.Size = new Size(150, 17);
        _scoreLabel.Text = "Score: P1: 0 | P2: 0";

        _boardPanel.Location = new Point(10, 34);
        _boardPanel.Name = "_boardPanel";
        _boardPanel.Size = new Size(400, 400);
        _boardPanel.TabIndex = 2;

        AutoScaleDimensions = new SizeF(7F, 15F);
        AutoScaleMode = AutoScaleMode.Font;
        ClientSize = new Size(600, 600);
        Controls.Add(_boardPanel);
        Controls.Add(_statusStrip);
        Controls.Add(_menuStrip);
        FormBorderStyle = FormBorderStyle.FixedSingle;
        KeyPreview = true;
        MainMenuStrip = _menuStrip;
        MaximizeBox = false;
        Name = "MainForm";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "Black Hole";
        _menuStrip.ResumeLayout(false);
        _menuStrip.PerformLayout();
        _statusStrip.ResumeLayout(false);
        _statusStrip.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }
}
