using System;
using System.Collections.Generic;
using System.Text;

namespace feladat
{
    public interface IDocumentStatistics
    {
        public event EventHandler? FileContentReady;
        public event EventHandler? TextStatisticsReady;

        public void Load();
        public void ComputeDistinctWords();

        public Dictionary<string, int> GetDistinctWordCount();
    }
}
