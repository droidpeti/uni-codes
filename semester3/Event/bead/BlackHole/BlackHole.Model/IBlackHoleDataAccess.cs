namespace BlackHole.Model;

public interface IBlackHoleDataAccess
{
    Task<(int Size, Player CurrentPlayer, int P1Entered, int P2Entered, Field[,] Board)> LoadAsync(string path);
    Task SaveAsync(string path, int size, Player currentPlayer, int p1Entered, int p2Entered, Field[,] board);
}
