using Microsoft.AspNetCore.Mvc;
using AntamNghe.Infrastructure.Data;
using AntamNghe.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SpamReportsController : ControllerBase
    {
        private readonly AppDbContext _db;
        public SpamReportsController(AppDbContext db)
        {
            _db = db;
        }

        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _db.SpamReports.OrderByDescending(s => s.ReportedAt).ToListAsync();
            return Ok(list);
        }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] SpamReport model)
        {
            if (string.IsNullOrWhiteSpace(model.PhoneNumber))
                return BadRequest("PhoneNumber is required");

            model.ReportedAt = DateTime.UtcNow;
            _db.SpamReports.Add(model);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetAll), new { id = model.Id }, model);
        }
    }
}
