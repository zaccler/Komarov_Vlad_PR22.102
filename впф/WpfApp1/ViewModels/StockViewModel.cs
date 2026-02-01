using System.Collections.ObjectModel;
using WpfApp1.Core;
using WpfApp1.Data;
using WpfApp1.models;

namespace WpfApp1.ViewModels
{
    public class StockViewModel : ViewModelBase
    {
        private UnitOfWork _uow;

        public ObservableCollection<StockBalance> Items { get; set; }
        public RelayCommand LoadCommand { get; private set; }

        public StockViewModel(UnitOfWork uow)
        {
            _uow = uow;
            LoadCommand = new RelayCommand(Load);
            Load(null);
        }

        private void Load(object p)
        {
            Items = new ObservableCollection<StockBalance>(_uow.StockBalances.GetAll());
            OnPropertyChanged("Items");
        }
    }
}
