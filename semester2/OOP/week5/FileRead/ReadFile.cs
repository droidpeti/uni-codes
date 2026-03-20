namespace FileRead;

public class ReadFile
{
    private StreamReader sr;
    public ReadFile(string filename)
    {
        sr = new StreamReader(filename);
    }

    ~ReadFile()
    {
        sr.Close();
    }

    public Fisher Read()
    {
        if (sr.EndOfStream)
        {
            return null;
        }

        string[] data = sr.ReadLine().Split(" ", StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);
        Fisher f = new Fisher(data[0]); 
        for(int i = 1; i < data.Length; i += 4)
        {
            f.AddCatch(data.Skip(i).Take(4).ToArray());
        }
        return f;
    }
}
