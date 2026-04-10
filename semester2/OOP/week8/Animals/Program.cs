namespace Animals;
public enum Mood
{
    Good,
    Average,
    Bad
}

public static class Reader
{
    public static int n;
    public static List<Animal> animals;
    public static List<Mood> moodList;
    public static int day;
    public static void Read(string filename)
    {
        StreamReader sr = new StreamReader(filename);
        n = int.Parse(sr.ReadLine());
        Reader.animals = new List<Animal>();
        
        for(int i = 0; i < n; i++)
        {
            string[] row = sr.ReadLine().Split(" ");

            switch (row[0])
            {
                case "K":
                    animals.Add(new Dog(row[1], int.Parse(row[2])));
                    break;
                case "M":
                    animals.Add(new Bird(row[1], int.Parse(row[2])));
                    break;
                case "H":
                    animals.Add(new Fish(row[1], int.Parse(row[2])));
                    break;
            }
        }
        Reader.moodList = new List<Mood>();
        foreach(char m in sr.ReadLine())
        {
            switch (m)
            {
                case 'j':
                    moodList.Add(Mood.Good);
                    break;
                case 'a':
                    moodList.Add(Mood.Average);
                    break;
                case 'r':
                    moodList.Add(Mood.Bad);
                    break;
            }
        }
        sr.Close();
        day = 0;
    }
    public static void Print()
    {
        Console.WriteLine("Animal data:");
        foreach(Animal animal in animals)
        {
            Console.WriteLine("\t" + animal);
        }
        Console.WriteLine("Mood data");
        for(int i= 0; i < moodList.Count; i++)
        {
            Console.WriteLine($"\tday #{i+1}: {Enum.GetName(moodList[i])}");
        }
    }
    public static void Simulate()
    {
        Mood m = moodList[day];

        Console.WriteLine($"Day #{day+1}, Mood: {Enum.GetName(m)}");

        for(int i = 0; i < animals.Count; i++)
        {
            animals[i].React(m);
            Console.WriteLine("\t" + animals[i]);

            if(animals[i].Hp <= 0)
            {
                Console.WriteLine($"\t {animals[0].Name} is dead!");
                animals.Remove(animals[0]);
                i--;
            }
        }
        day++;
    }

    public static bool HasMore()
    {
        return day < moodList.Count;
    }

    public static List<string> MostHealth()
    {
        List<string> top = new List<string>();
        int maxHp = 0;
        foreach(Animal animal in animals)
        {
            if(animal.Hp > maxHp)
            {
                maxHp = animal.Hp;
                top.Clear();
            }
            if(animal.Hp == maxHp)
            {
                top.Add(animal.Name);
            }
        }
        return top;
    }
}
class Program
{
    static void Main(string[] args)
    {
        Reader.Read("animals.txt");
        Reader.Print();

        while (Reader.HasMore())
        {
            Reader.Simulate();
            Console.WriteLine($"\tHealthiest animals: {string.Join(", ", Reader.MostHealth())}");
        }
    }
}
