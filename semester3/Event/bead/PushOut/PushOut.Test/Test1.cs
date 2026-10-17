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
