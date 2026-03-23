using AntamNghe.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace AntamNghe.Infrastructure.Data
{
    public class SpamReportConfiguration : IEntityTypeConfiguration<SpamReport>
    {
        public void Configure(EntityTypeBuilder<SpamReport> builder)
        {
            builder.HasKey(x => x.Id);
            builder.Property(x => x.PhoneNumber).IsRequired().HasMaxLength(20);
            builder.Property(x => x.ReportedAt).IsRequired();
        }
    }
}
