class Program
{
    static void Main(string[] args)
    {
        bool running = true;
        CinemaManager manager = CinemaManager.Instance;

        while (running)
        {
            Console.WriteLine("\n--- Cinema Booking System ---");
            Console.WriteLine("1. Load Data from file");
            Console.WriteLine("2. Show most watched film");
            Console.WriteLine("3. Show seat statistics for a show");
            Console.WriteLine("4. Exit");
            Console.Write("Select an option: ");

            string choice = Console.ReadLine();

            if (choice == "1")
            {
                try
                {
                    manager.LoadData("data.txt");
                    Console.WriteLine("Data loaded successfully.");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Error loading data: " + ex.Message);
                }
            }
            else if (choice == "2")
            {
                if (manager.Shows.Count == 0) Console.WriteLine("Please load data first.");
                else manager.PrintMostWatchedFilm();
            }
            else if (choice == "3")
            {
                if (manager.Shows.Count == 0)
                {
                    Console.WriteLine("Please load data first.");
                    continue;
                }
                Console.Write("Enter Show ID (e.g., Show1, Show2, Show3): ");
                string showId = Console.ReadLine();
                Show foundShow = null;
                foreach (Show s in manager.Shows)
                {
                    if (s.Id == showId)
                    {
                        foundShow = s;
                        break;
                    }
                }
                if (foundShow != null)
                {
                    Console.WriteLine("Show: " + foundShow.FilmName);
                    Console.WriteLine("Free: " + foundShow.GetFreeCount());
                    Console.WriteLine("Booked: " + foundShow.GetBookedCount());
                    Console.WriteLine("Sold: " + foundShow.GetSoldCount());
                }
                else
                {
                    Console.WriteLine("Show not found.");
                }
            }
            else if (choice == "4")
            {
                running = false;
            }
        }
    }
}
