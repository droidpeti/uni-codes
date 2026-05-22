using CinemaApp;

namespace CinemaTests;

[TestClass]
public sealed class Test
{
    [TestMethod]
        public void VenueFactory_CreatesSmallVenue()
        {
            Venue testVenue = VenueFactory.CreateVenue("Small");
            
            Assert.AreEqual(VenueCategory.Small, testVenue.Category);
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
            Venue testVenue = VenueFactory.CreateVenue("Small");
            testVenue.RowCount = 2;
            testVenue.SeatsPerRow = 2;
            Show testShow = new Show("Test1", "Test Film", "12:00", testVenue);

            int freeCount = testShow.GetFreeCount();

            Assert.AreEqual(4, freeCount);
        }
}
