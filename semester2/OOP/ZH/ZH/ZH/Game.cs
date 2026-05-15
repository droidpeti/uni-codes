using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZH
{
    public class Game
    {
        private List<Party> teams;
        private int roundCount = 0;
        public Game(string filename) 
        {
            StreamReader sr = new StreamReader(filename);
            int teamSize = int.Parse(sr.ReadLine());
            int teamCount = 2;
            teams = new List<Party>(teamCount);
            for (int i = 0; i < teamCount; i++) 
            {
                string teamName = sr.ReadLine();
                List<Fighter> fighters = new List<Fighter>(teamSize);
                for(int j = 0; j < teamSize; j++)
                {
                    string[] row = sr.ReadLine().Split(" ");
                    string name = row[0];
                    string cast = row[1];
                    int hp = int.Parse(row[2]);
                    int damage = int.Parse(row[3]);
                    FighterType type;
                    switch (cast)
                    {
                        case "harcos":
                            type = FighterType.Warrior;
                            break;
                        case "kósza":
                            type = FighterType.Stray;
                            break;
                        case "varázsló":
                            type = FighterType.Wizard;
                            break;
                        default:
                            type = FighterType.Warrior;
                            break;
                    }
                    fighters.Add(new Fighter(name, cast, hp, damage, type));
                }
                teams.Add(new Party(teamName, fighters));
            }
            sr.Close();
        }

        public void SimulateRound()
        {
            Console.WriteLine($"Round #{++roundCount}: ");
            for (int i = 0; i < teams[0].Fighters.Count; i++)
            {
                teams[0].Fighters[i].Attack(teams[1].Fighters);
                teams[1].Fighters[i].Attack(teams[0].Fighters);
            }
        }

        public void RunGame()
        {
            while ((!teams[0].isDeafeated()) && (!teams[1].isDeafeated()))
            {
                SimulateRound();
            }
            Party winner;
            if (teams[0].isDeafeated())
            {
                winner = teams[1];
            }
            else
            {
                winner = teams[0];
            }
            Console.WriteLine($"The Winner is: {winner.Name}!");
            foreach (Fighter fighter in winner.Fighters)
            {
                Console.WriteLine($"{fighter.Name}, {fighter.Cast}, {fighter.Damage} damage, {fighter.Hp} health");
            }
            
        }
    }
}
