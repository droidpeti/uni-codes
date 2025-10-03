namespace _3dvector_addition;

class Program
{
    private struct Vector3D
    {
        public double X;
        public double Y;
        public double Z;

        public override string ToString()
        {
            return $"X: {X} Y: {Y} Z: {Z}";
        }

        public static Vector3D VectorAddition(List<Vector3D> vectors)
        {
            Vector3D res = new Vector3D { X = 0, Y = 0, Z = 0 };
            foreach (Vector3D v in vectors)
            {
                res.X += v.X;
                res.Y += v.Y;
                res.Z += v.Z;
            }
            return res;
        }

        public void Input()
        {
            string[] input;
            bool ok = false;
            do
            {
                System.Console.Write("Please input 3 numbers for a 3D vector (X Y Z): ");
                input = Console.ReadLine().Split(" ");
                if (input.Length != 3)
                {
                    ok = false;
                }
                foreach (string s in input)
                {
                    try
                    {
                        Double.Parse(s);
                    }
                    catch
                    {
                        ok = false;
                        continue;
                    }
                    ok = true;
                }
                if (!ok)
                {
                    System.Console.WriteLine($"Invalid input!");
                }
            } while (!ok);
            X = double.Parse(input[0]);
            Y = double.Parse(input[1]);
            Z = double.Parse(input[2]);
        }
    }
    static void Main(string[] args)
    {
        Vector3D v1 = new Vector3D();
        Vector3D v2 = new Vector3D();
        v1.Input();
        v2.Input();
        Vector3D v3 = Vector3D.VectorAddition(new List<Vector3D> { v1, v2 });
        System.Console.WriteLine($"Result: {v3}");
    }
}
