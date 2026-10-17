#!/usr/bin/env bash
set -e

mkdir -p BlackHole/BlackHole
mkdir -p BlackHole/BlackHole.Model
mkdir -p BlackHole/BlackHole.Test

cd BlackHole

cat << 'EOF' > BlackHole.slnx
<Solution>
  <Project Path="BlackHole.Model/BlackHole.Model.csproj" />
  <Project Path="BlackHole.Test/BlackHole.Test.csproj" />
  <Project Path="BlackHole/BlackHole.csproj" />
</Solution>
EOF

cat << 'EOF' > BlackHole.Model/BlackHole.Model.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>net10.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

</Project>
EOF

cat << 'EOF' > BlackHole.Model/Player.cs
namespace BlackHole.Model;

public enum Player
{
    None,
    Player1,
    Player2
}
EOF

cat << 'EOF' > BlackHole.Model/Field.cs
namespace BlackHole.Model;

public enum Field
{
    Empty,
    BlackHole,
    Player1Ship,
    Player2Ship
}
EOF

cat << 'EOF' > BlackHole.Model/GameEventArgs.cs
namespace BlackHole.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public int Player1Entered { get; }
    public int Player2Entered { get; }
    public Player CurrentPlayer { get; }

    public GameEventArgs(Player winner, int player1Entered, int player2Entered, Player currentPlayer)
    {
        Winner = winner;
        Player1Entered = player1Entered;
        Player2Entered = player2Entered;
        CurrentPlayer = currentPlayer;
    }
}
EOF

cat << 'EOF' > BlackHole.Model/IBlackHoleDataAccess.cs
namespace BlackHole.Model;

public interface IBlackHoleDataAccess
{
    Task<(int Size, Player CurrentPlayer, int P1Entered, int P2Entered, Field[,] Board)> LoadAsync(string path);
    Task SaveAsync(string path, int size, Player currentPlayer, int p1Entered, int p2Entered, Field[,] board);
}
EOF

cat << 'EOF' > BlackHole.Model/BlackHoleDataAccess.cs
namespace BlackHole.Model;

public class BlackHoleDataAccess : IBlackHoleDataAccess
{
    public async Task<(int Size, Player CurrentPlayer, int P1Entered, int P2Entered, Field[,] Board)> LoadAsync(string path)
    {
        try
        {
            using StreamReader reader = new StreamReader(path);
            string? header = await reader.ReadLineAsync();
            if (string.IsNullOrWhiteSpace(header))
                throw new InvalidDataException("Invalid save file header.");

            string[] parts = header.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 4)
                throw new InvalidDataException("Corrupted save file header.");

            int size = int.Parse(parts[0]);
            Player currentPlayer = Enum.Parse<Player>(parts[1]);
            int p1Entered = int.Parse(parts[2]);
            int p2Entered = int.Parse(parts[3]);

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

            return (size, currentPlayer, p1Entered, p2Entered, board);
        }
        catch (Exception ex)
        {
            throw new IOException("Failed to load the game.", ex);
        }
    }

    public async Task SaveAsync(string path, int size, Player currentPlayer, int p1Entered, int p2Entered, Field[,] board)
    {
        try
        {
            using StreamWriter writer = new StreamWriter(path);
            await writer.WriteLineAsync($"{size} {currentPlayer} {p1Entered} {p2Entered}");
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

cat << 'EOF' > BlackHole.Model/BlackHoleGameModel.cs
namespace BlackHole.Model;

public class BlackHoleGameModel
{
    private readonly IBlackHoleDataAccess? _dataAccess;
    private Field[,] _board;

    public int Size { get; private set; }
    public Player CurrentPlayer { get; private set; }
    public int Player1Entered { get; private set; }
    public int Player2Entered { get; private set; }
    public int TargetShips => (Size - 1) / 2;
    public bool IsGameOver { get; private set; }
    public (int Row, int Col)? SelectedShip { get; private set; }

    public event EventHandler<GameEventArgs>? GameChanged;
    public event EventHandler<GameEventArgs>? GameOver;

    public BlackHoleGameModel(IBlackHoleDataAccess? dataAccess = null)
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
        if (size != 5 && size != 7 && size != 9)
            throw new ArgumentException("Board size must be 5, 7, or 9.", nameof(size));

        Size = size;
        _board = new Field[Size, Size];
        CurrentPlayer = Player.Player1;
        Player1Entered = 0;
        Player2Entered = 0;
        IsGameOver = false;
        SelectedShip = null;

        int center = Size / 2;
        for (int r = 0; r < Size; r++)
        {
            for (int c = 0; c < Size; c++)
            {
                if (r == center && c == center)
                {
                    _board[r, c] = Field.BlackHole;
                }
                else if (r == c || r + c == Size - 1)
                {
                    _board[r, c] = r < center ? Field.Player1Ship : Field.Player2Ship;
                }
                else
                {
                    _board[r, c] = Field.Empty;
                }
            }
        }

        OnGameChanged();
    }

    public void SelectCell(int row, int col)
    {
        if (IsGameOver)
            return;

        if (row < 0 || row >= Size || col < 0 || col >= Size)
            return;

        Field clicked = _board[row, col];
        Field ownShip = CurrentPlayer == Player.Player1 ? Field.Player1Ship : Field.Player2Ship;

        if (clicked == ownShip)
        {
            SelectedShip = (row, col);
            OnGameChanged();
            return;
        }

        if (SelectedShip.HasValue)
        {
            var (sRow, sCol) = SelectedShip.Value;
            int dRow = row - sRow;
            int dCol = col - sCol;

            if ((dRow == 0 && dCol != 0) || (dRow != 0 && dCol == 0))
            {
                int stepR = Math.Sign(dRow);
                int stepC = Math.Sign(dCol);
                MoveSelectedShip(stepR, stepC);
            }
        }
    }

    public bool MoveShip(int row, int col, int dRow, int dCol)
    {
        if (IsGameOver)
            return false;

        if (row < 0 || row >= Size || col < 0 || col >= Size)
            return false;

        if (Math.Abs(dRow) + Math.Abs(dCol) != 1)
            return false;

        Field ownShip = CurrentPlayer == Player.Player1 ? Field.Player1Ship : Field.Player2Ship;
        if (_board[row, col] != ownShip)
            return false;

        SelectedShip = (row, col);
        return MoveSelectedShip(dRow, dCol);
    }

    private bool MoveSelectedShip(int dRow, int dCol)
    {
        if (!SelectedShip.HasValue)
            return false;

        var (startR, startC) = SelectedShip.Value;
        Field ship = _board[startR, startC];

        int currR = startR;
        int currC = startC;
        bool enteredBlackHole = false;

        while (true)
        {
            int nextR = currR + dRow;
            int nextC = currC + dCol;

            if (nextR < 0 || nextR >= Size || nextC < 0 || nextC >= Size)
                break;

            if (_board[nextR, nextC] == Field.BlackHole)
            {
                enteredBlackHole = true;
                break;
            }

            if (_board[nextR, nextC] != Field.Empty)
                break;

            currR = nextR;
            currC = nextC;
        }

        if (!enteredBlackHole && currR == startR && currC == startC)
            return false;

        _board[startR, startC] = Field.Empty;

        if (enteredBlackHole)
        {
            if (CurrentPlayer == Player.Player1)
                Player1Entered++;
            else
                Player2Entered++;
        }
        else
        {
            _board[currR, currC] = ship;
        }

        SelectedShip = null;

        if (Player1Entered >= TargetShips)
        {
            IsGameOver = true;
            OnGameChanged();
            OnGameOver(Player.Player1);
        }
        else if (Player2Entered >= TargetShips)
        {
            IsGameOver = true;
            OnGameChanged();
            OnGameOver(Player.Player2);
        }
        else
        {
            CurrentPlayer = CurrentPlayer == Player.Player1 ? Player.Player2 : Player.Player1;
            OnGameChanged();
        }

        return true;
    }

    public async Task LoadGameAsync(string path)
    {
        if (_dataAccess == null)
            throw new InvalidOperationException("No data access is provided.");

        var (size, currentPlayer, p1Entered, p2Entered, board) = await _dataAccess.LoadAsync(path);
        Size = size;
        CurrentPlayer = currentPlayer;
        Player1Entered = p1Entered;
        Player2Entered = p2Entered;
        _board = board;
        SelectedShip = null;
        IsGameOver = Player1Entered >= TargetShips || Player2Entered >= TargetShips;

        OnGameChanged();
    }

    public async Task SaveGameAsync(string path)
    {
        if (_dataAccess == null)
            throw new InvalidOperationException("No data access is provided.");

        await _dataAccess.SaveAsync(path, Size, CurrentPlayer, Player1Entered, Player2Entered, _board);
    }

    private void OnGameChanged()
    {
        Player winner = Player.None;
        if (IsGameOver)
        {
            winner = Player1Entered >= TargetShips ? Player.Player1 : Player.Player2;
        }
        GameChanged?.Invoke(this, new GameEventArgs(winner, Player1Entered, Player2Entered, CurrentPlayer));
    }

    private void OnGameOver(Player winner)
    {
        GameOver?.Invoke(this, new GameEventArgs(winner, Player1Entered, Player2Entered, CurrentPlayer));
    }
}
EOF

cat << 'EOF' > BlackHole/BlackHole.csproj
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>net10.0-windows</TargetFramework>
    <EnableWindowsTargeting>true</EnableWindowsTargeting>
    <Nullable>enable</Nullable>
    <UseWindowsForms>true</UseWindowsForms>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="..\BlackHole.Model\BlackHole.Model.csproj" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > BlackHole/Program.cs
namespace BlackHole;

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

cat << 'EOF' > BlackHole/MainForm.Designer.cs
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
EOF

cat << 'EOF' > BlackHole/MainForm.cs
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
EOF

cat << 'EOF' > BlackHole/MainForm.resx
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

cat << 'EOF' > BlackHole.Test/BlackHole.Test.csproj
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
    <ProjectReference Include="..\BlackHole.Model\BlackHole.Model.csproj" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Microsoft.VisualStudio.TestTools.UnitTesting" />
  </ItemGroup>

</Project>
EOF

cat << 'EOF' > BlackHole.Test/MSTestSettings.cs
[assembly: Parallelize(Scope = ExecutionScope.MethodLevel)]
EOF

cat << 'EOF' > BlackHole.Test/Test1.cs
using BlackHole.Model;

namespace BlackHole.Test;

[TestClass]
public sealed class Test1
{
    private sealed class MockDataAccess : IBlackHoleDataAccess
    {
        public int SavedSize { get; private set; }
        public Player SavedPlayer { get; private set; }
        public int SavedP1Entered { get; private set; }
        public int SavedP2Entered { get; private set; }
        public Field[,]? SavedBoard { get; private set; }

        public int SizeToLoad { get; set; } = 5;
        public Player PlayerToLoad { get; set; } = Player.Player2;
        public int P1EnteredToLoad { get; set; } = 1;
        public int P2EnteredToLoad { get; set; } = 1;
        public Field[,]? BoardToLoad { get; set; }

        public Task<(int Size, Player CurrentPlayer, int P1Entered, int P2Entered, Field[,] Board)> LoadAsync(string path)
        {
            Field[,] board = BoardToLoad ?? new Field[SizeToLoad, SizeToLoad];
            return Task.FromResult((SizeToLoad, PlayerToLoad, P1EnteredToLoad, P2EnteredToLoad, board));
        }

        public Task SaveAsync(string path, int size, Player currentPlayer, int p1Entered, int p2Entered, Field[,] board)
        {
            SavedSize = size;
            SavedPlayer = currentPlayer;
            SavedP1Entered = p1Entered;
            SavedP2Entered = p2Entered;
            SavedBoard = board;
            return Task.CompletedTask;
        }
    }

    [TestMethod]
    [DataRow(5, 2)]
    [DataRow(7, 3)]
    [DataRow(9, 4)]
    public void NewGame_InitializesBoardCorrectly(int size, int expectedTarget)
    {
        var model = new BlackHoleGameModel();
        model.NewGame(size);

        Assert.AreEqual(size, model.Size);
        Assert.AreEqual(expectedTarget, model.TargetShips);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);
        Assert.AreEqual(0, model.Player1Entered);
        Assert.AreEqual(0, model.Player2Entered);
        Assert.IsFalse(model.IsGameOver);

        int center = size / 2;
        Assert.AreEqual(Field.BlackHole, model.GetField(center, center));

        int p1Count = 0;
        int p2Count = 0;
        for (int r = 0; r < size; r++)
        {
            for (int c = 0; c < size; c++)
            {
                if (model.GetField(r, c) == Field.Player1Ship) p1Count++;
                if (model.GetField(r, c) == Field.Player2Ship) p2Count++;
            }
        }

        Assert.AreEqual(size - 1, p1Count);
        Assert.AreEqual(size - 1, p2Count);
    }

    [TestMethod]
    public void MoveShip_SlidesUntilWallOrOtherShip()
    {
        var model = new BlackHoleGameModel();
        model.NewGame(5);

        bool moved = model.MoveShip(0, 0, 1, 0);

        Assert.IsTrue(moved);
        Assert.AreEqual(Field.Empty, model.GetField(0, 0));
        Assert.AreEqual(Field.Player1Ship, model.GetField(3, 0));
        Assert.AreEqual(Player.Player2, model.CurrentPlayer);
    }

    [TestMethod]
    public void MoveShip_EntersBlackHole_IncrementsScore()
    {
        var model = new BlackHoleGameModel();
        model.NewGame(5);

        Assert.IsTrue(model.MoveShip(1, 1, 0, 1));
        Assert.AreEqual(Field.Player1Ship, model.GetField(1, 2));
        Assert.AreEqual(Player.Player2, model.CurrentPlayer);

        Assert.IsTrue(model.MoveShip(4, 0, -1, 0));
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);

        Assert.IsTrue(model.MoveShip(1, 2, 1, 0));
        Assert.AreEqual(Field.Empty, model.GetField(1, 2));
        Assert.AreEqual(Field.BlackHole, model.GetField(2, 2));
        Assert.AreEqual(1, model.Player1Entered);
    }

    [TestMethod]
    public void MoveShip_WinningCondition_FiresGameOverEvent()
    {
        var model = new BlackHoleGameModel();
        model.NewGame(5);

        Player winner = Player.None;
        model.GameOver += (_, e) => winner = e.Winner;

        model.MoveShip(1, 1, 0, 1);
        model.MoveShip(4, 0, -1, 0);
        model.MoveShip(1, 2, 1, 0);
        model.MoveShip(4, 4, -1, 0);
        model.MoveShip(1, 3, 0, -1);
        model.MoveShip(3, 4, -1, 0);
        model.MoveShip(1, 2, 1, 0);

        Assert.IsTrue(model.IsGameOver);
        Assert.AreEqual(2, model.Player1Entered);
        Assert.AreEqual(Player.Player1, winner);
    }

    [TestMethod]
    public void MoveShip_InvalidMove_ReturnsFalseAndDoesNotChangeTurn()
    {
        var model = new BlackHoleGameModel();
        model.NewGame(5);

        bool movedOutOfBounds = model.MoveShip(0, 0, -1, 0);
        Assert.IsFalse(movedOutOfBounds);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);

        bool movedOpponentShip = model.MoveShip(4, 0, -1, 0);
        Assert.IsFalse(movedOpponentShip);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);
    }

    [TestMethod]
    public async Task SaveAndLoadGame_UsesDataAccessCorrectly()
    {
        var mock = new MockDataAccess();
        var model = new BlackHoleGameModel(mock);
        model.NewGame(7);
        model.MoveShip(0, 0, 1, 0);

        await model.SaveGameAsync("dummy.bh");

        Assert.AreEqual(7, mock.SavedSize);
        Assert.AreEqual(Player.Player2, mock.SavedPlayer);
        Assert.IsNotNull(mock.SavedBoard);

        Field[,] customBoard = new Field[5, 5];
        customBoard[2, 2] = Field.BlackHole;
        customBoard[0, 2] = Field.Player1Ship;
        mock.SizeToLoad = 5;
        mock.PlayerToLoad = Player.Player1;
        mock.P1EnteredToLoad = 1;
        mock.P2EnteredToLoad = 0;
        mock.BoardToLoad = customBoard;

        await model.LoadGameAsync("dummy.bh");

        Assert.AreEqual(5, model.Size);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);
        Assert.AreEqual(1, model.Player1Entered);
        Assert.AreEqual(Field.Player1Ship, model.GetField(0, 2));
    }
}
EOF

echo "BlackHole solution successfully generated in ./BlackHole"
