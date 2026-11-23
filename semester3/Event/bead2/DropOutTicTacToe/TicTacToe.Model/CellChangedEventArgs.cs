namespace TicTacToe.Model;

public class CellChangedEventArgs : EventArgs
{
    public CellChangedEventArgs(int row, int column, Player player)
    {
        Row = row;
        Column = column;
        Player = player;
    }

    public int Row { get; }

    public int Column { get; }

    public Player Player { get; }
}
