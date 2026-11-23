using TicTacToe.Persistence;

namespace TicTacToe.Tests;

internal class FakeGameDataAccess : IGameDataAccess
{
    public GameData? Stored { get; set; }

    public string? LastPath { get; private set; }

    public bool ThrowOnLoad { get; set; }

    public bool ThrowOnSave { get; set; }

    public Task<GameData> LoadAsync(string path)
    {
        LastPath = path;

        if (ThrowOnLoad || Stored == null)
        {
            throw new GameDataException("Simulated load failure.");
        }

        return Task.FromResult(Stored);
    }

    public Task SaveAsync(string path, GameData data)
    {
        LastPath = path;

        if (ThrowOnSave)
        {
            throw new GameDataException("Simulated save failure.");
        }

        Stored = data;
        return Task.CompletedTask;
    }
}
