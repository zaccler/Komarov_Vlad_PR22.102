using System.Collections.Generic;
using System.Windows;
using WpfApp1.Data;
using WpfApp1.models;
using WpfApp1.ViewModels;

namespace WpfApp1
{
    public partial class MainWindow : Window
    {
        public MainWindow(Users user, List<string> roles)
        {
            InitializeComponent();
            DataContext = new MainViewModel(new UnitOfWork(), user, roles);
        }
    }
}
