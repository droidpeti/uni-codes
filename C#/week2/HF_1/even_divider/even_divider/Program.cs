namespace even_dividers;

class Program
{
    static void Main(string[] args)
    {
        Console.Write("Please input a whole number, you want to get the even dividers of: ");
        int num;
        bool ok;
        do
        {
            ok = Int32.TryParse(Console.ReadLine(), out num);
            if (!ok || num <= 0)
            {
                Console.Write("Invalid Input!\nPlease input a whole positive number: ");
            }
        } while (!ok || num <= 0);

        for (int i = 1; i <= num; i++)
        {
            if (num % i == 0 && i % 2 == 0)
            {
                Console.WriteLine(i);
            }
        }
    }
}
