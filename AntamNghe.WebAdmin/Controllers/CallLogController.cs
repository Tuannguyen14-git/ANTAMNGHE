using Microsoft.AspNetCore.Mvc;

namespace AntamNghe.WebAdmin.Controllers
{
    public class CallLogController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}