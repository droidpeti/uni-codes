namespace ATM;

public class AtmMachine
{
    public class PocketIndexOutOfRangeException : Exception
    {
        public PocketIndexOutOfRangeException() : base("Pocket error")
        {
            
        }
    }
    public class NegativeWithdrawException : Exception
    {
        public NegativeWithdrawException() : base("Withdraw error")
        {
            
        }
    }
    public class NegativeBalanceException : Exception
    {
        public NegativeBalanceException() : base("Balance error")
        {
            
        }
    }

    public class BalanceOverLimitException : Exception
    {
        public BalanceOverLimitException() : base("Balance error")
        {
            
        }
    }

    private int[] card;
    private int pocketLimit = 3;
    private string[] services = new string[] {"Food", "Leisure", "Sport"};
    private int limit = 2000;

    public AtmMachine()
    {
        card = new int[pocketLimit];
    }

    public int Get(int pocket)
    {
        if(pocket < 1 || pocket > pocketLimit)
        {
            throw new PocketIndexOutOfRangeException();
        }
        return card[pocket-1];
    }
    public void Withdraw(int pocket, int value)
    {
        if(pocket < 1 || pocket > pocketLimit)
        {
            throw new PocketIndexOutOfRangeException();
        }

        if(value < 0)
        {
            throw new NegativeWithdrawException();
        }

        if (value > card[pocket - 1])
        {
            throw new NegativeBalanceException();
        }

        card[pocket-1] -= value;
    }

    public void Deposit(int pocket, int value)
    {
        if(pocket < 1 || pocket > pocketLimit)
        {
            throw new PocketIndexOutOfRangeException();
        }

        if(value < 0)
        {
            throw new NegativeWithdrawException();
        }

        if (value+card[pocket-1] > limit)
        {
            throw new NegativeBalanceException();
        }

        card[pocket-1] += value;
    }

    public override string ToString()
    {
        string s = "Card information:\n";
        for(int i = 0; i < pocketLimit; i++)
        {
            s+= $"\t{services[i]} - {card[i]} Ft\n";
        }
        return s;
    }

    // indexer property
    public int this[int pocket]
    {
        get
        {
            if(pocket < 1 || pocket > pocketLimit)
            {
                throw new PocketIndexOutOfRangeException();
            }

            return card[pocket];
        }
    }
}
