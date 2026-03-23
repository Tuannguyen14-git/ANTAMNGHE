using Microsoft.AspNetCore.Mvc;
using AntamNghe.WebAdmin.Models;
using System.Text.Json;

namespace AntamNghe.WebAdmin.Controllers
{
    public class DashboardController : Controller
    {
        private readonly HttpClient _client;

        public DashboardController()
        {
            _client = new HttpClient();
            _client.BaseAddress = new Uri("https://localhost:7295/");
        }

        public async Task<IActionResult> Index()
        {
            var res = await _client.GetAsync("api/dashboard");

            var json = await res.Content.ReadAsStringAsync();

            var data = JsonSerializer.Deserialize<DashboardViewModel>(json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return View(data);
        }
    }
}