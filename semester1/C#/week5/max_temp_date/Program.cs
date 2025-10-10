namespace max_temp_date;

class Program
{
    public struct TempData
    {
        public double temp;
        public string date;

        public override string ToString()
        {
            return $"{temp} - {date}";
        }
    }
    static void Main(string[] args)
    {
        Console.WriteLine("Please input temperature - date (YYYY-mm-dd) pairs!");

        List<TempData> tempDatas = new List<TempData>();

        while (true)
        {
            System.Console.Write("Please input the next temperature - date (YYYY-mm-dd) pair in this format (15 2024-01-01) : ");
            string input = Console.ReadLine();

            if (input == "")
            {
                break;
            }
            string[] tempData = input.Split(' ');

            if (tempData.Length != 2)
            {
                System.Console.WriteLine("Invalid input!");
                continue;
            }

            double temp = 0;
            if (!double.TryParse(tempData[0], out temp))
            {
                System.Console.WriteLine("Invalid input!");
                continue;
            }

            if(temp < -273.15)
            {
                System.Console.WriteLine("Invalid input!");
                continue;
            }

            tempDatas.Add(new TempData
            {
                temp = temp,
                date = tempData[1]
            }
            );
        }

        if (tempDatas.Count == 0)
        {
            System.Console.WriteLine("No data!");
            return;
        }

        double maxTemp = tempDatas.Select(t => t.temp).Max();
        TempData maxTempStruct = tempDatas.Where(t => t.temp == maxTemp).Select(t => t).FirstOrDefault();
        
        System.Console.WriteLine($"Warmest Date is: {maxTempStruct}");
    }
}
