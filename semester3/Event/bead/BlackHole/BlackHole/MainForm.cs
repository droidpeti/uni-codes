using BlackHole.Model;

namespace BlackHole;

public partial class MainForm : Form
{
    private const int CellSize = 65;
    private readonly BlackHoleGameModel _model;
    private Button[,] _buttons = null!;

    public MainForm()
    {
        InitializeComponent();

        _model = new BlackHoleGameModel(new BlackHoleDataAccess());
        _model.GameChanged += OnGameChanged;
        _model.GameOver += OnGameOver;

        KeyDown += OnMainFormKeyDown;

        GenerateBoard();
        UpdateBoard();
    }

    private void GenerateBoard()
    {
        _boardPanel.Controls.Clear();
        int n = _model.Size;
        _buttons = new Button[n, n];

        for (int r = 0; r < n; r++)
        {
            for (int c = 0; c < n; c++)
            {
                Button btn = new Button
                {
                    Location = new Point(c * CellSize, r * CellSize),
                    Size = new Size(CellSize, CellSize),
                    FlatStyle = FlatStyle.Flat,
                    Font = new Font(FontFamily.GenericSansSerif, 14, FontStyle.Bold),
                    Tag = (r, c),
                    TabStop = false
                };
                btn.Click += OnCellClick;
                _buttons[r, c] = btn;
                _boardPanel.Controls.Add(btn);
            }
        }

        int boardPixels = n * CellSize;
        _boardPanel.Size = new Size(boardPixels, boardPixels);
        ClientSize = new Size(
            boardPixels + 20,
            boardPixels + _menuStrip.Height + _statusStrip.Height + 20
        );
    }

    private void UpdateBoard()
    {
        int n = _model.Size;
        if (_buttons == null || _buttons.GetLength(0) != n)
        {
            GenerateBoard();
        }

        for (int r = 0; r < n; r++)
        {
            for (int c = 0; c < n; c++)
            {
                Button btn = _buttons![r, c];
                Field field = _model.GetField(r, c);
                bool isSelected = _model.SelectedShip.HasValue &&
                                  _model.SelectedShip.Value.Row == r &&
                                  _model.SelectedShip.Value.Col == c;

                switch (field)
                {
                    case Field.BlackHole:
                        btn.BackColor = Color.Black;
                        btn.ForeColor = Color.White;
                        btn.Text = "●";
                        break;
                    case Field.Player1Ship:
                        btn.BackColor = isSelected ? Color.Gold : Color.IndianRed;
                        btn.ForeColor = Color.White;
                        btn.Text = "▲";
                        break;
                    case Field.Player2Ship:
                        btn.BackColor = isSelected ? Color.Gold : Color.SteelBlue;
                        btn.ForeColor = Color.White;
                        btn.Text = "▲";
                        break;
                    case Field.Empty:
                        btn.BackColor = Color.WhiteSmoke;
                        btn.ForeColor = Color.Black;
                        btn.Text = string.Empty;
                        break;
                }
            }
        }

        string playerText = _model.CurrentPlayer == Player.Player1 ? "Player 1 (Red)" : "Player 2 (Blue)";
        _turnLabel.Text = $"Turn: {playerText}";
        _scoreLabel.Text = $"In Black Hole - P1: {_model.Player1Entered}/{_model.TargetShips} | P2: {_model.Player2Entered}/{_model.TargetShips}";
    }

    private void OnCellClick(object? sender, EventArgs e)
    {
        if (sender is Button { Tag: ValueTuple<int, int> pos })
        {
            _model.SelectCell(pos.Item1, pos.Item2);
        }
    }

    private void OnMainFormKeyDown(object? sender, KeyEventArgs e)
    {
        if (!_model.SelectedShip.HasValue)
            return;

        var (r, c) = _model.SelectedShip.Value;
        switch (e.KeyCode)
        {
            case Keys.Up:
            case Keys.W:
                _model.MoveShip(r, c, -1, 0);
                e.Handled = true;
                break;
            case Keys.Down:
            case Keys.S:
                _model.MoveShip(r, c, 1, 0);
                e.Handled = true;
                break;
            case Keys.Left:
            case Keys.A:
                _model.MoveShip(r, c, 0, -1);
                e.Handled = true;
                break;
            case Keys.Right:
            case Keys.D:
                _model.MoveShip(r, c, 0, 1);
                e.Handled = true;
                break;
        }
    }

    private void OnGameChanged(object? sender, GameEventArgs e)
    {
        UpdateBoard();
    }

    private void OnGameOver(object? sender, GameEventArgs e)
    {
        string winnerName = e.Winner == Player.Player1 ? "Player 1 (Red)" : "Player 2 (Blue)";
        MessageBox.Show(
            $"{winnerName} won the game!",
            "Game Over",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        );
    }

    private void OnNewGame5Click(object? sender, EventArgs e) => _model.NewGame(5);
    private void OnNewGame7Click(object? sender, EventArgs e) => _model.NewGame(7);
    private void OnNewGame9Click(object? sender, EventArgs e) => _model.NewGame(9);

    private async void OnSaveGameClick(object? sender, EventArgs e)
    {
        using SaveFileDialog dialog = new SaveFileDialog
        {
            Filter = "Black Hole Save (*.bh)|*.bh|All files (*.*)|*.*",
            Title = "Save Game"
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            try
            {
                await _model.SaveGameAsync(dialog.FileName);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }

    private async void OnLoadGameClick(object? sender, EventArgs e)
    {
        using OpenFileDialog dialog = new OpenFileDialog
        {
            Filter = "Black Hole Save (*.bh)|*.bh|All files (*.*)|*.*",
            Title = "Load Game"
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            try
            {
                await _model.LoadGameAsync(dialog.FileName);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }

    private void OnExitClick(object? sender, EventArgs e) => Close();
}
