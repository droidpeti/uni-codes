namespace ZH2;

class Program
{
    static void Main(string[] args)
    {
        Console.Write("Please input a decimal number representing the starting value: ");
        double start = Convert.ToDouble(Console.ReadLine());

        Console.Write("Please input a decimal number representing where we stop: ");
        double end = Convert.ToDouble(Console.ReadLine());

        Console.Write("Please input a decimal number representing the size of the steps we take: ");
        double step = Convert.ToDouble(Console.ReadLine());

        for(double i = start; i <= end; i+=step)
        {
            Console.WriteLine($"{i}^2 = {i*i}");
        }
    }
}
