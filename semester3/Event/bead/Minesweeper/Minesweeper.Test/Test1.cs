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
