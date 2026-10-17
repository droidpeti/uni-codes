using PushOut.Model;

namespace PushOut;

public partial class MainForm : Form
{
    private const int CellSize = 75;
    private readonly PushOutGameModel _model;
    private Button[,] _buttons = null!;

    public MainForm()
    {
        InitializeComponent();

        _model = new PushOutGameModel(new PushOutDataAccess());
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
                    Font = new Font(FontFamily.GenericSansSerif, 18, FontStyle.Bold),
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
        int minWidth = Math.Max(boardPixels + 20, 360);
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
                bool isSelected = _model.SelectedPebble.HasValue &&
                                  _model.SelectedPebble.Value.Row == r &&
                                  _model.SelectedPebble.Value.Col == c;

                switch (field)
                {
                    case Field.WhitePebble:
                        btn.BackColor = isSelected ? Color.Gold : Color.Snow;
                        btn.ForeColor = Color.DimGray;
                        btn.Text = "●";
                        break;
                    case Field.BlackPebble:
                        btn.BackColor = isSelected ? Color.Gold : Color.FromArgb(45, 45, 48);
                        btn.ForeColor = Color.White;
                        btn.Text = "●";
                        break;
                    case Field.Empty:
                        btn.BackColor = Color.LightGray;
                        btn.ForeColor = Color.Black;
                        btn.Text = string.Empty;
                        break;
                }
            }
        }

        _turnLabel.Text = $"Turn: {_model.CurrentPlayer}";
        _stepsLabel.Text = $"| Steps left: {_model.RemainingSteps}";
        _scoreLabel.Text = $"| White: {_model.WhiteCount}  Black: {_model.BlackCount}";
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
        if (!_model.SelectedPebble.HasValue)
            return;

        var (r, c) = _model.SelectedPebble.Value;
        switch (e.KeyCode)
        {
            case Keys.Up:
            case Keys.W:
                _model.PushPebble(r, c, -1, 0);
                e.Handled = true;
                break;
            case Keys.Down:
            case Keys.S:
                _model.PushPebble(r, c, 1, 0);
                e.Handled = true;
                break;
            case Keys.Left:
            case Keys.A:
                _model.PushPebble(r, c, 0, -1);
                e.Handled = true;
                break;
            case Keys.Right:
            case Keys.D:
                _model.PushPebble(r, c, 0, 1);
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
        string message = e.Winner == Player.None
            ? "The game ended in a draw!"
            : $"{e.Winner} player won the game!";

        MessageBox.Show(
            message,
            "Game Over",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        );

        _model.NewGame(_model.Size);
    }

    private void OnNewGame3Click(object? sender, EventArgs e) => _model.NewGame(3);
    private void OnNewGame4Click(object? sender, EventArgs e) => _model.NewGame(4);
    private void OnNewGame6Click(object? sender, EventArgs e) => _model.NewGame(6);

    private async void OnSaveGameClick(object? sender, EventArgs e)
    {
        using SaveFileDialog dialog = new SaveFileDialog
        {
            Filter = "Push Out Save (*.po)|*.po|All files (*.*)|*.*",
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
            Filter = "Push Out Save (*.po)|*.po|All files (*.*)|*.*",
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
