using DocuStatView.Persistence;
using System;
using System.Collections.Generic;
using System.Text;

namespace feladat.Persistence
{
    public static class FileManagerFactory
    {
        public static IFileManager? CreateForPath(string path)
        => Path.GetExtension(path).ToLowerInvariant() switch
        {
            ".txt" => new TxtFileManager(path),
            ".pdf" => new PdfFileManager(path),
            _ => null
        };
    }
}
