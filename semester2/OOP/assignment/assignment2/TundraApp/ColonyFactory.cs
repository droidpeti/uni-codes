namespace TundraApp;

public static class ColonyFactory
{
    public static void ReadFile(string filename, List<Prey> preys, List<Predator> predators)
    {
        using StreamReader sr = new StreamReader(filename);
        
        string[] row = sr.ReadLine().Split(' ');
        int preyCount = int.Parse(row[0]);
        int predatorCount = int.Parse(row[1]);

        preys.Clear();
        predators.Clear();

        int totalColonies = preyCount + predatorCount;
        for(int i = 0; i < totalColonies; i++)
        {
            row = sr.ReadLine().Split(' ');
            string name = row[0];
            char speciesChar = char.Parse(row[1]);
            int pop = int.Parse(row[2]);

            Colony newColony = CreateColony(name, speciesChar, pop);

            if (newColony is Prey p)
            {
                preys.Add(p); 
            }
            else if (newColony is Predator pr)
            {
                predators.Add(pr);
            }
        }
    }
    public static Colony CreateColony(string name, char species, int population)
    {
        switch (species)
        {
            case 'h':
                return new Owl(name, population);
            case 's':
                return new Fox(name, population);
            case 'f':
                return new Wolf(name, population);
            case 'l':
                return new Lemming(name, population);
            case 'n':
                return new Rabbit(name, population);
            case 'u':
                return new Gopher(name, population);
        }
        throw new ArgumentException("Invalid species!");
    }
}
