namespace profit_prog;

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

        int negativeYearCount = 0;

        for (int i = 0; i < count; i++)
        {
            System.Console.Write("Next data: ");

            double data = 0;

            while (!double.TryParse(Console.ReadLine(), out data))
            {
                System.Console.Write("Incorrect input!");
            }
            if (data < 0)
            {
                negativeYearCount++;
            }

        }
        
        System.Console.WriteLine("Number of years where you lost money: " + negativeYearCount);
    }
}
