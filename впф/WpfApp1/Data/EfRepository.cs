using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using WpfApp1.models;

namespace WpfApp1.Data
{
    public class EfRepository<T> where T : class
    {
        private intergrirovanieEntities _db;
        private DbSet<T> _set;

        public EfRepository(intergrirovanieEntities db)
        {
            _db = db;
            _set = _db.Set<T>();
        }

        public List<T> GetAll()
        {
            return _set.ToList();
        }

        public void Add(T entity)
        {
            _set.Add(entity);
        }

        public void Remove(T entity)
        {
            _set.Remove(entity);
        }
    }
}
