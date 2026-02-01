using System.Linq;
using WpfApp1.models;

namespace WpfApp1.Services
{
    public class ProductionPlanningService
    {
        private intergrirovanieEntities _db;

        public ProductionPlanningService(intergrirovanieEntities db)
        {
            _db = db;
        }

        public void GenerateStages(int productionOrderId)
        {
            var order = _db.ProductionOrder.FirstOrDefault(x => x.ProductionOrderId == productionOrderId);
            if (order == null) return;

            bool any = _db.ProductionStage.Any(s => s.ProductionOrderId == productionOrderId);
            if (any) return;

            _db.ProductionStage.Add(new ProductionStage { ProductionOrderId = productionOrderId, SeqNo = 1, StageType = "prep", Status = "planned" });
            _db.ProductionStage.Add(new ProductionStage { ProductionOrderId = productionOrderId, SeqNo = 2, StageType = "assembly", Status = "planned" });
            _db.ProductionStage.Add(new ProductionStage { ProductionOrderId = productionOrderId, SeqNo = 3, StageType = "test", Status = "planned" });
            _db.ProductionStage.Add(new ProductionStage { ProductionOrderId = productionOrderId, SeqNo = 4, StageType = "pack", Status = "planned" });

            _db.SaveChanges();
        }
    }
}
