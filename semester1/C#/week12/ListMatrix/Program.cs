using System.Collections.Generic;

namespace ListMatrix;

class Program
{
    static void Main(string[] args)
    {
        List<List<int>> matrix;
        matrix = new List<List<int>>();

        for(int i = 0; i < 3; i++)
        {
            List<int> l = new List<int>();

            for(int j = 0; j < 3; j++)
            {
                l.Add(i*matrix.Count + j + 1);
            }
            matrix.Add(l);
        }

        for(int i = 0; i < 3; i++)
        {
            string r = "";
            for(int j = 0; j < 3; j++)
            {
                r += matrix[i][j] + " ";
            }
            System.Console.WriteLine(r);
        }
    }
}
