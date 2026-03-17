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
            "Push(Object element)"
        };
        
        byte choice = 255;
        Array array = null;
        
        do
        {
            Console.WriteLine("\n-------------------------");
            for(int i = 0; i < choices.Length; i++)
            {
                Console.WriteLine($"{i}: {choices[i]}");
            }
            Console.Write("\nPlease make your choice: ");
            
            string input = Console.ReadLine();
            
            if(byte.TryParse(input, out choice))
            {
                if (choice >= 2 && choice <= 8 && array == null)
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
