using System.Windows;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.Services;

namespace WpfApp1.ViewModels
{
    public class LoginViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public string Username { get; set; }
        public string Password { get; set; }
        public string Error { get; set; }

        public RelayCommand LoginCommand { get; private set; }

        public LoginViewModel(UnitOfWork uow)
        {
            _uow = uow;
            Username = "";
            Password = "";
            Error = "";

            LoginCommand = new RelayCommand(Login);
        }

        private void Login(object param)
        {
            Error = "";
            OnPropertyChanged("Error");

            AuthService auth = new AuthService(_uow.Db);
            var res = auth.Login(Username, Password);

            if (res == null)
            {
                Error = "Неверный логин или пароль.";
                OnPropertyChanged("Error");
                return;
            }

            Window loginWindow = param as Window;
            MainWindow mw = new MainWindow(res.User, res.Roles);
            mw.Show();

            if (loginWindow != null)
                loginWindow.Close();
        }
    }
}
