using System;
using System.Drawing;
using System.Windows.Forms;
using Hunt.Model;

namespace Hunt
{
    public partial class MainForm : Form
    {
        private HuntGameModel _model;
        private MenuStrip _menuStrip;
        private StatusStrip _statusStrip;
        private ToolStripStatusLabel _statusLabel;
        private TableLayoutPanel _gridPanel;
        private Button[,] _buttons;

        private int _selectedX = -1;
        private int _selectedY = -1;

        public MainForm()
        {
            InitializeUI();

            _model = new HuntGameModel(new HuntDataAccess());
            _model.GameAdvanced += Model_GameAdvanced;
            _model.GameOver += Model_GameOver;

            _model.NewGame(3);
        }

        private void InitializeUI()
        {
            this.Text = "Hunt Game";
            this.FormBorderStyle = FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;

            _menuStrip = new MenuStrip();
            var fileMenu = new ToolStripMenuItem("File");

            var newGameMenu = new ToolStripMenuItem("New Game");
            newGameMenu.DropDownItems.Add("3x3", null, (s, e) => _model.NewGame(3));
            newGameMenu.DropDownItems.Add("5x5", null, (s, e) => _model.NewGame(5));
            newGameMenu.DropDownItems.Add("7x7", null, (s, e) => _model.NewGame(7));

            fileMenu.DropDownItems.Add(newGameMenu);
            fileMenu.DropDownItems.Add("Save Game", null, async (s, e) => await SaveGame());
            fileMenu.DropDownItems.Add("Load Game", null, async (s, e) => await LoadGame());
            fileMenu.DropDownItems.Add("-");
            fileMenu.DropDownItems.Add("Exit", null, (s, e) => this.Close());

            _menuStrip.Items.Add(fileMenu);
            this.Controls.Add(_menuStrip);
            this.MainMenuStrip = _menuStrip;

            _statusStrip = new StatusStrip();
            _statusLabel = new ToolStripStatusLabel();
            _statusStrip.Items.Add(_statusLabel);
            this.Controls.Add(_statusStrip);

            _gridPanel = new TableLayoutPanel();
            _gridPanel.Dock = DockStyle.Fill;
            this.Controls.Add(_gridPanel);
            _gridPanel.BringToFront();
        }

        private void GenerateGrid(int size)
        {
            _gridPanel.Controls.Clear();
            _gridPanel.ColumnStyles.Clear();
            _gridPanel.RowStyles.Clear();

            _gridPanel.ColumnCount = size;
            _gridPanel.RowCount = size;
            _buttons = new Button[size, size];

            int buttonSize = 60;
            this.ClientSize = new Size(size * buttonSize, size * buttonSize + _menuStrip.Height + _statusStrip.Height);

            for (int i = 0; i < size; i++)
            {
                _gridPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100f / size));
                _gridPanel.RowStyles.Add(new RowStyle(SizeType.Percent, 100f / size));

                for (int j = 0; j < size; j++)
                {
                    Button btn = new Button
                    {
                        Dock = DockStyle.Fill,
                        Margin = new Padding(1),
                        Font = new Font("Arial", 16, FontStyle.Bold),
                        Tag = new Point(i, j)
                    };
                    btn.Click += GridButton_Click;
                    _buttons[i, j] = btn;
                    _gridPanel.Controls.Add(btn, j, i);
                }
            }
        }

        private void GridButton_Click(object sender, EventArgs e)
        {
            Button btn = sender as Button;
            Point pos = (Point)btn.Tag;

            if (_selectedX == -1)
            {
                if ((_model.CurrentPlayer == Player.Escaper && _model.Board[pos.X, pos.Y] == Field.Escaper) ||
                    (_model.CurrentPlayer == Player.Attacker && _model.Board[pos.X, pos.Y] == Field.Attacker))
                {
                    _selectedX = pos.X;
                    _selectedY = pos.Y;
                    btn.BackColor = Color.LightYellow;
                }
            }
            else
            {
                int fromX = _selectedX;
                int fromY = _selectedY;
                _selectedX = -1;
                _selectedY = -1;

                _model.Move(fromX, fromY, pos.X, pos.Y);
            }
        }

        private void Model_GameAdvanced(object sender, GameEventArgs e)
        {
            if (_buttons == null || _buttons.GetLength(0) != _model.BoardSize)
            {
                GenerateGrid(_model.BoardSize);
            }

            UpdateGrid();
            _statusLabel.Text = $"Turn: {_model.CurrentPlayer} | Rounds: {e.RoundsPlayed}/{_model.MaxRounds}";
        }

        private void Model_GameOver(object sender, GameEventArgs e)
        {
            UpdateGrid();
            string winnerStr = e.Winner == Player.Escaper ? "Escaper" : "Attacker";
            MessageBox.Show($"Game Over! Winner: {winnerStr}\nRounds played: {e.RoundsPlayed}", "Game Over", MessageBoxButtons.OK, MessageBoxIcon.Information);

            _model.NewGame(_model.BoardSize);
        }

        private void UpdateGrid()
        {
            for (int i = 0; i < _model.BoardSize; i++)
            {
                for (int j = 0; j < _model.BoardSize; j++)
                {
                    _buttons[i, j].BackColor = SystemColors.Control;
                    switch (_model.Board[i, j])
                    {
                        case Field.Empty:
                            _buttons[i, j].Text = "";
                            break;
                        case Field.Escaper:
                            _buttons[i, j].Text = "🏃";
                            _buttons[i, j].ForeColor = Color.Blue;
                            break;
                        case Field.Attacker:
                            _buttons[i, j].Text = "⚔️";
                            _buttons[i, j].ForeColor = Color.Red;
                            break;
                    }
                }
            }
        }

        private async Task SaveGame()
        {
            using (SaveFileDialog dlg = new SaveFileDialog { Filter = "Hunt Save|*.hunt" })
            {
                if (dlg.ShowDialog() == DialogResult.OK)
                {
                    await _model.SaveGameAsync(dlg.FileName);
                }
            }
        }

        private async Task LoadGame()
        {
            using (OpenFileDialog dlg = new OpenFileDialog { Filter = "Hunt Save|*.hunt" })
            {
                if (dlg.ShowDialog() == DialogResult.OK)
                {
                    await _model.LoadGameAsync(dlg.FileName);
                }
            }
        }
    }
}
