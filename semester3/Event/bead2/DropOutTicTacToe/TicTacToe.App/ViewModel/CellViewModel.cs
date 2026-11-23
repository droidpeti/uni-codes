namespace TicTacToe.ViewModel;

public class CellViewModel : ViewModelBase
{
    private string _text = string.Empty;
    private bool _isWinning;

    public CellViewModel(int row, int column)
    {
        Row = row;
        Column = column;
    }

    public int Row { get; }

    public int Column { get; }

    public string Text
    {
        get => _text;
        set
        {
            if (_text != value)
            {
                _text = value;
                OnPropertyChanged();
            }
        }
    }

    public bool IsWinning
    {
        get => _isWinning;
        set
        {
            if (_isWinning != value)
            {
                _isWinning = value;
                OnPropertyChanged();
            }
        }
    }
}
