namespace Sequential;

public class FishReader
{
    public class Catch
    {
        public TimeOnly time;
        public string species;
        public double length;
        public double weight;

        public Catch(string[] data)
        {
            time = TimeOnly.Parse(data[0]);
            species = data[1];
            length = double.Parse(data[2]);
            weight = double.Parse(data[3]);
        }
    }
    
    private StreamReader sr;
    private string name;
    private List<Catch> fishes = new List<Catch>();
    public FishReader(string filename)
    {
        try
        {
            sr = new StreamReader(filename);
        }
        catch (FileNotFoundException e)
        {
            Console.WriteLine("File not found!");
            sr = null;
        }
    }

    public override string ToString()
    {
        string output = name + "\'s catches: ";

        foreach(Catch c in fishes)
        {
            output += $"\n\t{c.time} - {c.species} - {c.length} m - {c.weight} kg";
        }

        return output;
    }
}
