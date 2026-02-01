using System.Collections.ObjectModel;
using System.Linq;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.models;

namespace WpfApp1.ViewModels
{
    public class QualityViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public ObservableCollection<QualityDefect> Items { get; set; }

        private QualityDefect _selected;
        public QualityDefect Selected
        {
            get { return _selected; }
            set { _selected = value; OnPropertyChanged("Selected"); }
        }

        public RelayCommand LoadCommand { get; private set; }
        public RelayCommand AddCommand { get; private set; }
        public RelayCommand SaveCommand { get; private set; }
        public RelayCommand DeleteCommand { get; private set; }

        public QualityViewModel(UnitOfWork uow)
        {
            _uow = uow;
            LoadCommand = new RelayCommand(Load);
            AddCommand = new RelayCommand(Add);
            SaveCommand = new RelayCommand(Save);
            DeleteCommand = new RelayCommand(Delete, CanDelete);

            Load(null);
        }

        private void Load(object p)
        {
            Items = new ObservableCollection<QualityDefect>(_uow.QualityDefects.GetAll());
            OnPropertyChanged("Items");
            Selected = Items.FirstOrDefault();
        }

        private void Add(object p)
        {
            QualityDefect d = new QualityDefect();
            d.ProductionStageId = 1;
            d.Description = "Новый дефект";
            d.Severity = "medium";
            d.Decision = "repair";
            d.QtyAffected = 1;

            _uow.QualityDefects.Add(d);
            Items.Add(d);
            Selected = d;
        }

        private bool CanDelete(object p) { return Selected != null; }

        private void Delete(object p)
        {
            if (Selected == null) return;
            _uow.QualityDefects.Remove(Selected);
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
