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
