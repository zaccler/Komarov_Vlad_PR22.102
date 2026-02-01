using System.Collections.ObjectModel;
using System.Linq;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.models;

namespace WpfApp1.ViewModels
{
    public class ProductsViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public ObservableCollection<Product> Items { get; set; }

        private Product _selected;
        public Product Selected
        {
            get { return _selected; }
            set { _selected = value; OnPropertyChanged("Selected"); }
        }

        public RelayCommand LoadCommand { get; private set; }
        public RelayCommand AddCommand { get; private set; }
        public RelayCommand DeleteCommand { get; private set; }
        public RelayCommand SaveCommand { get; private set; }

        public ProductsViewModel(UnitOfWork uow)
        {
            _uow = uow;

            LoadCommand = new RelayCommand(Load);
            AddCommand = new RelayCommand(Add);
            DeleteCommand = new RelayCommand(Delete, CanDelete);
            SaveCommand = new RelayCommand(Save);

            Load(null);
        }

        private void Load(object p)
        {
            Items = new ObservableCollection<Product>(_uow.Products.GetAll());
            OnPropertyChanged("Items");
            Selected = Items.FirstOrDefault();
        }

        private void Add(object p)
        {
            Product x = new Product();
            x.Article = "PR-NEW";
            x.Name = "Новый продукт";
            x.Category = "Категория";
            x.Unit = "шт";
            x.Status = "active";

            _uow.Products.Add(x);
            Items.Add(x);
            Selected = x;
        }

        private bool CanDelete(object p)
        {
            return Selected != null;
        }

        private void Delete(object p)
        {
            if (Selected == null) return;

            _uow.Products.Remove(Selected);
            Items.Remove(Selected);
            Selected = Items.FirstOrDefault();
        }

        private void Save(object p)
        {
            _uow.Save();
            Load(null);
        }
    }
}
