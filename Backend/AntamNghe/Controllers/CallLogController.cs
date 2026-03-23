using Microsoft.AspNetCore.Mvc;
using AntamNghe.Infrastructure.Data;
using AntamNghe.Domain.Entities;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CallLogController : ControllerBase
    {
        private readonly AppDbContext _context;

        public CallLogController(AppDbContext context)
        {
            _context = context;
        }

        // GET ALL
        [HttpGet]
        public IActionResult GetAll()
        {
            return Ok(_context.CallLogs.ToList());
        }

        // ADD LOG
        [HttpPost]
        public IActionResult Add([FromBody] CallLog log)
        {
            _context.CallLogs.Add(log);
            _context.SaveChanges();

            return Ok(log);
        }
    }
}