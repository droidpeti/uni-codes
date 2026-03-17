using Microsoft.VisualStudio.TestTools.UnitTesting;
using System; // Added this back ONLY for IndexOutOfRangeException
using ArrayProject;

namespace ArrayProject.Tests;

[TestClass]
public sealed class ArrayTest
{
    [TestMethod]
    public void Constructor_SetsCorrectLength()
    {
        Array arr = new Array(5);
        Assert.AreEqual(5, arr.Length());
    }

    [TestMethod]
    public void SetAndGetElement_ValidIndex_SavesAndReturnsValue()
    {
        Array arr = new Array(3);
        string expectedValue = "Test String";

        arr.SetElement(1, expectedValue);
        Object actualValue = arr.GetElement(1);

        Assert.AreEqual(expectedValue, actualValue);
    }

    [TestMethod]
    public void GetElement_IndexOutOfBounds_ThrowsException()
    {
        Array arr = new Array(2);

        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(5));
        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(-1));
    }

    [TestMethod]
    public void SetElement_IndexOutOfBounds_ThrowsException()
    {
        Array arr = new Array(2);

        Assert.Throws<IndexOutOfRangeException>(() => arr.SetElement(5, "Bad Index"));
    }

    [TestMethod]
    public void Resize_MakeLarger_KeepsOldDataAndUpdatesLength()
    {
        Array arr = new Array(2);
        arr.SetElement(0, "First");
        arr.SetElement(1, "Second");

        arr.Resize(5);

        Assert.AreEqual(5, arr.Length());
        Assert.AreEqual("First", arr.GetElement(0));
        Assert.AreEqual("Second", arr.GetElement(1));
        Assert.IsNull(arr.GetElement(4));
    }

    [TestMethod]
    public void Resize_MakeSmaller_TruncatesDataAndUpdatesLength()
    {
        Array arr = new Array(5);
        arr.SetElement(0, "Keep me");
        arr.SetElement(4, "Lose me");

        arr.Resize(1);

        Assert.AreEqual(1, arr.Length());
        Assert.AreEqual("Keep me", arr.GetElement(0));
        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(4));
    }

    [TestMethod]
    public void Clear_SetsAllElementsToNull()
    {
        Array arr = new Array(3);
        arr.SetElement(0, "A");
        arr.SetElement(1, "B");
        arr.SetElement(2, "C");

        arr.Clear();

        Assert.IsNull(arr.GetElement(0));
        Assert.IsNull(arr.GetElement(1));
        Assert.IsNull(arr.GetElement(2));
        Assert.AreEqual(3, arr.Length());
    }

    [TestMethod]
    public void ZeroLength_SetsLengthToZero()
    {
        Array arr = new Array(5);

        arr.ZeroLength();

        Assert.AreEqual(0, arr.Length());
        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(0));
    }

    [TestMethod]
    public void Push_AddsElementToEndAndIncreasesLength()
    {
        Array arr = new Array(2);
        arr.SetElement(0, "A");
        arr.SetElement(1, "B");

        arr.Push("C");

        Assert.AreEqual(3, arr.Length());
        Assert.AreEqual("C", arr.GetElement(2));
        Assert.AreEqual("A", arr.GetElement(0));
    }

    [TestMethod]
    public void GetInterval_ValidRange_ReturnsNewArrayWithSlice()
    {
        Array arr = new Array(5);
        arr.SetElement(0, "A");
        arr.SetElement(1, "B");
        arr.SetElement(2, "C");
        arr.SetElement(3, "D");

        Array interval = arr.GetInterval(1, 3);

        Assert.IsNotNull(interval);
        Assert.AreEqual(2, interval.Length());
        Assert.AreEqual("B", interval.GetElement(0));
        Assert.AreEqual("C", interval.GetElement(1));
    }

    [TestMethod]
    public void GetInterval_StartGreaterOrEqualEnd_ReturnsNull()
    {
        Array arr = new Array(3);
        
        Assert.IsNull(arr.GetInterval(2, 1));
        Assert.IsNull(arr.GetInterval(1, 1));
    }

    [TestMethod]
    public void PushArray_AppendsAnotherArrayToEnd()
    {
        Array mainArr = new Array(2);
        mainArr.SetElement(0, "1");
        mainArr.SetElement(1, "2");

        Array secondArr = new Array(2);
        secondArr.SetElement(0, "3");
        secondArr.SetElement(1, "4");

        mainArr.PushArray(secondArr);

        Assert.AreEqual(4, mainArr.Length());
        Assert.AreEqual("3", mainArr.GetElement(2));
        Assert.AreEqual("4", mainArr.GetElement(3));
    }

    [TestMethod]
    public void Unshift_AddsElementToFrontAndShiftsRight()
    {
        Array arr = new Array(2);
        arr.SetElement(0, "B");
        arr.SetElement(1, "C");

        arr.Unshift("A");

        Assert.AreEqual(3, arr.Length());
        Assert.AreEqual("A", arr.GetElement(0));
        Assert.AreEqual("B", arr.GetElement(1));
        Assert.AreEqual("C", arr.GetElement(2));
    }

    [TestMethod]
    public void GetInnerArray_ReturnsRawObjectArray()
    {
        Array arr = new Array(3);
        arr.SetElement(0, "Test");

        Object[] inner = arr.GetInnerArray();

        Assert.IsNotNull(inner);
        Assert.AreEqual(3, inner.Length);
        Assert.AreEqual("Test", inner[0]);
    }

    [TestMethod]
    public void Fill_SetsAllElementsToSameValue()
    {
        Array arr = new Array(3);
        
        arr.Fill("X");

        Assert.AreEqual("X", arr.GetElement(0));
        Assert.AreEqual("X", arr.GetElement(1));
        Assert.AreEqual("X", arr.GetElement(2));
    }

    [TestMethod]
    public void AddInterval_AppendsSliceOfAnotherArray()
    {
        Array mainArr = new Array(1);
        mainArr.SetElement(0, "A");

        Array secondArr = new Array(4);
        secondArr.SetElement(0, "W");
        secondArr.SetElement(1, "X");
        secondArr.SetElement(2, "Y");
        secondArr.SetElement(3, "Z");

        mainArr.AddInterval(secondArr, 1, 3);

        Assert.AreEqual(3, mainArr.Length());
        Assert.AreEqual("A", mainArr.GetElement(0));
        Assert.AreEqual("X", mainArr.GetElement(1));
        Assert.AreEqual("Y", mainArr.GetElement(2));
    }

    [TestMethod]
    public void CountNotNull_ReturnsCorrectTally()
    {
        Array arr = new Array(5);
        arr.SetElement(1, "Data 1");
        arr.SetElement(4, "Data 2");

        int count = arr.CountNotNull();

        Assert.AreEqual(2, count);
    }
}
