using System;

namespace frozen_lake;

class Program
{
    static void Main(string[] args)
    {
        int count = Int32.Parse(Console.ReadLine());
        int[] data = new int[count];
        for(int i = 0; i < count; i++){
            data[i] = Int32.Parse(Console.ReadLine());
        }

        int frozenDaysCount = 0;
        for (int i = 0; i < count; i++)
        {
            if (data[i] >= 0)
            {
                frozenDaysCount++;
            }
        }

        System.Console.WriteLine(frozenDaysCount);        
    }
}
