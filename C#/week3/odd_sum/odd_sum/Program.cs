namespace odd_sum;

class Program
{
    static void Main(string[] args)
    {
        uint n = 0;
        Console.Write("Input a Natural number: ");
        while (!uint.TryParse(Console.ReadLine(), out n))
        {
            Console.WriteLine("Incorrect input!");
        }

        uint res = 0;

        for (uint i = 1; i <= n; i++)
        {
            if (i % 2 == 1)
            {
                res += i;
            }
        }
        System.Console.WriteLine("Az eredmény: " + res);
    }
}
