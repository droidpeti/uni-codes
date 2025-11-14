namespace LibraryBooks;

class Program
{
    struct Book
    {
        public string Author;
        public string Title;
        public int Count;
        public int RentCount;
    }

    static Book[] ReadArray()
    {
        int n = 0;
        int.TryParse(Console.ReadLine(), out n);
        Book[] books = new Book[n];

        for(int i = 0; i < n; i++)
        {
            Book b = new Book();
            b.Author = Console.ReadLine();
            b.Title = Console.ReadLine();
            b.Count = int.Parse(Console.ReadLine());
            b.RentCount = int.Parse(Console.ReadLine());

            books[i] = b;
        }

        return books;
    }

    static List<Book> ReadList()
    {
        int n = 0;
        int.TryParse(Console.ReadLine(), out n);
        List<Book> books = new List<Book>();

        for(int i = 0; i < n; i++)
        {
            Book b = new Book();
            b.Author = Console.ReadLine();
            b.Title = Console.ReadLine();
            b.Count = int.Parse(Console.ReadLine());
            b.RentCount = int.Parse(Console.ReadLine());

            books.Add(b);
        }

        return books;
    }

    static void ReadArrayOut(out Book[] books)
    {
        int n = 0;
        int.TryParse(Console.ReadLine(), out n);
        books = new Book[n];

        for(int i = 0; i < n; i++)
        {
            Book b = new Book();
            b.Author = Console.ReadLine();
            b.Title = Console.ReadLine();
            b.Count = int.Parse(Console.ReadLine());
            b.RentCount = int.Parse(Console.ReadLine());

            books[i] = b;
        }
    }

    static List<Book> FilterBooksArrayList(Book[] books)
    {
        List<Book> filtered = new List<Book>();

        for(int i = 0; i < books.Length; i++)
        {
            if(books[i].Count - books[i].RentCount <= 2)
            {
                filtered.Add(books[i]);
            }
        }

        return filtered;
    }

    static List<Book> FilterBooksListList(List<Book> books)
    {
        List<Book> filtered = new List<Book>();

        for(int i = 0; i < books.Count; i++)
        {
            if(books[i].Count - books[i].RentCount <= 2)
            {
                filtered.Add(books[i]);
            }
        }

        return filtered;
    }

    static Book[] BookAppend(Book[] books, Book book)
    {
        Book[] n = new Book[books.Length+1];

        for(int i = 0; i < books.Length; i++)
        {
            n[i] = books[i];
        }

        n[n.Length-1] = book;

        return n;
    }

    static Book[] FilterBooksArrayArray(Book[] books)
    {
        Book[] filtered = new Book[0];

        for(int i = 0; i < books.Length; i++)
        {
            if(books[i].Count - books[i].RentCount <= 2)
            {
                filtered = BookAppend(filtered, books[i]);
            }
        }

        return filtered;
    }

    static void FilterBooksArrayListOut(Book[] books, out List<Book> filtered)
    {
        filtered = new List<Book>();

        for(int i = 0; i < books.Length; i++)
        {
            if(books[i].Count - books[i].RentCount <= 2)
            {
                filtered.Add(books[i]);
            }
        }
    }

    static void WriteList(List<Book> books)
    {
        for(int i = 0; i < books.Count; i++)
        {
            System.Console.WriteLine(books[i].Title);
        }
    }

    static void WriteArray(Book[] books)
    {
        for(int i = 0; i < books.Length; i++)
        {
            System.Console.WriteLine(books[i].Title);
        }
    }

    static void Main(string[] args)
    {
        // V1
        /*
        Book[] books = ReadArray();
        List<Book> filtered = FilterBooksArrayList(books);
        WriteList(filtered);
        */

        // V2
        /*
        List<Book> books = ReadList();
        List<Book> filtered = FilterBooksListList(books);
        WriteList(filtered);
        */

        // V3
        /*
        Book[] books = ReadArray();
        Book[] filtered = FilterBooksArrayArray(books);
        WriteArray(filtered);
        */

        //V4
        Book[] books = new Book[0];
        ReadArrayOut(out books);
        List<Book> filtered;
        FilterBooksArrayListOut(books, out filtered);
        WriteList(filtered);
    }
}
