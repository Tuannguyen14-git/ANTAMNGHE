using System;

namespace AntamNghe.Domain.Entities
{
    public class SpamReport
    {
        public int Id { get; set; }
        public string PhoneNumber { get; set; } = string.Empty;
        public string? Reason { get; set; }
        public DateTime ReportedAt { get; set; } = DateTime.UtcNow;
        public string? Reporter { get; set; } // Username hoặc userId nếu có xác thực
    }
}
