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
}
