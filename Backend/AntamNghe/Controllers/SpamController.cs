using AntamNghe.Domain.Entities;
using AntamNghe.Infrastructure.Data;
using Microsoft.AspNetCore.Mvc;
using System.Text;
using System.Text.Json;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SpamController : ControllerBase
    {
        private readonly AppDbContext _context;

        public SpamController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetAllSpam()
        {
            var list = _context.SpamNumbers.ToList();
            return Ok(list);
        }

        [HttpGet("check/{phone}")]
        public IActionResult CheckSpam(string phone)
        {
            var spam = _context.SpamNumbers.FirstOrDefault(x => x.Phone == phone);

            return Ok(new { isSpam = spam != null });
        }

        [HttpPost]
        public IActionResult AddSpam(SpamNumber spam)
        {
            _context.SpamNumbers.Add(spam);
            _context.SaveChanges();

            return Ok(spam);
        }
        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            var spam = _context.SpamNumbers.Find(id);

            if (spam == null)
                return NotFound();

            _context.SpamNumbers.Remove(spam);
            _context.SaveChanges();

            return Ok();
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, SpamNumber model)
        {
            var spam = _context.SpamNumbers.Find(id);

            if (spam == null)
                return NotFound();

            spam.Phone = model.Phone;
            spam.Type = model.Type;
            spam.ReportCount = model.ReportCount;

            _context.SaveChanges();

            return Ok(spam);
        }
        [HttpGet("{id}")]
        public IActionResult GetById(int id)
        {
            var spam = _context.SpamNumbers.Find(id);

            if (spam == null)
                return NotFound();

            return Ok(spam);
        }
    }
}