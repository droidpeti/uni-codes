using System.IO;

namespace ELTE.DocuStat.Persistence
{
    public static class FileManagerFactory
    {
        public static IFileManager? CreateForPath(string path)
        {
            return Path.GetExtension(path).ToLower() switch
            {
                ".txt" => new TxtFileManager(path),
                ".pdf" => new PdfFileManager(path),
                _ => null
            };
        }
    }
}
