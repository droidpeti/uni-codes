namespace Chameleons.Model;

public struct Field
{
    public CellColor Background { get; set; }
    public Player Occupant { get; set; }
    public int ForeignTurns { get; set; }
}
