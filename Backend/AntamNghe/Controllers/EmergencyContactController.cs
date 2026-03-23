using Microsoft.AspNetCore.Mvc;
using AntamNghe.Domain.Entities;
using AntamNghe.Infrastructure.Data;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmergencyContactController : ControllerBase
    {
        private readonly AppDbContext _context;
        public EmergencyContactController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            return Ok(_context.EmergencyContacts.OrderByDescending(v => v.CreatedAt).ToList());
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var item = _context.EmergencyContacts.Find(id);
            if (item == null) return NotFound();
            return Ok(item);
        }

        [HttpPost]
        public IActionResult Create([FromBody] EmergencyContact item)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            item.CreatedAt = DateTime.UtcNow;
            _context.EmergencyContacts.Add(item);
            _context.SaveChanges();
            return CreatedAtAction(nameof(Get), new { id = item.Id }, item);
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] EmergencyContact item)
        {
            var existing = _context.EmergencyContacts.Find(id);
            if (existing == null) return NotFound();
            existing.PhoneNumber = item.PhoneNumber;
            existing.Name = item.Name;
            existing.Note = item.Note;
            _context.SaveChanges();
            return Ok(existing);
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var item = _context.EmergencyContacts.Find(id);
            if (item == null) return NotFound();
            _context.EmergencyContacts.Remove(item);
            _context.SaveChanges();
            return NoContent();
        }
    }
}