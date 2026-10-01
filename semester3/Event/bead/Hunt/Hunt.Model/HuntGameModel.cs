using System;
using System.Collections.Generic;
using System.Text;

namespace Hunt.Model
{
    public class HuntGameModel
    {
        private IHuntDataAccess _dataAccess;
        private Field[,] _board;
        private int _boardSize;
        private Player _currentPlayer;
        private int _rounds;
        private int _maxRounds;

        public event EventHandler<GameEventArgs> GameAdvanced;
        public event EventHandler<GameEventArgs> GameOver;

        public int BoardSize => _boardSize;
        public Field[,] Board => _board;
        public Player CurrentPlayer => _currentPlayer;
        public int Rounds => _rounds;
        public int MaxRounds => _maxRounds;

        public HuntGameModel(IHuntDataAccess dataAccess)
        {
            _dataAccess = dataAccess;
        }

        public void NewGame(int size)
        {
            _boardSize = size;
            _board = new Field[size, size];
            _maxRounds = 4 * size;
            _rounds = 0;
            _currentPlayer = Player.Escaper;

            for (int i = 0; i < size; i++)
                for (int j = 0; j < size; j++)
                    _board[i, j] = Field.Empty;

            _board[0, 0] = Field.Attacker;
            _board[0, size - 1] = Field.Attacker;
            _board[size - 1, 0] = Field.Attacker;
            _board[size - 1, size - 1] = Field.Attacker;

            _board[size / 2, size / 2] = Field.Escaper;

            OnGameAdvanced();
        }

        public void Move(int fromX, int fromY, int toX, int toY)
        {
            if (!IsValidMove(fromX, fromY, toX, toY)) return;

            _board[toX, toY] = _board[fromX, fromY];
            _board[fromX, fromY] = Field.Empty;

            if (_currentPlayer == Player.Attacker)
            {
                _rounds++;
            }

            _currentPlayer = _currentPlayer == Player.Escaper ? Player.Attacker : Player.Escaper;

            CheckGameOver();

            if (!IsGameOver())
                OnGameAdvanced();
        }

        private bool IsValidMove(int fromX, int fromY, int toX, int toY)
        {
            if (fromX < 0 || fromY < 0 || toX < 0 || toY < 0 || fromX >= _boardSize || fromY >= _boardSize || toX >= _boardSize || toY >= _boardSize)
                return false;

            if (_board[toX, toY] != Field.Empty)
                return false;

            if (Math.Abs(fromX - toX) + Math.Abs(fromY - toY) != 1)
                return false;

            if (_currentPlayer == Player.Escaper && _board[fromX, fromY] != Field.Escaper)
                return false;

            if (_currentPlayer == Player.Attacker && _board[fromX, fromY] != Field.Attacker)
                return false;

            return true;
        }

        private void CheckGameOver()
        {
            if (IsEscaperBlocked())
            {
                GameOver?.Invoke(this, new GameEventArgs { IsGameOver = true, Winner = Player.Attacker, RoundsPlayed = _rounds });
                return;
            }

            if (_rounds >= _maxRounds)
            {
                GameOver?.Invoke(this, new GameEventArgs { IsGameOver = true, Winner = Player.Escaper, RoundsPlayed = _rounds });
                return;
            }
        }

        private bool IsGameOver()
        {
            return IsEscaperBlocked() || _rounds >= _maxRounds;
        }

        private bool IsEscaperBlocked()
        {
            int ex = -1, ey = -1;
            for (int i = 0; i < _boardSize; i++)
            {
                for (int j = 0; j < _boardSize; j++)
                {
                    if (_board[i, j] == Field.Escaper)
                    {
                        ex = i; ey = j; break;
                    }
                }
            }

            int[] dx = { -1, 1, 0, 0 };
            int[] dy = { 0, 0, -1, 1 };

            for (int i = 0; i < 4; i++)
            {
                int nx = ex + dx[i];
                int ny = ey + dy[i];
                if (nx >= 0 && ny >= 0 && nx < _boardSize && ny < _boardSize && _board[nx, ny] == Field.Empty)
                {
                    return false;
                }
            }
            return true;
        }

        public async Task SaveGameAsync(string path)
        {
            if (_dataAccess != null)
                await _dataAccess.SaveAsync(path, _board, _currentPlayer, _rounds);
        }

        public async Task LoadGameAsync(string path)
        {
            if (_dataAccess != null)
            {
                var data = await _dataAccess.LoadAsync(path);
                _boardSize = data.board.GetLength(0);
                _board = data.board;
                _currentPlayer = data.currentPlayer;
                _rounds = data.rounds;
                _maxRounds = 4 * _boardSize;
                OnGameAdvanced();
            }
        }

        private void OnGameAdvanced()
        {
            GameAdvanced?.Invoke(this, new GameEventArgs { IsGameOver = false, RoundsPlayed = _rounds });
        }
    }
}
