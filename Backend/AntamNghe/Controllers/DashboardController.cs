using Microsoft.AspNetCore.Mvc;
using AntamNghe.Infrastructure.Data;

namespace AntamNghe.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DashboardController : ControllerBase
    {
        private readonly AppDbContext _context;

        public DashboardController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public IActionResult GetStats()
        {
            var totalSpam = _context.SpamNumbers.Count();

            var totalCalls = _context.CallLogs.Count();

            var totalReports = _context.SpamNumbers.Sum(x => x.ReportCount);

            return Ok(new
            {
                totalSpam,
                totalCalls,
                totalReports
            });
        }
    }
}