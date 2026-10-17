namespace Minesweeper.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public Player CurrentPlayer { get; }
    public int RemainingSafeCells { get; }

    public GameEventArgs(Player winner, Player currentPlayer, int remainingSafeCells)
    {
        Winner = winner;
        CurrentPlayer = currentPlayer;
        RemainingSafeCells = remainingSafeCells;
    }
}
