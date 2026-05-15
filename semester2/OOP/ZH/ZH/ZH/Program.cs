namespace ZH
{
    internal class Program
    {
        static void Main(string[] args)
        {
            Game game = new Game("input.txt");
            /*
            foreach (Party team in game.Teams) {
                Console.WriteLine($"{team.Name}'s Fighters: ");
                foreach(Fighter fighter in team.Fighters)
                {
                    Console.WriteLine($"{fighter.Name}, {fighter.Cast}, {fighter.Damage} damage, {fighter.Hp} health");
                }
            }
            */
            game.RunGame();
        }
    }
}
