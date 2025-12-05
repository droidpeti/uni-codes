namespace _2d_arr;

class Program
{
    static void Main(string[] args)
    {
        int [][] matrix = new int [3][];
        for(int i = 0; i < matrix.Length; i++)
        {
            matrix[i] = new int[3];
        }

        for(int i = 0; i < matrix.Length; i++)
        {
            for(int j = 0; j < matrix[i].Length; j++)
            {
                matrix[i][j] = i * matrix.Length + j + 1;
            }
        }

        string r = "";

        for(int i = 0; i < matrix.Length; i++)
        {
            for(int j = 0; j < matrix[i].Length; j++)
            {
                r += matrix[i][j] + " ";
                matrix[i][j] = i * matrix.Length + j + 1;
            }
        }
        System.Console.WriteLine(r);
    }
}
