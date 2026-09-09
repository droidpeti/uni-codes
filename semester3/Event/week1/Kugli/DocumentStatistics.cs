using System;

namespace Kugli;


public class DocumentStatistics
{
    private string _filePath;
    public string FileContent { get; private set; }
    public Dictionary<string, int> DistinctWordCount;

    public DocumentStatistics(string fileName)
    {
        _filePath = fileName;
        DistinctWordCount = new Dictionary<string, int>();
    }

    public void Load()
    {
        FileContent = System.IO.File.ReadAllText(_filePath);
    }

    public void ComputeDistinctWords()
    {
        string[] words = FileContent.Split();
        words = words.Where(s => s.Length > 0).ToArray();

        for(int i = 0; i < words.Length; i++)
        {
            while (words[i].Length > 0 && !Char.IsLetter(words[i][0]))
            {
                words[i] = words[i].Remove(0, 1);
            }
            while (words[i].Length > 0 && !Char.IsLetter(words[i][1]))
            {
                words[i] = words[i].Remove(words[i].Length - 1, 1);
            }
            if (String.IsNullOrEmpty(words[i]))
            {
                continue;
            }
            words[i] = words[i].ToLower();
            if (DistinctWordCount.ContainsKey(words[i]))
            {
                DistinctWordCount[words[i]]++;
            }
            else
            {
                DistinctWordCount.Add(words[i], 1);
            }
        }
        
    }

    
}
