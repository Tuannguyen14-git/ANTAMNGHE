using Microsoft.AspNetCore.Mvc;
using AntamNghe.WebAdmin.Models;
using System.Text.Json;

namespace AntamNghe.WebAdmin.Controllers
{
    public class CallLogController : Controller
    {
        private readonly HttpClient _client;

        public CallLogController()
        {
            _client = new HttpClient();
            _client.BaseAddress = new Uri("https://localhost:7295/");
        }

        public async Task<IActionResult> Index()
        {
            var res = await _client.GetAsync("api/calllog");

            var json = await res.Content.ReadAsStringAsync();

            var data = JsonSerializer.Deserialize<List<CallLog>>(json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return View(data);
        }
    }
}