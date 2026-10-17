using BlackHole.Model;

namespace BlackHole.Test;

[TestClass]
public sealed class Test1
{
    private sealed class MockDataAccess : IBlackHoleDataAccess
    {
        public int SavedSize { get; private set; }
        public Player SavedPlayer { get; private set; }
        public int SavedP1Entered { get; private set; }
        public int SavedP2Entered { get; private set; }
        public Field[,]? SavedBoard { get; private set; }

        public int SizeToLoad { get; set; } = 5;
        public Player PlayerToLoad { get; set; } = Player.Player2;
        public int P1EnteredToLoad { get; set; } = 1;
        public int P2EnteredToLoad { get; set; } = 1;
        public Field[,]? BoardToLoad { get; set; }

        public Task<(int Size, Player CurrentPlayer, int P1Entered, int P2Entered, Field[,] Board)> LoadAsync(string path)
        {
            Field[,] board = BoardToLoad ?? new Field[SizeToLoad, SizeToLoad];
            return Task.FromResult((SizeToLoad, PlayerToLoad, P1EnteredToLoad, P2EnteredToLoad, board));
        }

        public Task SaveAsync(string path, int size, Player currentPlayer, int p1Entered, int p2Entered, Field[,] board)
        {
            SavedSize = size;
            SavedPlayer = currentPlayer;
            SavedP1Entered = p1Entered;
            SavedP2Entered = p2Entered;
            SavedBoard = board;
            return Task.CompletedTask;
        }
    }

    [TestMethod]
    [DataRow(5, 2)]
    [DataRow(7, 3)]
    [DataRow(9, 4)]
    public void NewGame_InitializesBoardCorrectly(int size, int expectedTarget)
    {
        var model = new BlackHoleGameModel();
        model.NewGame(size);

        Assert.AreEqual(size, model.Size);
        Assert.AreEqual(expectedTarget, model.TargetShips);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);
        Assert.AreEqual(0, model.Player1Entered);
        Assert.AreEqual(0, model.Player2Entered);
        Assert.IsFalse(model.IsGameOver);

        int center = size / 2;
        Assert.AreEqual(Field.BlackHole, model.GetField(center, center));

        int p1Count = 0;
        int p2Count = 0;
        for (int r = 0; r < size; r++)
        {
            for (int c = 0; c < size; c++)
            {
                if (model.GetField(r, c) == Field.Player1Ship) p1Count++;
                if (model.GetField(r, c) == Field.Player2Ship) p2Count++;
            }
        }

        Assert.AreEqual(size - 1, p1Count);
        Assert.AreEqual(size - 1, p2Count);
    }

    [TestMethod]
    public void MoveShip_SlidesUntilWallOrOtherShip()
    {
        var model = new BlackHoleGameModel();
        model.NewGame(5);

        bool moved = model.MoveShip(0, 0, 1, 0);

        Assert.IsTrue(moved);
        Assert.AreEqual(Field.Empty, model.GetField(0, 0));
        Assert.AreEqual(Field.Player1Ship, model.GetField(3, 0));
        Assert.AreEqual(Player.Player2, model.CurrentPlayer);
    }

    [TestMethod]
    public void MoveShip_EntersBlackHole_IncrementsScore()
    {
        var model = new BlackHoleGameModel();
        model.NewGame(5);

        Assert.IsTrue(model.MoveShip(1, 1, 0, 1));
        Assert.AreEqual(Field.Player1Ship, model.GetField(1, 2));
        Assert.AreEqual(Player.Player2, model.CurrentPlayer);

        Assert.IsTrue(model.MoveShip(4, 0, -1, 0));
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);

        Assert.IsTrue(model.MoveShip(1, 2, 1, 0));
        Assert.AreEqual(Field.Empty, model.GetField(1, 2));
        Assert.AreEqual(Field.BlackHole, model.GetField(2, 2));
        Assert.AreEqual(1, model.Player1Entered);
    }

    [TestMethod]
    public void MoveShip_InvalidMove_ReturnsFalseAndDoesNotChangeTurn()
    {
        var model = new BlackHoleGameModel();
        model.NewGame(5);

        bool movedOutOfBounds = model.MoveShip(0, 0, -1, 0);
        Assert.IsFalse(movedOutOfBounds);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);

        bool movedOpponentShip = model.MoveShip(4, 0, -1, 0);
        Assert.IsFalse(movedOpponentShip);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);
    }

    [TestMethod]
    public async Task SaveAndLoadGame_UsesDataAccessCorrectly()
    {
        var mock = new MockDataAccess();
        var model = new BlackHoleGameModel(mock);
        model.NewGame(7);
        model.MoveShip(0, 0, 1, 0);

        await model.SaveGameAsync("dummy.bh");

        Assert.AreEqual(7, mock.SavedSize);
        Assert.AreEqual(Player.Player2, mock.SavedPlayer);
        Assert.IsNotNull(mock.SavedBoard);

        Field[,] customBoard = new Field[5, 5];
        customBoard[2, 2] = Field.BlackHole;
        customBoard[0, 2] = Field.Player1Ship;
        mock.SizeToLoad = 5;
        mock.PlayerToLoad = Player.Player1;
        mock.P1EnteredToLoad = 1;
        mock.P2EnteredToLoad = 0;
        mock.BoardToLoad = customBoard;

        await model.LoadGameAsync("dummy.bh");

        Assert.AreEqual(5, model.Size);
        Assert.AreEqual(Player.Player1, model.CurrentPlayer);
        Assert.AreEqual(1, model.Player1Entered);
        Assert.AreEqual(Field.Player1Ship, model.GetField(0, 2));
    }
}
