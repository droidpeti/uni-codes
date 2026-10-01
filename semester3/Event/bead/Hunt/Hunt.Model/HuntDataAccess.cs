using System;
using System.IO;
using System.Threading.Tasks;

namespace Hunt.Model
{
    public class HuntDataAccess : IHuntDataAccess
    {
        public async Task SaveAsync(string path, Field[,] board, Player currentPlayer, int rounds)
        {
            using (StreamWriter writer = new StreamWriter(path))
            {
                int size = board.GetLength(0);
                await writer.WriteLineAsync($"{size} {(int)currentPlayer} {rounds}");
                for (int i = 0; i < size; i++)
                {
                    for (int j = 0; j < size; j++)
                    {
                        await writer.WriteAsync($"{(int)board[i, j]} ");
                    }
                    await writer.WriteLineAsync();
                }
            }
        }

        public async Task<(Field[,] board, Player currentPlayer, int rounds)> LoadAsync(string path)
        {
            using (StreamReader reader = new StreamReader(path))
            {
                string[] header = (await reader.ReadLineAsync()).Split();
                int size = int.Parse(header[0]);
                Player currentPlayer = (Player)int.Parse(header[1]);
                int rounds = int.Parse(header[2]);

                Field[,] board = new Field[size, size];
                for (int i = 0; i < size; i++)
                {
                    string[] line = (await reader.ReadLineAsync()).Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
                    for (int j = 0; j < size; j++)
                    {
                        board[i, j] = (Field)int.Parse(line[j]);
                    }
                }
                return (board, currentPlayer, rounds);
            }
        }
    }
}
