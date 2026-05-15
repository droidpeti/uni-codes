using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZH
{
    public enum FighterType
    {
        Warrior,
        Stray,
        Wizard
    }
    public class Fighter
    {
        public string Name { get; private set; }
        public string Cast {  get; private set; }
        public int Hp { get; private set; }
        public int Damage { get; private set; }
        public FighterType Type { get; private set; }

        public Fighter(string name, string cast, int hp, int damage, FighterType type)
        {
            Name = name;
            Cast = cast;
            Hp = hp;
            Damage = damage;
            Type = type;
        }
        public bool IsAlive()
        {
            return Hp > 0;
        }
        public void Attack(List<Fighter> enemies)
        {
            if (!IsAlive())
            {
                return;
            }

            List<Fighter> aliveEnemies = new List<Fighter>();
            foreach (Fighter enemy in enemies)
            {
                if (enemy.IsAlive())
                {
                    aliveEnemies.Add(enemy);
                }
            }

            if(aliveEnemies.Count < 1)
            {
                return;
            }

            Console.WriteLine($"{Name} attacks!");
            switch (Type) {
                case FighterType.Warrior:
                    aliveEnemies[0].TakeDamage(Damage);
                    break;
                case FighterType.Stray:
                    Random random = new Random();
                    aliveEnemies[random.Next(0,aliveEnemies.Count)].TakeDamage(Damage);
                    break;
                case FighterType.Wizard:
                    foreach(Fighter enemy in enemies)
                    {
                        enemy.TakeDamage(Damage);
                    }
                    break;
            }
        }
        public void TakeDamage(int amount)
        {
            if(Hp <= 0)
            {
                return;
            }
            Console.WriteLine($"{Name} took {amount} damage, health goes from {Hp} to {Hp - amount}");
            Hp -= amount;
            if(Hp < 0)
            {
                Hp = 0;
            }
        }
    }
}
