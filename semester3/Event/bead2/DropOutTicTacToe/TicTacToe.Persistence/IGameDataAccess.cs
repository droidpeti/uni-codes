namespace TicTacToe.Persistence;

public interface IGameDataAccess
{
    Task<GameData> LoadAsync(string path);

    Task SaveAsync(string path, GameData data);
}
