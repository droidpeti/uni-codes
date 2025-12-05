namespace Matrix;

class Program
{
    static void Main(string[] args)
    {
        int [,] matrix = new int[3,3];

        for(int i = 0; i < matrix.GetLength(0); i++)
        {
           for(int j = 0; j < matrix.GetLength(1); j++)
            {
                matrix[i,j] = matrix.GetLength(0) * i + j + 1;
            } 
        }

        for(int i = 0; i < matrix.GetLength(0); i++)
        {
            string r = "";
            for(int j = 0; j < matrix.GetLength(1); j++)
            {
                r += matrix[i,j] + " ";
            }
            System.Console.WriteLine(r);
        }
    }
}
