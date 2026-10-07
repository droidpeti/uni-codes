using System;
using System.Collections.Generic;
using System.Text;

namespace DocuStatView.Persistence
{
    public class TxtFileManager : IFileManager
    {
        private readonly string _path;
        public TxtFileManager(string path)
        {
            _path = path;
        }
        public string Load()
        {
            try
            {
                return File.ReadAllText(_path);
            }
            catch (Exception ex)
            {
                throw new FileManagerException(ex.Message, ex);
            }
        }
    }
}
