namespace ATM;

class Program
{
    static void Main(string[] args)
    {
        // ATM
        
        AtmMachine atm = new AtmMachine();

        Menu menu = new Menu();
        menu.Run();
    }
}

public class Menu
{
    AtmMachine atm;
    public void Run()
    {
        atm = new AtmMachine();
        int n = -1;
        do
        {
            ShowMenu();
            Console.Write("Please choose: ");
            try
            {
                n = int.Parse(Console.ReadLine());
            }
            catch(FormatException)
            {
                Console.WriteLine("Bad option");
                n = -1;
            }

            switch (n)
            {
                case 1:
                    Console.WriteLine(atm);
                    break;
                case 2:
                    Query();
                    break;
                case 3:
                    Deposit();
                    break;
                case 4:
                    Withdraw();
                    break;
                default:
                    break;
            }

        }while(n != 0);
        
    }
    private void ShowMenu()
    {
        Console.WriteLine("MENU");
        Console.WriteLine("0 - Exit");
        Console.WriteLine("1 - Card information");
        Console.WriteLine("2 - Pocket balance");
        Console.WriteLine("3 - Deposit");
        Console.WriteLine("4 - Withdraw");
    }

    private void Query()
    {
        try
        {
            Console.Write("Pocket Id: ");
            int pocket = int.Parse(Console.ReadLine());
            Console.WriteLine($"Balance: {atm[pocket]} $");
        }
        catch (FormatException)
        {
            Console.WriteLine("Wrong data");
        }
        catch(AtmMachine.PocketIndexOutOfRangeException e)
        {
            Console.WriteLine($"Error: {e.Message}");
        }
    }
    private void Deposit()
    {
        try
        {
            Console.Write("Pocket Id: ");
            int pocket = int.Parse(Console.ReadLine());

            Console.Write("Amount to deposit: ");
            int value = int.Parse(Console.ReadLine());

            atm.Deposit(pocket,value);
            Console.WriteLine("Succesfully added");
        }
        catch (FormatException)
        {
            Console.WriteLine("Wrong data");
        }
        catch(Exception e)
        {
            Console.WriteLine($"Error: {e.Message}");
        }
    }
    private void Withdraw()
    {
        try
        {
            Console.Write("Pocket Id: ");
            int pocket = int.Parse(Console.ReadLine());

            Console.Write("Amount to withdraw: ");
            int value = int.Parse(Console.ReadLine());

            atm.Withdraw(pocket,value);
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Succesfull withdrawal");
            Console.ForegroundColor = ConsoleColor.White;
        }
        catch (FormatException)
        {
            Console.WriteLine("Wrong data");
        }
        catch(Exception e)
        {
            Console.WriteLine($"Error: {e.Message}");
        }
    }
}
