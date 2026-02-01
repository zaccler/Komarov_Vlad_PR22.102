using WpfApp1.models;

namespace WpfApp1.Data
{
    public class UnitOfWork
    {
        public intergrirovanieEntities Db { get; private set; }

        public EfRepository<Product> Products { get; private set; }
        public EfRepository<Material> Materials { get; private set; }
        public EfRepository<Supplier> Suppliers { get; private set; }
        public EfRepository<ProductionOrder> ProductionOrders { get; private set; }
        public EfRepository<ProductionStage> ProductionStages { get; private set; }
        public EfRepository<StockBalance> StockBalances { get; private set; }
        public EfRepository<QualityDefect> QualityDefects { get; private set; }

        public UnitOfWork()
        {
            Db = new intergrirovanieEntities();

            Products = new EfRepository<Product>(Db);
            Materials = new EfRepository<Material>(Db);
            Suppliers = new EfRepository<Supplier>(Db);
            ProductionOrders = new EfRepository<ProductionOrder>(Db);
            ProductionStages = new EfRepository<ProductionStage>(Db);
            StockBalances = new EfRepository<StockBalance>(Db);
            QualityDefects = new EfRepository<QualityDefect>(Db);
        }

        public void Save()
        {
            Db.SaveChanges();
        }
    }
}
