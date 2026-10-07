using DocuStatView.Persistence;
using feladat.Persistence;
using Microsoft.Extensions.DependencyInjection;

namespace feladat;

class Program
{
    static int Main(string[] args)
    {
        string filePath;
        IFileManager fileManager = null;
        do {
            System.Console.WriteLine("Add meg az elérési útvonalat: ");
            filePath = Console.ReadLine();
            //System.IO.Path.GetExtension(filePath);
        }while(!System.IO.File.Exists(filePath));

        fileManager = FileManagerFactory.CreateForPath(filePath);

        ServiceCollection services = new ServiceCollection();
        services.AddSingleton<IDocumentStatistics, DocumentStatistics>();
        services.AddSingleton<IFileManager>(fileManager);

        using ServiceProvider serviceProvider = services.BuildServiceProvider();

        IDocumentStatistics stat = serviceProvider.GetRequiredService<IDocumentStatistics>();
        try
        {
            stat.Load();
        }
        catch(Exception ex){
            System.Console.WriteLine($"Hiba: {ex.Message}");
            return -1;
        }

        int minOccurrence = ReadPositive("Add meg a min. előfordulást: ");
        int minLength = ReadPositive("Add meg a min. szó hosszot: ");
        Console.Write("Add meg a kizárt szavakat (szó,szó): ");
        string[] ignoredWords = Console.ReadLine().Split(',');

        stat.ComputeDistinctWords();
        var pairs = stat.GetDistinctWordCount()
            .Where(p => p.Value >= minOccurrence)
            .Where(p => p.Key.Length >= minLength)
            .Where(p => !ignoredWords.Contains(p.Key))
            .OrderByDescending(p => p.Value);
        foreach (var pair in pairs)
        {
            Console.WriteLine($"{pair.Key}: {pair.Value}");
        }

        return 0;   
    }

    static int ReadPositive(string message){
        while (true){
            System.Console.Write(message);
            if (int.TryParse(Console.ReadLine(), out int b)){
                return b;
            }
        }

    }
}
