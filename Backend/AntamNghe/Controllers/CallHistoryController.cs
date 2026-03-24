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

        private ObjectResult LocalOnly() =>
            StatusCode(StatusCodes.Status410Gone, new
            {
                message = "Call history is kept on-device only and is no longer stored by the server."
            });

        [HttpGet]
        public IActionResult GetAll()
        {
            return LocalOnly();
        }

        [HttpGet("{id}")]
        public IActionResult Get(int id)
        {
            return LocalOnly();
        }

        [HttpPost]
        public IActionResult Create([FromBody] CallHistory item)
        {
            return LocalOnly();
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] CallHistory item)
        {
            return LocalOnly();
        }

        [HttpDelete("{id}")]
        public IActionResult Delete(int id)
        {
            return LocalOnly();
        }
    }
}