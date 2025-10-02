namespace triangle;

class Program
{
    static void Main(string[] args)
    {
        int[] sides = new int[3];

        for (int i = 0; i < sides.Length; i++)
        {
            bool ok = false;
            Console.Write($"Please input the length of side number {i + 1}: ");
            do
            {
                ok = Int32.TryParse(Console.ReadLine(), out sides[i]);
                if (!ok || sides[i] <= 0)
                {
                    Console.Write("Invalid input!\nPlease enter a whole, positive number: ");
                }
            } while (!ok || sides[i] <= 0);
        }

        if (sides[0] * sides[0] == sides[1] * sides[1] + sides[2] * sides[2] ||
            sides[1] * sides[1] == sides[0] * sides[0] + sides[2] * sides[2] ||
            sides[2] * sides[2] == sides[1] * sides[1] + sides[0] * sides[0])
        {
            Console.WriteLine("This is a right-angled triangle!");
        }
        else
        {
            Console.WriteLine("This isn't a right-angled triangle!");
        }
    }
}
