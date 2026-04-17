namespace GardenProject;

class Program
{
    static void Main(string[] args)
    {
        Gardener kertesz = new Gardener(10);

            kertesz.garden.Plant(1, Potato.GetPotato(), 5);
            kertesz.garden.Plant(2, Potato.GetPotato(), 5);
            kertesz.garden.Plant(5, Potato.GetPotato(), 5);
            kertesz.garden.Plant(3, Pea.GetPea(), 5);
            kertesz.garden.Plant(4, Tulip.GetTulip(), 3);

            Console.WriteLine("Betakarítható parcellák azonosítói: " + string.Join(", ", kertesz.garden.Harvestables(10)));

            kertesz.garden.Harvest(1, 10);
            kertesz.garden.Harvest(4, 10);

            Console.WriteLine("Betakarítható parcellák azonosítói: " + string.Join(", ", kertesz.garden.Harvestables(10)));
    }
}
