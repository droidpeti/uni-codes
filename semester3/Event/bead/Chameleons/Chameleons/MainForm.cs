using Chameleons.Model;

namespace Chameleons;

public partial class MainForm : Form
{
    private const int CellSize = 68;
    private readonly ChameleonsGameModel _model;
    private Button[,] _buttons = null!;

    public MainForm()
    {
        InitializeComponent();

        _model = new ChameleonsGameModel(new ChameleonsDataAccess());
        _model.GameChanged += OnGameChanged;
        _model.GameOver += OnGameOver;

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
                    Font = new Font(FontFamily.GenericSansSerif, 22, FontStyle.Bold),
                    Tag = (r, c),
                    TabStop = false
                };
                btn.FlatAppearance.BorderSize = 2;
                btn.Click += OnCellClick;
                _buttons[r, c] = btn;
                _boardPanel.Controls.Add(btn);
            }
        }

        int boardPixels = n * CellSize;
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
                bool isSelected = _model.SelectedChameleon.HasValue &&
                                  _model.SelectedChameleon.Value.Row == r &&
                                  _model.SelectedChameleon.Value.Col == c;

                btn.BackColor = field.Background switch
                {
                    CellColor.Red => Color.LightCoral,
                    CellColor.Green => Color.DarkSeaGreen,
                    _ => Color.Silver
                };

                btn.FlatAppearance.BorderColor = isSelected ? Color.Gold : Color.FromArgb(60, 60, 60);
                btn.FlatAppearance.BorderSize = isSelected ? 4 : 1;

                switch (field.Occupant)
                {
                    case Player.Red:
                        btn.ForeColor = Color.DarkRed;
                        btn.Text = "●";
                        break;
                    case Player.Green:
                        btn.ForeColor = Color.DarkGreen;
                        btn.Text = "●";
                        break;
                    default:
                        btn.Text = string.Empty;
                        break;
                }
            }
        }

        _turnLabel.Text = $"Turn: {_model.CurrentPlayer}";
        _scoreLabel.Text = $"| Red: {_model.RedCount}  Green: {_model.GreenCount}";
    }

    private void OnCellClick(object? sender, EventArgs e)
    {
        if (sender is Button { Tag: ValueTuple<int, int> pos })
        {
            _model.SelectCell(pos.Item1, pos.Item2);
        }
    }

    private void OnGameChanged(object? sender, GameEventArgs e)
    {
        UpdateBoard();
    }

    private void OnGameOver(object? sender, GameEventArgs e)
    {
        MessageBox.Show(
            $"{e.Winner} player won the game!",
            "Game Over",
            MessageBoxButtons.OK,
            MessageBoxIcon.Information
        );
    }

    private void OnNewGame3Click(object? sender, EventArgs e) => _model.NewGame(3);
    private void OnNewGame5Click(object? sender, EventArgs e) => _model.NewGame(5);
    private void OnNewGame7Click(object? sender, EventArgs e) => _model.NewGame(7);

    private async void OnSaveGameClick(object? sender, EventArgs e)
    {
        using SaveFileDialog dialog = new SaveFileDialog
        {
            Filter = "Chameleons Save (*.chm)|*.chm|All files (*.*)|*.*",
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
            Filter = "Chameleons Save (*.chm)|*.chm|All files (*.*)|*.*",
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
