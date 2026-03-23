namespace AntamNghe.Domain.Entities
{
    public class SpamNumber
    {
        public int Id { get; set; }
        public string Phone { get; set; }
        public string Type { get; set; }
        public int ReportCount { get; set; }
    }
}