namespace masodik;

class Program
{
    static void Main(string[] args)
    {
        Notebook n = new Notebook(5, Notebook.Type.Line);
        Console.WriteLine($"Blank page count: {n.BlankPageCount}");
        try
        {
            n.Fill(1, "Test");
        } catch (Notebook.BadIndex e)
        {
            Console.WriteLine(e.Message);
        }
        System.Console.WriteLine(n.GetFirstBlankId()+1);
    }
}
