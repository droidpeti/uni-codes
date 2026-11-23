using System.Text;

namespace TicTacToe.Persistence;

public class FileGameDataAccess : IGameDataAccess
{
    private const char EmptyChar = '.';
    private const char FirstChar = 'X';
    private const char SecondChar = 'O';
    private const int HeaderLineCount = 4;

    public async Task<GameData> LoadAsync(string path)
    {
        try
        {
            string[] lines = await File.ReadAllLinesAsync(path);
            if (lines.Length <= HeaderLineCount)
            {
                throw new GameDataException("The file is incomplete.");
            }

            int size = int.Parse(lines[0]);
            int currentPlayer = int.Parse(lines[1]);
            int firstPlayerSeconds = int.Parse(lines[2]);
            int secondPlayerSeconds = int.Parse(lines[3]);

            if (size < 1 || lines.Length != size + HeaderLineCount)
            {
                throw new GameDataException("The number of board rows is invalid.");
            }

            int[,] board = new int[size, size];
            for (int row = 0; row < size; row++)
            {
                string line = lines[row + HeaderLineCount];
                if (line.Length != size)
                {
                    throw new GameDataException("A board row has an invalid length.");
                }

                for (int column = 0; column < size; column++)
                {
                    board[row, column] = ParseCell(line[column]);
                }
            }

            return new GameData(size, board, currentPlayer, firstPlayerSeconds, secondPlayerSeconds);
        }
        catch (GameDataException)
        {
            throw;
        }
        catch (Exception ex)
        {
            throw new GameDataException("The game file could not be read.", ex);
        }
    }

    public async Task SaveAsync(string path, GameData data)
    {
        try
        {
            List<string> lines = new()
            {
                data.Size.ToString(),
                data.CurrentPlayer.ToString(),
                data.FirstPlayerSeconds.ToString(),
                data.SecondPlayerSeconds.ToString()
            };

            for (int row = 0; row < data.Size; row++)
            {
                StringBuilder builder = new();
                for (int column = 0; column < data.Size; column++)
                {
                    builder.Append(ToChar(data.Board[row, column]));
                }

                lines.Add(builder.ToString());
            }

            await File.WriteAllLinesAsync(path, lines);
        }
        catch (Exception ex)
        {
            throw new GameDataException("The game could not be saved.", ex);
        }
    }

    private static int ParseCell(char value)
    {
        switch (value)
        {
            case EmptyChar:
                return 0;
            case FirstChar:
                return 1;
            case SecondChar:
                return 2;
            default:
                throw new GameDataException("The board contains an invalid character.");
        }
    }

    private static char ToChar(int value)
    {
        switch (value)
        {
            case 1:
                return FirstChar;
            case 2:
                return SecondChar;
            default:
                return EmptyChar;
        }
    }
}
