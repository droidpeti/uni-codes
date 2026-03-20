namespace Sequential;

class Program
{
    static void Main(string[] args)
    {
        Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("en-US");
        string filename = "data.txt";

        FishIter fi = new FishIter(filename);

        foreach(FishIter fisher in fi)
        {
            Console.WriteLine(fisher);
        }

    }
}
