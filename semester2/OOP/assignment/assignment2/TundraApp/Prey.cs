namespace TundraApp;

public abstract class Prey : Colony
{
    protected int multiplier;
    protected double breedingMultiplier;
    protected int roundsToBreed, maxPopulation, newPopulation;
    public Prey(
        string name, char species, int population, int multiplier,
        int roundsToBreed, int maxPopulation, int newPopulation,
        double breedingMultiplier
    ) : base(name, species, population)
    {
        this.multiplier = multiplier;
        this.roundsToBreed = roundsToBreed;
        this.maxPopulation = maxPopulation;
        this.newPopulation = newPopulation;
        this.breedingMultiplier = breedingMultiplier;
    }
    public bool AttackedBy(Predator hunter)
    {
        int loss = hunter.Population*multiplier;
        if(Population >= loss)
        {
            Population -= hunter.Population*multiplier;
            return true;
        }
        Population = 0;
        return false;
    }

    public override void EndOfTurn(int curRound)
    {
        if(curRound % roundsToBreed != 0)
        {
            return;
        }
        
        Population = (int)(breedingMultiplier*Population);
        if(Population > maxPopulation)
        {
            Population = newPopulation;
        }
    }
}

public class Rabbit : Prey
{
    public Rabbit(string name, int population)
    : base(name, 'n', population, 2, 2, 100, 20, 1.5)
    {

    }
}

public class Gopher : Prey
{
    public Gopher(string name, int population) 
    : base(name, 'u', population, 2, 4, 200, 40, 2)
    {
        
    }
}

public class Lemming : Prey
{
    public Lemming(string name, int population)
    : base(name, 'l', population, 4, 2, 200, 30, 2)
    {
        
    }
}

