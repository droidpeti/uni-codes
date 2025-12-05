namespace _1DArr;

class Program
{
    static void Main(string[] args)
    {
        int[] matrix = new int[3*3];

        for (int i = 0; i < 3*3; i++)
        {
            matrix[i] = i+1;
        }

        string r = "";
        for(int i = 0; i < 3*3; i++)
        {
            if(i % 3 == 0 && i != 0)
            {
                System.Console.WriteLine(r);
                r = "";
            }
            r += matrix[i] + " ";
        }

        System.Console.WriteLine(r);
        System.Console.WriteLine();

        for(int i = 0; i < 3; i++)
        {
            r = "";
            for(int j = 0; j < 3; j++)
            {
                r += matrix[i*3+j] + " ";
            }
            System.Console.WriteLine(r);
        }
    }
}
