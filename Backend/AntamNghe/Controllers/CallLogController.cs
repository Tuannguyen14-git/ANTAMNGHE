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

        private ObjectResult LocalOnly() =>
            StatusCode(StatusCodes.Status410Gone, new
            {
                message = "Call logs are processed on-device only and are no longer accepted by the server."
            });

        // GET ALL
        [HttpGet]
        public IActionResult GetAll()
        {
            return LocalOnly();
        }

        // ADD LOG
        [HttpPost]
        public IActionResult Add([FromBody] CallLog log)
        {
            return LocalOnly();
        }
    }
}