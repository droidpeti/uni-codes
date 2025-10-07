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

        int frozenDaysCount = data.Where(d => d > 0).Count();

        System.Console.WriteLine(frozenDaysCount);        
    }
}
