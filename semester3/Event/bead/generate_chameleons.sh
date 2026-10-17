#!/usr/bin/env bash
set -e

mkdir -p Chameleons/Chameleons
mkdir -p Chameleons/Chameleons.Model
mkdir -p Chameleons/Chameleons.Test

cd Chameleons

cat << 'EOF' > Chameleons.slnx
<Solution>
  <Project Path="Chameleons.Model/Chameleons.Model.csproj" />
  <Project Path="Chameleons.Test/Chameleons.Test.csproj" />
  <Project Path="Chameleons/Chameleons.csproj" />
</Solution>
EOF

cat << 'EOF' > Chameleons.Model/Chameleons.Model.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
EOF

cat << 'EOF' > Chameleons.Model/Player.cs
namespace Chameleons.Model;

public enum Player
{
    None,
    Red,
    Green
}
EOF

cat << 'EOF' > Chameleons.Model/CellColor.cs
namespace Chameleons.Model;

public enum CellColor
{
    Gray,
    Red,
    Green
}
EOF

cat << 'EOF' > Chameleons.Model/Field.cs
namespace Chameleons.Model;

public struct Field
{
    public CellColor Background { get; set; }
    public Player Occupant { get; set; }
    public int ForeignTurns { get; set; }
}
EOF

cat << 'EOF' > Chameleons.Model/GameEventArgs.cs
namespace Chameleons.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public Player CurrentPlayer { get; }
    public int RedCount { get; }
    public int GreenCount { get; }

    public GameEventArgs(Player winner, Player currentPlayer, int redCount, int greenCount)
    {
        Winner = winner;
        CurrentPlayer = currentPlayer;
        RedCount = redCount;
        GreenCount = greenCount;
    }
}
EOF

cat << 'EOF' > Chameleons.Model/IChameleonsDataAccess.cs
namespace Chameleons.Model;

public interface IChameleonsDataAccess
{
    Task<(int Size, Player CurrentPlayer, Field[,] Board)> LoadAsync(string path);
    Task SaveAsync(string path, int size, Player currentPlayer, Field[,] board);
}
EOF

cat << 'EOF' > Chameleons.Model/ChameleonsDataAccess.cs
namespace Chameleons.Model;

public class ChameleonsDataAccess : IChameleonsDataAccess
{
    public async Task<(int Size, Player CurrentPlayer, Field[,] Board)> LoadAsync(string path)
    {
        try
        {
            using StreamReader reader = new StreamReader(path);
            string? header = await reader.ReadLineAsync();
            if (string.IsNullOrWhiteSpace(header))
                throw new InvalidDataException("Invalid save file header.");

            string[] parts = header.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 2)
                throw new InvalidDataException("Corrupted save file header.");

            int size = int.Parse(parts[0]);
            Player currentPlayer = Enum.Parse<Player>(parts[1]);

            Field[,] board = new Field[size, size];
            for (int r = 0; r < size; r++)
            {
                string? line = await reader.ReadLineAsync();
                if (string.IsNullOrWhiteSpace(line))
                    throw new InvalidDataException("Missing board row in save file.");

                string[] cells = line.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                if (cells.Length != size)
                    throw new InvalidDataException("Invalid board row length in save file.");

                for (int c = 0; c < size; c++)
                {
                    string[] cellData = cells[c].Split(':');
                    board[r, c] = new Field
                    {
                        Background = Enum.Parse<CellColor>(cellData[0]),
                        Occupant = Enum.Parse<Player>(cellData[1]),
                        ForeignTurns = int.Parse(cellData[2])
                    };
                }
            }

            return (size, currentPlayer, board);
        }
        catch (Exception ex)
        {
            throw new IOException("Failed to load the game.", ex);
        }
    }

    public async Task SaveAsync(string path, int size, Player currentPlayer, Field[,] board)
    {
        try
        {
            using StreamWriter writer = new StreamWriter(path);
            await writer.WriteLineAsync($"{size} {currentPlayer}");
            for (int r = 0; r < size; r++)
            {
                string[] row = new string[size];
                for (int c = 0; c < size; c++)
                {
                    Field f = board[r, c];
                    row[c] = $"{f.Background}:{f.Occupant}:{f.ForeignTurns}";
                }
                await writer.WriteLineAsync(string.Join(" ", row));
            }
        }
        catch (Exception ex)
        {
            throw new IOException("Failed to save the game.", ex);
        }
    }
}
EOF

cat << 'EOF' > Chameleons.Model/ChameleonsGameModel.cs
namespace Chameleons.Model;

public class ChameleonsGameModel
{
    private readonly IChameleonsDataAccess? _dataAccess;
    private Field[,] _board;

    public int Size { get; private set; }
    public Player CurrentPlayer { get; private set; }
    public int RedCount { get; private set; }
    public int GreenCount { get; private set; }
    public bool IsGameOver { get; private set; }
    public (int Row, int Col)? SelectedChameleon { get; private set; }

    public event EventHandler<GameEventArgs>? GameChanged;
    public event EventHandler<GameEventArgs>? GameOver;

    public ChameleonsGameModel(IChameleonsDataAccess? dataAccess = null)
    {
        _dataAccess = dataAccess;
        Size = 5;
        _board = new Field[Size, Size];
        NewGame(Size);
    }

    public Field GetField(int row, int col)
    {
        if (row < 0 || row >= Size || col < 0 || col >= Size)
            throw new ArgumentOutOfRangeException(nameof(row));
        return _board[row, col];
    }

    public void NewGame(int size)
    {
        if (size != 3 && size != 5 && size != 7)
            throw new ArgumentException("Board size must be 3, 5, or 7.", nameof(size));

        Size = size;
        _board = new Field[Size, Size];
        CurrentPlayer = Player.Red;
        IsGameOver = false;
        SelectedChameleon = null;

        GenerateSpiralBoard();
        RecalculateCounts();
        OnGameChanged();
    }

    private void GenerateSpiralBoard()
    {
        CellColor[,] colors = new CellColor[Size, Size];
        bool[,] visited = new bool[Size, Size];

        int[] dr = { 0, 1, 0, -1 };
        int[] dc = { 1, 0, -1, 0 };
        int r = 0, c = 0, dir = 0;

        int total = Size * Size;
        int redTarget = (total - 1) / 2;
        int greenTarget = (total - 1) / 2;
        int redPlaced = 0, greenPlaced = 0;
        CellColor currentBand = CellColor.Red;

        for (int i = 0; i < total - 1; i++)
        {
            visited[r, c] = true;

            if (currentBand == CellColor.Red && redPlaced < redTarget)
            {
                colors[r, c] = CellColor.Red;
                redPlaced++;
            }
            else if (currentBand == CellColor.Green && greenPlaced < greenTarget)
            {
                colors[r, c] = CellColor.Green;
                greenPlaced++;
            }
            else if (redPlaced < redTarget)
            {
                colors[r, c] = CellColor.Red;
                redPlaced++;
            }
            else
            {
                colors[r, c] = CellColor.Green;
                greenPlaced++;
            }

            int nr = r + dr[dir];
            int nc = c + dc[dir];
            if (nr < 0 || nr >= Size || nc < 0 || nc >= Size || visited[nr, nc])
            {
                if (dir == 2)
                {
                    currentBand = currentBand == CellColor.Red ? CellColor.Green : CellColor.Red;
                }
                dir = (dir + 1) % 4;
                nr = r + dr[dir];
                nc = c + dc[dir];
            }
            r = nr;
            c = nc;
        }

        int center = Size / 2;
        colors[center, center] = CellColor.Gray;

        for (int row = 0; row < Size; row++)
        {
            for (int col = 0; col < Size; col++)
            {
                CellColor bg = colors[row, col];
                Player occ = bg == CellColor.Red ? Player.Red : (bg == CellColor.Green ? Player.Green : Player.None);
                _board[row, col] = new Field
                {
                    Background = bg,
                    Occupant = occ,
                    ForeignTurns = 0
                };
            }
        }
    }

    public void SetupCustomBoard(int size, Player currentPlayer, Field[,] board)
    {
        Size = size;
        CurrentPlayer = currentPlayer;
        _board = (Field[,])board.Clone();
        SelectedChameleon = null;
        RecalculateCounts();
        IsGameOver = RedCount == 0 || GreenCount == 0;
        OnGameChanged();
    }

    public void SelectCell(int row, int col)
    {
        if (IsGameOver)
            return;

        if (row < 0 || row >= Size || col < 0 || col >= Size)
            return;

        if (_board[row, col].Occupant == CurrentPlayer)
        {
            SelectedChameleon = (row, col);
            OnGameChanged();
            return;
        }

        if (SelectedChameleon.HasValue && _board[row, col].Occupant == Player.None)
        {
            var (sRow, sCol) = SelectedChameleon.Value;
            MoveChameleon(sRow, sCol, row, col);
        }
    }

    public bool MoveChameleon(int fromRow, int fromCol, int toRow, int toCol)
    {
        if (IsGameOver)
            return false;

        if (fromRow < 0 || fromRow >= Size || fromCol < 0 || fromCol >= Size)
            return false;

        if (toRow < 0 || toRow >= Size || toCol < 0 || toCol >= Size)
            return false;

        if (_board[fromRow, fromCol].Occupant != CurrentPlayer)
            return false;

        if (_board[toRow, toCol].Occupant != Player.None)
            return false;

        int dRow = toRow - fromRow;
        int dCol = toCol - fromCol;
        int dist = Math.Abs(dRow) + Math.Abs(dCol);

        if (dRow != 0 && dCol != 0)
            return false;

        Player opponent = CurrentPlayer == Player.Red ? Player.Green : Player.Red;

        if (dist == 1)
        {
            ExecuteMove(fromRow, fromCol, toRow, toCol);
        }
        else if (dist == 2)
        {
            int midRow = (fromRow + toRow) / 2;
            int midCol = (fromCol + toCol) / 2;

            if (_board[midRow, midCol].Occupant != opponent)
                return false;

            _board[midRow, midCol].Occupant = Player.None;
            _board[midRow, midCol].ForeignTurns = 0;

            ExecuteMove(fromRow, fromCol, toRow, toCol);
        }
        else
        {
            return false;
        }

        SelectedChameleon = null;
        UpdateChameleonAdaptations(toRow, toCol);
        RecalculateCounts();

        if (RedCount == 0 || GreenCount == 0)
        {
            IsGameOver = true;
            Player winner = RedCount > 0 ? Player.Red : Player.Green;
            OnGameChanged(winner);
            OnGameOver(winner);
        }
        else
        {
            CurrentPlayer = opponent;
            OnGameChanged();
        }

        return true;
    }

    private void ExecuteMove(int fromRow, int fromCol, int toRow, int toCol)
    {
        Player mover = _board[fromRow, fromCol].Occupant;
        _board[fromRow, fromCol].Occupant = Player.None;
        _board[fromRow, fromCol].ForeignTurns = 0;

        _board[toRow, toCol].Occupant = mover;
        _board[toRow, toCol].ForeignTurns = 0;
    }

    private void UpdateChameleonAdaptations(int movedToRow, int movedToCol)
    {
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                Field f = _board[r, c];
                if (f.Occupant == Player.None || f.Background == CellColor.Gray)
                {
                    _board[r, c].ForeignTurns = 0;
                    continue;
                }

                bool isOnForeignColor =
                    (f.Occupant == Player.Red && f.Background == CellColor.Green) ||
                    (f.Occupant == Player.Green && f.Background == CellColor.Red);

                if (!isOnForeignColor)
                {
                    _board[r, c].ForeignTurns = 0;
                    continue;
                }

                if (r == movedToRow && c == movedToCol)
                {
                    _board[r, c].ForeignTurns = 1;
                }
                else if (f.ForeignTurns >= 1)
                {
                    _board[r, c].Occupant = f.Background == CellColor.Red ? Player.Red : Player.Green;
                    _board[r, c].ForeignTurns = 0;
                }
            }
        }
    }

    private void RecalculateCounts()
    {
        int red = 0;
        int green = 0;
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                if (_board[r, c].Occupant == Player.Red) red++;
                else if (_board[r, c].Occupant == Player.Green) green++;
            }
        }
        RedCount = red;
        GreenCount = green;
    }

    public async Task LoadGameAsync(string path)
    {
        if (_dataAccess == null)
            throw new InvalidOperationException("No data access is provided.");

        var (size, currentPlayer, board) = await _dataAccess.LoadAsync(path);
        Size = size;
        CurrentPlayer = currentPlayer;
        _board = board;
        SelectedChameleon = null;
        RecalculateCounts();
        IsGameOver = RedCount == 0 || GreenCount == 0;

        OnGameChanged();
    }

    public async Task SaveGameAsync(string path)
    {
        if (_dataAccess == null)
            throw new InvalidOperationException("No data access is provided.");

        await _dataAccess.SaveAsync(path, Size, CurrentPlayer, _board);
    }

    private void OnGameChanged(Player winner = Player.None)
    {
        GameChanged?.Invoke(this, new GameEventArgs(winner, CurrentPlayer, RedCount, GreenCount));
    }

    private void OnGameOver(Player winner)
    {
        GameOver?.Invoke(this, new GameEventArgs(winner, CurrentPlayer, RedCount, GreenCount));
    }
}
EOF

cat << 'EOF' > Chameleons/Chameleons.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net10.0-windows</TargetFramework>
    <EnableWindowsTargeting>true</EnableWindowsTargeting>
    <InvariantGlobalization>true</InvariantGlobalization>
    <Nullable>enable</Nullable>
    <UseWindowsForms>true</UseWindowsForms>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\Chameleons.Model\Chameleons.Model.csproj" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > Chameleons/Program.cs
namespace Chameleons;

static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
    }
}
EOF

cat << 'EOF' > Chameleons/MainForm.Designer.cs
#nullable enable
namespace Chameleons;

partial class MainForm
{
    private System.ComponentModel.IContainer? components = null;
    private MenuStrip _menuStrip = null!;
    private ToolStripMenuItem _fileMenuItem = null!;
    private ToolStripMenuItem _newGame3MenuItem = null!;
    private ToolStripMenuItem _newGame5MenuItem = null!;
    private ToolStripMenuItem _newGame7MenuItem = null!;
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
        _newGame3MenuItem = new ToolStripMenuItem();
        _newGame5MenuItem = new ToolStripMenuItem();
        _newGame7MenuItem = new ToolStripMenuItem();
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
        _menuStrip.Size = new Size(500, 24);
        _menuStrip.TabIndex = 0;
        _menuStrip.Text = "Menu";

        _fileMenuItem.DropDownItems.AddRange(new ToolStripItem[]
        {
            _newGame3MenuItem,
            _newGame5MenuItem,
            _newGame7MenuItem,
            _separator1,
            _saveMenuItem,
            _loadMenuItem,
            _separator2,
            _exitMenuItem
        });
        _fileMenuItem.Name = "_fileMenuItem";
        _fileMenuItem.Size = new Size(37, 20);
        _fileMenuItem.Text = "&File";

        _newGame3MenuItem.Name = "_newGame3MenuItem";
        _newGame3MenuItem.Size = new Size(180, 22);
        _newGame3MenuItem.Text = "New Game (3x3)";
        _newGame3MenuItem.Click += OnNewGame3Click;

        _newGame5MenuItem.Name = "_newGame5MenuItem";
        _newGame5MenuItem.Size = new Size(180, 22);
        _newGame5MenuItem.Text = "New Game (5x5)";
        _newGame5MenuItem.Click += OnNewGame5Click;

        _newGame7MenuItem.Name = "_newGame7MenuItem";
        _newGame7MenuItem.Size = new Size(180, 22);
        _newGame7MenuItem.Text = "New Game (7x7)";
        _newGame7MenuItem.Click += OnNewGame7Click;

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
        _statusStrip.Location = new Point(0, 478);
        _statusStrip.Name = "_statusStrip";
        _statusStrip.Size = new Size(500, 22);
        _statusStrip.TabIndex = 1;
        _statusStrip.Text = "Status";

        _turnLabel.Name = "_turnLabel";
        _turnLabel.Size = new Size(110, 17);
        _turnLabel.Text = "Turn: Red";

        _scoreLabel.Name = "_scoreLabel";
        _scoreLabel.Size = new Size(180, 17);
        _scoreLabel.Text = "| Red: 12  Green: 12";

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
        Text = "Chameleons";
        _menuStrip.ResumeLayout(false);
        _menuStrip.PerformLayout();
        _statusStrip.ResumeLayout(false);
        _statusStrip.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }
}
EOF

cat << 'EOF' > Chameleons/MainForm.cs
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
EOF

cat << 'EOF' > Chameleons/MainForm.resx
<?xml version="1.0" encoding="utf-8"?>
<root>
  <xsd:schema id="root" xmlns="" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata">
    <xsd:element name="root" msdata:IsDataSet="true">
    </xsd:element>
  </xsd:schema>
  <resheader name="resmimetype">
    <value>text/microsoft-resx</value>
  </resheader>
  <resheader name="version">
    <value>2.0</value>
  </resheader>
  <resheader name="reader">
    <value>System.Resources.ResXResourceReader, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
  </resheader>
  <resheader name="writer">
    <value>System.Resources.ResXResourceWriter, System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089</value>
  </resheader>
</root>
EOF

cat << 'EOF' > Chameleons.Test/Chameleons.Test.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <LangVersion>latest</LangVersion>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.12.0" />
    <PackageReference Include="MSTest" Version="3.6.4" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="..\Chameleons.Model\Chameleons.Model.csproj" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Microsoft.VisualStudio.TestTools.UnitTesting" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > Chameleons.Test/MSTestSettings.cs
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
EOF

cat << 'EOF' > Chameleons.Test/Test1.cs
using Chameleons.Model;

namespace Chameleons.Test;

[TestClass]
public sealed class Test1
{
    private sealed class MockDataAccess : IChameleonsDataAccess
    {
        public int SavedSize { get; private set; }
        public Player SavedPlayer { get; private set; }
        public Field[,]? SavedBoard { get; private set; }

        public int SizeToLoad { get; set; } = 3;
        public Player PlayerToLoad { get; set; } = Player.Green;
        public Field[,]? BoardToLoad { get; set; }

        public Task<(int Size, Player CurrentPlayer, Field[,] Board)> LoadAsync(string path)
        {
            Field[,] board = BoardToLoad ?? new Field[SizeToLoad, SizeToLoad];
            return Task.FromResult((SizeToLoad, PlayerToLoad, board));
        }

        public Task SaveAsync(string path, int size, Player currentPlayer, Field[,] board)
        {
            SavedSize = size;
            SavedPlayer = currentPlayer;
            SavedBoard = board;
            return Task.CompletedTask;
        }
    }

    [TestMethod]
    [DataRow(3, 4)]
    [DataRow(5, 12)]
    [DataRow(7, 24)]
    public void NewGame_InitializesBoardCorrectly(int size, int expectedCount)
    {
        var model = new ChameleonsGameModel();
        model.NewGame(size);

        Assert.AreEqual(size, model.Size);
        Assert.AreEqual(Player.Red, model.CurrentPlayer);
        Assert.AreEqual(expectedCount, model.RedCount);
        Assert.AreEqual(expectedCount, model.GreenCount);
        Assert.IsFalse(model.IsGameOver);

        int center = size / 2;
        Assert.AreEqual(CellColor.Gray, model.GetField(center, center).Background);
        Assert.AreEqual(Player.None, model.GetField(center, center).Occupant);
    }

    [TestMethod]
    public void MoveChameleon_AdjacentEmptyCell_MovesAndSwitchesTurn()
    {
        var model = new ChameleonsGameModel();
        model.NewGame(3);

        bool moved = model.MoveChameleon(0, 1, 1, 1);

        Assert.IsTrue(moved);
        Assert.AreEqual(Player.None, model.GetField(0, 1).Occupant);
        Assert.AreEqual(Player.Red, model.GetField(1, 1).Occupant);
        Assert.AreEqual(Player.Green, model.CurrentPlayer);
    }

    [TestMethod]
    public void MoveChameleon_JumpOverOpponent_RemovesOpponentAndWins()
    {
        var model = new ChameleonsGameModel();
        Field[,] board = new Field[3, 3];
        board[0, 0] = new Field { Background = CellColor.Red, Occupant = Player.Red };
        board[0, 1] = new Field { Background = CellColor.Green, Occupant = Player.Green };
        board[0, 2] = new Field { Background = CellColor.Red, Occupant = Player.None };

        model.SetupCustomBoard(3, Player.Red, board);

        Player? winner = null;
        model.GameOver += (_, e) => winner = e.Winner;

        bool jumped = model.MoveChameleon(0, 0, 0, 2);

        Assert.IsTrue(jumped);
        Assert.AreEqual(Player.None, model.GetField(0, 1).Occupant);
        Assert.AreEqual(Player.Red, model.GetField(0, 2).Occupant);
        Assert.AreEqual(0, model.GreenCount);
        Assert.IsTrue(model.IsGameOver);
        Assert.AreEqual(Player.Red, winner);
    }

    [TestMethod]
    public void MoveChameleon_ColorAdaptationAfterOneTurn_ChangesOccupantOwner()
    {
        var model = new ChameleonsGameModel();
        Field[,] board = new Field[3, 3];
        board[0, 0] = new Field { Background = CellColor.Red, Occupant = Player.Red };
        board[0, 1] = new Field { Background = CellColor.Green, Occupant = Player.None };
        board[2, 0] = new Field { Background = CellColor.Green, Occupant = Player.Green };
        board[2, 1] = new Field { Background = CellColor.Green, Occupant = Player.None };
        board[2, 2] = new Field { Background = CellColor.Red, Occupant = Player.Red };

        model.SetupCustomBoard(3, Player.Red, board);

        Assert.IsTrue(model.MoveChameleon(0, 0, 0, 1));
        Assert.AreEqual(Player.Red, model.GetField(0, 1).Occupant);

        Assert.IsTrue(model.MoveChameleon(2, 0, 2, 1));
        Assert.AreEqual(Player.Green, model.GetField(0, 1).Occupant);
    }

    [TestMethod]
    public void MoveChameleon_InvalidMoves_ReturnFalse()
    {
        var model = new ChameleonsGameModel();
        model.NewGame(3);

        Assert.IsFalse(model.MoveChameleon(0, 0, 0, 1));
        Assert.IsFalse(model.MoveChameleon(1, 0, 1, 1));
        Assert.AreEqual(Player.Red, model.CurrentPlayer);
    }

    [TestMethod]
    public async Task SaveAndLoadGame_UsesDataAccessCorrectly()
    {
        var mock = new MockDataAccess();
        var model = new ChameleonsGameModel(mock);
        model.NewGame(5);

        await model.SaveGameAsync("test.chm");

        Assert.AreEqual(5, mock.SavedSize);
        Assert.AreEqual(Player.Red, mock.SavedPlayer);
        Assert.IsNotNull(mock.SavedBoard);

        Field[,] customBoard = new Field[3, 3];
        customBoard[0, 0] = new Field { Background = CellColor.Red, Occupant = Player.Red };
        customBoard[2, 2] = new Field { Background = CellColor.Green, Occupant = Player.Green };
        mock.SizeToLoad = 3;
        mock.PlayerToLoad = Player.Green;
        mock.BoardToLoad = customBoard;

        await model.LoadGameAsync("test.chm");

        Assert.AreEqual(3, model.Size);
        Assert.AreEqual(Player.Green, model.CurrentPlayer);
        Assert.AreEqual(Player.Red, model.GetField(0, 0).Occupant);
    }
}
EOF

echo "Chameleons solution successfully generated in ./Chameleons"
