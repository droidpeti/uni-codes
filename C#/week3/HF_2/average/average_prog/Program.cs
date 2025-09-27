namespace average_prog;

class Program
{
    static void Main(string[] args)
    {
        int count = 0;
        System.Console.Write("Input the length of the array: ");
        while (!int.TryParse(Console.ReadLine(), out count))
        {
            System.Console.Write("Incorrect input! ");
        }

        double[] numbers = new double[count];

        for (int i = 0; i < count; i++)
        {
            System.Console.Write("Next data: ");

            double data = 0;

            while (!double.TryParse(Console.ReadLine(), out data))
            {
                System.Console.Write("Incorrect input!");
            }
            numbers[i] = data;
        }

        double upperLimit;
        System.Console.Write("Input the upper limit: ");
        while (!double.TryParse(Console.ReadLine(), out upperLimit))
        {
            System.Console.Write("Incorrect input! ");
        }

        double sum = 0;
        int count2 = 0;

        foreach (double num in numbers)
        {
            if (num < upperLimit)
            {
                count2++;
                sum += num;
            }
        }

        if (count2 != 0)
        {
            System.Console.WriteLine("The average of the numbers under the upper limit: " + (sum / count2));
        }
        else
        {
            System.Console.WriteLine("There were no numbers smaller than the upper limit");
        }
        
    }
}
