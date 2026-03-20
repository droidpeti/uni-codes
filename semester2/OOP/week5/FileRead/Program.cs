namespace FileRead;

class Program
{
    static void Main(string[] args)
    {

        Thread.CurrentThread.CurrentCulture = new System.Globalization.CultureInfo("en-US");

        FileStream fs = new FileStream("data.txt", FileMode.Open);
        StreamReader sr = new StreamReader(fs);

        List<Fisher> fishers = new List<Fisher>();

        while (!sr.EndOfStream)
        {
            string[] data = sr.ReadLine().Split(" ", StringSplitOptions.TrimEntries | StringSplitOptions.RemoveEmptyEntries);
            Fisher f = new Fisher(data[0]); 
            for(int i = 1; i < data.Length; i += 4)
            {
                f.AddCatch(data.Skip(i).Take(4).ToArray());
            }
            Console.WriteLine(f);
        }

        sr.Close();
        fs.Close();
    }

    
}
