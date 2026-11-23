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
