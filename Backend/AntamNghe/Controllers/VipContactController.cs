using Microsoft.AspNetCore.Mvc;
using AntamNghe.Domain.Entities;
using AntamNghe.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VipContactController : ControllerBase
    {
        private readonly AppDbContext _context;

        public VipContactController(AppDbContext context)
        {
            _context = context;
        }

        public class VipContactRequest
        {
            public int UserId { get; set; }
            public string Phone { get; set; } = string.Empty;
            public string? Name { get; set; }
        }

        [HttpGet]
        public IActionResult GetAll([FromQuery] int? userId)
        {
            var query = _context.VipContacts.AsNoTracking();
            if (userId.HasValue)
            {
                query = query.Where(x => x.UserId == userId.Value);
            }

            var items = query
                .OrderBy(x => x.Name)
                .ThenBy(x => x.Phone)
                .Select(x => new { x.Id, x.UserId, x.Name, x.Phone })
                .ToList();

            return Ok(items);
        }

        [HttpGet("{id:int}")]
        public IActionResult Get(int id)
        {
            var item = _context.VipContacts
                .AsNoTracking()
                .Where(x => x.Id == id)
                .Select(x => new { x.Id, x.UserId, x.Name, x.Phone })
                .FirstOrDefault();

            return item == null ? NotFound() : Ok(item);
        }

        [HttpPost]
        public IActionResult Create([FromBody] VipContactRequest model)
        {
            if (string.IsNullOrWhiteSpace(model.Phone))
            {
                return BadRequest(new { message = "Phone is required" });
            }

            var entity = new VipContact
            {
                UserId = model.UserId,
                Phone = model.Phone.Trim(),
                Name = string.IsNullOrWhiteSpace(model.Name) ? model.Phone.Trim() : model.Name.Trim(),
            };

            _context.VipContacts.Add(entity);
            _context.SaveChanges();

            return CreatedAtAction(nameof(Get), new { id = entity.Id }, new
            {
                entity.Id,
                entity.UserId,
                entity.Name,
                entity.Phone,
            });
        }

        [HttpPut("{id:int}")]
        public IActionResult Update(int id, [FromBody] VipContactRequest model)
        {
            if (string.IsNullOrWhiteSpace(model.Phone))
            {
                return BadRequest(new { message = "Phone is required" });
            }

            var entity = _context.VipContacts.Find(id);
            if (entity == null) return NotFound();

            entity.UserId = model.UserId;
            entity.Phone = model.Phone.Trim();
            entity.Name = string.IsNullOrWhiteSpace(model.Name) ? model.Phone.Trim() : model.Name.Trim();
            _context.SaveChanges();

            return Ok(new
            {
                entity.Id,
                entity.UserId,
                entity.Name,
                entity.Phone,
            });
        }

        [HttpDelete("{id:int}")]
        public IActionResult Delete(int id)
        {
            var entity = _context.VipContacts.Find(id);
            if (entity == null) return NotFound();

            _context.VipContacts.Remove(entity);
            _context.SaveChanges();
            return NoContent();
        }
    }
}