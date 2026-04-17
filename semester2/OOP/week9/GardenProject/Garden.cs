namespace GardenProject;

public class Garden
{
    private readonly List<Parcel> parcels;
    public Garden(int parcelCount)
    {
        parcels = new List<Parcel>();
        for(int i = 0; i < parcelCount; i++)
        {
            parcels.Add(new Parcel());
        }
    }

    public Parcel this[int index]
    {
        get
        {
            if(index < 0 || index > parcels.Count - 1)
            {
                throw new IndexOutOfRangeException();
            }
            return parcels[index];
        }
    }

    public void Plant(int parcelIndex, PlantType plant, int months)
    {
        if(parcelIndex < 0 || parcelIndex > parcels.Count - 1)
        {
            throw new IndexOutOfRangeException();
        }
        parcels[parcelIndex].Plant(plant, months);
    }

    public void Harvest(int parcelIndex, int months)
    {
        if(parcelIndex < 0 || parcelIndex > parcels.Count - 1)
        {
            throw new IndexOutOfRangeException();
        }
        if (parcels[parcelIndex].Harvestable(months))
        {
            parcels[parcelIndex].Harvest();
            Console.WriteLine(parcelIndex + "has been harvested");
        }
        else
        {
            Console.WriteLine(parcelIndex + "can not be harvested");
        }
    }

    public List<int> Harvestables(int months)
    {
        List<int> harvestables = new List<int>();
        for(int i = 0; i < parcels.Count; i++)
        {
            if (parcels[i].Harvestable(months))
            {
                harvestables.Add(i);
            }
        }
        return harvestables;
    }
}


public abstract class PlantType
{
    public readonly int timeToGrow;
    public PlantType(int time)
    {
        timeToGrow = time;
    }

    public virtual bool IsCrop() { return false ;}
}

abstract class Crop : PlantType
{
    protected Crop(int time) : base(time) {}
    public override bool IsCrop()
    {
        return base.IsCrop();
    }
}

abstract class DecorativePlant : PlantType
{
    protected DecorativePlant(int time) : base (time){}
}

class Potato : Crop
{
    public Potato() : base(3){}
    private static Potato potato;
    public static Potato GetPotato()
    {
        if(potato == null)
        {
            potato = new Potato();
        }
        return potato;
    }
}

class Pepper : Crop
{
    public Pepper() : base(3){}
    private static Pepper pepper;
    public static Pepper GetPepper()
    {
        if(pepper == null)
        {
            pepper = new Pepper();
        }
        return pepper;
    }
}

class Pea : Crop
{
    public Pea() : base(3){}
    private static Pea pea;
    public static Pea GetPea()
    {
        if(pea == null)
        {
            pea = new Pea();
        }
        return pea;
    }
}

class Tulip : DecorativePlant
{
    public Tulip() : base(3){}
    private static Tulip tulip;
    public static Tulip GetTulip()
    {
        if(tulip == null)
        {
            tulip = new Tulip();
        }
        return tulip;
    }
}

public class Parcel
{
    public PlantType IsPlanted {get; private set;}
    public int Time{get; private set;}
    public void Plant(PlantType plant, int months)
    {
        IsPlanted = plant;
        Time = months;
    }

    public bool Harvestable(int months)
    {
        return 
            IsPlanted != null &&
            IsPlanted.IsCrop() &&
            months - Time == IsPlanted.timeToGrow;
    }

    public void Harvest()
    {
        IsPlanted = null;
        Time = 0;
    }
}

public class Gardener
{
    public Garden garden;
    public Gardener(int parcelCount)
    {
        garden = new Garden(parcelCount);
    }
}
