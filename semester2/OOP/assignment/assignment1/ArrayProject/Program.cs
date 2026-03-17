namespace ArrayProject;

class Program
{
    static void Main(string[] args)
    {
        Console.WriteLine("Welcome to Array project!");
        string[] choices =
        {
            "Quit",
            "Constructor Array(int n)",
            "GetElement(int index)",
            "SetElement(int index, Object value)",
            "Length()",
            "Resize(int n)",
            "Clear()",
            "ZeroLength()",
            "Push(Object element)",
            "GetInterval(int start, int end)",
            "PushArray(Array other)",
            "Unshift(Object element)",
            "GetInnerArray() [Prints Array]",
            "Fill(Object element)",
            "AddInterval(Array other, int start, int end)",
            "CountNotNull()"
        };
        
        byte choice = 255;
        Array array = null;
        
        do
        {
            Console.WriteLine("\n-------------------------");
            for(int i = 0; i < choices.Length; i++)
            {
                Console.WriteLine($"{i,2}: {choices[i]}");
            }
            Console.Write("\nPlease make your choice: ");
            
            string input = Console.ReadLine();
            
            if(byte.TryParse(input, out choice))
            {
                if (choice >= 2 && choice <= choices.Length && array == null)
                {
                    Console.WriteLine("Error: You must create the array (Choice 1) before doing that!");
                    continue; 
                }

                switch (choice)
                {
                    case 0:
                        Console.WriteLine("Goodbye!");
                        break;
                        
                    case 1:
                        int n;
                        do
                        {
                            Console.Write("Please enter the array's size: ");
                        } while(!int.TryParse(Console.ReadLine(), out n) || n < 0);
                        
                        array = new Array(n);
                        Console.WriteLine($"Success: Array created with size {n}.");
                        break;
                        
                    case 2:
                        Console.Write("Enter index to get: ");
                        if (int.TryParse(Console.ReadLine(), out int getIndex))
                        {
                            try 
                            {
                                Console.WriteLine($"Element at index {getIndex} is: {array.GetElement(getIndex) ?? "null"}");
                            }
                            catch (IndexOutOfRangeException)
                            {
                                Console.WriteLine("Error: That index is out of bounds.");
                            }
                        }
                        break;
                        
                    case 3:
                        Console.Write("Enter index to set: ");
                        if (int.TryParse(Console.ReadLine(), out int setIndex))
                        {
                            Console.Write("Enter a value (we will save it as a string): ");
                            string val = Console.ReadLine();
                            try
                            {
                                array.SetElement(setIndex, val);
                                Console.WriteLine("Success: Element saved.");
                            }
                            catch (IndexOutOfRangeException)
                            {
                                Console.WriteLine("Error: That index is out of bounds.");
                            }
                        }
                        break;

                    case 4:
                        Console.WriteLine($"The current array length is: {array.Length()}");
                        break;

                    case 5:
                        Console.Write("Enter new size: ");
                        if (int.TryParse(Console.ReadLine(), out int newSize) && newSize >= 0)
                        {
                            array.Resize(newSize);
                            Console.WriteLine($"Success: Array resized to {newSize}.");
                        }
                        else
                        {
                            Console.WriteLine("Error: Invalid size.");
                        }
                        break;

                    case 6:
                        array.Clear();
                        Console.WriteLine("Success: Array cleared.");
                        break;

                    case 7:
                        array.ZeroLength();
                        Console.WriteLine("Success: Array length set to zero.");
                        break;

                    case 8:
                        Console.Write("Enter value to push: ");
                        string pushVal = Console.ReadLine();
                        array.Push(pushVal);
                        Console.WriteLine($"Success: '{pushVal}' pushed to the end of the array.");
                        break;

                    case 9:
                        Console.Write("Enter start index: ");
                        int.TryParse(Console.ReadLine(), out int start);
                        Console.Write("Enter end index (exclusive): ");
                        int.TryParse(Console.ReadLine(), out int end);
                        
                        try 
                        {
                            Array interval = array.GetInterval(start, end);
                            if (interval == null)
                            {
                                Console.WriteLine("Result: null (start >= end)");
                            }
                            else
                            {
                                Console.WriteLine($"Success: Extracted array of length {interval.Length()}");
                                for(int i = 0; i < interval.Length(); i++)
                                    Console.WriteLine($"  [{i}]: {interval.GetElement(i) ?? "null"}");
                            }
                        }
                        catch (IndexOutOfRangeException)
                        {
                            Console.WriteLine("Error: One of the bounds is out of range.");
                        }
                        break;

                    case 10:
                        Console.Write("Enter items for the new array separated by commas (e.g., A,B,C): ");
                        string[] items = Console.ReadLine().Split(',');
                        Array newArray = new Array(items.Length);
                        for(int i = 0; i < items.Length; i++) newArray.SetElement(i, items[i].Trim());
                        
                        array.PushArray(newArray);
                        Console.WriteLine($"Success: Pushed {items.Length} items to the main array.");
                        break;

                    case 11:
                        Console.Write("Enter value to unshift (add to front): ");
                        string unshiftVal = Console.ReadLine();
                        array.Unshift(unshiftVal);
                        Console.WriteLine($"Success: '{unshiftVal}' added to the front.");
                        break;

                    case 12:
                        Object[] inner = array.GetInnerArray();
                        Console.WriteLine($"--- Inner Array Contents (Length: {inner.Length}) ---");
                        for(int i = 0; i < inner.Length; i++)
                        {
                            Console.WriteLine($"[{i}]: {inner[i] ?? "null"}");
                        }
                        break;

                    case 13:
                        Console.Write("Enter value to fill the array with: ");
                        string fillVal = Console.ReadLine();
                        array.Fill(fillVal);
                        Console.WriteLine("Success: Array filled.");
                        break;

                    case 14:
                        Console.Write("Enter items for the SECOND array separated by commas (e.g., X,Y,Z): ");
                        string[] addItems = Console.ReadLine().Split(',');
                        Array secondArray = new Array(addItems.Length);
                        for(int i = 0; i < addItems.Length; i++) secondArray.SetElement(i, addItems[i].Trim());
                        
                        Console.Write("Enter start index of the second array to copy: ");
                        int.TryParse(Console.ReadLine(), out int addStart);
                        Console.Write("Enter end index (exclusive) of the second array: ");
                        int.TryParse(Console.ReadLine(), out int addEnd);
                        
                        try
                        {
                            array.AddInterval(secondArray, addStart, addEnd);
                            Console.WriteLine("Success: Interval added to main array.");
                        }
                        catch (IndexOutOfRangeException)
                        {
                            Console.WriteLine("Error: Interval bounds were out of range for the second array.");
                        }
                        break;

                    case 15:
                        Console.WriteLine($"Number of non-null elements: {array.CountNotNull()}");
                        break;

                    default:
                        if (choice != 0) Console.WriteLine("Invalid choice. Try again.");
                        break;
                }
            }
            else
            {
                Console.WriteLine("Invalid input. Please enter a number from the menu.");
                choice = 255;
            }
            
        } while(choice != 0);
    }
}
