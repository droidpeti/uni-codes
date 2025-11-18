using System;

namespace lasting_freeze
{
    class Program
    {
        static void Main(string[] args)
        {
            string line = Console.ReadLine();

            int count = Int32.Parse(line.Split(' ')[0]);
            int k = Int32.Parse(line.Split(' ')[1]);

            int streak_start = -1;
            int streak_end = -1;
            int current_streak_length = 0; 

            bool found = false; 
            int final_start = -1;
            int final_end = -1;

            for(int i = 0; i < count; i++)
            {
                line = Console.ReadLine();
                if (line == null) {
                    break; 
                }

                string[] parts = line.Split(' ');
                int max_temp = Int32.Parse(parts[1]); 

                if(max_temp <= 0)
                {
                    if (current_streak_length == 0)
                    {
                        streak_start = i;
                    }
                    current_streak_length++;
                    streak_end = i;

                    if(current_streak_length == k && !found)
                    {
                        final_start = streak_start;
                        final_end = streak_end;
                        found = true;
                    }
                }
                else
                {
                    current_streak_length = 0;
                    streak_start = -1;
                    streak_end = -1;
                }
            }

            if(found)
            {
                System.Console.WriteLine($"{final_start + 1} {final_end + 1}");
            }
            else
            {
                System.Console.WriteLine("-1");
            }
        }
    }
}