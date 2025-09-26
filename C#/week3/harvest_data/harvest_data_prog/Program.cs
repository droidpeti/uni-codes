namespace harvest_data_prog;

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

        double[] harvestdata = new double[count];

        for (int i = 0; i < count; i++)
        {
            System.Console.Write("Next data: ");

            double data = 0;

            while (!double.TryParse(Console.ReadLine(), out data))
            {
                System.Console.Write("Incorrect input!");
            }

            harvestdata[i] = data;
        }

        double harvestsum = 0;

        for (int i = 0; i < count; i++)
        {
            harvestsum += harvestdata[i];
        }

        System.Console.WriteLine("Sum: " + harvestsum);
    }
}
