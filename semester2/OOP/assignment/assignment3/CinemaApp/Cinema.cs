public enum ViewerType { Child, Student, Adult, Pensioner, Regular }
public enum SeatState { Free, Booked, Sold }
public enum RoomCategory { Small, Large, VIP }

public abstract class Room
{
    public string Name;
    public RoomCategory Category;
    public int RowCount;
    public int SeatsPerRow;    
    public abstract int GetDiscount(ViewerType viewer);
}

public class SmallRoom : Room
{
    public SmallRoom()
    {
        Category = RoomCategory.Small;
    }

    public override int GetDiscount(ViewerType viewer)
    {
        if (viewer == ViewerType.Child) return 40;
        if (viewer == ViewerType.Student) return 30;
        if (viewer == ViewerType.Adult) return 10;
        if (viewer == ViewerType.Pensioner) return 30;
        if (viewer == ViewerType.Regular) return 30;
        return 0;
    }
}

public class LargeRoom : Room
{
    public LargeRoom()
    {
        Category = RoomCategory.Large;
    }

    public override int GetDiscount(ViewerType viewer)
    {
        if (viewer == ViewerType.Child) return 40;
        if (viewer == ViewerType.Student) return 20;
        if (viewer == ViewerType.Adult) return 0;
        if (viewer == ViewerType.Pensioner) return 20;
        if (viewer == ViewerType.Regular) return 30;
        return 0;
    }
}

public class VipRoom : Room
{
    public VipRoom()
    {
        Category = RoomCategory.VIP;
    }

    public override int GetDiscount(ViewerType viewer)
    {
        return 0;
    }
}

public class RoomFactory
{
    public static Room CreateRoom(string categoryType)
    {
        if (categoryType == "Small") return new SmallRoom();
        if (categoryType == "Large") return new LargeRoom();
        if (categoryType == "VIP") return new VipRoom();
        throw new Exception("Invalid Room Category");
    }
}

public class Seat
{
    public char Row;
    public int Number;
    public SeatState State;

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
    public string Id;
    public string FilmName;
    public string Time;
    public Room ShowRoom;
    public List<Seat> Seats;
    public int BasePrice = 2000;

    public Show(string id, string filmName, string time, Room showRoom)
    {
        Id = id;
        FilmName = filmName;
        Time = time;
        ShowRoom = showRoom;
        Seats = new List<Seat>();

        char currentRow = 'A';
        for (int i = 0; i < showRoom.RowCount; i++)
        {
            for (int j = 1; j <= showRoom.SeatsPerRow; j++)
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
        int discount = ShowRoom.GetDiscount(viewer);
        return BasePrice * ((100.0 - discount) / 100.0);
    }
}

public class CinemaManager
{
    private static CinemaManager instance;
    public List<Room> Rooms;
    public List<Show> Shows;
    private CinemaManager()
    {
        Rooms = new List<Room>();
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
            if (parts[0] == "ROOM")
            {
                Room room = RoomFactory.CreateRoom(parts[2]);
                room.Name = parts[1];
                room.RowCount = int.Parse(parts[3]);
                room.SeatsPerRow = int.Parse(parts[4]);
                Rooms.Add(room);
            }
            else if (parts[0] == "SHOW")
            {
                Room assignedRoom = null;
                foreach (Room r in Rooms)
                {
                    if (r.Name == parts[4])
                    {
                        assignedRoom = r;
                        break;
                    }
                }
                Show show = new Show(parts[1], parts[2], parts[3], assignedRoom);
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
