using System;
using System.Collections.Generic;

namespace town_temps_non_freezing
{
    class Program
    {
        static void Main(string[] args)
        {
            string line = Console.ReadLine();
            if (string.IsNullOrEmpty(line)) return;

            string[] parts = line.Split(' ');
            int N = int.Parse(parts[0]);
            int M = int.Parse(parts[1]);
            List<int> goodTowns = new List<int>();

            for (int i = 0; i < N; i++)
            {
                string rowInput = Console.ReadLine();
                string[] temps = rowInput.Split(' ');

                bool allPositive = true;

                for (int j = 0; j < M; j++)
                {
                    int temp = int.Parse(temps[j]);
                    
                    if (temp <= 0)
                    {
                        allPositive = false;
                        break;
                    }
                }

                if (allPositive)
                {
                    goodTowns.Add(i + 1); 
                }
            }

            Console.Write($"{goodTowns.Count} ");

            for(int i = 0; i < goodTowns.Count; i++)
            {
                Console.Write($"{goodTowns[i]} ");
            }
        }
    }
}
