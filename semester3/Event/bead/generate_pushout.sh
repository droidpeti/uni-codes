#!/usr/bin/env bash
set -e

mkdir -p PushOut/PushOut
mkdir -p PushOut/PushOut.Model
mkdir -p PushOut/PushOut.Test

cd PushOut

cat << 'EOF' > PushOut.slnx
<Solution>
  <Project Path="PushOut.Model/PushOut.Model.csproj" />
  <Project Path="PushOut.Test/PushOut.Test.csproj" />
  <Project Path="PushOut/PushOut.csproj" />
</Solution>
EOF

cat << 'EOF' > PushOut.Model/PushOut.Model.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
EOF

cat << 'EOF' > PushOut.Model/Player.cs
namespace PushOut.Model;

public enum Player
{
    None,
    White,
    Black
}
EOF

cat << 'EOF' > PushOut.Model/Field.cs
namespace PushOut.Model;

public enum Field
{
    Empty,
    WhitePebble,
    BlackPebble
}
EOF

cat << 'EOF' > PushOut.Model/GameEventArgs.cs
namespace PushOut.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public int RemainingSteps { get; }
    public int WhiteCount { get; }
    public int BlackCount { get; }
    public Player CurrentPlayer { get; }

    public GameEventArgs(Player winner, int remainingSteps, int whiteCount, int blackCount, Player currentPlayer)
    {
        Winner = winner;
        RemainingSteps = remainingSteps;
        WhiteCount = whiteCount;
        BlackCount = blackCount;
        CurrentPlayer = currentPlayer;
    }
}
EOF

cat << 'EOF' > PushOut.Model/IPushOutDataAccess.cs
namespace PushOut.Model;

public interface IPushOutDataAccess
{
    Task<(int Size, Player CurrentPlayer, int RemainingSteps, Field[,] Board)> LoadAsync(string path);
    Task SaveAsync(string path, int size, Player currentPlayer, int remainingSteps, Field[,] board);
}
EOF

cat << 'EOF' > PushOut.Model/PushOutDataAccess.cs
namespace PushOut.Model;

public class PushOutDataAccess : IPushOutDataAccess
{
    public async Task<(int Size, Player CurrentPlayer, int RemainingSteps, Field[,] Board)> LoadAsync(string path)
    {
        try
        {
            using StreamReader reader = new StreamReader(path);
            string? header = await reader.ReadLineAsync();
            if (string.IsNullOrWhiteSpace(header))
                throw new InvalidDataException("Invalid save file header.");

            string[] parts = header.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 3)
                throw new InvalidDataException("Corrupted save file header.");

            int size = int.Parse(parts[0]);
            Player currentPlayer = Enum.Parse<Player>(parts[1]);
            int remainingSteps = int.Parse(parts[2]);

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
                    board[r, c] = Enum.Parse<Field>(cells[c]);
                }
            }

            return (size, currentPlayer, remainingSteps, board);
        }
        catch (Exception ex)
        {
            throw new IOException("Failed to load the game.", ex);
        }
    }

    public async Task SaveAsync(string path, int size, Player currentPlayer, int remainingSteps, Field[,] board)
    {
        try
        {
            using StreamWriter writer = new StreamWriter(path);
            await writer.WriteLineAsync($"{size} {currentPlayer} {remainingSteps}");
            for (int r = 0; r < size; r++)
            {
                string[] row = new string[size];
                for (int c = 0; c < size; c++)
                {
                    row[c] = board[r, c].ToString();
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

cat << 'EOF' > PushOut.Model/PushOutGameModel.cs
namespace PushOut.Model;

public class PushOutGameModel
{
    private readonly IPushOutDataAccess? _dataAccess;
    private readonly Random _random = new Random();
    private Field[,] _board;

    public int Size { get; private set; }
    public Player CurrentPlayer { get; private set; }
    public int RemainingSteps { get; private set; }
    public int WhiteCount { get; private set; }
    public int BlackCount { get; private set; }
    public bool IsGameOver { get; private set; }
    public (int Row, int Col)? SelectedPebble { get; private set; }

    public event EventHandler<GameEventArgs>? GameChanged;
    public event EventHandler<GameEventArgs>? GameOver;

    public PushOutGameModel(IPushOutDataAccess? dataAccess = null)
    {
        _dataAccess = dataAccess;
        Size = 3;
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
        if (size != 3 && size != 4 && size != 6)
            throw new ArgumentException("Board size must be 3, 4, or 6.", nameof(size));

        Size = size;
        _board = new Field[Size, Size];
        CurrentPlayer = Player.White;
        RemainingSteps = 5 * Size;
        IsGameOver = false;
        SelectedPebble = null;

        List<(int r, int c)> positions = new List<(int r, int c)>();
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                _board[r, c] = Field.Empty;
                positions.Add((r, c));
            }
        }

        for (int i = positions.Count - 1; i > 0; i--)
        {
            int j = _random.Next(i + 1);
            (positions[i], positions[j]) = (positions[j], positions[i]);
        }

        for (int i = 0; i < Size; i++)
        {
            var (wr, wc) = positions[i];
            _board[wr, wc] = Field.WhitePebble;

            var (br, bc) = positions[Size + i];
            _board[br, bc] = Field.BlackPebble;
        }

        RecalculateCounts();
        OnGameChanged();
    }

    public void SetupCustomBoard(int size, Player currentPlayer, int remainingSteps, Field[,] board)
    {
        Size = size;
        CurrentPlayer = currentPlayer;
        RemainingSteps = remainingSteps;
        _board = (Field[,])board.Clone();
        SelectedPebble = null;
        RecalculateCounts();
        IsGameOver = RemainingSteps <= 0 || WhiteCount == 0 || BlackCount == 0;
        OnGameChanged();
    }

    public void SelectCell(int row, int col)
    {
        if (IsGameOver)
            return;

        if (row < 0 || row >= Size || col < 0 || col >= Size)
            return;

        Field clicked = _board[row, col];
        Field ownPebble = CurrentPlayer == Player.White ? Field.WhitePebble : Field.BlackPebble;

        if (clicked == ownPebble)
        {
            if (SelectedPebble.HasValue && SelectedPebble.Value != (row, col))
            {
                var (sRow, sCol) = SelectedPebble.Value;
                int dRow = row - sRow;
                int dCol = col - sCol;
                if (Math.Abs(dRow) + Math.Abs(dCol) == 1)
                {
                    PushPebble(sRow, sCol, dRow, dCol);
                    return;
                }
            }

            SelectedPebble = (row, col);
            OnGameChanged();
            return;
        }

        if (SelectedPebble.HasValue)
        {
            var (sRow, sCol) = SelectedPebble.Value;
            int dRow = row - sRow;
            int dCol = col - sCol;

            if ((dRow == 0 && dCol != 0) || (dRow != 0 && dCol == 0))
            {
                PushPebble(sRow, sCol, Math.Sign(dRow), Math.Sign(dCol));
            }
        }
    }

    public bool PushPebble(int row, int col, int dRow, int dCol)
    {
        if (IsGameOver)
            return false;

        if (row < 0 || row >= Size || col < 0 || col >= Size)
            return false;

        if (Math.Abs(dRow) + Math.Abs(dCol) != 1)
            return false;

        Field ownPebble = CurrentPlayer == Player.White ? Field.WhitePebble : Field.BlackPebble;
        if (_board[row, col] != ownPebble)
            return false;

        List<(int r, int c, Field f)> chain = new List<(int r, int c, Field f)>();
        int currR = row;
        int currC = col;

        while (currR >= 0 && currR < Size && currC >= 0 && currC < Size && _board[currR, currC] != Field.Empty)
        {
            chain.Add((currR, currC, _board[currR, currC]));
            currR += dRow;
            currC += dCol;
        }

        _board[row, col] = Field.Empty;

        foreach (var item in chain)
        {
            int nextR = item.r + dRow;
            int nextC = item.c + dCol;
            if (nextR >= 0 && nextR < Size && nextC >= 0 && nextC < Size)
            {
                _board[nextR, nextC] = item.f;
            }
        }

        SelectedPebble = null;
        RemainingSteps--;
        RecalculateCounts();

        if (RemainingSteps <= 0 || WhiteCount == 0 || BlackCount == 0)
        {
            IsGameOver = true;
            Player winner = GetWinner();
            OnGameChanged(winner);
            OnGameOver(winner);
        }
        else
        {
            CurrentPlayer = CurrentPlayer == Player.White ? Player.Black : Player.White;
            OnGameChanged();
        }

        return true;
    }

    public async Task LoadGameAsync(string path)
    {
        if (_dataAccess == null)
            throw new InvalidOperationException("No data access is provided.");

        var (size, currentPlayer, remainingSteps, board) = await _dataAccess.LoadAsync(path);
        Size = size;
        CurrentPlayer = currentPlayer;
        RemainingSteps = remainingSteps;
        _board = board;
        SelectedPebble = null;
        RecalculateCounts();
        IsGameOver = RemainingSteps <= 0 || WhiteCount == 0 || BlackCount == 0;

        OnGameChanged(IsGameOver ? GetWinner() : Player.None);
    }

    public async Task SaveGameAsync(string path)
    {
        if (_dataAccess == null)
            throw new InvalidOperationException("No data access is provided.");

        await _dataAccess.SaveAsync(path, Size, CurrentPlayer, RemainingSteps, _board);
    }

    private void RecalculateCounts()
    {
        int w = 0;
        int b = 0;
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                if (_board[r, c] == Field.WhitePebble) w++;
                else if (_board[r, c] == Field.BlackPebble) b++;
            }
        }
        WhiteCount = w;
        BlackCount = b;
    }

    private Player GetWinner()
    {
        if (WhiteCount > BlackCount) return Player.White;
        if (BlackCount > WhiteCount) return Player.Black;
        return Player.None;
    }

    private void OnGameChanged(Player winner = Player.None)
    {
        GameChanged?.Invoke(this, new GameEventArgs(winner, RemainingSteps, WhiteCount, BlackCount, CurrentPlayer));
    }

    private void OnGameOver(Player winner)
    {
        GameOver?.Invoke(this, new GameEventArgs(winner, RemainingSteps, WhiteCount, BlackCount, CurrentPlayer));
    }
}
EOF

cat << 'EOF' > PushOut/PushOut.csproj
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
    <ProjectReference Include="..\PushOut.Model\PushOut.Model.csproj" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > PushOut/Program.cs
namespace PushOut;

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

cat << 'EOF' > PushOut/MainForm.Designer.cs
#nullable enable
namespace PushOut;

partial class MainForm
{
    private System.ComponentModel.IContainer? components = null;
    private MenuStrip _menuStrip = null!;
    private ToolStripMenuItem _fileMenuItem = null!;
    private ToolStripMenuItem _newGame3MenuItem = null!;
    private ToolStripMenuItem _newGame4MenuItem = null!;
    private ToolStripMenuItem _newGame6MenuItem = null!;
    private ToolStripSeparator _separator1 = null!;
    private ToolStripMenuItem _saveMenuItem = null!;
    private ToolStripMenuItem _loadMenuItem = null!;
    private ToolStripSeparator _separator2 = null!;
    private ToolStripMenuItem _exitMenuItem = null!;
    private StatusStrip _statusStrip = null!;
    private ToolStripStatusLabel _turnLabel = null!;
    private ToolStripStatusLabel _stepsLabel = null!;
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
        _newGame4MenuItem = new ToolStripMenuItem();
        _newGame6MenuItem = new ToolStripMenuItem();
        _separator1 = new ToolStripSeparator();
        _saveMenuItem = new ToolStripMenuItem();
        _loadMenuItem = new ToolStripMenuItem();
        _separator2 = new ToolStripSeparator();
        _exitMenuItem = new ToolStripMenuItem();
        _statusStrip = new StatusStrip();
        _turnLabel = new ToolStripStatusLabel();
        _stepsLabel = new ToolStripStatusLabel();
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
            _newGame4MenuItem,
            _newGame6MenuItem,
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
        _newGame3MenuItem.Size = new Size(195, 22);
        _newGame3MenuItem.Text = "New Game (3x3 - 15 steps)";
        _newGame3MenuItem.Click += OnNewGame3Click;

        _newGame4MenuItem.Name = "_newGame4MenuItem";
        _newGame4MenuItem.Size = new Size(195, 22);
        _newGame4MenuItem.Text = "New Game (4x4 - 20 steps)";
        _newGame4MenuItem.Click += OnNewGame4Click;

        _newGame6MenuItem.Name = "_newGame6MenuItem";
        _newGame6MenuItem.Size = new Size(195, 22);
        _newGame6MenuItem.Text = "New Game (6x6 - 30 steps)";
        _newGame6MenuItem.Click += OnNewGame6Click;

        _separator1.Name = "_separator1";
        _separator1.Size = new Size(192, 6);

        _saveMenuItem.Name = "_saveMenuItem";
        _saveMenuItem.Size = new Size(195, 22);
        _saveMenuItem.Text = "&Save Game...";
        _saveMenuItem.Click += OnSaveGameClick;

        _loadMenuItem.Name = "_loadMenuItem";
        _loadMenuItem.Size = new Size(195, 22);
        _loadMenuItem.Text = "&Load Game...";
        _loadMenuItem.Click += OnLoadGameClick;

        _separator2.Name = "_separator2";
        _separator2.Size = new Size(192, 6);

        _exitMenuItem.Name = "_exitMenuItem";
        _exitMenuItem.Size = new Size(195, 22);
        _exitMenuItem.Text = "E&xit";
        _exitMenuItem.Click += OnExitClick;

        _statusStrip.Items.AddRange(new ToolStripItem[] { _turnLabel, _stepsLabel, _scoreLabel });
        _statusStrip.Location = new Point(0, 478);
        _statusStrip.Name = "_statusStrip";
        _statusStrip.Size = new Size(500, 22);
        _statusStrip.TabIndex = 1;
        _statusStrip.Text = "Status";

        _turnLabel.Name = "_turnLabel";
        _turnLabel.Size = new Size(100, 17);
        _turnLabel.Text = "Turn: White";

        _stepsLabel.Name = "_stepsLabel";
        _stepsLabel.Size = new Size(100, 17);
        _stepsLabel.Text = "| Steps left: 15";

        _scoreLabel.Name = "_scoreLabel";
        _scoreLabel.Size = new Size(140, 17);
        _scoreLabel.Text = "| White: 3  Black: 3";

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
        KeyPreview = true;
        MainMenuStrip = _menuStrip;
        MaximizeBox = false;
        Name = "MainForm";
        StartPosition = FormStartPosition.CenterScreen;
        Text = "Push Out";
        _menuStrip.ResumeLayout(false);
        _menuStrip.PerformLayout();
        _statusStrip.ResumeLayout(false);
        _statusStrip.PerformLayout();
        ResumeLayout(false);
        PerformLayout();
    }
}
EOF

cat << 'EOF' > PushOut/MainForm.cs
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
EOF

cat << 'EOF' > PushOut/MainForm.resx
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

cat << 'EOF' > PushOut.Test/PushOut.Test.csproj
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
    <ProjectReference Include="..\PushOut.Model\PushOut.Model.csproj" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Microsoft.VisualStudio.TestTools.UnitTesting" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > PushOut.Test/MSTestSettings.cs
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
EOF

cat << 'EOF' > PushOut.Test/Test1.cs
using PushOut.Model;

namespace PushOut.Test;

[TestClass]
public sealed class Test1
{
    private sealed class MockDataAccess : IPushOutDataAccess
    {
        public int SavedSize { get; private set; }
        public Player SavedPlayer { get; private set; }
        public int SavedRemainingSteps { get; private set; }
        public Field[,]? SavedBoard { get; private set; }

        public int SizeToLoad { get; set; } = 3;
        public Player PlayerToLoad { get; set; } = Player.Black;
        public int RemainingStepsToLoad { get; set; } = 10;
        public Field[,]? BoardToLoad { get; set; }

        public Task<(int Size, Player CurrentPlayer, int RemainingSteps, Field[,] Board)> LoadAsync(string path)
        {
            Field[,] board = BoardToLoad ?? new Field[SizeToLoad, SizeToLoad];
            return Task.FromResult((SizeToLoad, PlayerToLoad, RemainingStepsToLoad, board));
        }

        public Task SaveAsync(string path, int size, Player currentPlayer, int remainingSteps, Field[,] board)
        {
            SavedSize = size;
            SavedPlayer = currentPlayer;
            SavedRemainingSteps = remainingSteps;
            SavedBoard = board;
            return Task.CompletedTask;
        }
    }

    [TestMethod]
    [DataRow(3, 15)]
    [DataRow(4, 20)]
    [DataRow(6, 30)]
    public void NewGame_InitializesBoardCorrectly(int size, int expectedSteps)
    {
        var model = new PushOutGameModel();
        model.NewGame(size);

        Assert.AreEqual(size, model.Size);
        Assert.AreEqual(expectedSteps, model.RemainingSteps);
        Assert.AreEqual(Player.White, model.CurrentPlayer);
        Assert.AreEqual(size, model.WhiteCount);
        Assert.AreEqual(size, model.BlackCount);
        Assert.IsFalse(model.IsGameOver);
    }

    [TestMethod]
    public void PushPebble_ChainPushAndFallOffEdge_UpdatesBoardAndCounts()
    {
        var model = new PushOutGameModel();
        Field[,] board = new Field[3, 3];
        board[0, 0] = Field.WhitePebble;
        board[0, 1] = Field.BlackPebble;
        board[0, 2] = Field.BlackPebble;

        model.SetupCustomBoard(3, Player.White, 15, board);

        bool pushed = model.PushPebble(0, 0, 0, 1);

        Assert.IsTrue(pushed);
        Assert.AreEqual(Field.Empty, model.GetField(0, 0));
        Assert.AreEqual(Field.WhitePebble, model.GetField(0, 1));
        Assert.AreEqual(Field.BlackPebble, model.GetField(0, 2));
        Assert.AreEqual(1, model.WhiteCount);
        Assert.AreEqual(1, model.BlackCount);
        Assert.AreEqual(14, model.RemainingSteps);
        Assert.AreEqual(Player.Black, model.CurrentPlayer);
    }

    [TestMethod]
    public void PushPebble_LastStep_TriggersGameOverWithCorrectWinner()
    {
        var model = new PushOutGameModel();
        Field[,] board = new Field[3, 3];
        board[1, 1] = Field.WhitePebble;
        board[2, 2] = Field.WhitePebble;
        board[0, 0] = Field.BlackPebble;

        model.SetupCustomBoard(3, Player.White, 1, board);

        Player? eventWinner = null;
        model.GameOver += (_, e) => eventWinner = e.Winner;

        bool pushed = model.PushPebble(1, 1, 0, 1);

        Assert.IsTrue(pushed);
        Assert.IsTrue(model.IsGameOver);
        Assert.AreEqual(0, model.RemainingSteps);
        Assert.AreEqual(Player.White, eventWinner);
    }

    [TestMethod]
    public void PushPebble_DrawCondition_FiresGameOverWithNone()
    {
        var model = new PushOutGameModel();
        Field[,] board = new Field[3, 3];
        board[1, 1] = Field.WhitePebble;
        board[0, 0] = Field.BlackPebble;

        model.SetupCustomBoard(3, Player.White, 1, board);

        Player? eventWinner = null;
        model.GameOver += (_, e) => eventWinner = e.Winner;

        model.PushPebble(1, 1, 0, 1);

        Assert.IsTrue(model.IsGameOver);
        Assert.AreEqual(Player.None, eventWinner);
    }

    [TestMethod]
    public void PushPebble_InvalidMove_ReturnsFalse()
    {
        var model = new PushOutGameModel();
        Field[,] board = new Field[3, 3];
        board[0, 0] = Field.WhitePebble;
        board[1, 1] = Field.BlackPebble;

        model.SetupCustomBoard(3, Player.White, 10, board);

        Assert.IsFalse(model.PushPebble(1, 1, 0, 1));
        Assert.IsFalse(model.PushPebble(2, 2, 0, 1));
        Assert.AreEqual(Player.White, model.CurrentPlayer);
        Assert.AreEqual(10, model.RemainingSteps);
    }

    [TestMethod]
    public async Task SaveAndLoadGame_UsesDataAccessCorrectly()
    {
        var mock = new MockDataAccess();
        var model = new PushOutGameModel(mock);
        model.NewGame(4);

        await model.SaveGameAsync("test.po");

        Assert.AreEqual(4, mock.SavedSize);
        Assert.AreEqual(Player.White, mock.SavedPlayer);
        Assert.AreEqual(20, mock.SavedRemainingSteps);

        Field[,] customBoard = new Field[3, 3];
        customBoard[0, 0] = Field.WhitePebble;
        customBoard[2, 2] = Field.BlackPebble;
        mock.SizeToLoad = 3;
        mock.PlayerToLoad = Player.Black;
        mock.RemainingStepsToLoad = 8;
        mock.BoardToLoad = customBoard;

        await model.LoadGameAsync("test.po");

        Assert.AreEqual(3, model.Size);
        Assert.AreEqual(Player.Black, model.CurrentPlayer);
        Assert.AreEqual(8, model.RemainingSteps);
        Assert.AreEqual(Field.WhitePebble, model.GetField(0, 0));
    }
}
EOF

echo "PushOut solution successfully generated in ./PushOut"
