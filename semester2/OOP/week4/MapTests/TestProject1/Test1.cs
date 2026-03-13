using Map;

namespace TestProject1;

[TestClass]
public sealed class Test1
{
    [TestMethod]
    public void TestMethod1()
    {
        Assert.IsTrue(true);
    }

    [TestMethod]
    public void TestInsert()
    {
        MyMap map = new MyMap();

        map.Insert(1, "one");
        Assert.AreEqual(map.ToString(), "[(1:one)]");

        map.Insert(-1, "minus one");
        Assert.AreEqual(map.ToString(), "[(-1:minus one), (1:one)]");

        map.Insert(2, "two");
        Assert.AreEqual(map.ToString(), "[(-1:minus one), (1:one), (2:two)]");

        Assert.Throws<MyMap.ExistingKeyException>(() => map.Insert(1, "not good"));
    }

    [TestMethod]
    public void TestClear()
    {
        MyMap map = new MyMap();
        map.Insert(1, "one");

        map.Clear();

        Assert.AreEqual(map.ToString(), "[]");
    }

    [TestMethod]
    public void TestCount()
    {
        MyMap map = new MyMap();
        map.Insert(1, "one");

        Assert.AreEqual(map.Count(), 1);
    }

    [TestMethod]
    public void TestContains()
    {
        MyMap map = new MyMap();

        Assert.IsFalse(map.Contains(1));

        map.Insert(1, "one");

        Assert.IsTrue(map.Contains(1));
    }
}
