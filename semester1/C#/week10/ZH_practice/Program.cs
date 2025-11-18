namespace ZH_practice;

class Program
{
    public struct Day
    {
        public double max_temp;
        public double min_temp;

        public bool isFreezing()
        {
            return max_temp <= 0 || min_temp <= 0;
        }
    }
    static void part1()
    {
        int count;
        do
        {
            System.Console.Write("Please input how many days there will be: ");
        }while(!Int32.TryParse(Console.ReadLine(), out count) || count < 0);

        Day[] days = new Day[count];
        int freezing_count = 0;
        for(int i = 0; i < count; i++)
        {
            do
            {
                System.Console.Write($"Please enter the minimum temperature of day #{i+1}: ");
            }while(!Double.TryParse(Console.ReadLine(), out days[i].min_temp));
            
            do
            {
                System.Console.Write($"Please enter the maximum temperature of day #{i+1}: ");
            }while(!Double.TryParse(Console.ReadLine(), out days[i].max_temp));

            if (days[i].isFreezing())
            {
                freezing_count++;
            }
        }

        System.Console.WriteLine($"The amount of freezing days is: {freezing_count}");
    }

    static void part2()
    {
        
    }
    static void Main(string[] args)
    {
        part1();
    }
}
