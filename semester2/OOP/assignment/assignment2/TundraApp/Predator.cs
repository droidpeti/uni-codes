namespace TundraApp;

public abstract class Predator : Colony
{
    protected int neededToBreed, breedAmount;
    public Predator(
        string name, char species, int population,
        int neededToBreed, int breedAmount
    ) : base(name, species, population)
    {
        this.neededToBreed = neededToBreed;
        this.breedAmount = breedAmount;
    }
    public void Hunt(Prey target)
    {
        if (!target.AttackedBy(this))
        {
            Population = (int)(Population * 0.75);
        }
    }
    public override void EndOfTurn(int curRound)
    {
        if (curRound % 8 != 0)
        {
            return;
        }
        int timesToBreed = Population / neededToBreed;
        if(timesToBreed == 0)
        {
            return;
        }
        Population += timesToBreed*breedAmount;
    }
}

public class Owl : Predator
{
    public Owl(string name, int population)
    : base(name, 'h', population, 4, 1)
    {
        
    }
}

public class Fox : Predator
{
    public Fox(string name, int population)
    : base(name, 's', population, 4, 3)
    {
        
    }
}

public class Wolf : Predator
{
    public Wolf(string name, int population)
    : base(name, 'f', population, 4, 2)
    {
        
    }
}
