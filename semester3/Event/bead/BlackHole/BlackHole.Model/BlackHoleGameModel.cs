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
