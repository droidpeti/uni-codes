namespace ArrayProject;

public class Array
{
    private Object[] array;
    
    public Array(int n)
    {
        this.array = new Object[n];
    }

    public Object GetElement(int index)
    {
        if(index < 0 || index > array.Length - 1)
        {
            throw new IndexOutOfRangeException();
        }

        return array[index];
    }

    public void SetElement(int index, Object value)
    {
        if(index < 0 || index > array.Length - 1)
        {
            throw new IndexOutOfRangeException();
        }

        array[index] = value;
    }

    public int Length()
    {
        return array.Length;
    }

    public void Resize(int n)
    {
        Object[] copy = new Object[n];
        int min = (n < array.Length) ? n : array.Length;

        for(int i = 0; i < min; i++)
        {
            copy[i] = array[i];
        }

        array = copy;
    }

    public void Clear()
    {
        for(int i = 0; i < array.Length; i++)
        {
            array[i] = null;
        }
    }

    public void ZeroLength()
    {
        array = new Object[0];
    }

    public void Push(Object element)
    {
        Resize(array.Length+1);
        array[array.Length-1] = element;
    }

    public Array GetInterval(int startIndex, int endIndex)
    {
        if(startIndex >= endIndex)
        {
            return null;
        }
        if(startIndex < 0 || endIndex > array.Length)
        {
            throw new IndexOutOfRangeException();
        }

        Array intervalArray = new Array(endIndex - startIndex);
        for(int i = 0; i < intervalArray.Length(); i++)
        {
            intervalArray.SetElement(i, array[startIndex + i]);
        }
        return intervalArray;
    }

    public void PushArray(Array arrayToPush)
    {
        for(int i = 0; i < arrayToPush.Length(); i++)
        {
            Push(arrayToPush.GetElement(i));
        }
    }

    public void Unshift(Object element)
    {
        Resize(array.Length+1);
        for(int i = array.Length-2; i >= 0; i--)
        {
            array[i+1] = array[i];
        }
        array[0] = element;
    }

    public Object[] GetInnerArray()
    {
        return array;
    }

    public void Fill(Object element)
    {
        for(int i = 0; i < array.Length; i++)
        {
            array[i] = element;
        }
    }

    public void AddInterval(Array arrayToAdd, int startIndex, int endIndex)
    {
        Array interval = arrayToAdd.GetInterval(startIndex, endIndex);
        if (interval != null)
        {
            PushArray(interval); 
        }
    }

    public int CountNotNull()
    {
        int notNullCount = 0;
        for(int i = 0; i < array.Length; i++)
        {
            if(array[i] != null)
            {
                notNullCount++;
            }
        }
        return notNullCount;
    }
}
