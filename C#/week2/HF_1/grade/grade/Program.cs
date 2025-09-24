namespace grade;

class Program
{
    static void Main(string[] args)
    {
        Console.Write("Please input your points (0-100): ");
        double points;
        bool ok;
        do
        {
            ok = Double.TryParse(Console.ReadLine(), out points);
            if (!ok || (points > 100 || points < 0))
            {
                Console.Write("Invalid Input!\nPlease input a number between 0 and 100: ");
            }
        } while (!ok || (points > 100 || points < 0));

        if (points >= 0 && points < 20)
        {
            Console.WriteLine("Your grade is: 1");
        }
        else if (points >= 20 && points < 40)
        {
            Console.WriteLine("Your grade is: 2");
        }
        else if (points >= 40 && points < 60)
        {
            Console.WriteLine("Your grade is: 3");
        }
        else if (points >= 60 && points < 80)
        {
            Console.WriteLine("Your grade is: 4");
        }
        else
        {
            Console.WriteLine("Your grade is: 5");
        }
    }
}
