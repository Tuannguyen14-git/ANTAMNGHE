FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY AntamNghe.Domain/AntamNghe.Domain.csproj AntamNghe.Domain/
COPY AntamNghe.Infrastructure/AntamNghe.Infrastructure.csproj AntamNghe.Infrastructure/
COPY AntamNghe/AntamNghe.csproj AntamNghe/
RUN dotnet restore AntamNghe/AntamNghe.csproj

COPY . .
WORKDIR /src/AntamNghe
RUN dotnet publish AntamNghe.csproj -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

ENV ASPNETCORE_URLS=http://0.0.0.0:10000
EXPOSE 10000

ENTRYPOINT ["dotnet", "AntamNghe.dll"]