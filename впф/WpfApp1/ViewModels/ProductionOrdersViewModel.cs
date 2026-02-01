using System.Collections.ObjectModel;
using System.Linq;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.models;
using WpfApp1.Services;

namespace WpfApp1.ViewModels
{
    public class ProductionOrdersViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public ObservableCollection<ProductionOrder> Orders { get; set; }
        public ObservableCollection<ProductionStage> Stages { get; set; }

        private ProductionOrder _selectedOrder;
        public ProductionOrder SelectedOrder
        {
            get { return _selectedOrder; }
            set { _selectedOrder = value; OnPropertyChanged("SelectedOrder"); LoadStages(); }
        }

        public RelayCommand LoadCommand { get; private set; }
        public RelayCommand AddCommand { get; private set; }
        public RelayCommand SaveCommand { get; private set; }
        public RelayCommand GenerateStagesCommand { get; private set; }

        public ProductionOrdersViewModel(UnitOfWork uow)
        {
            _uow = uow;

            LoadCommand = new RelayCommand(Load);
            AddCommand = new RelayCommand(Add);
            SaveCommand = new RelayCommand(Save);
            GenerateStagesCommand = new RelayCommand(GenerateStages, CanGenerateStages);

            Load(null);
        }

        private void Load(object p)
        {
            Orders = new ObservableCollection<ProductionOrder>(_uow.ProductionOrders.GetAll());
            OnPropertyChanged("Orders");
            SelectedOrder = Orders.FirstOrDefault();
        }

        private void Add(object p)
        {
            ProductionOrder o = new ProductionOrder();
            o.ClientId = 1;
            o.ProductId = 1;
            o.Qty = 1;
            o.Priority = "normal";
            o.Status = "planned";

            _uow.ProductionOrders.Add(o);
            Orders.Add(o);
            SelectedOrder = o;
        }

        private void Save(object p)
        {
            _uow.Save();
            Load(null);
        }

        private bool CanGenerateStages(object p)
        {
            return SelectedOrder != null && SelectedOrder.ProductionOrderId > 0;
        }

        private void GenerateStages(object p)
        {
            ProductionPlanningService svc = new ProductionPlanningService(_uow.Db);
            svc.GenerateStages(SelectedOrder.ProductionOrderId);
            LoadStages();
        }

        private void LoadStages()
        {
            Stages = new ObservableCollection<ProductionStage>();

            if (SelectedOrder == null)
            {
                OnPropertyChanged("Stages");
                return;
            }

            var list = _uow.Db.ProductionStage
                .Where(s => s.ProductionOrderId == SelectedOrder.ProductionOrderId)
                .OrderBy(s => s.SeqNo)
                .ToList();

            foreach (var s in list) Stages.Add(s);
            OnPropertyChanged("Stages");
        }
    }
}
