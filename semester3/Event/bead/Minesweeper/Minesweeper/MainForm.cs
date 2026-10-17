using Minesweeper.Model;

namespace Minesweeper;

public partial class MainForm : Form
{
    private readonly MinesweeperGameModel _model;
    private Button[,] _buttons = null!;

    public MainForm()
    {
        InitializeComponent();

        _model = new MinesweeperGameModel(new MinesweeperDataAccess());
        _model.GameChanged += OnGameChanged;
        _model.GameOver += OnGameOver;

        GenerateBoard();
        UpdateBoard();
    }

    private void GenerateBoard()
    {
        _boardPanel.Controls.Clear();
        int n = _model.Size;
        int cellSize = n == 16 ? 38 : 48;
        _buttons = new Button[n, n];

        for (int r = 0; r < n; r++)
        {
            for (int c = 0; c < n; c++)
            {
                Button btn = new Button
                {
                    Location = new Point(c * cellSize, r * cellSize),
                    Size = new Size(cellSize, cellSize),
                    FlatStyle = FlatStyle.Flat,
                    Font = new Font(FontFamily.GenericSansSerif, 11, FontStyle.Bold),
                    Tag = (r, c),
                    TabStop = false
                };
                btn.Click += OnCellClick;
                _buttons[r, c] = btn;
                _boardPanel.Controls.Add(btn);
            }
        }

        int boardPixels = n * cellSize;
        _boardPanel.Size = new Size(boardPixels, boardPixels);
        int minWidth = Math.Max(boardPixels + 20, 320);
        ClientSize = new Size(
            minWidth,
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

                if (!field.IsRevealed)
                {
                    btn.Enabled = true;
                    btn.BackColor = Color.LightSlateGray;
                    btn.ForeColor = Color.Black;
                    btn.Text = string.Empty;
                }
                else if (field.IsMine)
                {
                    btn.Enabled = false;
                    btn.BackColor = Color.Crimson;
                    btn.ForeColor = Color.White;
                    btn.Text = "*";
                }
                else
                {
                    btn.Enabled = false;
                    btn.BackColor = Color.WhiteSmoke;
                    btn.ForeColor = Color.DarkBlue;
                    btn.Text = field.AdjacentMines > 0 ? field.AdjacentMines.ToString() : string.Empty;
                }
            }
        }

        string pName = _model.CurrentPlayer == Player.Player1 ? "Player 1" : "Player 2";
        _turnLabel.Text = $"Turn: {pName}";
        _remainingLabel.Text = $"| Safe cells left: {_model.RemainingSafeCells}";
    }

    private void OnCellClick(object? sender, EventArgs e)
    {
        if (sender is Button { Tag: ValueTuple<int, int> pos })
        {
            _model.Step(pos.Item1, pos.Item2);
        }
    }

    private void OnGameChanged(object? sender, GameEventArgs e)
    {
        UpdateBoard();
    }

    private void OnGameOver(object? sender, GameEventArgs e)
    {
        string message = e.Winner == Player.None
            ? "All safe cells revealed! The game is a draw!"
            : $"{(e.Winner == Player.Player1 ? "Player 1" : "Player 2")} won the game!";

        MessageBox.Show(
            message,
            "Game Over",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        );
    }

    private void OnNewGame6Click(object? sender, EventArgs e) => _model.NewGame(6);
    private void OnNewGame10Click(object? sender, EventArgs e) => _model.NewGame(10);
    private void OnNewGame16Click(object? sender, EventArgs e) => _model.NewGame(16);

    private async void OnSaveGameClick(object? sender, EventArgs e)
    {
        using SaveFileDialog dialog = new SaveFileDialog
        {
            Filter = "Minesweeper Save (*.ms)|*.ms|All files (*.*)|*.*",
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
            Filter = "Minesweeper Save (*.ms)|*.ms|All files (*.*)|*.*",
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
