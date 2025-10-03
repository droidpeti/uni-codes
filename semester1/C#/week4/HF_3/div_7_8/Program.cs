namespace div_7_8;

class Program
{
    static void Main(string[] args)
    {
        int num1;
        int num2;

        do
        {
            System.Console.Write("Please input an integer: ");
        } while (!Int32.TryParse(Console.ReadLine(), out num1));

        do
        {
            System.Console.Write("Please input the second integer: ");
        } while (!Int32.TryParse(Console.ReadLine(), out num2));

        for (int i = Math.Min(num1, num2); i <= Math.Max(num1, num2); i++)
        {
            if (i % 7 == 0)
            {
                System.Console.WriteLine($"{i} is divisible by 7 ");
            }
            if (i % 8 == 0)
            {
                System.Console.WriteLine($"{i} is divisible by 8 ");
            }
        }
    }
}
