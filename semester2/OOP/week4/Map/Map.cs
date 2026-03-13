namespace Map;

internal class Item
{
    public int key;
    public string data;
    public Item(int k, string d)
    {
        key = k;
        data = d;
    }

    public override string ToString()
    {
        return $"({key}:{data})";
    }
}

public class MyMap
{
    public class ExistingKeyException : Exception
    {
        public ExistingKeyException() : base("Key already exists"){}
    }
    public class NotExistingKeyException : Exception
    {
        public NotExistingKeyException() : base("Bad key"){}
    }
    List<Item> seq = new List<Item>();

    public void Clear()
    {
        seq.Clear();
    }
    public int Count()
    {
        return seq.Count();
    }

    private bool BinSearch(int k, out int ind)
    {
        bool ok = false;
        int l = 0, h = seq.Count-1;
        ind = 0;

        while (!ok && l <= h)
        {
            ind = (l+h)/2;
            if(seq[ind].key == k)
            {
                ok = true;
            }
            else if(seq[ind].key < k)
            {
                l = ind + 1;
            }
            else if(seq[ind].key > k)
            {
                h = ind - 1;
            }
        }

        if (!ok)
        {
            ind = l;
        }

        return ok;
    }

    public void Insert(int k, string d)
    {
        bool ok = BinSearch(k, out int ind);
        if (!ok)
        {
            seq.Insert(ind, new Item(k, d));
            return;
        }
        throw new ExistingKeyException();
    }
    public void Remove(int k)
    {
        bool ok = BinSearch(k, out int ind);
        if (ok)
        {
            seq.RemoveAt(ind);
            return;
        }
        throw new NotExistingKeyException();
    }

    public bool Contains(int k)
    {
        return BinSearch(k, out int ind);
    }

    public string this[int k]
    {
        get
        {
            bool ok = BinSearch(k, out int ind);
            if (ok)
            {
                return seq[ind].data;
            }
            throw new NotExistingKeyException();
        }
    }

    public override string ToString()
    {
        return $"[{string.Join(", ", seq)}]";
    }
}
