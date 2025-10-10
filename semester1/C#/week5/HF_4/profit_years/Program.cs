namespace profit_years;

class Program
{
    public struct Year
    {
        public double profit;
        public int year;
        public override string ToString()
        {
            return $"For {year} the ptofit was {profit}";
        }
    }
    static void Main(string[] args)
    {
        Console.WriteLine("Please inputSplit Years and their profits (YYYY profit) ");

        List<Year> years = new List<Year>();

        while (true)
        {
            Console.Write("Please inputSplit the next year profit pair (YYYY profit): ");
            string input = Console.ReadLine();

            if (input == "")
            {
                break;
            }

            string[] inputSplit = input.Split(' ');

            if (inputSplit.Length != 2)
            {
                System.Console.WriteLine("Invalid Input!");
                continue;
            }

            int year;

            if (!Int32.TryParse(inputSplit[0], out year))
            {
                System.Console.WriteLine("Invalid Input!");
                continue;
            }

            double profit;
            if (!Double.TryParse(inputSplit[1], out profit))
            {
                System.Console.WriteLine("Invalid Input!");
                continue;
            }
            years.Add(new Year { year = year, profit = profit });


        }
        years = years.OrderBy(y => y.year).ToList();

        foreach (Year y in years)
        {
            if (y.profit < 0)
            {
                System.Console.WriteLine($"{y.year} was the first unprofitable year with a loss of: {y.profit}");
                return;
            }
        }
        System.Console.WriteLine("There were no unprofitable years!");
        
    }
}
