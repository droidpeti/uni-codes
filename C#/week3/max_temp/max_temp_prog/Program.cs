namespace max_temp_prog;

class Program
{
    static void Main(string[] args)
    {
        uint length = 0;

        Console.Write("How much will the length of the array be: ");
        while (!uint.TryParse(Console.ReadLine(), out length))
        {
            System.Console.Write("Incorrect input: ");
        }

        if (length == 0)
        {
            return;
        }

        double[] tempdata = new double[length];

        for (int i = 0; i < length; i++)
        {
            System.Console.Write("Next data: ");

            double data = 0;
            while (!double.TryParse(Console.ReadLine(), out data))
            {
                System.Console.Write("Incorrect input: ");
            }

            tempdata[i] = data;
        }

        int maxindex = 0;
        double maxtemp = tempdata[0];

        for (int i = 1; i < length; i++)
        {
            if (tempdata[i] > maxtemp)
            {
                maxindex = i;
                maxtemp = tempdata[i];
            }
        }

        System.Console.WriteLine("Highest temperature: " + maxtemp);
    }
}
