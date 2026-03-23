using Microsoft.AspNetCore.Mvc;
using AntamNghe.Domain.Entities;
using AntamNghe.Infrastructure.Data;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CallHistoryController : ControllerBase
    {
        private readonly AppDbContext _context;
        public CallHistoryController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            return Ok(_context.CallHistories.OrderByDescending(v => v.CallTime).ToList());
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var item = _context.CallHistories.Find(id);
            if (item == null) return NotFound();
            return Ok(item);
        }

        [HttpPost]
        public IActionResult Create([FromBody] CallHistory item)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            item.CallTime = DateTime.UtcNow;
            _context.CallHistories.Add(item);
            _context.SaveChanges();
            return CreatedAtAction(nameof(Get), new { id = item.Id }, item);
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] CallHistory item)
        {
            var existing = _context.CallHistories.Find(id);
            if (existing == null) return NotFound();
            existing.PhoneNumber = item.PhoneNumber;
            existing.Note = item.Note;
            existing.CallTime = item.CallTime;
            _context.SaveChanges();
            return Ok(existing);
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var item = _context.CallHistories.Find(id);
            if (item == null) return NotFound();
            _context.CallHistories.Remove(item);
            _context.SaveChanges();
            return NoContent();
        }
    }
}