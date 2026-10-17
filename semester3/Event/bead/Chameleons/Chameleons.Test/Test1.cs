using Chameleons.Model;

namespace Chameleons.Test;

[TestClass]
public sealed class Test1
{
    private sealed class MockDataAccess : IChameleonsDataAccess
    {
        public int SavedSize { get; private set; }
        public Player SavedPlayer { get; private set; }
        public Field[,]? SavedBoard { get; private set; }

        public int SizeToLoad { get; set; } = 3;
        public Player PlayerToLoad { get; set; } = Player.Green;
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
    [DataRow(3, 4)]
    [DataRow(5, 12)]
    [DataRow(7, 24)]
    public void NewGame_InitializesBoardCorrectly(int size, int expectedCount)
    {
        var model = new ChameleonsGameModel();
        model.NewGame(size);

        Assert.AreEqual(size, model.Size);
        Assert.AreEqual(Player.Red, model.CurrentPlayer);
        Assert.AreEqual(expectedCount, model.RedCount);
        Assert.AreEqual(expectedCount, model.GreenCount);
        Assert.IsFalse(model.IsGameOver);

        int center = size / 2;
        Assert.AreEqual(CellColor.Gray, model.GetField(center, center).Background);
        Assert.AreEqual(Player.None, model.GetField(center, center).Occupant);
    }

    [TestMethod]
    public void MoveChameleon_AdjacentEmptyCell_MovesAndSwitchesTurn()
    {
        var model = new ChameleonsGameModel();
        model.NewGame(3);

        bool moved = model.MoveChameleon(0, 1, 1, 1);

        Assert.IsTrue(moved);
        Assert.AreEqual(Player.None, model.GetField(0, 1).Occupant);
        Assert.AreEqual(Player.Red, model.GetField(1, 1).Occupant);
        Assert.AreEqual(Player.Green, model.CurrentPlayer);
    }

    [TestMethod]
    public void MoveChameleon_JumpOverOpponent_RemovesOpponentAndWins()
    {
        var model = new ChameleonsGameModel();
        Field[,] board = new Field[3, 3];
        board[0, 0] = new Field { Background = CellColor.Red, Occupant = Player.Red };
        board[0, 1] = new Field { Background = CellColor.Green, Occupant = Player.Green };
        board[0, 2] = new Field { Background = CellColor.Red, Occupant = Player.None };

        model.SetupCustomBoard(3, Player.Red, board);

        Player? winner = null;
        model.GameOver += (_, e) => winner = e.Winner;

        bool jumped = model.MoveChameleon(0, 0, 0, 2);

        Assert.IsTrue(jumped);
        Assert.AreEqual(Player.None, model.GetField(0, 1).Occupant);
        Assert.AreEqual(Player.Red, model.GetField(0, 2).Occupant);
        Assert.AreEqual(0, model.GreenCount);
        Assert.IsTrue(model.IsGameOver);
        Assert.AreEqual(Player.Red, winner);
    }

    [TestMethod]
    public void MoveChameleon_ColorAdaptationAfterOneTurn_ChangesOccupantOwner()
    {
        var model = new ChameleonsGameModel();
        Field[,] board = new Field[3, 3];
        board[0, 0] = new Field { Background = CellColor.Red, Occupant = Player.Red };
        board[0, 1] = new Field { Background = CellColor.Green, Occupant = Player.None };
        board[2, 0] = new Field { Background = CellColor.Green, Occupant = Player.Green };
        board[2, 1] = new Field { Background = CellColor.Green, Occupant = Player.None };
        board[2, 2] = new Field { Background = CellColor.Red, Occupant = Player.Red };

        model.SetupCustomBoard(3, Player.Red, board);

        Assert.IsTrue(model.MoveChameleon(0, 0, 0, 1));
        Assert.AreEqual(Player.Red, model.GetField(0, 1).Occupant);

        Assert.IsTrue(model.MoveChameleon(2, 0, 2, 1));
        Assert.AreEqual(Player.Green, model.GetField(0, 1).Occupant);
    }

    [TestMethod]
    public void MoveChameleon_InvalidMoves_ReturnFalse()
    {
        var model = new ChameleonsGameModel();
        model.NewGame(3);

        Assert.IsFalse(model.MoveChameleon(0, 0, 0, 1));
        Assert.IsFalse(model.MoveChameleon(1, 0, 1, 1));
        Assert.AreEqual(Player.Red, model.CurrentPlayer);
    }

    [TestMethod]
    public async Task SaveAndLoadGame_UsesDataAccessCorrectly()
    {
        var mock = new MockDataAccess();
        var model = new ChameleonsGameModel(mock);
        model.NewGame(5);

        await model.SaveGameAsync("test.chm");

        Assert.AreEqual(5, mock.SavedSize);
        Assert.AreEqual(Player.Red, mock.SavedPlayer);
        Assert.IsNotNull(mock.SavedBoard);

        Field[,] customBoard = new Field[3, 3];
        customBoard[0, 0] = new Field { Background = CellColor.Red, Occupant = Player.Red };
        customBoard[2, 2] = new Field { Background = CellColor.Green, Occupant = Player.Green };
        mock.SizeToLoad = 3;
        mock.PlayerToLoad = Player.Green;
        mock.BoardToLoad = customBoard;

        await model.LoadGameAsync("test.chm");

        Assert.AreEqual(3, model.Size);
        Assert.AreEqual(Player.Green, model.CurrentPlayer);
        Assert.AreEqual(Player.Red, model.GetField(0, 0).Occupant);
    }
}
