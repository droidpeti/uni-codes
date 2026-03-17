using Microsoft.VisualStudio.TestTools.UnitTesting;
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
        // Arrange
        Array arr = new Array(3);
        string expectedValue = "Test String";

        // Act
        arr.SetElement(1, expectedValue);
        Object actualValue = arr.GetElement(1);

        // Assert
        Assert.AreEqual(expectedValue, actualValue);
    }

    [TestMethod]
    public void GetElement_IndexOutOfBounds_ThrowsException()
    {
        // Arrange
        Array arr = new Array(2);

        // Act & Assert
        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(5));
        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(-1));
    }

    [TestMethod]
    public void SetElement_IndexOutOfBounds_ThrowsException()
    {
        // Arrange
        Array arr = new Array(2);

        // Act & Assert
        Assert.Throws<IndexOutOfRangeException>(() => arr.SetElement(5, "Bad Index"));
    }

    [TestMethod]
    public void Resize_MakeLarger_KeepsOldDataAndUpdatesLength()
    {
        // Arrange
        Array arr = new Array(2);
        arr.SetElement(0, "First");
        arr.SetElement(1, "Second");

        // Act
        arr.Resize(5);

        // Assert
        Assert.AreEqual(5, arr.Length());
        Assert.AreEqual("First", arr.GetElement(0));
        Assert.AreEqual("Second", arr.GetElement(1));
        Assert.IsNull(arr.GetElement(4));
    }

    [TestMethod]
    public void Resize_MakeSmaller_TruncatesDataAndUpdatesLength()
    {
        // Arrange
        Array arr = new Array(5);
        arr.SetElement(0, "Keep me");
        arr.SetElement(4, "Lose me");

        // Act
        arr.Resize(1);

        // Assert
        Assert.AreEqual(1, arr.Length());
        Assert.AreEqual("Keep me", arr.GetElement(0));
        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(4));
    }

    [TestMethod]
    public void Clear_SetsAllElementsToNull()
    {
        // Arrange
        Array arr = new Array(3);
        arr.SetElement(0, "A");
        arr.SetElement(1, "B");
        arr.SetElement(2, "C");

        // Act
        arr.Clear();

        // Assert
        Assert.IsNull(arr.GetElement(0));
        Assert.IsNull(arr.GetElement(1));
        Assert.IsNull(arr.GetElement(2));
        Assert.AreEqual(3, arr.Length());
    }

    [TestMethod]
    public void ZeroLength_SetsLengthToZero()
    {
        // Arrange
        Array arr = new Array(5);

        // Act
        arr.ZeroLength();

        // Assert
        Assert.AreEqual(0, arr.Length());
        Assert.Throws<IndexOutOfRangeException>(() => arr.GetElement(0));
    }

    [TestMethod]
    public void Push_AddsElementToEndAndIncreasesLength()
    {
        // Arrange
        Array arr = new Array(2);
        arr.SetElement(0, "A");
        arr.SetElement(1, "B");

        // Act
        arr.Push("C");

        // Assert
        Assert.AreEqual(3, arr.Length());
        Assert.AreEqual("C", arr.GetElement(2));
        Assert.AreEqual("A", arr.GetElement(0));
    }
}
