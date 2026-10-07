using DocuStatView.Persistence;
using iText.Kernel.Geom;
using iText.Kernel.Pdf;
using iText.Kernel.Pdf.Canvas.Parser;
using System;
using System.Collections.Generic;
using System.Text;

namespace feladat.Persistence
{
    public class PdfFileManager: IFileManager
    {
        private readonly string _path;
        public PdfFileManager(string path)
        {
            _path = path;
        }

        public string Load()
        {
            try
            {
                using PdfReader reader = new PdfReader(_path);
                using PdfDocument document = new PdfDocument(reader);
                StringBuilder text = new StringBuilder();
                for (int pageNumber = 1;
                pageNumber <= document.GetNumberOfPages();
                pageNumber++)
                {
                    PdfPage page = document.GetPage(pageNumber);
                    text.Append(PdfTextExtractor.GetTextFromPage(page));
                }
                return text.ToString();
            }
            catch (Exception ex)
            {
                throw new FileManagerException(ex.Message, ex);
            }
        }
    }
}
