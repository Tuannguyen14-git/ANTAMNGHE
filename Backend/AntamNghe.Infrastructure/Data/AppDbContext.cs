using Microsoft.EntityFrameworkCore;
using AntamNghe.Domain.Entities;

namespace AntamNghe.Infrastructure.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<SpamNumber> SpamNumbers { get; set; }

        public DbSet<VipContact> VipContacts { get; set; }

        public DbSet<CallLog> CallLogs { get; set; }

        public DbSet<User> Users { get; set; }

        public DbSet<EmergencyKeyword> EmergencyKeywords { get; set; }
        public DbSet<BlockedNumber> BlockedNumbers { get; set; }
        public DbSet<CallHistory> CallHistories { get; set; }
        public DbSet<EmergencyContact> EmergencyContacts { get; set; }
        public DbSet<SpamReport> SpamReports { get; set; }
        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);
            modelBuilder.ApplyConfiguration(new SpamReportConfiguration());
        }
    }
}