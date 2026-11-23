using System.Windows;
using Microsoft.Win32;
using TicTacToe.Model;
using TicTacToe.Persistence;
using TicTacToe.View;
using TicTacToe.ViewModel;

namespace TicTacToe;

public partial class App : Application
{
    private const string Caption = "Drop-Out Tic-Tac-Toe";
    private const string FileFilter = "Game files (*.dtt)|*.dtt";

    private GameModel _model = null!;
    private MainViewModel _viewModel = null!;
    private MainWindow _window = null!;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        _model = new GameModel(new FileGameDataAccess());
        _viewModel = new MainViewModel(_model);
        _viewModel.SaveGameRequested += OnSaveGameRequested;
        _viewModel.LoadGameRequested += OnLoadGameRequested;
        _viewModel.GameFinished += OnGameFinished;
        _viewModel.ExitRequested += OnExitRequested;

        _window = new MainWindow { DataContext = _viewModel };
        _window.Show();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _model.Dispose();
        base.OnExit(e);
    }

    private async void OnSaveGameRequested(object? sender, EventArgs e)
    {
        SaveFileDialog dialog = new()
        {
            Title = "Save game",
            Filter = FileFilter,
            DefaultExt = ".dtt"
        };

        if (dialog.ShowDialog() != true)
        {
            return;
        }

        try
        {
            await _model.SaveGameAsync(dialog.FileName);
            MessageBox.Show("The game was saved successfully.", Caption, MessageBoxButton.OK, MessageBoxImage.Information);
        }
        catch (Exception ex) when (ex is GameDataException or InvalidOperationException)
        {
            MessageBox.Show("Saving failed: " + ex.Message, Caption, MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private async void OnLoadGameRequested(object? sender, EventArgs e)
    {
        OpenFileDialog dialog = new()
        {
            Title = "Load game",
            Filter = FileFilter,
            DefaultExt = ".dtt"
        };

        if (dialog.ShowDialog() != true)
        {
            return;
        }

        try
        {
            await _model.LoadGameAsync(dialog.FileName);
        }
        catch (GameDataException ex)
        {
            MessageBox.Show("Loading failed: " + ex.Message, Caption, MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }

    private void OnGameFinished(object? sender, MessageEventArgs e)
    {
        MessageBox.Show(e.Message, Caption, MessageBoxButton.OK, MessageBoxImage.Information);
    }

    private void OnExitRequested(object? sender, EventArgs e)
    {
        Shutdown();
    }
}
