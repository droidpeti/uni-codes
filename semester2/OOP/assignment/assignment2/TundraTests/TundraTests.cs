using Microsoft.VisualStudio.TestTools.UnitTesting;
using TundraApp;

namespace TundraTests;

[TestClass]
public class ColonyFactoryTests
{
    [TestMethod]
    public void CreateColony_ValidSpecies_ReturnsCorrectType()
    {
        Colony owl = ColonyFactory.CreateColony("Baglyok", 'h', 10);
        Colony lemming = ColonyFactory.CreateColony("Kicsik", 'l', 50);

        Assert.IsInstanceOfType(owl, typeof(Owl));
        Assert.IsInstanceOfType(lemming, typeof(Lemming));
        Assert.AreEqual(10, owl.Population);
    }

    [TestMethod]
    public void CreateColony_InvalidSpecies_ThrowsException()
    {
        Assert.Throws<ArgumentException>(() => 
        {
            ColonyFactory.CreateColony("Hibas", 'x', 100);
        });
    }
}

[TestClass]
public class PreyTests
{
    [TestMethod]
    public void AttackedBy_EnoughPopulation_DecreasesAndReturnsTrue()
    {
        Lemming lemming = new Lemming("L", 100);
        Wolf wolf = new Wolf("W", 10);

        bool success = lemming.AttackedBy(wolf);

        Assert.IsTrue(success);
        Assert.AreEqual(60, lemming.Population);
    }

    [TestMethod]
    public void AttackedBy_NotEnoughPopulation_DiesAndReturnsFalse()
    {
        Lemming lemming = new Lemming("L", 30);
        Wolf wolf = new Wolf("W", 10);

        bool success = lemming.AttackedBy(wolf);

        Assert.IsFalse(success);
        Assert.AreEqual(0, lemming.Population);
    }

    [TestMethod]
    public void EndOfTurn_CorrectRound_MultipliesPopulation()
    {
        Lemming lemming = new Lemming("L", 50);
        
        lemming.EndOfTurn(2);

        Assert.AreEqual(100, lemming.Population); // 50 * 2 = 100
    }

    [TestMethod]
    public void EndOfTurn_Overpopulation_DropsToLimit()
    {
        Lemming lemming = new Lemming("L", 150);

        lemming.EndOfTurn(2);

        Assert.AreEqual(30, lemming.Population);
    }

    [TestMethod]
    public void EndOfTurn_WrongRound_DoesNothing()
    {
        Lemming lemming = new Lemming("L", 50);

        lemming.EndOfTurn(3);

        Assert.AreEqual(50, lemming.Population);
    }
}

[TestClass]
public class PredatorTests
{
    [TestMethod]
    public void Hunt_Unsuccessful_LosesQuarterOfPopulation()
    {
        Wolf wolf = new Wolf("W", 100);
        Lemming lemming = new Lemming("L", 10);

        wolf.Hunt(lemming);

        Assert.AreEqual(75, wolf.Population);
    }

    [TestMethod]
    public void Hunt_Successful_PopulationRemainsSame()
    {
        Wolf wolf = new Wolf("W", 10);
        Lemming lemming = new Lemming("L", 1000);

        wolf.Hunt(lemming);

        Assert.AreEqual(10, wolf.Population);
    }

    [TestMethod]
    public void EndOfTurn_8thRound_BreedsCorrectly()
    {
        Wolf wolf = new Wolf("W", 10);

        wolf.EndOfTurn(8);

        Assert.AreEqual(14, wolf.Population);
    }

    [TestMethod]
    public void EndOfTurn_Not8thRound_DoesNothing()
    {
        Wolf wolf = new Wolf("W", 10);

        wolf.EndOfTurn(7);

        Assert.AreEqual(10, wolf.Population);
    }
}
