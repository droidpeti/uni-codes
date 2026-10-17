namespace Chameleons.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public Player CurrentPlayer { get; }
    public int RedCount { get; }
    public int GreenCount { get; }

    public GameEventArgs(Player winner, Player currentPlayer, int redCount, int greenCount)
    {
        Winner = winner;
        CurrentPlayer = currentPlayer;
        RedCount = redCount;
        GreenCount = greenCount;
    }
}
