namespace TundraApp;
public abstract class Colony
{
    public string Name {get; protected set;}
    public int Population {get; protected set;}
    public char Species {get; protected set;}
    public Colony(string name, char species, int population)
    {
        Name = name;
        Species = species;
        Population = population;
    }
    public abstract void EndOfTurn(int curRound);
    public override string ToString()
    {
        return $"{Name} {this.GetType().Name} colony, population: {Population}";
    }
}
