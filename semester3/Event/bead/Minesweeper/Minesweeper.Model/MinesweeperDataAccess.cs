namespace Minesweeper.Model;

public class MinesweeperDataAccess : IMinesweeperDataAccess
{
    public async Task<(int Size, Player CurrentPlayer, Field[,] Board)> LoadAsync(string path)
    {
        try
        {
            using StreamReader reader = new StreamReader(path);
            string? header = await reader.ReadLineAsync();
            if (string.IsNullOrWhiteSpace(header))
                throw new InvalidDataException("Invalid save file header.");

            string[] parts = header.Split(' ', StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length < 2)
                throw new InvalidDataException("Corrupted save file header.");

            int size = int.Parse(parts[0]);
            Player currentPlayer = Enum.Parse<Player>(parts[1]);

            Field[,] board = new Field[size, size];
            for (int r = 0; r < size; r++)
            {
                string? line = await reader.ReadLineAsync();
                if (string.IsNullOrWhiteSpace(line))
                    throw new InvalidDataException("Missing board row in save file.");

                string[] cells = line.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                if (cells.Length != size)
                    throw new InvalidDataException("Invalid board row length in save file.");

                for (int c = 0; c < size; c++)
                {
                    string[] cellData = cells[c].Split(':');
                    board[r, c] = new Field
                    {
                        IsMine = cellData[0] == "1",
                        IsRevealed = cellData[1] == "1",
                        AdjacentMines = int.Parse(cellData[2])
                    };
                }
            }

            return (size, currentPlayer, board);
        }
        catch (Exception ex)
        {
            throw new IOException("Failed to load the game.", ex);
        }
    }

    public async Task SaveAsync(string path, int size, Player currentPlayer, Field[,] board)
    {
        try
        {
            using StreamWriter writer = new StreamWriter(path);
            await writer.WriteLineAsync($"{size} {currentPlayer}");
            for (int r = 0; r < size; r++)
            {
                string[] row = new string[size];
                for (int c = 0; c < size; c++)
                {
                    Field f = board[r, c];
                    int m = f.IsMine ? 1 : 0;
                    int rev = f.IsRevealed ? 1 : 0;
                    row[c] = $"{m}:{rev}:{f.AdjacentMines}";
                }
                await writer.WriteLineAsync(string.Join(" ", row));
            }
        }
        catch (Exception ex)
        {
            throw new IOException("Failed to save the game.", ex);
        }
    }
}
