namespace CinemaApp;

public enum ViewerType { Child, Student, Adult, Pensioner, Regular }
public enum SeatState { Free, Booked, Sold }
public enum VenueCategory { Small, Large, VIP }

public abstract class Venue{
    public string Name {get; set;}
    public VenueCategory Category {get; set;}
    public int RowCount {get; set;}
    public int SeatsPerRow {get; set;}
    public abstract int GetDiscount(ViewerType viewer);
}

public class SmallVenue : Venue
{
    public SmallVenue()
    {
        Category = VenueCategory.Small;
    }

    public override int GetDiscount(ViewerType viewer)
    {
        switch (viewer)
        {
            case ViewerType.Child:
                return 40;
            case ViewerType.Student:
                return 30;
            case ViewerType.Adult:
                return 10;
            case ViewerType.Pensioner:
                return 30;
            case ViewerType.Regular:
                return 30;
            default:
                return 0;
        }
    }
}

public class LargeVenue : Venue
{
    public LargeVenue()
    {
        Category = VenueCategory.Large;
    }

    public override int GetDiscount(ViewerType viewer)
    {
        switch (viewer)
        {
            case ViewerType.Child:
                return 40;
            case ViewerType.Student:
                return 20;
            case ViewerType.Adult:
                return 0;
            case ViewerType.Pensioner:
                return 20;
            case ViewerType.Regular:
                return 30;
            default:
                return 0;
        }
    }
}

public class VipVenue : Venue
{
    public VipVenue()
    {
        Category = VenueCategory.VIP;
    }

    public override int GetDiscount(ViewerType viewer)
    {
        return 0;
    }
}

public class VenueFactory
{
    public static Venue CreateVenue(string category)
    {
        switch (category)
        {
            case "Small":
                return new SmallVenue();
            case "Large":
                return new LargeVenue();
            case "VIP":
                return new VipVenue();
            default:
                throw new Exception("Invalid Venue Category");
        }
    }
}

public class Seat
{
    public char Row {get; set;}
    public int Number {get; set;}
    public SeatState State {get; set;}

    public Seat(char row, int number)
    {
        Row = row;
        Number = number;
        State = SeatState.Free;
    }

    public void TransitionToBooked()
    {
        if (State == SeatState.Free)
        {
            State = SeatState.Booked;
        }
    }

    public void TransitionToSold()
    {
        if (State == SeatState.Free || State == SeatState.Booked)
        {
            State = SeatState.Sold;
        }
    }
}

public class Show
{
    public string Id {get; set;}
    public string FilmName {get; set;}
    public string Time {get; set;}
    public Venue ShowVenue {get; set;}
    public List<Seat> Seats {get; set;}
    public int BasePrice = 2000;

    public Show(string id, string filmName, string time, Venue showVenue)
    {
        Id = id;
        FilmName = filmName;
        Time = time;
        ShowVenue = showVenue;
        Seats = new List<Seat>();

        char currentRow = 'A';
        for (int i = 0; i < showVenue.RowCount; i++)
        {
            for (int j = 1; j <= showVenue.SeatsPerRow; j++)
            {
                Seats.Add(new Seat(currentRow, j));
            }
            currentRow++;
        }
    }

    public Seat GetSeat(char row, int number)
    {
        foreach (Seat s in Seats)
        {
            if (s.Row == row && s.Number == number)
            {
                return s;
            }
        }
        return null;
    }

    public int GetFreeCount()
    {
        int count = 0;
        foreach (Seat s in Seats)
        {
            if (s.State == SeatState.Free) count++;
        }
        return count;
    }

    public int GetBookedCount()
    {
        int count = 0;
        foreach (Seat s in Seats)
        {
            if (s.State == SeatState.Booked) count++;
        }
        return count;
    }

    public int GetSoldCount()
    {
        int count = 0;
        foreach (Seat s in Seats)
        {
            if (s.State == SeatState.Sold) count++;
        }
        return count;
    }

    public double CalculatePrice(ViewerType viewer)
    {
        int discount = ShowVenue.GetDiscount(viewer);
        return BasePrice * ((100.0 - discount) / 100.0);
    }
}

public class CinemaManager
{
    private static CinemaManager instance;
    public List<Venue> Venues;
    public List<Show> Shows;
    private CinemaManager()
    {
        Venues = new List<Venue>();
        Shows = new List<Show>();
    }

    public static CinemaManager Instance
    {
        get
        {
            if (instance == null)
            {
                instance = new CinemaManager();
            }
            return instance;
        }
    }

    public void LoadData(string filePath)
    {
        StreamReader reader = new StreamReader(filePath);
        string line;
        while ((line = reader.ReadLine()) != null)
        {
            string[] parts = line.Split(';');
            if (parts[0] == "VENUE")
            {
                Venue venue = VenueFactory.CreateVenue(parts[2]);
                venue.Name = parts[1];
                venue.RowCount = int.Parse(parts[3]);
                venue.SeatsPerRow = int.Parse(parts[4]);
                Venues.Add(venue);
            }
            else if (parts[0] == "SHOW")
            {
                Venue assignedVenue = null;
                foreach (Venue v in Venues)
                {
                    if (v.Name == parts[4])
                    {
                        assignedVenue = v;
                        break;
                    }
                }
                Show show = new Show(parts[1], parts[2], parts[3], assignedVenue);
                Shows.Add(show);
            }
            else if (parts[0] == "BOOK")
            {
                Show targetShow = null;
                foreach (Show s in Shows)
                {
                    if (s.Id == parts[1])
                    {
                        targetShow = s;
                        break;
                    }
                }
                Seat seat = targetShow.GetSeat(parts[2][0], int.Parse(parts[3]));
                if (seat != null) seat.TransitionToBooked();
            }
            else if (parts[0] == "BUY")
            {
                Show targetShow = null;
                foreach (Show s in Shows)
                {
                    if (s.Id == parts[1])
                    {
                        targetShow = s;
                        break;
                    }
                }
                Seat seat = targetShow.GetSeat(parts[2][0], int.Parse(parts[3]));
                if (seat != null) seat.TransitionToSold();
            }
        }
        reader.Close();
    }

    public void PrintMostWatchedFilm()
    {
        List<string> films = new List<string>();
        List<int> counts = new List<int>();

        foreach (Show s in Shows)
        {
            int soldCount = s.GetSoldCount();
            bool found = false;
            for (int i = 0; i < films.Count; i++)
            {
                if (films[i] == s.FilmName)
                {
                    counts[i] += soldCount;
                    found = true;
                    break;
                }
            }
            if (!found)
            {
                films.Add(s.FilmName);
                counts.Add(soldCount);
            }
        }

        int max = -1;
        string bestFilm = "";
        for (int i = 0; i < films.Count; i++)
        {
            if (counts[i] > max)
            {
                max = counts[i];
                bestFilm = films[i];
            }
        }
        Console.WriteLine("Most Watched Film: " + bestFilm + " (" + max + " tickets sold)");
    }
}
