namespace BlackHole.Model;

public class GameEventArgs : EventArgs
{
    public Player Winner { get; }
    public int Player1Entered { get; }
    public int Player2Entered { get; }
    public Player CurrentPlayer { get; }

    public GameEventArgs(Player winner, int player1Entered, int player2Entered, Player currentPlayer)
    {
        Winner = winner;
        Player1Entered = player1Entered;
        Player2Entered = player2Entered;
        CurrentPlayer = currentPlayer;
    }
}
