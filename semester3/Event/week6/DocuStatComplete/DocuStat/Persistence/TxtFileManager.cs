using System;
using System.IO;
using System.Threading.Tasks;

namespace ELTE.DocuStat.Persistence
{
    public class TxtFileManager : IFileManager
    {
        private readonly string _path;

        public TxtFileManager(string path)
        {
            _path = path;
        }

        public async Task<string> LoadAsync()
        {
            try
            {
                return await File.ReadAllTextAsync(_path);
            }
            catch (Exception ex)
            {
                throw new FileManagerException("Error during reading TXT file: " + ex.Message, ex);
            }
        }
    }
}
