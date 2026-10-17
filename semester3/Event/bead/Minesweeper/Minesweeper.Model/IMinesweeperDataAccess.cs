namespace Minesweeper.Model;

public interface IMinesweeperDataAccess
{
    Task<(int Size, Player CurrentPlayer, Field[,] Board)> LoadAsync(string path);
    Task SaveAsync(string path, int size, Player currentPlayer, Field[,] board);
}
