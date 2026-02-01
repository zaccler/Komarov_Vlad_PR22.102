using System.Collections.ObjectModel;
using System.Linq;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.models;

namespace WpfApp1.ViewModels
{
    public class MaterialsViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public ObservableCollection<Material> Items { get; set; }

        private Material _selected;
        public Material Selected
        {
            get { return _selected; }
            set { _selected = value; OnPropertyChanged("Selected"); }
        }

        public RelayCommand LoadCommand { get; private set; }
        public RelayCommand AddCommand { get; private set; }
        public RelayCommand DeleteCommand { get; private set; }
        public RelayCommand SaveCommand { get; private set; }

        public MaterialsViewModel(UnitOfWork uow)
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
            Items = new ObservableCollection<Material>(_uow.Materials.GetAll());
            OnPropertyChanged("Items");
            Selected = Items.FirstOrDefault();
        }

        private void Add(object p)
        {
            Material m = new Material();
            m.Code = "M-NEW";
            m.Name = "Новый материал";
            m.Type = "raw";
            m.Unit = "кг";
            m.MinQty = 0;
            m.MarketPrice = 0;

            _uow.Materials.Add(m);
            Items.Add(m);
            Selected = m;
        }

        private bool CanDelete(object p) { return Selected != null; }

        private void Delete(object p)
        {
            if (Selected == null) return;
            _uow.Materials.Remove(Selected);
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
