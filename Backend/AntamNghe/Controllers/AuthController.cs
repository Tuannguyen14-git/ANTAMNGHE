using Microsoft.AspNetCore.Mvc;
using AntamNghe.Infrastructure.Data;
using AntamNghe.Domain.Entities;
using Microsoft.Extensions.Configuration;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using System.IdentityModel.Tokens.Jwt;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _config;

        public AuthController(AppDbContext context, IConfiguration config)
        {
            _context = context;
            _config = config;
        }

        public class RegisterRequest
        {
            public string Phone { get; set; }
            public string Password { get; set; }
            // optional fields
            public string? Name { get; set; }
            public string? Email { get; set; }
        }

        [HttpPost("register")]
        public IActionResult Register([FromBody] RegisterRequest req)
        {
            if (req == null || string.IsNullOrWhiteSpace(req.Phone) || string.IsNullOrWhiteSpace(req.Password))
                return BadRequest(new { message = "Phone and password are required" });

            // Basic check: unique phone
            var exists = _context.Users.Any(x => x.Phone == req.Phone);
            if (exists)
                return Conflict(new { message = "Phone already registered" });

            // Create user entity and hash password before saving
            var user = new User
            {
                Name = req.Name ?? string.Empty,
                Email = req.Email ?? string.Empty,
                Phone = req.Phone,
                Password = BCrypt.Net.BCrypt.HashPassword(req.Password)
            };

            _context.Users.Add(user);
            _context.SaveChanges();

            return Ok(new { id = user.Id, phone = user.Phone });
        }

        public class LoginRequest
        {
            public string Phone { get; set; }
            public string Password { get; set; }
        }

        [HttpPost("login")]
        public IActionResult Login([FromBody] LoginRequest model)
        {
            if (model == null || string.IsNullOrWhiteSpace(model.Phone) || string.IsNullOrWhiteSpace(model.Password))
                return BadRequest(new { message = "Phone and password are required" });

            var user = _context.Users.FirstOrDefault(x => x.Phone == model.Phone);
            if (user == null)
                return Unauthorized();

            // verify password
            var verified = BCrypt.Net.BCrypt.Verify(model.Password, user.Password);
            if (!verified)
                return Unauthorized();

            // generate JWT
            var token = GenerateJwtToken(user);

            // Trả về đầy đủ thông tin user
            return Ok(new { token, user = new { id = user.Id, phone = user.Phone, name = user.Name, email = user.Email } });
        }

        private string GenerateJwtToken(User user)
        {
            var key = _config["Jwt:Key"];
            var issuer = _config["Jwt:Issuer"];
            var expireMinutes = int.TryParse(_config["Jwt:ExpireMinutes"], out var m) ? m : 60;

            var tokenHandler = new JwtSecurityTokenHandler();
            var keyBytes = Encoding.UTF8.GetBytes(key ?? string.Empty);
            var claims = new[] {
                new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                new Claim(ClaimTypes.Name, user.Phone)
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = System.DateTime.UtcNow.AddMinutes(expireMinutes),
                Issuer = issuer,
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(keyBytes), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}