namespace Hello_world
{
    internal class Program
    {
        static void Main(string[] args)
        {
            int width;
            int height;
            string title;
            Console.Write("Please input the height of the rectangle: ");
            Int32.TryParse(Console.ReadLine(), out height);
            Console.Write("Please input the width of the rectangle: ");
            Int32.TryParse(Console.ReadLine(), out width);
            if (height <= 0)
            {
                height = 20;
            }
            if (width <= 0)
            {
                width = 20;
            }
            Console.Write("Please input the title you want to display: ");
            title = Console.ReadLine();
            Rectangle rect = new Rectangle { width = width, height=height, title=title };
            rect.Draw();
            Console.ReadLine();
        }
    }

    public class Rectangle()
    {
        public int width { get; set; }
        public int height { get; set; }
        public string title { get; set; }

        public void Draw()
        {
            Console.Clear();
            for (int i = 0; i < height; i++)
            {
                if (i == 0)
                {
                    Console.Write("╔");
                    for (int k = 0; k < width - 2; k++)
                        Console.Write("=");
                    Console.WriteLine("╗");
                }
                else if (i == height - 1)
                {
                    Console.Write("╚");
                    for (int k = 0; k < width - 2; k++)
                        Console.Write("=");
                    Console.WriteLine("╝");
                }
                else
                {
                    Console.Write("|");
                    for (int k = 0; k < width - 2; k++)
                        Console.Write(" ");
                    Console.WriteLine("|");
                }
            }
            int y = (height / 2);
            int x = (width / 2) - (title.Length/2);
            Console.SetCursorPosition(x, y);
            Console.Write(title);
        }
    }
}
