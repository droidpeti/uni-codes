using DocuStatView.Persistence;

namespace feladat;

public class DocumentStatistics: IDocumentStatistics {
    private readonly IFileManager _fileManager;
    public string FileContent {get; private set;}
    public Dictionary<string, int> DistinctWordCount {get; private set;}

    public event EventHandler? FileContentReady;
    public event EventHandler? TextStatisticsReady;

    public DocumentStatistics(IFileManager fileManager)
    {
        _fileManager = fileManager;
        DistinctWordCount = new Dictionary<string, int>();
    }

    public void Load(){
        FileContent = _fileManager.Load();
        OnFileContentReady();
    }

    public void ComputeDistinctWords(){
        string[] words = FileContent.Split();
        words = words.Where(s => s.Length > 0).ToArray();

        for (int i = 0; i < words.Length; i++){
            string.Concat(
            words[i]
            .SkipWhile(c => !char.IsLetter(c))
            .Reverse()
            .SkipWhile(c => !char.IsLetter(c))
            .Reverse()
            );

            if (String.IsNullOrEmpty(words[i])){
                continue;
            }
            string itemLowerCase = words[i].ToLower() ;
            if (DistinctWordCount.ContainsKey(itemLowerCase)){
                DistinctWordCount[itemLowerCase]++;
            }
            else{
                DistinctWordCount.Add(itemLowerCase, 1);
            }
        }
        OnTextStatisticsReady();
    }

    private void OnFileContentReady()
    {
        FileContentReady?.Invoke(this, EventArgs.Empty);
    }
    private void OnTextStatisticsReady()
    {
        TextStatisticsReady?.Invoke(this, EventArgs.Empty);
    }

    public Dictionary<string, int> GetDistinctWordCount()
    {
        return DistinctWordCount;
    }
}