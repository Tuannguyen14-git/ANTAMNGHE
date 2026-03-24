using AntamNghe.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

var port = Environment.GetEnvironmentVariable("PORT");
if (!string.IsNullOrWhiteSpace(port))
{
    builder.WebHost.UseUrls($"http://0.0.0.0:{port}");
}

var connectionString = ResolveConnectionString(builder.Configuration);
var corsSettings = ResolveCorsSettings(builder.Configuration, builder.Environment);

// Add services to the container.
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseNpgsql(connectionString));
builder.Services.AddControllers();
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
    {
        if (corsSettings.AllowAnyOrigin)
        {
            policy.AllowAnyHeader().AllowAnyMethod().AllowAnyOrigin();
            return;
        }

        policy.WithOrigins(corsSettings.AllowedOrigins.ToArray())
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// JWT Authentication
var jwtSection = builder.Configuration.GetSection("Jwt");
var jwtKey = jwtSection.GetValue<string>("Key");
var jwtIssuer = jwtSection.GetValue<string>("Issuer");

if (!string.IsNullOrEmpty(jwtKey))
{
    builder.Services.AddAuthentication(options =>
    {
        options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    })
    .AddJwtBearer(options =>
    {
        options.RequireHttpsMetadata = false;
        options.SaveToken = true;
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ValidateIssuer = true,
            ValidIssuer = jwtIssuer,
            ValidateAudience = false,
            ValidateLifetime = true
        };
    });
}

var app = builder.Build();

app.UseForwardedHeaders();

if (!app.Environment.IsDevelopment() && corsSettings.AllowAnyOrigin)
{
    app.Logger.LogWarning("CORS is allowing any origin in production. Set CORS_ALLOWED_ORIGINS to explicit domains when ready.");
}

if (ShouldRunMigrationsOnStartup(builder.Configuration, app.Environment))
{
    using var scope = app.Services.CreateScope();
    var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    dbContext.Database.Migrate();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
    app.UseHttpsRedirection();
}

app.UseCors("Frontend");

app.UseAuthentication();
app.UseAuthorization();

app.MapGet("/", () => Results.Ok(new
{
    message = "AntamNghe API is running",
    health = "/healthz"
}));
app.MapGet("/healthz", () => Results.Ok(new { status = "ok" }));
app.MapControllers();

app.Run();

static string ResolveConnectionString(IConfiguration configuration)
{
    var databaseUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
    if (!string.IsNullOrWhiteSpace(databaseUrl))
    {
        return BuildConnectionStringFromDatabaseUrl(databaseUrl);
    }

    return configuration.GetConnectionString("DefaultConnection")
        ?? throw new InvalidOperationException("DefaultConnection is not configured.");
}

static string BuildConnectionStringFromDatabaseUrl(string databaseUrl)
{
    if (!Uri.TryCreate(databaseUrl, UriKind.Absolute, out var databaseUri))
    {
        throw new InvalidOperationException("DATABASE_URL is not a valid absolute URI.");
    }

    var userInfo = databaseUri.UserInfo.Split(':', 2);
    if (userInfo.Length != 2)
    {
        throw new InvalidOperationException("DATABASE_URL must include username and password.");
    }

    var username = Uri.UnescapeDataString(userInfo[0]);
    var password = Uri.UnescapeDataString(userInfo[1]);
    var database = databaseUri.AbsolutePath.Trim('/');

    var builder = new Npgsql.NpgsqlConnectionStringBuilder
    {
        Host = databaseUri.Host,
        Port = databaseUri.Port,
        Username = username,
        Password = password,
        Database = database,
        SslMode = databaseUri.Scheme.Equals("postgres", StringComparison.OrdinalIgnoreCase)
            || databaseUri.Scheme.Equals("postgresql", StringComparison.OrdinalIgnoreCase)
            ? Npgsql.SslMode.Require
            : Npgsql.SslMode.Prefer
    };

    return builder.ConnectionString;
}

static CorsSettings ResolveCorsSettings(IConfiguration configuration, IWebHostEnvironment environment)
{
    var configuredOrigins = configuration
        .GetSection("Cors:AllowedOrigins")
        .Get<string[]>()?
        .Where(origin => !string.IsNullOrWhiteSpace(origin))
        .Select(origin => origin.Trim())
        .ToList()
        ?? new List<string>();

    var allowAnyOrigin = false;

    if (configuredOrigins.Any(origin => origin == "*"))
    {
        allowAnyOrigin = true;
        configuredOrigins.RemoveAll(origin => origin == "*");
    }

    var envOrigins = Environment.GetEnvironmentVariable("CORS_ALLOWED_ORIGINS");
    if (!string.IsNullOrWhiteSpace(envOrigins))
    {
        if (envOrigins.Trim() == "*")
        {
            allowAnyOrigin = true;
        }
        else
        {
            configuredOrigins.AddRange(
                envOrigins
                    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries));
        }
    }

    if (configuredOrigins.Count == 0 && environment.IsDevelopment())
    {
        allowAnyOrigin = true;
    }

    return new CorsSettings(
        allowAnyOrigin,
        configuredOrigins.Distinct(StringComparer.OrdinalIgnoreCase).ToList());
}

static bool ShouldRunMigrationsOnStartup(IConfiguration configuration, IWebHostEnvironment environment)
{
    var configuredValue = configuration["Database:RunMigrationsOnStartup"];
    if (bool.TryParse(configuredValue, out var shouldRunMigrations))
    {
        return shouldRunMigrations;
    }

    return !environment.IsDevelopment();
}

record CorsSettings(bool AllowAnyOrigin, List<string> AllowedOrigins);
