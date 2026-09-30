using System.Numerics;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Hunt.Model;
using System.Threading.Tasks;

namespace Hunt.Test
{
    [TestClass]
    public sealed class Test1
    {
        public class MockDataAccess : IHuntDataAccess
        {
            public Task SaveAsync(string path, Field[,] board, Player currentPlayer, int rounds) => Task.CompletedTask;
            public Task<(Field[,] board, Player currentPlayer, int rounds)> LoadAsync(string path)
                => Task.FromResult((new Field[3, 3], Player.Escaper, 0));
        }

        [TestClass]
        public class HuntGameModelTests
        {
            private HuntGameModel _model;

            [TestInitialize]
            public void Setup()
            {
                _model = new HuntGameModel(new MockDataAccess());
            }

            [TestMethod]
            public void NewGame_SetsCorrectInitialState()
            {
                _model.NewGame(3);

                Assert.AreEqual(3, _model.BoardSize);
                Assert.AreEqual(0, _model.Rounds);
                Assert.AreEqual(Player.Escaper, _model.CurrentPlayer);
                Assert.AreEqual(Field.Escaper, _model.Board[1, 1]);
                Assert.AreEqual(Field.Attacker, _model.Board[0, 0]);
            }

            [TestMethod]
            public void Move_ValidMove_ChangesPlayerAndBoard()
            {
                _model.NewGame(3);
                _model.Move(1, 1, 1, 2);

                Assert.AreEqual(Field.Empty, _model.Board[1, 1]);
                Assert.AreEqual(Field.Escaper, _model.Board[1, 2]);
                Assert.AreEqual(Player.Attacker, _model.CurrentPlayer);
                Assert.AreEqual(0, _model.Rounds);
            }

            [TestMethod]
            public void Move_InvalidMove_DoesNothing()
            {
                _model.NewGame(3);
                _model.Move(1, 1, 0, 0);

                Assert.AreEqual(Field.Escaper, _model.Board[1, 1]);
                Assert.AreEqual(Player.Escaper, _model.CurrentPlayer);
            }

            [TestMethod]
            public void GameOver_AttackerWins_WhenEscaperBlocked()
            {
                _model.NewGame(3);
                bool isGameOverFired = false;
                Player? winner = null;

                _model.GameOver += (sender, e) =>
                {
                    isGameOverFired = e.IsGameOver;
                    winner = e.Winner;
                };

                _model.Move(1, 1, 0, 1);
                _model.Move(0, 0, 0, 1);
            }
        }
    }
}
