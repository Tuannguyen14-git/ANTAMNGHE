using System.ComponentModel.DataAnnotations;

namespace AntamNghe.Domain.Entities
{
    public class VipList
    {
        [Key]
        public int Id { get; set; }
        [Required]
        [MaxLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;
        [MaxLength(100)]
        public string? Name { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}