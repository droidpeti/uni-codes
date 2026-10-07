using System;
using System.Collections.Generic;
using System.Text;

namespace DocuStatView.Persistence
{
    public class FileManagerException : IOException
    {
        public FileManagerException() { }
        public FileManagerException(string message) : base(message) { }
        public FileManagerException(string message, Exception inner)
        : base(message, inner) { }
    }
}
