using TicTacToe.Persistence;

namespace TicTacToe.Tests;

[TestClass]
public class FileGameDataAccessTests
{
    private string _path = null!;
    private FileGameDataAccess _access = null!;

    [TestInitialize]
    public void Initialize()
    {
        _path = Path.Combine(Path.GetTempPath(), Guid.NewGuid().ToString("N") + ".dtt");
        _access = new FileGameDataAccess();
    }

    [TestCleanup]
    public void Cleanup()
    {
        if (File.Exists(_path))
        {
            File.Delete(_path);
        }
    }

    [TestMethod]
    public async Task SaveAndLoad_RoundTrip()
    {
        int[,] board = new int[4, 4];
        board[3, 0] = 1;
        board[3, 1] = 2;
        board[2, 0] = 1;
        GameData original = new(4, board, 2, 65, 7);

        await _access.SaveAsync(_path, original);
        GameData loaded = await _access.LoadAsync(_path);

        Assert.AreEqual(4, loaded.Size);
        Assert.AreEqual(2, loaded.CurrentPlayer);
        Assert.AreEqual(65, loaded.FirstPlayerSeconds);
        Assert.AreEqual(7, loaded.SecondPlayerSeconds);
        for (int row = 0; row < 4; row++)
        {
            for (int column = 0; column < 4; column++)
            {
                Assert.AreEqual(board[row, column], loaded.Board[row, column]);
            }
        }
    }

    [TestMethod]
    public async Task LoadAsync_MissingFile_Throws()
    {
        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }

    [TestMethod]
    public async Task LoadAsync_InvalidCharacter_Throws()
    {
        await File.WriteAllTextAsync(_path, "4\n1\n0\n0\n....\n....\n....\n..Z.\n");

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }

    [TestMethod]
    public async Task LoadAsync_WrongRowCount_Throws()
    {
        await File.WriteAllTextAsync(_path, "4\n1\n0\n0\n....\n....\n");

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }

    [TestMethod]
    public async Task LoadAsync_NonNumericHeader_Throws()
    {
        await File.WriteAllTextAsync(_path, "four\n1\n0\n0\n....\n....\n....\n....\n");

        await Assert.ThrowsExceptionAsync<GameDataException>(() => _access.LoadAsync(_path));
    }
}
