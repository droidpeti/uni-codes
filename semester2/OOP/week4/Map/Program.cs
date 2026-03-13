namespace Map;

internal class Program
{
    static void Main(string[] args)
    {
        Dictionary<int, string> dict = new Dictionary<int, string>();
        dict[3] = "apple";

        int[] t = [1,3,2,3];
        Dictionary<int,int> count = new Dictionary<int, int>();

        foreach(int num in t)
        {
            if (count.ContainsKey(num))
            {
                count[num]++;
                continue;
            }
            count[num] = 1;
        }

        foreach(var item in count)
        {
            //Console.WriteLine($"{item.Key}:{item.Value}");
            Console.WriteLine(item);
        }

        // Map

        MyMap map = new MyMap();
        map.Insert(1, "one");
        Console.WriteLine(map);
        Console.WriteLine(map[1]);
        map.Remove(1);
        Console.WriteLine(map.Count());

        // Unit test



    }
}
