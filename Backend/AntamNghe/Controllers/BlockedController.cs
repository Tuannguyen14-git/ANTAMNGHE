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

        private ObjectResult LocalOnly() =>
            StatusCode(StatusCodes.Status410Gone, new
            {
                message = "Blocked numbers are managed on-device only and are no longer stored by the server."
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
        public IActionResult Create([FromBody] BlockedNumber blocked)
        {
            return LocalOnly();
        }

        [HttpPut("{id}")]
        public IActionResult Update(int id, [FromBody] BlockedNumber blocked)
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