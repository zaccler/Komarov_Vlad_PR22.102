using System.Windows;
using WpfApp1.Data;
using WpfApp1.ViewModels;

namespace WpfApp1.Views
{
    public partial class LoginWindow : Window
    {
        public LoginWindow()
        {
            InitializeComponent();
            DataContext = new LoginViewModel(new UnitOfWork());
        }

        private void Pwd_PasswordChanged(object sender, RoutedEventArgs e)
        {
            var vm = DataContext as LoginViewModel;
            if (vm != null)
                vm.Password = Pwd.Password;
        }
    }
}
