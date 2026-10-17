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
