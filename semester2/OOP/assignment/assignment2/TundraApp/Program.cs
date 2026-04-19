namespace TundraApp;

class Program
{
    private static List<Prey> preys = new List<Prey>();
    private static List<Predator> predators = new List<Predator>();
    
    private static int currentRound = 0;
    private static int initialPreyPopulation = 0;
    private static Random rnd = new Random();

    public static void Main(string[] args)
    {
        bool isRunning = true;
        while (isRunning)
        {
            Console.WriteLine("\nTundra Simulation");
            Console.WriteLine("1. Read File");
            Console.WriteLine("2. Print state of colonies");
            Console.WriteLine("3. Simulate single round");
            Console.WriteLine("4. Simulate until the end");
            Console.WriteLine("5. Exit");
            Console.Write("Choose one: ");
            
            string choice = Console.ReadLine();
            
            switch (choice)
            {
                case "1":
                    LoadFileMenu();
                    break;
                case "2":
                    PrintStatus();
                    break;
                case "3":
                    SimulateRound();
                    break;
                case "4":
                    RunFullSimulation();
                    break;
                case "5":
                    isRunning = false;
                    break;
                default:
                    Console.WriteLine("Invalid Choice!");
                    break;
            }
        }
    }

    private static void LoadFileMenu()
    {
        Console.Write("Please input the file's name (input.txt): ");
        string filename = Console.ReadLine();
        try
        {
            ColonyFactory.ReadFile(filename, preys, predators);
            initialPreyPopulation = 0;
            foreach (var p in preys)
            {
                initialPreyPopulation += p.Population;
            }
            currentRound = 0;
            
            Console.WriteLine("Succesfully Read File!");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error while reading file: {ex.Message}");
        }
    }

    private static void PrintStatus()
    {
        Console.WriteLine($"\n--- Round #{currentRound} ---");
        Console.WriteLine("Preys:");
        foreach (var p in preys) Console.WriteLine(p); 
        
        Console.WriteLine("\nPredators:");
        foreach (var p in predators) Console.WriteLine(p);
    }

    private static void SimulateRound()
    {
        currentRound++;
        if (preys.Count > 0)
        {
            foreach(Predator predator in predators)
            {
                int target = rnd.Next(0, preys.Count);
                predator.Hunt(preys[target]);
            }
        }

        foreach(Prey prey in preys)
        {
            prey.EndOfTurn(currentRound);
        } 
        foreach(Predator predator in predators)
        {
            predator.EndOfTurn(currentRound);
        } 

        preys.RemoveAll(p => p.Population <= 0);
        predators.RemoveAll(p => p.Population <= 0);
    }

    private static void RunFullSimulation()
    {
        int preyCount = initialPreyPopulation;
        int maxRounds = 1000;
        
        while (preyCount > 0 && preyCount < 4 * initialPreyPopulation && currentRound < maxRounds)
        {
            SimulateRound();
            
            preyCount = 0;
            foreach(Prey prey in preys)
            {
                preyCount += prey.Population;
            }
            PrintStatus();
        }
        
        Console.WriteLine($"\nSimulation ended after round #{currentRound}!");
        PrintStatus();
    }
}
