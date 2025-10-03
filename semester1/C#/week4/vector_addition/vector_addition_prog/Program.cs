namespace vector_addition_prog;

class Program
{
    private struct Vector()
    {
        public double X;
        public double Y;

        public void input()
        {
            Console.WriteLine("Input a vector: (x y)");
            string s = Console.ReadLine();
            string[] array = s.Split(' ');
            if (array.Length != 2)
            {
                return;
            }

            X = double.Parse(array[0]);
            Y = double.Parse(array[1]);
        }

        public override string ToString()
        {
            return $"X: {X} Y: {Y}";
        }  
    }

    static void Main(string[] args)
    {
        Vector v1 = new Vector();
        Vector v2 = new Vector();
        v1.input();
        v2.input();

        Vector res = new Vector();
        res.X = v1.X + v2.X;
        res.Y = v1.Y + v2.Y;

        System.Console.WriteLine($"Result: {res}");
        
    }
}
