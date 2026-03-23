using System.ComponentModel.DataAnnotations;

namespace AntamNghe.Domain.Entities
{
    public class CallHistory
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [MaxLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;
        public DateTime CallTime { get; set; } = DateTime.UtcNow;
        [MaxLength(100)]
        public string? Note { get; set; }
    }
}