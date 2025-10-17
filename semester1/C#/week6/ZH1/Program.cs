namespace ZH1;

class Program
{
    static void Main(string[] args)
    {
        Console.Write("Please input the amount of numbers, you will input: ");
        int count = 0;
        Int32.TryParse(Console.ReadLine(), out count);

        double[] numbers = new double[count];
        for (int i = 0; i < count; i++)
        {
            Console.Write($"Please input number {i + 1}: ");
            Double.TryParse(Console.ReadLine(), out numbers[i]);
        }

        double min = numbers[0];

        for (int i = 1; i < count; i++)
        {
            if (numbers[i] < min)
            {
                min = numbers[i];
            }
        }
        
        System.Console.WriteLine($"The smallest number is: {min}");
    }
}
