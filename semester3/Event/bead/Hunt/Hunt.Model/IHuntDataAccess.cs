using System.Threading.Tasks;

namespace Hunt.Model
{
    public interface IHuntDataAccess
    {
        Task SaveAsync(string path, Field[,] board, Player currentPlayer, int rounds);
        Task<(Field[,] board, Player currentPlayer, int rounds)> LoadAsync(string path);
    }
}
