namespace Minesweeper.Model;

public struct Field
{
    public bool IsMine { get; set; }
    public bool IsRevealed { get; set; }
    public int AdjacentMines { get; set; }
}
