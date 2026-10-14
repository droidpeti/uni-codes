using System;

namespace ELTE.DocuStat.Persistence
{
    public class FileManagerException : Exception
    {
        public FileManagerException(string message) : base(message) { }
        public FileManagerException(string message, Exception innerException) : base(message, innerException) { }
    }
}
