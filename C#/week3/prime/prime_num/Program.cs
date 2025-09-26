namespace prime_num;

class Program
{
    static void Main(string[] args)
    {
        uint sz = 0;

        Console.Write("Input a whole positive number: ");
        while (!uint.TryParse(Console.ReadLine(), out sz) || sz < 2)
        {
            Console.Write("Not a correct input! Enter a whole, positive number: ");
        }

        bool prime = true;

        for (uint i = 2; i <= sz - 1; i++)
        {
            if (sz % i == 0)
            {
                prime = false;
                break;
            }
        }

        if (prime)
        {
            Console.WriteLine("Prime!");
        }
        else
        {
            Console.WriteLine("Not prime!");
        }

    }
}
