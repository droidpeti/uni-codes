namespace cold_days_prog;

class Program
{
    static void Main(string[] args)
    {
        int count = 0;
        Console.Write("Input the length of the array: ");
        while (!int.TryParse(Console.ReadLine(), out count) || count <= 0)
        {
            Console.Write("Incorrect input! Please enter a positive integer: ");
        }

        double[] tempData = new double[count];

        for (int i = 0; i < count; i++)
        {
            Console.Write($"Next data ({i + 1}/{count}): ");

            double data;
            while (!double.TryParse(Console.ReadLine(), out data))
            {
                Console.Write("Incorrect input! Please enter a number: ");
            }
            tempData[i] = data;
        }

        double minTemp = tempData.Min();
        int minTempCount = tempData.Count(t => t == minTemp);

        double minPercent = (double)minTempCount / count * 100;

        Console.WriteLine($"The lowest temperature was: {minTemp}, it's occurrence is: {minPercent:F2}%");
    }
}