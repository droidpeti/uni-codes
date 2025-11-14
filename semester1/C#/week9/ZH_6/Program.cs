namespace ZH_6;

class Program
{
    static void Main(string[] args)
    {
        Console.Write("Please input the starting number: ");
        double start;
        Double.TryParse(Console.ReadLine(), out start);

        Console.Write("Please input the number where we stop: ");
        double stop;
        Double.TryParse(Console.ReadLine(), out stop);

        Console.Write("Please input the number we step by each time: ");
        double step;
        Double.TryParse(Console.ReadLine(), out step);

        for(double i = start; i <= stop; i += step)
        {
            System.Console.WriteLine($"{i}^2 = {i*i}");
        }
    }
}
