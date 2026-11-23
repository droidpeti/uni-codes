namespace TicTacToe.Model;

public class GameOverEventArgs : EventArgs
{
    public GameOverEventArgs(GameStatus status, IReadOnlyList<(int Row, int Column)> winningCells)
    {
        Status = status;
        WinningCells = winningCells;
    }

    public GameStatus Status { get; }

    public IReadOnlyList<(int Row, int Column)> WinningCells { get; }
}
