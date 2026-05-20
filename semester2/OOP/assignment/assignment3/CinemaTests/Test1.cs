using Microsoft.VisualStudio.TestTools.UnitTesting;
using CinemaBooking;

namespace CinemaBooking.Tests
{
    [TestClass]
    public class CinemaTests
    {
        [TestMethod]
        public void RoomFactory_CreatesSmallRoom()
        {
            Room testRoom = RoomFactory.CreateRoom("Small");
            
            Assert.AreEqual(RoomCategory.Small, testRoom.Category);
        }

        [TestMethod]
        public void Seat_InitialState_IsFree()
        {
            Seat testSeat = new Seat('A', 1);
            
            Assert.AreEqual(SeatState.Free, testSeat.State);
        }

        [TestMethod]
        public void Seat_TransitionToBooked_Success()
        {
            Seat testSeat = new Seat('A', 1);
            
            testSeat.TransitionToBooked();
            
            Assert.AreEqual(SeatState.Booked, testSeat.State);
        }

        [TestMethod]
        public void Seat_TransitionToSold_FromFree_Success()
        {
            Seat testSeat = new Seat('A', 1);
            
            testSeat.TransitionToSold();
            
            Assert.AreEqual(SeatState.Sold, testSeat.State);
        }

        [TestMethod]
        public void Seat_TransitionToSold_FromBooked_Success()
        {
            Seat testSeat = new Seat('A', 1);
            
            testSeat.TransitionToBooked();
            testSeat.TransitionToSold();
            
            Assert.AreEqual(SeatState.Sold, testSeat.State);
        }

        [TestMethod]
        public void Show_CalculatesCorrectFreeCount()
        {
            Room testRoom = RoomFactory.CreateRoom("Small");
            testRoom.RowCount = 2;
            testRoom.SeatsPerRow = 2;
            Show testShow = new Show("Test1", "Test Film", "12:00", testRoom);

            int freeCount = testShow.GetFreeCount();

            Assert.AreEqual(4, freeCount);
        }
    }
}
