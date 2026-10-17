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
