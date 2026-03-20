using System.Collections;

namespace Sequential;

public class FishIter : IEnumerable, IEnumerator
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

    public FishIter(string filename)
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

    public void Next()
    {
        string[] data = sr.ReadLine().Split(" ", StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);
        name = data[0];
        fishes.Clear();
        
        for(int i = 1; i < data.Length; i += 4)
        {
            fishes.Add(new Catch(data.Skip(i).Take(4).ToArray()));
        }
    }

    public bool HasNext()
    {
        return sr != null && !sr.EndOfStream;
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

    public IEnumerator GetEnumerator()
    {
        return this;
    }

    public object Current => this;

    public bool MoveNext()
    {
        if (sr == null || sr.EndOfStream){
            return false;
        }
        
        string[] data = sr.ReadLine().Split(" ", StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);
        name = data[0];
        fishes.Clear();
        
        for(int i = 1; i < data.Length; i += 4)
        {
            fishes.Add(new Catch(data.Skip(i).Take(4).ToArray()));
        }

        return true;
    }

    public void Reset()
    {
        throw new NotImplementedException();
    }
}
