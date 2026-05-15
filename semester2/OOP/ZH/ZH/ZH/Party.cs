using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ZH
{
    public class Party
    {
        public string Name { get; private set; }
        public List<Fighter> Fighters { get; private set; }
        public bool isDeafeated()
        {
            int aliveMembers = 0;
            foreach (Fighter fighter in Fighters)
            {
                if (fighter.IsAlive())
                {
                    aliveMembers++;
                }
            }
            return aliveMembers <= 0;
        }

        public Party(string name, List<Fighter> fighters)
        {
            Name = name;
            Fighters = fighters;
        }
    }
}
