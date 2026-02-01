using System.Collections.Generic;
using System.Linq;
using WpfApp1.models;

namespace WpfApp1.Services
{
    public class AuthResult
    {
        public Users User;
        public List<string> Roles;
    }

    public class AuthService
    {
        private intergrirovanieEntities _db;

        public AuthService(intergrirovanieEntities db)
        {
            _db = db;
        }

        public AuthResult Login(string username, string password)
        {
            // Упрощение для учебного проекта:
            // PasswordHash сравниваем как обычную строку.
            Users u = _db.Users.FirstOrDefault(x => x.Username == username && x.IsActive);
            if (u == null) return null;
            if (u.PasswordHash != password) return null;

            List<string> roles = _db.UserRole
                .Where(ur => ur.UserId == u.UserId)
                .Select(ur => ur.Role.Name)
                .ToList();

            AuthResult res = new AuthResult();
            res.User = u;
            res.Roles = roles;
            return res;
        }
    }
}
