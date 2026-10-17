namespace PushOut.Model;

public interface IPushOutDataAccess
{
    Task<(int Size, Player CurrentPlayer, int RemainingSteps, Field[,] Board)> LoadAsync(string path);
    Task SaveAsync(string path, int size, Player currentPlayer, int remainingSteps, Field[,] board);
}
