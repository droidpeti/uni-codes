namespace PushOut.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public int RemainingSteps { get; }
    public int WhiteCount { get; }
    public int BlackCount { get; }
    public Player CurrentPlayer { get; }

    public GameEventArgs(Player winner, int remainingSteps, int whiteCount, int blackCount, Player currentPlayer)
    {
        Winner = winner;
        RemainingSteps = remainingSteps;
        WhiteCount = whiteCount;
        BlackCount = blackCount;
        CurrentPlayer = currentPlayer;
    }
}
