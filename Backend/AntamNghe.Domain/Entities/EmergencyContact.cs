using System.ComponentModel.DataAnnotations;

namespace AntamNghe.Domain.Entities
{
    public class EmergencyContact
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [MaxLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;
        [MaxLength(100)]
        public string? Name { get; set; }
        [MaxLength(200)]
        public string? Note { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}