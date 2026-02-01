using System.Collections.ObjectModel;
using System.Linq;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.models;

namespace WpfApp1.ViewModels
{
    public class SuppliersViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public ObservableCollection<Supplier> Items { get; set; }

        private Supplier _selected;
        public Supplier Selected
        {
            get { return _selected; }
            set { _selected = value; OnPropertyChanged("Selected"); }
        }

        public RelayCommand LoadCommand { get; private set; }
        public RelayCommand AddCommand { get; private set; }
        public RelayCommand DeleteCommand { get; private set; }
        public RelayCommand SaveCommand { get; private set; }

        public SuppliersViewModel(UnitOfWork uow)
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
            Items = new ObservableCollection<Supplier>(_uow.Suppliers.GetAll());
            OnPropertyChanged("Items");
            Selected = Items.FirstOrDefault();
        }

        private void Add(object p)
        {
            Supplier s = new Supplier();
            s.Inn = "0000000000";
            s.Name = "Новый поставщик";
            s.Contacts = "";
            s.Rating = 3;
            s.PayTerms = "Предоплата";

            _uow.Suppliers.Add(s);
            Items.Add(s);
            Selected = s;
        }

        private bool CanDelete(object p) { return Selected != null; }

        private void Delete(object p)
        {
            if (Selected == null) return;
            _uow.Suppliers.Remove(Selected);
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
