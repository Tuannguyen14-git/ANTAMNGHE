using Microsoft.AspNetCore.Mvc;
using AntamNghe.WebAdmin.Models;
using System.Text.Json;
using System.Text;

namespace AntamNghe.WebAdmin.Controllers
{
    public class SpamController : Controller
    {
        private readonly HttpClient _client;

        public SpamController()
        {
            _client = new HttpClient();
            _client.BaseAddress = new Uri("https://localhost:7295/");
        }

        public async Task<IActionResult> Index()
        {
            var response = await _client.GetAsync("api/spam");

            var json = await response.Content.ReadAsStringAsync();

            var data = JsonSerializer.Deserialize<List<SpamNumber>>(json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return View(data);
        }

        public IActionResult Create()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Create(SpamNumber model)
        {
            if (!ModelState.IsValid)
                return View(model);

            var json = JsonSerializer.Serialize(model);

            var content = new StringContent(json, Encoding.UTF8, "application/json");

            var response = await _client.PostAsync("api/spam", content);

            if (!response.IsSuccessStatusCode)
            {
                ViewBag.Error = "Add failed!";
                return View(model);
            }

            return RedirectToAction("Index");
        }

        public async Task<IActionResult> Delete(int id)
        {
            await _client.DeleteAsync($"api/spam/{id}");

            return RedirectToAction("Index");
        }

        public async Task<IActionResult> Edit(int id)
        {
            var response = await _client.GetAsync($"api/spam/{id}");

            var json = await response.Content.ReadAsStringAsync();

            var data = JsonSerializer.Deserialize<SpamNumber>(json,
                new JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            return View(data);
        }

        [HttpPost]
        public async Task<IActionResult> Edit(SpamNumber model)
        {
            var json = JsonSerializer.Serialize(model);

            var content = new StringContent(json, Encoding.UTF8, "application/json");

            await _client.PutAsync($"api/spam/{model.Id}", content);

            return RedirectToAction("Index");
        }
    }
}