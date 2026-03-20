namespace FileRead;

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
public class Fisher
{
    public readonly string name;
    private List<Catch> fishes = new List<Catch>();

    public Fisher(string name)
    {
        this.name = name;
    }

    public void AddCatch(string[] catchData)
    {
        fishes.Add(new Catch(catchData));
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
