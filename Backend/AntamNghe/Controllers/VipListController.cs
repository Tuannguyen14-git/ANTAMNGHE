using Microsoft.AspNetCore.Mvc;
using AntamNghe.Domain.Entities;
using AntamNghe.Infrastructure.Data;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VipListController : ControllerBase
    {
        private readonly AppDbContext _context;
        public VipListController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetAll()
        {
            return Ok(_context.VipLists.OrderByDescending(v => v.CreatedAt).ToList());
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            var vip = _context.VipLists.Find(id);
            if (vip == null) return NotFound();
            return Ok(vip);
        }

        [HttpPost]
        public IActionResult Create([FromBody] VipList vip)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            vip.CreatedAt = DateTime.UtcNow;
            _context.VipLists.Add(vip);
            _context.SaveChanges();
            return CreatedAtAction(nameof(Get), new { id = vip.Id }, vip);
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] VipList vip)
        {
            var existing = _context.VipLists.Find(id);
            if (existing == null) return NotFound();
            existing.PhoneNumber = vip.PhoneNumber;
            existing.Name = vip.Name;
            _context.SaveChanges();
            return Ok(existing);
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var vip = _context.VipLists.Find(id);
            if (vip == null) return NotFound();
            _context.VipLists.Remove(vip);
            _context.SaveChanges();
            return NoContent();
        }
    }
}