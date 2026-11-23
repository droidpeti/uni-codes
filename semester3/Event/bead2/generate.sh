#!/usr/bin/env bash
set -euo pipefail

PROJECT_NAME="DropOutTicTacToe"
TFM="${TFM:-net8.0}"
ROOT="${1:-$PROJECT_NAME}"

mkdir -p "$ROOT/TicTacToe.Persistence" \
         "$ROOT/TicTacToe.Model" \
         "$ROOT/TicTacToe.App/View" \
         "$ROOT/TicTacToe.App/ViewModel" \
         "$ROOT/TicTacToe.Tests" \
         "$ROOT/docs"

cat > "$ROOT/Directory.Build.props" <<EOF
<Project>
  <PropertyGroup>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <LangVersion>latest</LangVersion>
    <EnableWindowsTargeting>true</EnableWindowsTargeting>
  </PropertyGroup>
</Project>
EOF

cat > "$ROOT/.gitignore" <<'EOF'
bin/
obj/
.vs/
*.user
*.dtt
EOF

cat > "$ROOT/TicTacToe.Persistence/TicTacToe.Persistence.csproj" <<EOF
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>$TFM</TargetFramework>
    <RootNamespace>TicTacToe.Persistence</RootNamespace>
  </PropertyGroup>

</Project>
EOF

cat > "$ROOT/TicTacToe.Persistence/GameData.cs" <<'EOF'
namespace TicTacToe.Persistence;

public class GameData
{
    public GameData(int size, int[,] board, int currentPlayer, int firstPlayerSeconds, int secondPlayerSeconds)
    {
        Size = size;
        Board = board;
        CurrentPlayer = currentPlayer;
        FirstPlayerSeconds = firstPlayerSeconds;
        SecondPlayerSeconds = secondPlayerSeconds;
    }

    public int Size { get; }

    public int[,] Board { get; }

    public int CurrentPlayer { get; }

    public int FirstPlayerSeconds { get; }

    public int SecondPlayerSeconds { get; }
}
EOF

cat > "$ROOT/TicTacToe.Persistence/GameDataException.cs" <<'EOF'
namespace TicTacToe.Persistence;

public class GameDataException : Exception
{
    public GameDataException(string message) : base(message)
    {
    }

    public GameDataException(string message, Exception innerException) : base(message, innerException)
    {
    }
}
EOF

cat > "$ROOT/TicTacToe.Persistence/IGameDataAccess.cs" <<'EOF'
namespace TicTacToe.Persistence;

public interface IGameDataAccess
{
    Task<GameData> LoadAsync(string path);

    Task SaveAsync(string path, GameData data);
}
EOF

cat > "$ROOT/TicTacToe.Persistence/FileGameDataAccess.cs" <<'EOF'
using System.Text;

namespace TicTacToe.Persistence;

public class FileGameDataAccess : IGameDataAccess
{
    private const char EmptyChar = '.';
    private const char FirstChar = 'X';
    private const char SecondChar = 'O';
    private const int HeaderLineCount = 4;

    public async Task<GameData> LoadAsync(string path)
    {
        try
        {
            string[] lines = await File.ReadAllLinesAsync(path);
            if (lines.Length <= HeaderLineCount)
            {
                throw new GameDataException("The file is incomplete.");
            }

            int size = int.Parse(lines[0]);
            int currentPlayer = int.Parse(lines[1]);
            int firstPlayerSeconds = int.Parse(lines[2]);
            int secondPlayerSeconds = int.Parse(lines[3]);

            if (size < 1 || lines.Length != size + HeaderLineCount)
            {
                throw new GameDataException("The number of board rows is invalid.");
            }

            int[,] board = new int[size, size];
            for (int row = 0; row < size; row++)
            {
                string line = lines[row + HeaderLineCount];
                if (line.Length != size)
                {
                    throw new GameDataException("A board row has an invalid length.");
                }

                for (int column = 0; column < size; column++)
                {
                    board[row, column] = ParseCell(line[column]);
                }
            }

            return new GameData(size, board, currentPlayer, firstPlayerSeconds, secondPlayerSeconds);
        }
        catch (GameDataException)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw new GameDataException("The game file could not be read.", ex);
        }
    }

    public async Task SaveAsync(string path, GameData data)
    {
        try
        {
            List<string> lines = new()
            {
                data.Size.ToString(),
                data.CurrentPlayer.ToString(),
                data.FirstPlayerSeconds.ToString(),
                data.SecondPlayerSeconds.ToString()
            };

            for (int row = 0; row < data.Size; row++)
            {
                StringBuilder builder = new();
                for (int column = 0; column < data.Size; column++)
                {
                    builder.Append(ToChar(data.Board[row, column]));
                }

                lines.Add(builder.ToString());
            }

            await File.WriteAllLinesAsync(path, lines);
        }
        catch (Exception ex)
        {
            throw new GameDataException("The game could not be saved.", ex);
        }
    }

    private static int ParseCell(char value)
    {
        switch (value)
        {
            case EmptyChar:
                return 0;
            case FirstChar:
                return 1;
            case SecondChar:
                return 2;
            default:
                throw new GameDataException("The board contains an invalid character.");
        }
    }

    private static char ToChar(int value)
    {
        switch (value)
        {
            case 1:
                return FirstChar;
            case 2:
                return SecondChar;
            default:
                return EmptyChar;
        }
    }
}
EOF

cat > "$ROOT/TicTacToe.Model/TicTacToe.Model.csproj" <<EOF
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>$TFM</TargetFramework>
    <RootNamespace>TicTacToe.Model</RootNamespace>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="../TicTacToe.Persistence/TicTacToe.Persistence.csproj" />
  </ItemGroup>

</Project>
EOF

cat > "$ROOT/TicTacToe.Model/Player.cs" <<'EOF'
namespace TicTacToe.Model;

public enum Player
{
    None = 0,
    First = 1,
    Second = 2
}
EOF

cat > "$ROOT/TicTacToe.Model/GameStatus.cs" <<'EOF'
namespace TicTacToe.Model;

public enum GameStatus
{
    InProgress,
    FirstPlayerWon,
    SecondPlayerWon,
    Draw
}
EOF

cat > "$ROOT/TicTacToe.Model/CellChangedEventArgs.cs" <<'EOF'
namespace TicTacToe.Model;

public class CellChangedEventArgs : EventArgs
{
    public CellChangedEventArgs(int row, int column, Player player)
    {
        Row = row;
        Column = column;
        Player = player;
    }

    public int Row { get; }

    public int Column { get; }

    public Player Player { get; }
}
EOF

cat > "$ROOT/TicTacToe.Model/GameOverEventArgs.cs" <<'EOF'
namespace TicTacToe.Model;

public class GameOverEventArgs : EventArgs
{
    public GameOverEventArgs(GameStatus status, IReadOnlyList<(int Row, int Column)> winningCells)
    {
        Status = status;
        WinningCells = winningCells;
    }

    public GameStatus Status { get; }

    public IReadOnlyList<(int Row, int Column)> WinningCells { get; }
}
EOF

cat > "$ROOT/TicTacToe.Model/GameModel.cs" <<'EOF'
using TicTacToe.Persistence;

namespace TicTacToe.Model;

public class GameModel : IDisposable
{
    public const int WinLength = 4;
    public const int MinSize = 4;
    public const int DefaultSize = 10;

    private static readonly (int Row, int Column)[] Directions = { (0, 1), (1, 1), (1, -1) };

    private readonly IGameDataAccess _dataAccess;
    private readonly System.Timers.Timer? _timer;
    private readonly object _sync = new();
    private readonly int[] _thinkingSeconds = new int[3];
    private Player[,] _board = new Player[0, 0];
    private List<(int Row, int Column)> _winningCells = new();

    public GameModel(IGameDataAccess dataAccess, bool enableTimer = true)
    {
        _dataAccess = dataAccess;
        ResetBoard(DefaultSize);

        if (enableTimer)
        {
            _timer = new System.Timers.Timer(1000) { AutoReset = true };
            _timer.Elapsed += (_, _) => Tick();
            _timer.Start();
        }
    }

    public event EventHandler? GameStarted;

    public event EventHandler<CellChangedEventArgs>? CellChanged;

    public event EventHandler? PlayerChanged;

    public event EventHandler? TimeChanged;

    public event EventHandler? PauseChanged;

    public event EventHandler<GameOverEventArgs>? GameOver;

    public int Size { get; private set; }

    public Player CurrentPlayer { get; private set; }

    public GameStatus Status { get; private set; }

    public bool IsPaused { get; private set; }

    public bool IsGameOver => Status != GameStatus.InProgress;

    public IReadOnlyList<(int Row, int Column)> WinningCells => _winningCells;

    public Player GetCell(int row, int column)
    {
        if (!IsInside(_board, row, column))
        {
            throw new ArgumentOutOfRangeException(nameof(row));
        }

        return _board[row, column];
    }

    public TimeSpan GetThinkingTime(Player player)
    {
        if (player == Player.None)
        {
            throw new ArgumentException("A real player is required.", nameof(player));
        }

        lock (_sync)
        {
            return TimeSpan.FromSeconds(_thinkingSeconds[(int)player]);
        }
    }

    public void NewGame(int size)
    {
        if (size < MinSize)
        {
            throw new ArgumentOutOfRangeException(nameof(size));
        }

        lock (_sync)
        {
            ResetBoard(size);
        }

        GameStarted?.Invoke(this, EventArgs.Empty);
    }

    public bool Step(int row, int column)
    {
        Player player;
        int landingRow;
        GameStatus status;

        lock (_sync)
        {
            if (IsGameOver || IsPaused || !IsInside(_board, row, column) || _board[row, column] != Player.None)
            {
                return false;
            }

            landingRow = FindLandingRow(column);
            player = CurrentPlayer;
            _board[landingRow, column] = player;

            List<(int Row, int Column)> winningCells = FindWinningCells(_board, landingRow, column);
            if (winningCells.Count > 0)
            {
                _winningCells = winningCells;
                Status = player == Player.First ? GameStatus.FirstPlayerWon : GameStatus.SecondPlayerWon;
            }
            else if (IsBoardFull())
            {
                Status = GameStatus.Draw;
            }
            else
            {
                CurrentPlayer = Opponent(player);
            }

            status = Status;
        }

        CellChanged?.Invoke(this, new CellChangedEventArgs(landingRow, column, player));

        if (status == GameStatus.InProgress)
        {
            PlayerChanged?.Invoke(this, EventArgs.Empty);
        }
        else
        {
            GameOver?.Invoke(this, new GameOverEventArgs(status, _winningCells.ToList()));
        }

        return true;
    }

    public void Pause()
    {
        lock (_sync)
        {
            if (IsGameOver || IsPaused)
            {
                return;
            }

            IsPaused = true;
        }

        PauseChanged?.Invoke(this, EventArgs.Empty);
    }

    public void Resume()
    {
        lock (_sync)
        {
            if (IsGameOver || !IsPaused)
            {
                return;
            }

            IsPaused = false;
        }

        PauseChanged?.Invoke(this, EventArgs.Empty);
    }

    public void Tick()
    {
        lock (_sync)
        {
            if (IsGameOver || IsPaused)
            {
                return;
            }

            _thinkingSeconds[(int)CurrentPlayer]++;
        }

        TimeChanged?.Invoke(this, EventArgs.Empty);
    }

    public async Task SaveGameAsync(string path)
    {
        GameData data;

        lock (_sync)
        {
            if (IsGameOver)
            {
                throw new InvalidOperationException("A finished game cannot be saved.");
            }

            int[,] board = new int[Size, Size];
            for (int row = 0; row < Size; row++)
            {
                for (int column = 0; column < Size; column++)
                {
                    board[row, column] = (int)_board[row, column];
                }
            }

            data = new GameData(
                Size,
                board,
                (int)CurrentPlayer,
                _thinkingSeconds[(int)Player.First],
                _thinkingSeconds[(int)Player.Second]);
        }

        await _dataAccess.SaveAsync(path, data);
    }

    public async Task LoadGameAsync(string path)
    {
        GameData data = await _dataAccess.LoadAsync(path);
        Player[,] board = ConvertBoard(data);

        lock (_sync)
        {
            _board = board;
            Size = data.Size;
            CurrentPlayer = (Player)data.CurrentPlayer;
            Status = GameStatus.InProgress;
            IsPaused = true;
            _winningCells = new();
            _thinkingSeconds[(int)Player.First] = data.FirstPlayerSeconds;
            _thinkingSeconds[(int)Player.Second] = data.SecondPlayerSeconds;
        }

        GameStarted?.Invoke(this, EventArgs.Empty);
    }

    public void Dispose()
    {
        _timer?.Dispose();
        GC.SuppressFinalize(this);
    }

    private void ResetBoard(int size)
    {
        _board = new Player[size, size];
        Size = size;
        CurrentPlayer = Player.First;
        Status = GameStatus.InProgress;
        IsPaused = false;
        _winningCells = new();
        Array.Clear(_thinkingSeconds, 0, _thinkingSeconds.Length);
    }

    private int FindLandingRow(int column)
    {
        for (int row = Size - 1; row >= 0; row--)
        {
            if (_board[row, column] == Player.None)
            {
                return row;
            }
        }

        return -1;
    }

    private bool IsBoardFull()
    {
        for (int column = 0; column < Size; column++)
        {
            if (_board[0, column] == Player.None)
            {
                return false;
            }
        }

        return true;
    }

    private static Player Opponent(Player player)
    {
        return player == Player.First ? Player.Second : Player.First;
    }

    private static bool IsInside(Player[,] board, int row, int column)
    {
        return row >= 0 && row < board.GetLength(0) && column >= 0 && column < board.GetLength(1);
    }

    private static List<(int Row, int Column)> FindWinningCells(Player[,] board, int row, int column)
    {
        Player player = board[row, column];

        foreach ((int rowStep, int columnStep) in Directions)
        {
            int startRow = row;
            int startColumn = column;
            while (IsInside(board, startRow - rowStep, startColumn - columnStep)
                   && board[startRow - rowStep, startColumn - columnStep] == player)
            {
                startRow -= rowStep;
                startColumn -= columnStep;
            }

            List<(int Row, int Column)> line = new();
            int index = 0;
            int currentRow = startRow;
            int currentColumn = startColumn;
            while (IsInside(board, currentRow, currentColumn) && board[currentRow, currentColumn] == player)
            {
                if (currentRow == row && currentColumn == column)
                {
                    index = line.Count;
                }

                line.Add((currentRow, currentColumn));
                currentRow += rowStep;
                currentColumn += columnStep;
            }

            if (line.Count >= WinLength)
            {
                int start = Math.Max(0, index - (WinLength - 1));
                return line.GetRange(start, WinLength);
            }
        }

        return new List<(int Row, int Column)>();
    }

    private static Player[,] ConvertBoard(GameData data)
    {
        int size = data.Size;

        if (size < MinSize || data.Board.GetLength(0) != size || data.Board.GetLength(1) != size)
        {
            throw new GameDataException("The board size is invalid.");
        }

        if (data.CurrentPlayer != (int)Player.First && data.CurrentPlayer != (int)Player.Second)
        {
            throw new GameDataException("The current player is invalid.");
        }

        if (data.FirstPlayerSeconds < 0 || data.SecondPlayerSeconds < 0)
        {
            throw new GameDataException("The thinking time is invalid.");
        }

        Player[,] board = new Player[size, size];
        int firstCount = 0;
        int secondCount = 0;

        for (int column = 0; column < size; column++)
        {
            bool filledFound = false;
            for (int row = 0; row < size; row++)
            {
                int value = data.Board[row, column];
                if (value < 0 || value > 2)
                {
                    throw new GameDataException("The board contains an invalid value.");
                }

                if (value == 0)
                {
                    if (filledFound)
                    {
                        throw new GameDataException("The board contains a floating sign.");
                    }

                    continue;
                }

                filledFound = true;
                board[row, column] = (Player)value;
                if (value == (int)Player.First)
                {
                    firstCount++;
                }
                else
                {
                    secondCount++;
                }
            }
        }

        int difference = firstCount - secondCount;
        if (difference is not (0 or 1))
        {
            throw new GameDataException("The number of signs is inconsistent.");
        }

        Player expectedPlayer = difference == 0 ? Player.First : Player.Second;
        if ((Player)data.CurrentPlayer != expectedPlayer)
        {
            throw new GameDataException("The current player does not match the board.");
        }

        if (firstCount + secondCount == size * size)
        {
            throw new GameDataException("The saved game is already finished.");
        }

        for (int row = 0; row < size; row++)
        {
            for (int column = 0; column < size; column++)
            {
                if (board[row, column] != Player.None && FindWinningCells(board, row, column).Count > 0)
                {
                    throw new GameDataException("The saved game is already finished.");
                }
            }
        }

        return board;
    }
}
EOF

cat > "$ROOT/TicTacToe.App/TicTacToe.App.csproj" <<EOF
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>WinExe</OutputType>
    <TargetFramework>${TFM}-windows</TargetFramework>
    <UseWPF>true</UseWPF>
    <RootNamespace>TicTacToe</RootNamespace>
    <AssemblyName>DropOutTicTacToe</AssemblyName>
  </PropertyGroup>

  <ItemGroup>
    <ProjectReference Include="../TicTacToe.Model/TicTacToe.Model.csproj" />
    <ProjectReference Include="../TicTacToe.Persistence/TicTacToe.Persistence.csproj" />
  </ItemGroup>

</Project>
EOF

cat > "$ROOT/TicTacToe.App/App.xaml" <<'EOF'
<Application x:Class="TicTacToe.App"
             xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml">
    <Application.Resources />
</Application>
EOF

cat > "$ROOT/TicTacToe.App/App.xaml.cs" <<'EOF'
using System.Windows;
using Microsoft.Win32;
using TicTacToe.Model;
using TicTacToe.Persistence;
using TicTacToe.View;
using TicTacToe.ViewModel;

namespace TicTacToe;

public partial class App : Application
{
    private const string Caption = "Drop-Out Tic-Tac-Toe";
    private const string FileFilter = "Game files (*.dtt)|*.dtt";

    private GameModel _model = null!;
    private MainViewModel _viewModel = null!;
    private MainWindow _window = null!;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        _model = new GameModel(new FileGameDataAccess());
        _viewModel = new MainViewModel(_model);
        _viewModel.SaveGameRequested += OnSaveGameRequested;
        _viewModel.LoadGameRequested += OnLoadGameRequested;
        _viewModel.GameFinished += OnGameFinished;
        _viewModel.ExitRequested += OnExitRequested;

        _window = new MainWindow { DataContext = _viewModel };
        _window.Show();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _model.Dispose();
        base.OnExit(e);
    }

    private async void OnSaveGameRequested(object? sender, EventArgs e)
    {
        SaveFileDialog dialog = new()
        {
            Title = "Save game",
            Filter = FileFilter,
            DefaultExt = ".dtt"
        };

        if (dialog.ShowDialog() != true)
        {
            return;
        }

        try
        {
            await _model.SaveGameAsync(dialog.FileName);
            MessageBox.Show("The game was saved successfully.", Caption, MessageBoxButton.OK, MessageBoxImage.Information);
        }
        catch (Exception ex) when (ex is GameDataException or InvalidOperationException)
        {
            MessageBox.Show("Saving failed: " + ex.Message, Caption, MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private async void OnLoadGameRequested(object? sender, EventArgs e)
    {
        OpenFileDialog dialog = new()
        {
            Title = "Load game",
            Filter = FileFilter,
            DefaultExt = ".dtt"
        };

        if (dialog.ShowDialog() != true)
        {
            return;
        }

        try
        {
            await _model.LoadGameAsync(dialog.FileName);
        }
        catch (GameDataException ex)
        {
            MessageBox.Show("Loading failed: " + ex.Message, Caption, MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void OnGameFinished(object? sender, MessageEventArgs e)
    {
        MessageBox.Show(e.Message, Caption, MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private void OnExitRequested(object? sender, EventArgs e)
    {
        Shutdown();
    }
}
EOF

cat > "$ROOT/TicTacToe.App/View/MainWindow.xaml.cs" <<'EOF'
using System.Windows;

namespace TicTacToe.View;

public partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
    }
}
EOF

cat > "$ROOT/TicTacToe.App/View/MainWindow.xaml" <<'EOF'
<Window x:Class="TicTacToe.View.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Drop-Out Tic-Tac-Toe"
        Width="780"
        Height="860"
        MinWidth="560"
        MinHeight="520"
        WindowStartupLocation="CenterScreen">
    <DockPanel>
        <Menu DockPanel.Dock="Top">
            <MenuItem Header="_Game">
                <MenuItem Header="_New game">
                    <MenuItem Header="_10 x 10" CommandParameter="10" Command="{Binding NewGameCommand}" />
                    <MenuItem Header="_20 x 20" CommandParameter="20" Command="{Binding NewGameCommand}" />
                    <MenuItem Header="_30 x 30" CommandParameter="30" Command="{Binding NewGameCommand}" />
                </MenuItem>
                <MenuItem Header="{Binding PauseMenuText}" Command="{Binding PauseCommand}" />
                <Separator />
                <MenuItem Header="_Save game..." Command="{Binding SaveGameCommand}" />
                <MenuItem Header="_Load game..." Command="{Binding LoadGameCommand}" />
                <Separator />
                <MenuItem Header="E_xit" Command="{Binding ExitCommand}" />
            </MenuItem>
        </Menu>

        <StatusBar DockPanel.Dock="Bottom">
            <StatusBarItem>
                <TextBlock Text="{Binding StatusText}" FontWeight="Bold" />
            </StatusBarItem>
            <Separator />
            <StatusBarItem>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="Player X thinking time: " />
                    <TextBlock Text="{Binding FirstPlayerTime}" />
                </StackPanel>
            </StatusBarItem>
            <Separator />
            <StatusBarItem>
                <StackPanel Orientation="Horizontal">
                    <TextBlock Text="Player O thinking time: " />
                    <TextBlock Text="{Binding SecondPlayerTime}" />
                </StackPanel>
            </StatusBarItem>
        </StatusBar>

        <Viewbox Margin="8" Stretch="Uniform">
            <ItemsControl ItemsSource="{Binding Cells}">
                <ItemsControl.ItemsPanel>
                    <ItemsPanelTemplate>
                        <UniformGrid Rows="{Binding Size}" Columns="{Binding Size}" />
                    </ItemsPanelTemplate>
                </ItemsControl.ItemsPanel>
                <ItemsControl.ItemTemplate>
                    <DataTemplate>
                        <Button Width="34"
                                Height="34"
                                Margin="1"
                                FontSize="18"
                                FontWeight="Bold"
                                Content="{Binding Text}"
                                CommandParameter="{Binding}"
                                Command="{Binding DataContext.StepCommand, RelativeSource={RelativeSource AncestorType=ItemsControl}}">
                            <Button.Style>
                                <Style TargetType="Button">
                                    <Setter Property="Background" Value="WhiteSmoke" />
                                    <Setter Property="Foreground" Value="Black" />
                                    <Setter Property="Template">
                                        <Setter.Value>
                                            <ControlTemplate TargetType="Button">
                                                <Border x:Name="Border"
                                                        Background="{TemplateBinding Background}"
                                                        BorderBrush="Gray"
                                                        BorderThickness="1">
                                                    <ContentPresenter HorizontalAlignment="Center"
                                                                      VerticalAlignment="Center" />
                                                </Border>
                                                <ControlTemplate.Triggers>
                                                    <MultiTrigger>
                                                        <MultiTrigger.Conditions>
                                                            <Condition Property="IsMouseOver" Value="True" />
                                                            <Condition Property="IsEnabled" Value="True" />
                                                        </MultiTrigger.Conditions>
                                                        <Setter TargetName="Border" Property="Background" Value="LightSkyBlue" />
                                                    </MultiTrigger>
                                                </ControlTemplate.Triggers>
                                            </ControlTemplate>
                                        </Setter.Value>
                                    </Setter>
                                    <Style.Triggers>
                                        <DataTrigger Binding="{Binding Text}" Value="X">
                                            <Setter Property="Foreground" Value="Crimson" />
                                        </DataTrigger>
                                        <DataTrigger Binding="{Binding Text}" Value="O">
                                            <Setter Property="Foreground" Value="RoyalBlue" />
                                        </DataTrigger>
                                        <DataTrigger Binding="{Binding IsWinning}" Value="True">
                                            <Setter Property="Background" Value="Gold" />
                                        </DataTrigger>
                                    </Style.Triggers>
                                </Style>
                            </Button.Style>
                        </Button>
                    </DataTemplate>
                </ItemsControl.ItemTemplate>
            </ItemsControl>
        </Viewbox>
    </DockPanel>
</Window>
EOF

cat > "$ROOT/TicTacToe.App/ViewModel/ViewModelBase.cs" <<'EOF'
using System.ComponentModel;
using System.Runtime.CompilerServices;

namespace TicTacToe.ViewModel;

public abstract class ViewModelBase : INotifyPropertyChanged
{
    public event PropertyChangedEventHandler? PropertyChanged;

    protected void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }
}
EOF

cat > "$ROOT/TicTacToe.App/ViewModel/DelegateCommand.cs" <<'EOF'
using System.Windows.Input;

namespace TicTacToe.ViewModel;

public class DelegateCommand : ICommand
{
    private readonly Action<object?> _execute;
    private readonly Func<object?, bool>? _canExecute;

    public DelegateCommand(Action<object?> execute, Func<object?, bool>? canExecute = null)
    {
        _execute = execute;
        _canExecute = canExecute;
    }

    public DelegateCommand(Action execute, Func<bool>? canExecute = null)
        : this(_ => execute(), canExecute == null ? null : _ => canExecute())
    {
    }

    public event EventHandler? CanExecuteChanged;

    public bool CanExecute(object? parameter)
    {
        return _canExecute?.Invoke(parameter) ?? true;
    }

    public void Execute(object? parameter)
    {
        _execute(parameter);
    }

    public void RaiseCanExecuteChanged()
    {
        CanExecuteChanged?.Invoke(this, EventArgs.Empty);
    }
}
EOF

cat > "$ROOT/TicTacToe.App/ViewModel/MessageEventArgs.cs" <<'EOF'
namespace TicTacToe.ViewModel;

public class MessageEventArgs : EventArgs
{
    public MessageEventArgs(string message)
    {
        Message = message;
    }

    public string Message { get; }
}
EOF

cat > "$ROOT/TicTacToe.App/ViewModel/CellViewModel.cs" <<'EOF'
namespace TicTacToe.ViewModel;

public class CellViewModel : ViewModelBase
{
    private string _text = string.Empty;
    private bool _isWinning;

    public CellViewModel(int row, int column)
    {
        Row = row;
        Column = column;
    }

    public int Row { get; }

    public int Column { get; }

    public string Text
    {
        get => _text;
        set
        {
            if (_text != value)
            {
                _text = value;
                OnPropertyChanged();
            }
        }
    }

    public bool IsWinning
    {
        get => _isWinning;
        set
        {
            if (_isWinning != value)
            {
                _isWinning = value;
                OnPropertyChanged();
            }
        }
    }
}
EOF

cat > "$ROOT/TicTacToe.App/ViewModel/MainViewModel.cs" <<'EOF'
using TicTacToe.Model;

namespace TicTacToe.ViewModel;

public class MainViewModel : ViewModelBase
{
    private readonly GameModel _model;
    private CellViewModel[,] _cellMap = new CellViewModel[0, 0];
    private IReadOnlyList<CellViewModel> _cells = Array.Empty<CellViewModel>();

    public MainViewModel(GameModel model)
    {
        _model = model;
        _model.GameStarted += OnGameStarted;
        _model.CellChanged += OnCellChanged;
        _model.PlayerChanged += OnPlayerChanged;
        _model.TimeChanged += OnTimeChanged;
        _model.PauseChanged += OnPauseChanged;
        _model.GameOver += OnGameOver;

        NewGameCommand = new DelegateCommand(parameter => _model.NewGame(Convert.ToInt32(parameter)));
        PauseCommand = new DelegateCommand(TogglePause, () => !_model.IsGameOver);
        SaveGameCommand = new DelegateCommand(RequestSave, () => !_model.IsGameOver);
        LoadGameCommand = new DelegateCommand(RequestLoad);
        ExitCommand = new DelegateCommand(() => ExitRequested?.Invoke(this, EventArgs.Empty));
        StepCommand = new DelegateCommand(ExecuteStep, CanStep);

        BuildBoard();
    }

    public event EventHandler? SaveGameRequested;

    public event EventHandler? LoadGameRequested;

    public event EventHandler? ExitRequested;

    public event EventHandler<MessageEventArgs>? GameFinished;

    public DelegateCommand NewGameCommand { get; }

    public DelegateCommand PauseCommand { get; }

    public DelegateCommand SaveGameCommand { get; }

    public DelegateCommand LoadGameCommand { get; }

    public DelegateCommand ExitCommand { get; }

    public DelegateCommand StepCommand { get; }

    public IReadOnlyList<CellViewModel> Cells => _cells;

    public int Size => _model.Size;

    public string PauseMenuText => _model.IsPaused ? "_Resume" : "_Pause";

    public string StatusText
    {
        get
        {
            switch (_model.Status)
            {
                case GameStatus.FirstPlayerWon:
                    return "Player X wins!";
                case GameStatus.SecondPlayerWon:
                    return "Player O wins!";
                case GameStatus.Draw:
                    return "The game is a draw.";
                default:
                    string next = "Next: Player " + Symbol(_model.CurrentPlayer);
                    return _model.IsPaused ? "Game paused. " + next : next;
            }
        }
    }

    public string FirstPlayerTime => FormatTime(_model.GetThinkingTime(Player.First));

    public string SecondPlayerTime => FormatTime(_model.GetThinkingTime(Player.Second));

    private void TogglePause()
    {
        if (_model.IsPaused)
        {
            _model.Resume();
        }
        else
        {
            _model.Pause();
        }
    }

    private void RequestSave()
    {
        _model.Pause();
        SaveGameRequested?.Invoke(this, EventArgs.Empty);
    }

    private void RequestLoad()
    {
        _model.Pause();
        LoadGameRequested?.Invoke(this, EventArgs.Empty);
    }

    private void ExecuteStep(object? parameter)
    {
        if (parameter is CellViewModel cell)
        {
            _model.Step(cell.Row, cell.Column);
        }
    }

    private bool CanStep(object? parameter)
    {
        return parameter is CellViewModel cell
               && cell.Text.Length == 0
               && !_model.IsPaused
               && !_model.IsGameOver;
    }

    private void BuildBoard()
    {
        int size = _model.Size;
        CellViewModel[,] map = new CellViewModel[size, size];
        List<CellViewModel> list = new(size * size);

        for (int row = 0; row < size; row++)
        {
            for (int column = 0; column < size; column++)
            {
                CellViewModel cell = new(row, column)
                {
                    Text = Symbol(_model.GetCell(row, column))
                };
                map[row, column] = cell;
                list.Add(cell);
            }
        }

        _cellMap = map;
        _cells = list;
    }

    private void RefreshState()
    {
        OnPropertyChanged(nameof(StatusText));
        OnPropertyChanged(nameof(FirstPlayerTime));
        OnPropertyChanged(nameof(SecondPlayerTime));
        OnPropertyChanged(nameof(PauseMenuText));
        RefreshCommands();
    }

    private void RefreshCommands()
    {
        StepCommand.RaiseCanExecuteChanged();
        PauseCommand.RaiseCanExecuteChanged();
        SaveGameCommand.RaiseCanExecuteChanged();
    }

    private void OnGameStarted(object? sender, EventArgs e)
    {
        BuildBoard();
        OnPropertyChanged(nameof(Size));
        OnPropertyChanged(nameof(Cells));
        RefreshState();
    }

    private void OnCellChanged(object? sender, CellChangedEventArgs e)
    {
        _cellMap[e.Row, e.Column].Text = Symbol(e.Player);
    }

    private void OnPlayerChanged(object? sender, EventArgs e)
    {
        OnPropertyChanged(nameof(StatusText));
    }

    private void OnTimeChanged(object? sender, EventArgs e)
    {
        OnPropertyChanged(nameof(FirstPlayerTime));
        OnPropertyChanged(nameof(SecondPlayerTime));
    }

    private void OnPauseChanged(object? sender, EventArgs e)
    {
        OnPropertyChanged(nameof(StatusText));
        OnPropertyChanged(nameof(PauseMenuText));
        RefreshCommands();
    }

    private void OnGameOver(object? sender, GameOverEventArgs e)
    {
        foreach ((int row, int column) in e.WinningCells)
        {
            _cellMap[row, column].IsWinning = true;
        }

        OnPropertyChanged(nameof(StatusText));
        RefreshCommands();
        GameFinished?.Invoke(this, new MessageEventArgs(StatusText));
    }

    private static string Symbol(Player player)
    {
        switch (player)
        {
            case Player.First:
                return "X";
            case Player.Second:
                return "O";
            default:
                return string.Empty;
        }
    }

    private static string FormatTime(TimeSpan time)
    {
        return $"{(int)time.TotalHours:00}:{time.Minutes:00}:{time.Seconds:00}";
    }
}
EOF

cat > "$ROOT/TicTacToe.Tests/TicTacToe.Tests.csproj" <<EOF
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <TargetFramework>$TFM</TargetFramework>
    <IsPackable>false</IsPackable>
    <IsTestProject>true</IsTestProject>
    <RootNamespace>TicTacToe.Tests</RootNamespace>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.11.1" />
    <PackageReference Include="MSTest.TestAdapter" Version="3.6.1" />
    <PackageReference Include="MSTest.TestFramework" Version="3.6.1" />
  </ItemGroup>

  <ItemGroup>
    <Using Include="Microsoft.VisualStudio.TestTools.UnitTesting" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="../TicTacToe.Model/TicTacToe.Model.csproj" />
    <ProjectReference Include="../TicTacToe.Persistence/TicTacToe.Persistence.csproj" />
  </ItemGroup>

</Project>
EOF

cat > "$ROOT/TicTacToe.Tests/FakeGameDataAccess.cs" <<'EOF'
using TicTacToe.Persistence;

namespace TicTacToe.Tests;

internal class FakeGameDataAccess : IGameDataAccess
{
    public GameData? Stored { get; set; }

    public string? LastPath { get; private set; }

    public bool ThrowOnLoad { get; set; }

    public bool ThrowOnSave { get; set; }

    public Task<GameData> LoadAsync(string path)
    {
        LastPath = path;

        if (ThrowOnLoad || Stored == null)
        {
            throw new GameDataException("Simulated load failure.");
        }

        return Task.FromResult(Stored);
    }

    public Task SaveAsync(string path, GameData data)
    {
        LastPath = path;

        if (ThrowOnSave)
        {
            throw new GameDataException("Simulated save failure.");
        }

        Stored = data;
        return Task.CompletedTask;
    }
}
EOF

cat > "$ROOT/TicTacToe.Tests/GameModelTests.cs" <<'EOF'
using TicTacToe.Model;
using TicTacToe.Persistence;

namespace TicTacToe.Tests;

[TestClass]
public class GameModelTests
{
    private FakeGameDataAccess _dataAccess = null!;
    private GameModel _model = null!;

    [TestInitialize]
    public void Initialize()
    {
        _dataAccess = new FakeGameDataAccess();
        _model = new GameModel(_dataAccess, false);
        _model.NewGame(10);
    }

    [TestCleanup]
    public void Cleanup()
    {
        _model.Dispose();
    }

    private void PlayColumns(params int[] columns)
    {
        foreach (int column in columns)
        {
            Assert.IsTrue(_model.Step(0, column));
        }
    }

    private static int[,] EmptyBoard(int size)
    {
        return new int[size, size];
    }

    [TestMethod]
    public void NewGame_CreatesEmptyBoard()
    {
        _model.NewGame(20);

        Assert.AreEqual(20, _model.Size);
        Assert.AreEqual(Player.First, _model.CurrentPlayer);
        Assert.AreEqual(GameStatus.InProgress, _model.Status);
        Assert.IsFalse(_model.IsPaused);
        Assert.AreEqual(TimeSpan.Zero, _model.GetThinkingTime(Player.First));
        Assert.AreEqual(TimeSpan.Zero, _model.GetThinkingTime(Player.Second));

        for (int row = 0; row < 20; row++)
        {
            for (int column = 0; column < 20; column++)
            {
                Assert.AreEqual(Player.None, _model.GetCell(row, column));
            }
        }
    }

    [DataTestMethod]
    [DataRow(0)]
    [DataRow(3)]
    [DataRow(-5)]
    public void NewGame_TooSmallSize_Throws(int size)
    {
        Assert.ThrowsException<ArgumentOutOfRangeException>(() => _model.NewGame(size));
    }

    [TestMethod]
    public void NewGame_RaisesGameStartedEvent()
    {
        int count = 0;
        _model.GameStarted += (_, _) => count++;

        _model.NewGame(30);

        Assert.AreEqual(1, count);
    }

    [TestMethod]
    public void NewGame_ResetsFinishedGame()
    {
        PlayColumns(0, 0, 1, 1, 2, 2, 3);
        Assert.IsTrue(_model.IsGameOver);

        _model.NewGame(10);

        Assert.AreEqual(GameStatus.InProgress, _model.Status);
        Assert.AreEqual(0, _model.WinningCells.Count);
        Assert.IsTrue(_model.Step(0, 0));
    }

    [TestMethod]
    public void Step_DropsSignToBottomOfColumn()
    {
        Assert.IsTrue(_model.Step(0, 3));

        Assert.AreEqual(Player.First, _model.GetCell(9, 3));
        Assert.AreEqual(Player.None, _model.GetCell(0, 3));
    }

    [TestMethod]
    public void Step_ClickingHigherCellStillDropsToBottom()
    {
        Assert.IsTrue(_model.Step(5, 2));

        Assert.AreEqual(Player.First, _model.GetCell(9, 2));
        Assert.AreEqual(Player.None, _model.GetCell(5, 2));
    }

    [TestMethod]
    public void Step_StacksSignsInColumn()
    {
        PlayColumns(3, 3);

        Assert.AreEqual(Player.First, _model.GetCell(9, 3));
        Assert.AreEqual(Player.Second, _model.GetCell(8, 3));
    }

    [TestMethod]
    public void Step_SwitchesCurrentPlayer()
    {
        _model.Step(0, 0);
        Assert.AreEqual(Player.Second, _model.CurrentPlayer);

        _model.Step(0, 1);
        Assert.AreEqual(Player.First, _model.CurrentPlayer);
    }

    [TestMethod]
    public void Step_OnOccupiedCell_ReturnsFalse()
    {
        _model.Step(0, 3);

        Assert.IsFalse(_model.Step(9, 3));
        Assert.AreEqual(Player.Second, _model.CurrentPlayer);
    }

    [TestMethod]
    public void Step_OutOfRange_ReturnsFalse()
    {
        Assert.IsFalse(_model.Step(-1, 0));
        Assert.IsFalse(_model.Step(0, 10));
        Assert.IsFalse(_model.Step(10, 0));
        Assert.AreEqual(Player.First, _model.CurrentPlayer);
    }

    [TestMethod]
    public void Step_InFullColumn_ReturnsFalse()
    {
        for (int i = 0; i < 10; i++)
        {
            Assert.IsTrue(_model.Step(0, 0));
        }

        Assert.IsFalse(_model.Step(0, 0));
        Assert.AreEqual(GameStatus.InProgress, _model.Status);
    }

    [TestMethod]
    public void Step_RaisesCellChangedAndPlayerChangedEvents()
    {
        CellChangedEventArgs? cellArgs = null;
        int playerChangedCount = 0;
        _model.CellChanged += (_, e) => cellArgs = e;
        _model.PlayerChanged += (_, _) => playerChangedCount++;

        _model.Step(0, 4);

        Assert.IsNotNull(cellArgs);
        Assert.AreEqual(9, cellArgs.Row);
        Assert.AreEqual(4, cellArgs.Column);
        Assert.AreEqual(Player.First, cellArgs.Player);
        Assert.AreEqual(1, playerChangedCount);
    }

    [TestMethod]
    public void Step_WhenPaused_ReturnsFalseUntilResumed()
    {
        _model.Pause();

        Assert.IsTrue(_model.IsPaused);
        Assert.IsFalse(_model.Step(0, 0));
        Assert.AreEqual(Player.None, _model.GetCell(9, 0));

        _model.Resume();

        Assert.IsFalse(_model.IsPaused);
        Assert.IsTrue(_model.Step(0, 0));
    }

    [TestMethod]
    public void HorizontalFour_FirstPlayerWins()
    {
        GameOverEventArgs? args = null;
        int count = 0;
        _model.GameOver += (_, e) =>
        {
            args = e;
            count++;
        };

        PlayColumns(0, 0, 1, 1, 2, 2, 3);

        Assert.AreEqual(GameStatus.FirstPlayerWon, _model.Status);
        Assert.AreEqual(1, count);
        Assert.IsNotNull(args);
        Assert.AreEqual(GameStatus.FirstPlayerWon, args.Status);
        CollectionAssert.AreEquivalent(
            new List<(int, int)> { (9, 0), (9, 1), (9, 2), (9, 3) },
            args.WinningCells.ToList());
    }

    [TestMethod]
    public void HorizontalFour_SecondPlayerWins()
    {
        PlayColumns(0, 1, 0, 2, 5, 3, 5, 4);

        Assert.AreEqual(GameStatus.SecondPlayerWon, _model.Status);
        CollectionAssert.AreEquivalent(
            new List<(int, int)> { (9, 1), (9, 2), (9, 3), (9, 4) },
            _model.WinningCells.ToList());
    }

    [TestMethod]
    public void DiagonalFour_FirstPlayerWins()
    {
        PlayColumns(0, 1, 1, 2, 3, 2, 2, 3, 3, 5, 3);

        Assert.AreEqual(GameStatus.FirstPlayerWon, _model.Status);
        CollectionAssert.AreEquivalent(
            new List<(int, int)> { (9, 0), (8, 1), (7, 2), (6, 3) },
            _model.WinningCells.ToList());
    }

    [TestMethod]
    public void AntiDiagonalFour_FirstPlayerWins()
    {
        PlayColumns(6, 5, 5, 4, 3, 4, 4, 3, 3, 1, 3);

        Assert.AreEqual(GameStatus.FirstPlayerWon, _model.Status);
        CollectionAssert.AreEquivalent(
            new List<(int, int)> { (9, 6), (8, 5), (7, 4), (6, 3) },
            _model.WinningCells.ToList());
    }

    [TestMethod]
    public void FourInColumn_IsNotAWin()
    {
        PlayColumns(0, 1, 0, 1, 0, 1, 0);

        Assert.AreEqual(GameStatus.InProgress, _model.Status);
    }

    [TestMethod]
    public void LineLongerThanFour_MarksExactlyFourCells()
    {
        PlayColumns(0, 0, 1, 1, 3, 3, 4, 4, 2);

        Assert.AreEqual(GameStatus.FirstPlayerWon, _model.Status);
        Assert.AreEqual(4, _model.WinningCells.Count);
        Assert.IsTrue(_model.WinningCells.Contains((9, 2)));
    }

    [TestMethod]
    public void Step_AfterGameOver_ReturnsFalse()
    {
        PlayColumns(0, 0, 1, 1, 2, 2, 3);

        Assert.IsFalse(_model.Step(0, 5));
        Assert.AreEqual(Player.None, _model.GetCell(9, 5));
    }

    [TestMethod]
    public void FullBoardWithoutWinner_IsDraw()
    {
        _model.NewGame(4);
        GameOverEventArgs? args = null;
        _model.GameOver += (_, e) => args = e;

        PlayColumns(0, 1, 0, 1, 0, 1, 0, 1, 2, 3, 2, 3, 2, 3, 2, 3);

        Assert.AreEqual(GameStatus.Draw, _model.Status);
        Assert.IsNotNull(args);
        Assert.AreEqual(GameStatus.Draw, args.Status);
        Assert.AreEqual(0, args.WinningCells.Count);
    }

    [TestMethod]
    public void Tick_IncreasesCurrentPlayerTime()
    {
        _model.Tick();

        Assert.AreEqual(TimeSpan.FromSeconds(1), _model.GetThinkingTime(Player.First));
        Assert.AreEqual(TimeSpan.Zero, _model.GetThinkingTime(Player.Second));
    }

    [TestMethod]
    public void Tick_CountsTimeSeparatelyPerPlayer()
    {
        _model.Tick();
        _model.Step(0, 0);
        _model.Tick();
        _model.Tick();

        Assert.AreEqual(TimeSpan.FromSeconds(1), _model.GetThinkingTime(Player.First));
        Assert.AreEqual(TimeSpan.FromSeconds(2), _model.GetThinkingTime(Player.Second));
    }

    [TestMethod]
    public void Tick_WhenPaused_DoesNotIncreaseTime()
    {
        _model.Pause();
        _model.Tick();

        Assert.AreEqual(TimeSpan.Zero, _model.GetThinkingTime(Player.First));
    }

    [TestMethod]
    public void Tick_AfterGameOver_DoesNotIncreaseTime()
    {
        PlayColumns(0, 0, 1, 1, 2, 2, 3);
        _model.Tick();

        Assert.AreEqual(TimeSpan.Zero, _model.GetThinkingTime(Player.First));
        Assert.AreEqual(TimeSpan.Zero, _model.GetThinkingTime(Player.Second));
    }

    [TestMethod]
    public void Tick_RaisesTimeChangedEvent()
    {
        int count = 0;
        _model.TimeChanged += (_, _) => count++;

        _model.Tick();

        Assert.AreEqual(1, count);
    }

    [TestMethod]
    public void PauseAndResume_RaisePauseChangedEvent()
    {
        int count = 0;
        _model.PauseChanged += (_, _) => count++;

        _model.Pause();
        _model.Pause();
        _model.Resume();
        _model.Resume();

        Assert.AreEqual(2, count);
    }

    [TestMethod]
    public void Pause_AfterGameOver_IsIgnored()
    {
        PlayColumns(0, 0, 1, 1, 2, 2, 3);

        _model.Pause();

        Assert.IsFalse(_model.IsPaused);
    }

    [TestMethod]
    public async Task SaveGame_PassesCurrentStateToPersistence()
    {
        PlayColumns(0, 1);
        _model.Tick();
        _model.Tick();
        _model.Tick();

        await _model.SaveGameAsync("slot.dtt");

        Assert.AreEqual("slot.dtt", _dataAccess.LastPath);
        GameData? stored = _dataAccess.Stored;
        Assert.IsNotNull(stored);
        Assert.AreEqual(10, stored.Size);
        Assert.AreEqual((int)Player.First, stored.CurrentPlayer);
        Assert.AreEqual(3, stored.FirstPlayerSeconds);
        Assert.AreEqual(0, stored.SecondPlayerSeconds);
        Assert.AreEqual((int)Player.First, stored.Board[9, 0]);
        Assert.AreEqual((int)Player.Second, stored.Board[9, 1]);
        Assert.AreEqual(0, stored.Board[0, 0]);
    }

    [TestMethod]
    public async Task SaveGame_AfterGameOver_Throws()
    {
        PlayColumns(0, 0, 1, 1, 2, 2, 3);

        await Assert.ThrowsExceptionAsync<InvalidOperationException>(() => _model.SaveGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task SaveGame_PersistenceFailure_IsPropagated()
    {
        _dataAccess.ThrowOnSave = true;

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.SaveGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task LoadGame_ValidData_RestoresStateAndPauses()
    {
        int[,] board = EmptyBoard(4);
        board[3, 0] = 1;
        board[3, 1] = 2;
        board[2, 0] = 1;
        _dataAccess.Stored = new GameData(4, board, 2, 30, 12);
        int startedCount = 0;
        _model.GameStarted += (_, _) => startedCount++;

        await _model.LoadGameAsync("slot.dtt");

        Assert.AreEqual(1, startedCount);
        Assert.AreEqual(4, _model.Size);
        Assert.AreEqual(Player.Second, _model.CurrentPlayer);
        Assert.AreEqual(GameStatus.InProgress, _model.Status);
        Assert.IsTrue(_model.IsPaused);
        Assert.AreEqual(TimeSpan.FromSeconds(30), _model.GetThinkingTime(Player.First));
        Assert.AreEqual(TimeSpan.FromSeconds(12), _model.GetThinkingTime(Player.Second));
        Assert.AreEqual(Player.First, _model.GetCell(3, 0));
        Assert.AreEqual(Player.Second, _model.GetCell(3, 1));
        Assert.AreEqual(Player.First, _model.GetCell(2, 0));
        Assert.AreEqual(Player.None, _model.GetCell(2, 1));
    }

    [TestMethod]
    public async Task LoadGame_FloatingSign_Throws()
    {
        int[,] board = EmptyBoard(4);
        board[0, 0] = 1;
        _dataAccess.Stored = new GameData(4, board, 2, 0, 0);

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.LoadGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task LoadGame_WrongPlayerOnTurn_Throws()
    {
        int[,] board = EmptyBoard(4);
        board[3, 0] = 1;
        _dataAccess.Stored = new GameData(4, board, 1, 0, 0);

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.LoadGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task LoadGame_UnbalancedSigns_Throws()
    {
        int[,] board = EmptyBoard(4);
        board[3, 0] = 1;
        board[3, 1] = 1;
        _dataAccess.Stored = new GameData(4, board, 1, 0, 0);

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.LoadGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task LoadGame_AlreadyFinishedGame_Throws()
    {
        int[,] board = EmptyBoard(4);
        for (int column = 0; column < 4; column++)
        {
            board[3, column] = 1;
        }

        for (int column = 0; column < 3; column++)
        {
            board[2, column] = 2;
        }

        _dataAccess.Stored = new GameData(4, board, 2, 0, 0);

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.LoadGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task LoadGame_InvalidPlayer_Throws()
    {
        _dataAccess.Stored = new GameData(4, EmptyBoard(4), 0, 0, 0);

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.LoadGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task LoadGame_Failure_KeepsCurrentGame()
    {
        _model.Step(0, 0);
        int[,] board = EmptyBoard(4);
        board[0, 0] = 1;
        _dataAccess.Stored = new GameData(4, board, 2, 0, 0);

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.LoadGameAsync("slot.dtt"));

        Assert.AreEqual(10, _model.Size);
        Assert.AreEqual(Player.First, _model.GetCell(9, 0));
        Assert.AreEqual(Player.Second, _model.CurrentPlayer);
        Assert.IsFalse(_model.IsPaused);
    }

    [TestMethod]
    public async Task LoadGame_PersistenceFailure_IsPropagated()
    {
        _dataAccess.ThrowOnLoad = true;

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _model.LoadGameAsync("slot.dtt"));
    }

    [TestMethod]
    public async Task SaveAndLoad_RoundTripRestoresGame()
    {
        PlayColumns(0, 1, 2);
        _model.Tick();
        _model.Tick();
        await _model.SaveGameAsync("slot.dtt");

        using GameModel other = new(_dataAccess, false);
        await other.LoadGameAsync("slot.dtt");

        Assert.AreEqual(_model.Size, other.Size);
        Assert.AreEqual(_model.CurrentPlayer, other.CurrentPlayer);
        Assert.AreEqual(_model.GetThinkingTime(Player.First), other.GetThinkingTime(Player.First));
        Assert.AreEqual(_model.GetThinkingTime(Player.Second), other.GetThinkingTime(Player.Second));
        for (int row = 0; row < _model.Size; row++)
        {
            for (int column = 0; column < _model.Size; column++)
            {
                Assert.AreEqual(_model.GetCell(row, column), other.GetCell(row, column));
            }
        }

        other.Resume();
        Assert.IsTrue(other.Step(0, 3));
    }
}
EOF

cat > "$ROOT/TicTacToe.Tests/FileGameDataAccessTests.cs" <<'EOF'
using TicTacToe.Persistence;

namespace TicTacToe.Tests;

[TestClass]
public class FileGameDataAccessTests
{
    private string _path = null!;
    private FileGameDataAccess _access = null!;

    [TestInitialize]
    public void Initialize()
    {
        _path = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString("N") + ".dtt");
        _access = new FileGameDataAccess();
    }

    [TestCleanup]
    public void Cleanup()
    {
        if (File.Exists(_path))
        {
            File.Delete(_path);
        }
    }

    [TestMethod]
    public async Task SaveAndLoad_RoundTrip()
    {
        int[,] board = new int[4, 4];
        board[3, 0] = 1;
        board[3, 1] = 2;
        board[2, 0] = 1;
        GameData original = new(4, board, 2, 65, 7);

        await _access.SaveAsync(_path, original);
        GameData loaded = await _access.LoadAsync(_path);

        Assert.AreEqual(4, loaded.Size);
        Assert.AreEqual(2, loaded.CurrentPlayer);
        Assert.AreEqual(65, loaded.FirstPlayerSeconds);
        Assert.AreEqual(7, loaded.SecondPlayerSeconds);
        for (int row = 0; row < 4; row++)
        {
            for (int column = 0; column < 4; column++)
            {
                Assert.AreEqual(board[row, column], loaded.Board[row, column]);
            }
        }
    }

    [TestMethod]
    public async Task LoadAsync_MissingFile_Throws()
    {
        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }

    [TestMethod]
    public async Task LoadAsync_InvalidCharacter_Throws()
    {
        await File.WriteAllTextAsync(_path, "4\n1\n0\n0\n....\n....\n....\n..Z.\n");

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }

    [TestMethod]
    public async Task LoadAsync_WrongRowCount_Throws()
    {
        await File.WriteAllTextAsync(_path, "4\n1\n0\n0\n....\n....\n");

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }

    [TestMethod]
    public async Task LoadAsync_NonNumericHeader_Throws()
    {
        await File.WriteAllTextAsync(_path, "four\n1\n0\n0\n....\n....\n....\n....\n");

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }
}
EOF

cat > "$ROOT/docs/use-cases.puml" <<'EOF'
@startuml
left to right direction
skinparam shadowing false

actor "Játékos" as Player

rectangle "Potyogós amőba" {
  usecase "Új játék indítása" as UC1
  usecase "Táblaméret kiválasztása" as UC2
  usecase "Jel elhelyezése" as UC3
  usecase "Játék szüneteltetése és folytatása" as UC4
  usecase "Játék mentése" as UC5
  usecase "Játék betöltése" as UC6
  usecase "Gondolkodási idők megtekintése" as UC7
  usecase "Eredmény megtekintése" as UC8
  usecase "Kilépés" as UC9
}

Player --> UC1
Player --> UC3
Player --> UC4
Player --> UC5
Player --> UC6
Player --> UC7
Player --> UC9

UC1 .> UC2 : <<include>>
UC8 .> UC3 : <<extend>>
@enduml
EOF

cat > "$ROOT/docs/class-diagram.puml" <<'EOF'
@startuml
skinparam classAttributeIconSize 0
skinparam shadowing false
skinparam packageStyle rectangle
hide empty members

package "TicTacToe.Persistence" {
  interface IGameDataAccess {
    +LoadAsync(path : string) : Task<GameData>
    +SaveAsync(path : string, data : GameData) : Task
  }

  class FileGameDataAccess

  class GameData {
    +Size : int
    +Board : int[,]
    +CurrentPlayer : int
    +FirstPlayerSeconds : int
    +SecondPlayerSeconds : int
  }

  class GameDataException
}

package "TicTacToe.Model" {
  enum Player {
    None
    First
    Second
  }

  enum GameStatus {
    InProgress
    FirstPlayerWon
    SecondPlayerWon
    Draw
  }

  class GameModel {
    +Size : int
    +CurrentPlayer : Player
    +Status : GameStatus
    +IsPaused : bool
    +IsGameOver : bool
    +WinningCells : IReadOnlyList<(int, int)>
    +GetCell(row : int, column : int) : Player
    +GetThinkingTime(player : Player) : TimeSpan
    +NewGame(size : int)
    +Step(row : int, column : int) : bool
    +Pause()
    +Resume()
    +Tick()
    +SaveGameAsync(path : string) : Task
    +LoadGameAsync(path : string) : Task
    +GameStarted : event
    +CellChanged : event
    +PlayerChanged : event
    +TimeChanged : event
    +PauseChanged : event
    +GameOver : event
  }

  class CellChangedEventArgs {
    +Row : int
    +Column : int
    +Player : Player
  }

  class GameOverEventArgs {
    +Status : GameStatus
    +WinningCells : IReadOnlyList<(int, int)>
  }
}

package "TicTacToe.ViewModel" {
  abstract class ViewModelBase {
    #OnPropertyChanged(propertyName : string)
  }

  class DelegateCommand {
    +CanExecute(parameter : object) : bool
    +Execute(parameter : object)
    +RaiseCanExecuteChanged()
  }

  class CellViewModel {
    +Row : int
    +Column : int
    +Text : string
    +IsWinning : bool
  }

  class MainViewModel {
    +Cells : IReadOnlyList<CellViewModel>
    +Size : int
    +StatusText : string
    +FirstPlayerTime : string
    +SecondPlayerTime : string
    +PauseMenuText : string
    +NewGameCommand : DelegateCommand
    +PauseCommand : DelegateCommand
    +SaveGameCommand : DelegateCommand
    +LoadGameCommand : DelegateCommand
    +ExitCommand : DelegateCommand
    +StepCommand : DelegateCommand
    +SaveGameRequested : event
    +LoadGameRequested : event
    +ExitRequested : event
    +GameFinished : event
  }

  class MessageEventArgs {
    +Message : string
  }
}

package "TicTacToe (View)" {
  class App
  class MainWindow
}

interface INotifyPropertyChanged <<System.ComponentModel>>
interface ICommand <<System.Windows.Input>>
interface IDisposable <<System>>

FileGameDataAccess ..|> IGameDataAccess
FileGameDataAccess ..> GameData
FileGameDataAccess ..> GameDataException
IGameDataAccess ..> GameData

GameModel ..|> IDisposable
GameModel --> IGameDataAccess
GameModel ..> GameData
GameModel ..> GameDataException
GameModel --> Player
GameModel --> GameStatus
GameModel ..> CellChangedEventArgs
GameModel ..> GameOverEventArgs
CellChangedEventArgs --> Player
GameOverEventArgs --> GameStatus

ViewModelBase ..|> INotifyPropertyChanged
DelegateCommand ..|> ICommand
ViewModelBase <|-- MainViewModel
ViewModelBase <|-- CellViewModel
MainViewModel --> GameModel
MainViewModel *-- "n x n" CellViewModel
MainViewModel *-- "6" DelegateCommand
MainViewModel ..> MessageEventArgs

App --> GameModel
App --> MainViewModel
App ..> FileGameDataAccess
App --> MainWindow
MainWindow ..> MainViewModel : DataContext
@enduml
EOF

cat > "$ROOT/docs/documentation.md" <<'EOF'
# Potyogós amőba – 2. beadandó dokumentáció

Eseményvezérelt alkalmazások, 2025/2026 őszi félév

## 1. A fejlesztő adatai

- Név: (ide kerül a hallgató neve)
- Neptun-kód: (ide kerül a Neptun-kód)
- E-mail: (ide kerül az e-mail cím)
- Gyakorlatvezető: (ide kerül az oktató neve)
- Feladat: 19. Potyogós amőba

## 2. Feladatleírás

Készítendő egy WPF grafikus felületű alkalmazás, amellyel a potyogós amőba játék játszható két személy részére. A játékmező n × n méretű tábla, amelybe a játékosok felváltva X, illetve O jeleket ejtenek be felülről lefelé. A jel az oszlopban az első szabad helyen áll meg. A játék akkor ér véget, ha betelik a tábla (döntetlen), vagy valamelyik játékos négy egymás melletti jelet rak ki vízszintesen vagy átlósan.

A program minden lépésnél jelzi, hogy melyik játékos következik, és a tábla egy üres mezőjére kattintva lehet jelet elhelyezni, kizárólag szabályos lépések engedélyezettek. A program biztosítja új játék indítását a táblaméret megadásával (10 × 10, 20 × 20, 30 × 30), a játék szüneteltetését, valamint a játék mentését és betöltését. A program felismeri a játék végét, megjeleníti a győztest, és a táblán megjelöli a győztes négy jelet. A program folyamatosan jelzi külön-külön a két játékos gondolkodási idejét, vagyis azon idők összességét, amelyek az előző játékos lépésétől a saját lépéséig tartanak. Ezt az értéket a mentés is tárolja, a betöltés pedig visszaállítja.

## 3. A feladat elemzése

### 3.1. Követelmények összefoglalása

- A játékot két ember játssza ugyanazon a gépen, felváltva. A játékosok a program szempontjából az első (X) és a második (O) játékos, az első játékos kezd.
- A tábla mérete három előre megadott érték közül választható: 10, 20 vagy 30. A modell ennél általánosabb, legalább 4 × 4-es táblát elfogad, így kisebb tábla a tesztelésben is használható.
- Lépéskor a játékos egy üres mezőre kattint. A jel nem ott marad, hanem az adott oszlop legalsó szabad mezőjére esik. Foglalt mezőre kattintás, illetve szünetelés vagy játékvég alatti kattintás nem megengedett, a felület az ilyen mezőket letiltja, a modell pedig elutasítja a lépést.
- A nyerés feltétele a feladatkiírás szerint négy egymás melletti azonos jel vízszintesen vagy átlósan (mindkét átló irányban). Az oszlopban függőlegesen kirakott négyes a kiírás szerint nem nyerő. Ha egy lépés négynél hosszabb vonalat hoz létre, a program a lehelyezett jelet tartalmazó pontosan négy mezőt jelöli meg.
- Ha a tábla megtelt és nincs győztes, a játék döntetlen.
- A játék szüneteltethető. Szünetelés alatt nem telik a gondolkodási idő, és nem lehet lépni. A szünetelés a játék folytatásáig tart.
- A játék mentése tetszőleges fájlba lehetséges, amíg a játék tart. Mentéskor a program automatikusan szünetelteti a játékot. Befejezett játék mentésének nincs értelme, ezért az le van tiltva.
- Betöltés után a játék szünetel, a felhasználó a folytatással indíthatja újra az időmérést. A betöltött adatokat a program ellenőrzi: a méretet, a mezők értékeit, az oszlopokban a jelek elhelyezkedését (nem lehet lebegő jel), a két játékos jeleinek számát és a soron következő játékos helyességét, valamint azt, hogy a betöltött állás ne legyen már lezárt játék. Hibás adat esetén a program hibaüzenetet ad, a futó játék pedig változatlan marad.
- A gondolkodási idő mérése másodperces felbontású. Az idő annak a játékosnak telik, aki éppen soron van, ezért a két időt a játékosok külön halmozzák.
- A grafikus felület angol nyelvű, a megjelenő üzenetek és menüpontok is.

### 3.2. Felhasználói esetek

A felhasználói eseteket a use-cases.puml fájlból generált use-cases.png diagram szemlélteti.

Szereplő: a Játékos.

**UC1 – Új játék indítása.** A játékos a Game / New game menüben kiválasztja a táblaméretet (UC2 beépül). A program üres táblát jelenít meg, az X játékos kezd, a gondolkodási idők nullázódnak, a szünetelés megszűnik.

**UC2 – Táblaméret kiválasztása.** A játékos a három lehetséges méret (10 × 10, 20 × 20, 30 × 30) egyikét választja ki.

**UC3 – Jel elhelyezése.** A játékos egy üres mezőre kattint. A jel az oszlop legalsó szabad mezőjére kerül, a program átadja a lépést a másik játékosnak, és a státuszsorban megjeleníti, ki következik. Ha a lépés nyer vagy betölti a táblát, a játék véget ér (UC8).

**UC4 – Játék szüneteltetése és folytatása.** A játékos a Game / Pause menüponttal megállítja a játékot, majd a Game / Resume menüponttal folytatja. Szünetelés alatt nem lehet lépni és nem telik a gondolkodási idő. A menüpont felirata a játék állapotát követi.

**UC5 – Játék mentése.** A játékos a Game / Save game menüpontot választja. A program szünetelteti a játékot, fájlnevet kér, majd elmenti a tábla állását, a soron következő játékost és a két gondolkodási időt. Sikeres mentésről, illetve hibáról üzenetet ad.

**UC6 – Játék betöltése.** A játékos a Game / Load game menüpontot választja. A program szünetelteti a játékot, fájlt kér, majd betölti és ellenőrzi az adatokat. Hibás fájl esetén hibaüzenetet jelenít meg és a korábbi játék marad. Sikeres betöltés után a játék szünetel, a folytatással lehet tovább játszani.

**UC7 – Gondolkodási idők megtekintése.** A státuszsorban játék közben folyamatosan látható a két játékos gondolkodási ideje óra:perc:másodperc formában.

**UC8 – Eredmény megtekintése.** A játék végén a program üzenetablakban és a státuszsorban jelzi, hogy melyik játékos győzött, vagy hogy döntetlen lett az eredmény. Győzelem esetén a nyerő négy jel a táblán kiemelve jelenik meg.

**UC9 – Kilépés.** A játékos a Game / Exit menüponttal bezárja az alkalmazást.

## 4. A program szerkezete

### 4.1. Architektúra

A program MVVM (Model–View–ViewModel) architektúrában készült, a rétegek külön projektben találhatók, és a függőségek egyirányúak. Az osztályokat az class-diagram.puml fájlból generált class-diagram.png diagram mutatja.

- **TicTacToe.Persistence**: az adatkezelés rétege. Nem függ más rétegtől.
- **TicTacToe.Model**: a játék logikája. Csak az adatkezelés interfészét ismeri, grafikus osztályra nem hivatkozik.
- **TicTacToe.App**: a megjelenítés (View, ViewModel és az alkalmazás belépési pontja). Ez a projekt hivatkozik a modellre és az adatkezelésre.
- **TicTacToe.Tests**: a modell és az adatkezelés egységtesztjei.

### 4.2. Adatkezelés (TicTacToe.Persistence)

- Az **IGameDataAccess** interfész két aszinkron műveletet definiál: a betöltést és a mentést. A modell kizárólag ezt az interfészt ismeri, így a tesztekben a perzisztencia szimulálható.
- A **GameData** a mentett állapotot tárolja: a tábla méretét, a mezők tartalmát (0 üres, 1 az első, 2 a második játékos), a soron következő játékost és a két játékos gondolkodási idejét másodpercben.
- A **FileGameDataAccess** szöveges fájlba ment. A fájl első négy sora a méret, a soron következő játékos, az első játékos ideje és a második játékos ideje, ezt követi a tábla soronként, ahol a pont az üres mezőt, az X és az O a jeleket jelöli. Betöltéskor a formátumot ellenőrzi.
- A **GameDataException** jelzi az olvasási, írási és formátumhibákat. Minden alacsonyabb szintű hibát (fájl nem található, rossz szám, hibás karakter) ebbe csomagol.

### 4.3. Modell (TicTacToe.Model)

- A **Player** felsorolás a mező tartalmát és a játékosokat jelöli (None, First, Second), a **GameStatus** a játék állapotát (InProgress, FirstPlayerWon, SecondPlayerWon, Draw).
- A **GameModel** valósítja meg a teljes játéklogikát. Tárolja a táblát, a soron következő játékost, az állapotot, a szüneteltetést, a nyerő mezőket és a két játékos gondolkodási idejét.
  - A **NewGame** új játékot indít a megadott mérettel.
  - A **Step** a megadott mezőt tartalmazó oszlop legalsó szabad helyére ejti a soron következő játékos jelét, majd kiértékeli a lépést: ellenőrzi a nyerést a lehelyezett jel köré a három figyelt irányban (vízszintes és a két átlós), a tábla telítettségét, és szükség esetén átadja a lépést. Szabálytalan lépésnél hamis értékkel tér vissza, és az állapot nem változik.
  - A **Pause** és a **Resume** a szüneteltetést kezeli. A **Tick** a gondolkodási idő mérését végzi.
  - A **SaveGameAsync** és a **LoadGameAsync** az adatkezelésen keresztül ment, illetve tölt be. Betöltéskor a modell ellenőrzi az adatok konzisztenciáját, és csak érvényes adat esetén cseréli le az állapotát.
- Az időzítés a modellben van, mert a gondolkodási idő a játéklogika része. A modell egy másodperces ütemű időzítőt használ, amely minden ütemben meghívja a Tick műveletet. Az időzítő a konstruktor paraméterével kikapcsolható, így a tesztekben a Tick kézzel hívható. Az állapotmódosítások közös zárral védettek, mert az időzítő külön szálon fut.
- A modell eseményekkel jelez a nézetmodellnek: **GameStarted** (új vagy betöltött játék), **CellChanged** (jel lekerült a táblára), **PlayerChanged** (lépés átadása), **TimeChanged** (idő telt), **PauseChanged** (szüneteltetés változott), **GameOver** (vége a játéknak, a győztessel és a nyerő mezőkkel). Az esemény-paraméter osztályok a **CellChangedEventArgs** és a **GameOverEventArgs**.

### 4.4. Nézetmodell (TicTacToe.App/ViewModel)

- A **ViewModelBase** a változásértesítést valósítja meg, a **DelegateCommand** a parancsok általános megvalósítása.
- A **CellViewModel** egy mezőt reprezentál: a pozícióját, a megjelenő szöveget (X, O vagy üres) és azt, hogy nyerő mező-e.
- A **MainViewModel** a modell eseményeire feliratkozva tartja naprakészen a megjelenített adatokat: a mezők listáját, a táblaméretet, a státuszsor szövegét, a két gondolkodási időt és a szünetmenü feliratát. A felhasználói műveletek parancsokként érhetők el (új játék, szüneteltetés, mentés, betöltés, kilépés, lépés). A lépés parancs paramétere a kattintott mező, és csak üres mezőn, szünetelés és játékvég nélkül engedélyezett. A nézetmodell nem tárol játékadatot, mindent a modellből kérdez le.
- A fájlválasztást és az üzenetablakokat a nézetmodell nem végzi, hanem eseményekkel kéri (mentés, betöltés, kilépés kérése, játék vége).

### 4.5. Nézet (TicTacToe.App)

- A **MainWindow** a főablak, amely kizárólag XAML-ben leírt felületből áll, háttérkódja üres. Tartalmaz menüt (új játék a három mérettel, szüneteltetés és folytatás, mentés, betöltés, kilépés), a mezőrácsot, valamint a státuszsort, amely a soron következő játékost vagy az eredményt és a két gondolkodási időt mutatja. A mezőrács egy elemlista egyenletes rácsban, amely az ablak méretéhez igazodik, így a 30 × 30-as tábla is elfér. A jelek színezve jelennek meg, a nyerő mezők arany háttérrel.
- Az **App** osztály az alkalmazás belépési pontja: létrehozza a modellt, a nézetmodellt és az ablakot, összekapcsolja őket, megjeleníti a fájlválasztó és az üzenetablakokat a nézetmodell kéréseire, és kilépéskor felszabadítja a modellt.

## 5. Tesztelés

A modell működését egységtesztek ellenőrzik (MSTest). Az adatkezelést a modell tesztjeiben egy kézzel írt tesztdublőr (FakeGameDataAccess) helyettesíti, amely a mentett adatot a memóriában tartja, és kérésre hibát szimulál. Az időzítő a tesztekben ki van kapcsolva, a Tick műveletet a tesztek hívják.

### 5.1. GameModelTests – a modell tesztjei

**Új játék**
- NewGame_CreatesEmptyBoard: új játék után a tábla üres, az első játékos következik, az idők nullák, a játék nem szünetel.
- NewGame_TooSmallSize_Throws: túl kicsi táblaméret kivételt eredményez.
- NewGame_RaisesGameStartedEvent: új játék kiváltja a GameStarted eseményt.
- NewGame_ResetsFinishedGame: befejezett játék után az új játék újra játszható állapotot ad.

**Lépések**
- Step_DropsSignToBottomOfColumn: a jel az oszlop aljára esik.
- Step_ClickingHigherCellStillDropsToBottom: magasabb üres mezőre kattintva is az oszlop aljára kerül a jel.
- Step_StacksSignsInColumn: egymás utáni lépések egymásra rakódnak, a jelek váltakoznak.
- Step_SwitchesCurrentPlayer: lépés után a másik játékos következik.
- Step_OnOccupiedCell_ReturnsFalse: foglalt mezőre nem lehet lépni, az állapot nem változik.
- Step_OutOfRange_ReturnsFalse: a táblán kívüli pozíció elutasítandó.
- Step_InFullColumn_ReturnsFalse: teli oszlopba nem lehet jelet ejteni.
- Step_RaisesCellChangedAndPlayerChangedEvents: a lépés kiváltja a CellChanged és a PlayerChanged eseményt a helyes adatokkal.
- Step_WhenPaused_ReturnsFalseUntilResumed: szünetelés alatt nem lehet lépni, folytatás után igen.

**Nyerési feltételek és játékvég**
- HorizontalFour_FirstPlayerWins: vízszintes négyes az első játékosnak, a GameOver esemény pontosan egyszer fut le a nyerő mezőkkel.
- HorizontalFour_SecondPlayerWins: a második játékos nyerése.
- DiagonalFour_FirstPlayerWins: átlós négyes az egyik átló irányban.
- AntiDiagonalFour_FirstPlayerWins: átlós négyes a másik átló irányban.
- FourInColumn_IsNotAWin: a feladatkiírás szerint a függőleges négyes nem nyerő.
- LineLongerThanFour_MarksExactlyFourCells: négynél hosszabb vonal esetén pontosan négy mező van megjelölve, és ezek tartalmazzák a lehelyezett jelet.
- Step_AfterGameOver_ReturnsFalse: a játék vége után nem lehet lépni.
- FullBoardWithoutWinner_IsDraw: telt tábla győztes nélkül döntetlen, a GameOver esemény nyerő mezők nélkül jelentkezik.

**Idő és szüneteltetés**
- Tick_IncreasesCurrentPlayerTime: az idő a soron következő játékosnak telik.
- Tick_CountsTimeSeparatelyPerPlayer: a két játékos ideje külön halmozódik.
- Tick_WhenPaused_DoesNotIncreaseTime: szünetelés alatt nem telik az idő.
- Tick_AfterGameOver_DoesNotIncreaseTime: játékvég után nem telik az idő.
- Tick_RaisesTimeChangedEvent: az idő telése kiváltja a TimeChanged eseményt.
- PauseAndResume_RaisePauseChangedEvent: a szüneteltetés és a folytatás kiváltja a PauseChanged eseményt, az ismételt hívás nem.
- Pause_AfterGameOver_IsIgnored: befejezett játékot nem lehet szüneteltetni.

**Mentés és betöltés (szimulált perzisztenciával)**
- SaveGame_PassesCurrentStateToPersistence: a modell a helyes adatokat adja át az adatkezelésnek.
- SaveGame_AfterGameOver_Throws: befejezett játék mentése kivételt okoz.
- SaveGame_PersistenceFailure_IsPropagated: az adatkezelési hiba továbbadódik.
- LoadGame_ValidData_RestoresStateAndPauses: érvényes adat betöltése visszaállítja a táblát, a soron következő játékost és az időket, a játék szünetel, a GameStarted esemény lefut.
- LoadGame_FloatingSign_Throws: lebegő jelet tartalmazó adat elutasítása.
- LoadGame_WrongPlayerOnTurn_Throws: a táblának nem megfelelő soron következő játékos elutasítása.
- LoadGame_UnbalancedSigns_Throws: a két játékos jeleinek helytelen aránya elutasítandó.
- LoadGame_AlreadyFinishedGame_Throws: már lezárt állás elutasítása.
- LoadGame_InvalidPlayer_Throws: érvénytelen játékosazonosító elutasítása.
- LoadGame_Failure_KeepsCurrentGame: sikertelen betöltés után a korábbi játék változatlan.
- LoadGame_PersistenceFailure_IsPropagated: a betöltési hiba továbbadódik.
- SaveAndLoad_RoundTripRestoresGame: mentés és betöltés után a játék egy másik modellpéldányban is azonos állapotú, folytatás után pedig játszható.

### 5.2. FileGameDataAccessTests – a fájlkezelés tesztjei

- SaveAndLoad_RoundTrip: a mentett és visszatöltött adat megegyezik az eredetivel.
- LoadAsync_MissingFile_Throws: hiányzó fájl adatkezelési hibát ad.
- LoadAsync_InvalidCharacter_Throws: hibás karaktert tartalmazó tábla elutasítása.
- LoadAsync_WrongRowCount_Throws: hibás sorszámú fájl elutasítása.
- LoadAsync_NonNumericHeader_Throws: nem szám jellegű fejléc elutasítása.

A tesztek futtatása a megoldás mappájában a dotnet test paranccsal lehetséges.
EOF

if command -v dotnet >/dev/null 2>&1; then
  (
    cd "$ROOT"
    dotnet new sln -n "$PROJECT_NAME" >/dev/null
    dotnet sln add \
      TicTacToe.Persistence/TicTacToe.Persistence.csproj \
      TicTacToe.Model/TicTacToe.Model.csproj \
      TicTacToe.App/TicTacToe.App.csproj \
      TicTacToe.Tests/TicTacToe.Tests.csproj >/dev/null
  )
  echo "Solution created in $ROOT"
else
  echo "The dotnet SDK was not found, the solution file was not created."
  echo "Run 'dotnet new sln' and add the four projects once the SDK is installed."
fi

echo "Project generated in: $ROOT"
echo "Target framework: $TFM (override with: TFM=net10.0 ./generate_project.sh)"
echo "Build and test: cd $ROOT && dotnet test TicTacToe.Tests"
echo "Run the game (Windows): dotnet run --project TicTacToe.App"
