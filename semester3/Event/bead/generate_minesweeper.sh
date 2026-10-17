#!/usr/bin/env bash
set -e

mkdir -p Minesweeper/Minesweeper
mkdir -p Minesweeper/Minesweeper.Model
mkdir -p Minesweeper/Minesweeper.Test

cd Minesweeper

cat << 'EOF' > Minesweeper.slnx
<Solution>
  <Project Path="Minesweeper.Model/Minesweeper.Model.csproj" />
  <Project Path="Minesweeper.Test/Minesweeper.Test.csproj" />
  <Project Path="Minesweeper/Minesweeper.csproj" />
</Solution>
EOF

cat << 'EOF' > Minesweeper.Model/Minesweeper.Model.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
EOF

cat << 'EOF' > Minesweeper.Model/Player.cs
namespace Minesweeper.Model;

public enum Player
{
    None,
    Player1,
    Player2
}
EOF

cat << 'EOF' > Minesweeper.Model/Field.cs
namespace Minesweeper.Model;

public struct Field
{
    public bool IsMine { get; set; }
    public bool IsRevealed { get; set; }
    public int AdjacentMines { get; set; }
}
EOF

cat << 'EOF' > Minesweeper.Model/GameEventArgs.cs
namespace Minesweeper.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public Player CurrentPlayer { get; }
    public int RemainingSafeCells { get; }

    public GameEventArgs(Player winner, Player currentPlayer, int remainingSafeCells)
    {
        Winner = winner;
        CurrentPlayer = currentPlayer;
        RemainingSafeCells = remainingSafeCells;
    }
}
EOF

cat << 'EOF' > Minesweeper.Model/IMinesweeperDataAccess.cs
namespace Minesweeper.Model;

public interface IMinesweeperDataAccess
{
    Task<(int Size, Player CurrentPlayer, Field[,] Board)> LoadAsync(string path);
    Task SaveAsync(string path, int size, Player currentPlayer, Field[,] board);
}
EOF

cat << 'EOF' > Minesweeper.Model/MinesweeperDataAccess.cs
namespace Minesweeper.Model;

public class MinesweeperDataAccess : IMinesweeperDataAccess
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
                        IsMine = cellData[0] == "1",
                        IsRevealed = cellData[1] == "1",
                        AdjacentMines = int.Parse(cellData[2])
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
                    int m = f.IsMine ? 1 : 0;
                    int rev = f.IsRevealed ? 1 : 0;
                    row[c] = $"{m}:{rev}:{f.AdjacentMines}";
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

cat << 'EOF' > Minesweeper.Model/MinesweeperGameModel.cs
namespace Minesweeper.Model;

public class MinesweeperGameModel
{
    private readonly IMinesweeperDataAccess? _dataAccess;
    private readonly Random _random = new Random();
    private Field[,] _board;

    public int Size { get; private set; }
    public Player CurrentPlayer { get; private set; }
    public int RemainingSafeCells { get; private set; }
    public bool IsGameOver { get; private set; }

    public event EventHandler<GameEventArgs>? GameChanged;
    public event EventHandler<GameEventArgs>? GameOver;

    public MinesweeperGameModel(IMinesweeperDataAccess? dataAccess = null)
    {
        _dataAccess = dataAccess;
        Size = 6;
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
        if (size != 6 && size != 10 && size != 16)
            throw new ArgumentException("Board size must be 6, 10, or 16.", nameof(size));

        Size = size;
        _board = new Field[Size, Size];
        CurrentPlayer = Player.Player1;
        IsGameOver = false;

        int mineCount = Math.Max(1, (Size * Size) / 6);
        List<(int r, int c)> positions = new List<(int r, int c)>();
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                positions.Add((r, c));
            }
        }

        for (int i = positions.Count - 1; i > 0; i--)
        {
            int j = _random.Next(i + 1);
            (positions[i], positions[j]) = (positions[j], positions[i]);
        }

        for (int i = 0; i < mineCount; i++)
        {
            var (mr, mc) = positions[i];
            _board[mr, mc].IsMine = true;
        }

        RecalculateAdjacentsAndRemaining();
        OnGameChanged();
    }

    public void SetupCustomBoard(int size, Player currentPlayer, bool[,] mines)
    {
        Size = size;
        CurrentPlayer = currentPlayer;
        IsGameOver = false;
        _board = new Field[Size, Size];

        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                _board[r, c].IsMine = mines[r, c];
            }
        }

        RecalculateAdjacentsAndRemaining();
        OnGameChanged();
    }

    public bool Step(int row, int col)
    {
        if (IsGameOver)
            return false;

        if (row < 0 || row >= Size || col < 0 || col >= Size)
            return false;

        if (_board[row, col].IsRevealed)
            return false;

        if (_board[row, col].IsMine)
        {
            RevealAllMines();
            IsGameOver = true;
            Player winner = CurrentPlayer == Player.Player1 ? Player.Player2 : Player.Player1;
            OnGameChanged(winner);
            OnGameOver(winner);
            return true;
        }

        RevealCellsFrom(row, col);

        if (RemainingSafeCells == 0)
        {
            IsGameOver = true;
            OnGameChanged(Player.None);
            OnGameOver(Player.None);
        }
        else
        {
            CurrentPlayer = CurrentPlayer == Player.Player1 ? Player.Player2 : Player.Player1;
            OnGameChanged();
        }

        return true;
    }

    private void RevealCellsFrom(int startRow, int startCol)
    {
        Queue<(int r, int c)> queue = new Queue<(int r, int c)>();
        queue.Enqueue((startRow, startCol));

        while (queue.Count > 0)
        {
            var (r, c) = queue.Dequeue();
            if (r < 0 || r >= Size || c < 0 || c >= Size)
                continue;

            if (_board[r, c].IsRevealed || _board[r, c].IsMine)
                continue;

            _board[r, c].IsRevealed = true;
            RemainingSafeCells--;

            if (_board[r, c].AdjacentMines == 0)
            {
                for (int dr = -1; dr <= 1; dr++)
                {
                    for (int dc = -1; dc <= 1; dc++)
                    {
                        if (dr != 0 || dc != 0)
                        {
                            queue.Enqueue((r + dr, c + dc));
                        }
                    }
                }
            }
        }
    }

    private void RevealAllMines()
    {
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                if (_board[r, c].IsMine)
                {
                    _board[r, c].IsRevealed = true;
                }
            }
        }
    }

    private void RecalculateAdjacentsAndRemaining()
    {
        int safe = 0;
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                if (!_board[r, c].IsMine && !_board[r, c].IsRevealed)
                {
                    safe++;
                }

                int count = 0;
                for (int dr = -1; dr <= 1; dr++)
                {
                    for (int dc = -1; dc <= 1; dc++)
                    {
                        if (dr == 0 && dc == 0) continue;
                        int nr = r + dr;
                        int nc = c + dc;
                        if (nr >= 0 && nr < Size && nc >= 0 && nc < Size && _board[nr, nc].IsMine)
                        {
                            count++;
                        }
                    }
                }
                _board[r, c].AdjacentMines = count;
            }
        }
        RemainingSafeCells = safe;
    }

    public async Task LoadGameAsync(string path)
    {
        if (_dataAccess == null)
            throw new InvalidOperationException("No data access is provided.");

        var (size, currentPlayer, board) = await _dataAccess.LoadAsync(path);
        Size = size;
        CurrentPlayer = currentPlayer;
        _board = board;
        RecalculateAdjacentsAndRemaining();
        IsGameOver = RemainingSafeCells == 0;

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
        GameChanged?.Invoke(this, new GameEventArgs(winner, CurrentPlayer, RemainingSafeCells));
    }

    private void OnGameOver(Player winner)
    {
        GameOver?.Invoke(this, new GameEventArgs(winner, CurrentPlayer, RemainingSafeCells));
    }
}
EOF

cat << 'EOF' > Minesweeper/Minesweeper.csproj
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
    <ProjectReference Include="..\Minesweeper.Model\Minesweeper.Model.csproj" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > Minesweeper/Program.cs
namespace Minesweeper;

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

cat << 'EOF' > Minesweeper/MainForm.Designer.cs
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
EOF

cat << 'EOF' > Minesweeper/MainForm.cs
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
EOF

cat << 'EOF' > Minesweeper/MainForm.resx
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

cat << 'EOF' > Minesweeper.Test/Minesweeper.Test.csproj
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
    <ProjectReference Include="..\Minesweeper.Model\Minesweeper.Model.csproj" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Microsoft.VisualStudio.TestTools.UnitTesting" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > Minesweeper.Test/MSTestSettings.cs
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
EOF

cat << 'EOF' > Minesweeper.Test/Test1.cs
using Minesweeper.Model;

namespace Minesweeper.Test;

[TestClass]
public sealed class Test1
{
    private sealed class MockDataAccess : IMinesweeperDataAccess
    {
        public int SavedSize { get; private set; }
        public Player SavedPlayer { get; private set; }
        public Field[,]? SavedBoard { get; private set; }

        public int SizeToLoad { get; set; } = 6;
        public Player PlayerToLoad { get; set; } = Player.Player2;
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
    [DataRow(6)]
    [DataRow(10)]
    [DataRow(16)]
    public void NewGame_InitializesBoardCorrectly(int size)
    {
        var model = new MinesweeperGameModel();
        model.NewGame(size);

        Assert.AreEqual(size, model.Size);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);
        Assert.IsFalse(model.IsGameOver);

        int expectedMines = (size * size) / 6;
        Assert.AreEqual(size * size - expectedMines, model.RemainingSafeCells);
    }

    [TestMethod]
    public void Step_ZeroAdjacentMines_CascadesReveal()
    {
        var model = new MinesweeperGameModel();
        bool[,] mines = new bool[6, 6];
        mines[5, 5] = true;

        model.SetupCustomBoard(6, Player.Player1, mines);

        bool stepped = model.Step(0, 0);

        Assert.IsTrue(stepped);
        Assert.IsTrue(model.GetField(0, 0).IsRevealed);
        Assert.IsTrue(model.GetField(4, 4).IsRevealed);
        Assert.AreEqual(1, model.GetField(4, 4).AdjacentMines);
        Assert.AreEqual(0, model.RemainingSafeCells);
        Assert.IsTrue(model.IsGameOver);
    }

    [TestMethod]
    public void Step_HitMine_OtherPlayerWins()
    {
        var model = new MinesweeperGameModel();
        bool[,] mines = new bool[6, 6];
        mines[0, 0] = true;
        mines[5, 5] = true;

        model.SetupCustomBoard(6, Player.Player1, mines);

        Player? winner = null;
        model.GameOver += (_, e) => winner = e.Winner;

        bool stepped = model.Step(0, 0);

        Assert.IsTrue(stepped);
        Assert.IsTrue(model.IsGameOver);
        Assert.AreEqual(Player.Player2, winner);
    }

    [TestMethod]
    public void Step_RevealAllSafeCells_ResultsInDraw()
    {
        var model = new MinesweeperGameModel();
        bool[,] mines = new bool[6, 6];
        mines[5, 5] = true;

        model.SetupCustomBoard(6, Player.Player1, mines);

        Player? winner = null;
        model.GameOver += (_, e) => winner = e.Winner;

        model.Step(0, 0);

        Assert.IsTrue(model.IsGameOver);
        Assert.AreEqual(Player.None, winner);
    }

    [TestMethod]
    public void Step_AlreadyRevealedCell_ReturnsFalseAndKeepsTurn()
    {
        var model = new MinesweeperGameModel();
        bool[,] mines = new bool[6, 6];
        mines[0, 1] = true;

        model.SetupCustomBoard(6, Player.Player1, mines);

        Assert.IsTrue(model.Step(0, 0));
        Assert.AreEqual(Player.Player2, model.CurrentPlayer);

        Assert.IsFalse(model.Step(0, 0));
        Assert.AreEqual(Player.Player2, model.CurrentPlayer);
    }

    [TestMethod]
    public async Task SaveAndLoadGame_UsesDataAccessCorrectly()
    {
        var mock = new MockDataAccess();
        var model = new MinesweeperGameModel(mock);
        model.NewGame(10);

        await model.SaveGameAsync("test.ms");

        Assert.AreEqual(10, mock.SavedSize);
        Assert.AreEqual(Player.Player1, mock.SavedPlayer);
        Assert.IsNotNull(mock.SavedBoard);

        Field[,] customBoard = new Field[6, 6];
        customBoard[0, 0].IsMine = true;
        mock.SizeToLoad = 6;
        mock.PlayerToLoad = Player.Player2;
        mock.BoardToLoad = customBoard;

        await model.LoadGameAsync("test.ms");

        Assert.AreEqual(6, model.Size);
        Assert.AreEqual(Player.Player2, model.CurrentPlayer);
        Assert.IsTrue(model.GetField(0, 0).IsMine);
    }
}
EOF

echo "Minesweeper solution successfully generated in ./Minesweeper"
