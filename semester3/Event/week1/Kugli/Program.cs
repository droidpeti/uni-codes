namespace Kugli;

class Program
{
    static int ReadPositive(string message)
    {
        bool success = false;
        int number = 0;
        while (!success)
        {
            Console.Write(message);
            success = int.TryParse(Console.ReadLine(), out number);
            if(number < 1)
            {
                success = false;
            }
        }
        return number;
    }
    static int Main(string[] args)
    {
        Console.Write("Please Enter a file path: ");
        string fileName = Console.ReadLine();
        if (!System.IO.File.Exists(fileName))
        {
            System.Console.WriteLine("File Doesn't exist!");
            return -1;
        }
        DocumentStatistics ds = new DocumentStatistics(fileName);
        try
        {
            ds.Load();
        }
        catch(System.IO.IOException e)
        {
            System.Console.WriteLine(e.Message);
            return -1;
        }
        ds.ComputeDistinctWords();

        var pairs = ds.DistinctWordCount.OrderByDescending(p => p.Value);

        foreach (var pair in pairs)
        {
            Console.WriteLine($"{pair.Key}: {pair.Value}");
        }

        int minOccurrence;
        int minLength;

        minOccurrence = ReadPositive("Enter the minimum occurence number: ");
        minLength = ReadPositive("Enter the minimum length number: ");

        pairs = ds.DistinctWordCount
            .Where(p => p.Value >= minOccurrence)
            .Where(p => p.Key.Length >= minLength)
            .OrderByDescending(p => p.Value);

        Console.Write("Enter ignored words by splitting them with ,: ");
        List<string> ignoredWords = Console.ReadLine().Split(",").ToList();

        pairs = ds.DistinctWordCount
            .Where(p => p.Value >= minOccurrence)
            .Where(p => p.Key.Length >= minLength)
            .Where(p => !ignoredWords.Contains(p.Key))
            .OrderByDescending(p => p.Value);

        return 0;
    }
}
