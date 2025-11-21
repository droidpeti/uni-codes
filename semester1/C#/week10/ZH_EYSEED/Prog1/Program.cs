namespace Prog1;

class Program
{
    static void Main(string[] args)
    {
        int count;
        do
        {
            System.Console.Write("Please input how many days there will be: ");
        }while(!Int32.TryParse(Console.ReadLine(), out count) || count < 0);

        int[] steps = new int[count];
        int sum = 0;

        for(int i = 0; i < count; i++)
        {
            do
            {
                System.Console.Write($"Please enter the amount of steps for day#{i+1}: ");
            }while(!Int32.TryParse(Console.ReadLine(), out steps[i]) || steps[i] < 0);

            sum += steps[i];
        }

        int min = steps[0];

        for(int i = 0; i < count; i++)
        {
            if(min > steps[i])
            {
                min = steps[i];
            }
        }

        System.Console.WriteLine($"On average you stepped {sum/count} times a day\nThe minimum amount of steps was {min}");
    }
}
