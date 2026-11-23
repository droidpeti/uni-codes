namespace TicTacToe.Persistence;

public class GameData
{
    public GameData(int size, int[,] board, int currentPlayer, int firstPlayerSeconds, int secondPlayerSeconds)
    {
        Size = size;
        Board = board;
        CurrentPlayer = currentPlayer;
        FirstPlayerSeconds = firstPlayerSeconds;
        SecondPlayerSeconds = secondPlayerSeconds;
    }

    public int Size { get; }

    public int[,] Board { get; }

    public int CurrentPlayer { get; }

    public int FirstPlayerSeconds { get; }

    public int SecondPlayerSeconds { get; }
}
