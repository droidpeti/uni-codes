namespace HF_5;

class Program
{
    static void Main(string[] args)
    {
        uint count;
        while (true)
        {
            Console.Write("Please input the amount of numbers you want to input ( > 0 ): ");
            UInt32.TryParse(Console.ReadLine(), out count);
            if (count > 0)
            {
                break;
            }
            Console.WriteLine("Invalid input!");
        }

        double[] numbers = new double[count];

        for (uint i = 0; i < count; i++)
        {
            double num;
            while (true)
            {

                Console.Write($"Please input number {i + 1} ( > 0 ) : ");
                Double.TryParse(Console.ReadLine(), out num);
                if (num > 0)
                {
                    break;
                }
                Console.WriteLine("Invalid input!");
            }
            numbers[i] = num;
        }
        
        foreach(double d in numbers)
        {
            System.Console.WriteLine($"3 x {d} = {Math.Round(3*d, 2)}");
        }
    }
}
