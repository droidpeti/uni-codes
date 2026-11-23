using TicTacToe.Model;

namespace TicTacToe.ViewModel;

public class MainViewModel : ViewModelBase
{
    private readonly GameModel _model;
    private CellViewModel[,] _cellMap = new CellViewModel[0, 0];
    private IReadOnlyList<CellViewModel> _cells = Array.Empty<CellViewModel>();

    public MainViewModel(GameModel model)
    {
        _model = model;
        _model.GameStarted += OnGameStarted;
        _model.CellChanged += OnCellChanged;
        _model.PlayerChanged += OnPlayerChanged;
        _model.TimeChanged += OnTimeChanged;
        _model.PauseChanged += OnPauseChanged;
        _model.GameOver += OnGameOver;

        NewGameCommand = new DelegateCommand(parameter => _model.NewGame(Convert.ToInt32(parameter)));
        PauseCommand = new DelegateCommand(TogglePause, () => !_model.IsGameOver);
        SaveGameCommand = new DelegateCommand(RequestSave, () => !_model.IsGameOver);
        LoadGameCommand = new DelegateCommand(RequestLoad);
        ExitCommand = new DelegateCommand(() => ExitRequested?.Invoke(this, EventArgs.Empty));
        StepCommand = new DelegateCommand(ExecuteStep, CanStep);

        BuildBoard();
    }

    public event EventHandler? SaveGameRequested;

    public event EventHandler? LoadGameRequested;

    public event EventHandler? ExitRequested;

    public event EventHandler<MessageEventArgs>? GameFinished;

    public DelegateCommand NewGameCommand { get; }

    public DelegateCommand PauseCommand { get; }

    public DelegateCommand SaveGameCommand { get; }

    public DelegateCommand LoadGameCommand { get; }

    public DelegateCommand ExitCommand { get; }

    public DelegateCommand StepCommand { get; }

    public IReadOnlyList<CellViewModel> Cells => _cells;

    public int Size => _model.Size;

    public string PauseMenuText => _model.IsPaused ? "_Resume" : "_Pause";

    public string StatusText
    {
        get
        {
            switch (_model.Status)
            {
                case GameStatus.FirstPlayerWon:
                    return "Player X wins!";
                case GameStatus.SecondPlayerWon:
                    return "Player O wins!";
                case GameStatus.Draw:
                    return "The game is a draw.";
                default:
                    string next = "Next: Player " + Symbol(_model.CurrentPlayer);
                    return _model.IsPaused ? "Game paused. " + next : next;
            }
        }
    }

    public string FirstPlayerTime => FormatTime(_model.GetThinkingTime(Player.First));

    public string SecondPlayerTime => FormatTime(_model.GetThinkingTime(Player.Second));

    private void TogglePause()
    {
        if (_model.IsPaused)
        {
            _model.Resume();
        }
        else
        {
            _model.Pause();
        }
    }

    private void RequestSave()
    {
        _model.Pause();
        SaveGameRequested?.Invoke(this, EventArgs.Empty);
    }

    private void RequestLoad()
    {
        _model.Pause();
        LoadGameRequested?.Invoke(this, EventArgs.Empty);
    }

    private void ExecuteStep(object? parameter)
    {
        if (parameter is CellViewModel cell)
        {
            _model.Step(cell.Row, cell.Column);
        }
    }

    private bool CanStep(object? parameter)
    {
        return parameter is CellViewModel cell
               && cell.Text.Length == 0
               && !_model.IsPaused
               && !_model.IsGameOver;
    }

    private void BuildBoard()
    {
        int size = _model.Size;
        CellViewModel[,] map = new CellViewModel[size, size];
        List<CellViewModel> list = new(size * size);

        for (int row = 0; row < size; row++)
        {
            for (int column = 0; column < size; column++)
            {
                CellViewModel cell = new(row, column)
                {
                    Text = Symbol(_model.GetCell(row, column))
                };
                map[row, column] = cell;
                list.Add(cell);
            }
        }

        _cellMap = map;
        _cells = list;
    }

    private void RefreshState()
    {
        OnPropertyChanged(nameof(StatusText));
        OnPropertyChanged(nameof(FirstPlayerTime));
        OnPropertyChanged(nameof(SecondPlayerTime));
        OnPropertyChanged(nameof(PauseMenuText));
        RefreshCommands();
    }

    private void RefreshCommands()
    {
        StepCommand.RaiseCanExecuteChanged();
        PauseCommand.RaiseCanExecuteChanged();
        SaveGameCommand.RaiseCanExecuteChanged();
    }

    private void OnGameStarted(object? sender, EventArgs e)
    {
        BuildBoard();
        OnPropertyChanged(nameof(Size));
        OnPropertyChanged(nameof(Cells));
        RefreshState();
    }

    private void OnCellChanged(object? sender, CellChangedEventArgs e)
    {
        _cellMap[e.Row, e.Column].Text = Symbol(e.Player);
    }

    private void OnPlayerChanged(object? sender, EventArgs e)
    {
        OnPropertyChanged(nameof(StatusText));
    }

    private void OnTimeChanged(object? sender, EventArgs e)
    {
        OnPropertyChanged(nameof(FirstPlayerTime));
        OnPropertyChanged(nameof(SecondPlayerTime));
    }

    private void OnPauseChanged(object? sender, EventArgs e)
    {
        OnPropertyChanged(nameof(StatusText));
        OnPropertyChanged(nameof(PauseMenuText));
        RefreshCommands();
    }

    private void OnGameOver(object? sender, GameOverEventArgs e)
    {
        foreach ((int row, int column) in e.WinningCells)
        {
            _cellMap[row, column].IsWinning = true;
        }

        OnPropertyChanged(nameof(StatusText));
        RefreshCommands();
        GameFinished?.Invoke(this, new MessageEventArgs(StatusText));
    }

    private static string Symbol(Player player)
    {
        switch (player)
        {
            case Player.First:
                return "X";
            case Player.Second:
                return "O";
            default:
                return string.Empty;
        }
    }

    private static string FormatTime(TimeSpan time)
    {
        return $"{(int)time.TotalHours:00}:{time.Minutes:00}:{time.Seconds:00}";
    }
}
