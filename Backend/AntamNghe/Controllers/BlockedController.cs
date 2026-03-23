using Microsoft.AspNetCore.Mvc;
using AntamNghe.Domain.Entities;
using AntamNghe.Infrastructure.Data;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BlockedController : ControllerBase
    {
        private readonly AppDbContext _context;
        public BlockedController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            return Ok(_context.BlockedNumbers.OrderByDescending(v => v.CreatedAt).ToList());
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var blocked = _context.BlockedNumbers.Find(id);
            if (blocked == null) return NotFound();
            return Ok(blocked);
        }

        [HttpPost]
        public IActionResult Create([FromBody] BlockedNumber blocked)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            blocked.CreatedAt = DateTime.UtcNow;
            _context.BlockedNumbers.Add(blocked);
            _context.SaveChanges();
            return CreatedAtAction(nameof(Get), new { id = blocked.Id }, blocked);
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] BlockedNumber blocked)
        {
            var existing = _context.BlockedNumbers.Find(id);
            if (existing == null) return NotFound();
            existing.PhoneNumber = blocked.PhoneNumber;
            existing.Note = blocked.Note;
            _context.SaveChanges();
            return Ok(existing);
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var blocked = _context.BlockedNumbers.Find(id);
            if (blocked == null) return NotFound();
            _context.BlockedNumbers.Remove(blocked);
            _context.SaveChanges();
            return NoContent();
        }
    }
}