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
