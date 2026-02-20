namespace masodik;

internal class Notebook
{
    public class BadIndex : Exception
    {
        public BadIndex(string mess) : base (mess)
        {
            
        }
    }
    public int PageCount {get; set;}
    public Type NotebookType {get; set;}
    public enum Type
    {
        Line,
        Square,
        Blank
    }

    public Notebook(int c, Type t)
    {
        PageCount = c;
        NotebookType = t;
        blankPageCount = PageCount;
        contents = new List<string>();
        for(int i = 0; i < c; i++)
        {
            contents.Add("");
        }
    }

    private int blankPageCount;
    public int BlankPageCount
    {
        get
        {
            return blankPageCount;
        }
    }

    public List<string> contents;

    public void Fill(int page, string text)
    {
        if (page < 1 || page < PageCount)
        {
            throw new BadIndex("Error :P");
        }
        contents[page - 1] = text;

    }

    public int GetFirstBlankId()
    {
        for(int i = 0; i < contents.Count; i++)
        {
            if(contents[i] == "")
            {
                return i;
            }
        }
        return -1;
    }
}
