namespace AntamNghe.Domain.Entities
{
    public class CallLog
    {
        public int Id { get; set; }
        public string Phone { get; set; }
        public DateTime Time { get; set; }
        public string Status { get; set; } // Spam / Allowed / Missed
    }
}