namespace elso;

class Program
{
    public class Point
    {
        public class DivZeroEx : Exception
        {
            
        };
        public int x;
        public int y;

        public override string ToString()
        {
            return $"x: {x}, y: {y}";
        }

        public Point()
        {
            count++;
        }

        public Point(int x, int y)
        {
            count++;
            this.x = x;
            this.y = y;
        }

        public double Distance(Point p)
        {
            return Math.Sqrt(Math.Pow((x - p.x),2) + Math.Pow((y - p.y),2));
        }

        // static
        public static int count = 0;

        public static Point operator *(Point point, double mult)
        {
            return new Point{x = point.x * (int)mult, y = point.y * (int)mult};
        }

        public static Point operator *(Point point1, Point point2)
        {
            return new Point{x = point1.x * point2.x, y = point1.y * point2.y};
        }

        public static Point operator /(Point point, double div)
        {
            if(div == 0)
            {
                throw new DivZeroEx();
            }
            return new Point{x = point.x / (int)div, y = point.y * (int)div};
        }

        public static Point operator /(Point point1, Point point2)
        {
            return new Point{x = point1.x * point2.x, y = point1.y * point2.y};
        }
    }
    static void Main(string[] args)
    {
        Console.WriteLine(Point.count);
        Point point1 = new Point();
        point1.x = 1;
        point1.y = 1;
        Point point2 = new Point(10, 20);
        Point point3 = new Point{x = 5, y = 3};
        Console.WriteLine(point1);
        Console.WriteLine(point2);
        Console.WriteLine(point3);
        double dist = point1.Distance(point2);
        Console.WriteLine(dist);
        Console.WriteLine(Math.Round(dist, 2));
        Console.WriteLine($"{dist:0.00}");
        Console.WriteLine(Point.count);
        Console.WriteLine(point1*2);
        Console.WriteLine(point1*point2);
    }
}
