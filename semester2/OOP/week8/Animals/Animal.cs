using System;

namespace Animals;

public abstract class Animal
{
    public string Name {get; protected set;}
    public int Hp {get; protected set;}
    public string Type {get; protected set;}

    public Animal(string n, int h)
    {
        Name = n;
        Hp = h;
    }
    public abstract void React(Mood m);
    public override string ToString()
    {
        return $"{Name} is a {Type}, HP: {Hp}";
    }
}

public class Dog : Animal
{
    // 3 0 -10
    public Dog(string n, int h) : base(n, h)
    {
        Type = "Dog";
    }

    public override void React(Mood m)
    {
        switch (m)
        {
            case Mood.Good:
                Hp+=3;
                break;
            case Mood.Bad:
                Hp-=10;
                break;
        }
        if(Hp > 100)
        {
            Hp = 100;
        }
    }
}

public class Bird : Animal
{
    // 2 -1 -3
    public Bird(string n, int h) : base(n, h)
    {
        Type = "Bird";
    }

    public override void React(Mood m)
    {
        switch (m)
        {
            case Mood.Good:
                Hp+=2;
                break;
            case Mood.Average:
                Hp-=1;
                break;
            case Mood.Bad:
                Hp-=3;
                break;
        }
        if(Hp > 100)
        {
            Hp = 100;
        }
    }
}

public class Fish : Animal
{
    // 1 -3 -5
    public Fish(string n, int h) : base(n, h){
        Type = "Fish";
    }

    public override void React(Mood m)
    {
        switch (m)
        {
            case Mood.Good:
                Hp+=1;
                break;
            case Mood.Average:
                Hp-=3;
                break;
            case Mood.Bad:
                Hp-=5;
                break;
        }
        if(Hp > 100)
        {
            Hp = 100;
        }
    }
}
