using System.Collections.Generic;
using System.Linq;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.models;

namespace WpfApp1.ViewModels
{
    public class MainViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public Users CurrentUser { get; private set; }
        public List<string> Roles { get; private set; }

        public string HeaderText
        {
            get
            {
                string r = Roles != null ? string.Join(", ", Roles.ToArray()) : "";
                return "Пользователь: " + CurrentUser.Username + " | Роли: " + r;
            }
        }

        private object _currentViewModel;
        public object CurrentViewModel
        {
            get { return _currentViewModel; }
            set { _currentViewModel = value; OnPropertyChanged("CurrentViewModel"); }
        }

        public RelayCommand OpenProductsCommand { get; private set; }
        public RelayCommand OpenMaterialsCommand { get; private set; }
        public RelayCommand OpenSuppliersCommand { get; private set; }
        public RelayCommand OpenProductionOrdersCommand { get; private set; }
        public RelayCommand OpenStockCommand { get; private set; }
        public RelayCommand OpenQualityCommand { get; private set; }

        public MainViewModel(UnitOfWork uow, Users user, List<string> roles)
        {
            _uow = uow;
            CurrentUser = user;
            Roles = roles;

            OpenProductsCommand = new RelayCommand(OpenProducts);
            OpenMaterialsCommand = new RelayCommand(OpenMaterials);
            OpenSuppliersCommand = new RelayCommand(OpenSuppliers);
            OpenProductionOrdersCommand = new RelayCommand(OpenProductionOrders);
            OpenStockCommand = new RelayCommand(OpenStock);
            OpenQualityCommand = new RelayCommand(OpenQuality);

            CurrentViewModel = new ProductsViewModel(_uow);
            OnPropertyChanged("HeaderText");
        }

        private void OpenProducts(object p) { CurrentViewModel = new ProductsViewModel(_uow); }
        private void OpenMaterials(object p) { CurrentViewModel = new MaterialsViewModel(_uow); }
        private void OpenSuppliers(object p) { CurrentViewModel = new SuppliersViewModel(_uow); }
        private void OpenProductionOrders(object p) { CurrentViewModel = new ProductionOrdersViewModel(_uow); }
        private void OpenStock(object p) { CurrentViewModel = new StockViewModel(_uow); }
        private void OpenQuality(object p) { CurrentViewModel = new QualityViewModel(_uow); }
    }
}
