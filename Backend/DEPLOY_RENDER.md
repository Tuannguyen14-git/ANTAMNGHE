# Deploy Backend Len Render

File [render.yaml](c:/HocTap/AntamNghe/render.yaml) da duoc them de ban deploy nhanh backend ASP.NET Core len Render.

## Kien truc deploy

- Service API: `Backend/AntamNghe`
- Database: PostgreSQL tren Render
- Runtime: .NET 8
- Tu dong chay migration khi startup neu `Database__RunMigrationsOnStartup=true`

## Buoc deploy

1. Day code moi nhat len GitHub.
2. Vao Render va chon `New +` -> `Blueprint`.
3. Chon repo `ANTAMNGHE`.
4. Render se doc file `render.yaml` o root repo.
5. Tao service `antamnghe-api` va database `antamnghe-db`.

## Bien moi truong can thiet

Can set them trong Render:

- `Jwt__Key`: khoa JWT production, toi thieu 32 ky tu ngau nhien.
- `CORS_ALLOWED_ORIGINS`: danh sach origin duoc phep, cach nhau bang dau phay.

Vi du:

```text
https://your-flutter-web-app.onrender.com,https://your-admin-domain.com
```

Da co san trong blueprint:

- `ASPNETCORE_ENVIRONMENT=Production`
- `Database__RunMigrationsOnStartup=true`
- `Jwt__Issuer=AntamNghe`
- `ConnectionStrings__DefaultConnection` lay tu Render PostgreSQL

## Kiem tra sau deploy

1. Mo `https://your-api-domain/healthz` va dam bao tra ve `{"status":"ok"}`.
2. Thu `POST /api/Auth/register` hoac `POST /api/Auth/login`.
3. Xac nhan bang trong PostgreSQL da duoc tao sau lan start dau.

## Viec can lam tiep trong app Flutter

Sau khi API da len production, doi base URL trong Flutter ve domain Render production thay vi `localhost`.

File lien quan:

- [Backend/AntamNghe/Program.cs](c:/HocTap/AntamNghe/Backend/AntamNghe/Program.cs)
- [antamnghe_app/lib/services/config.dart](c:/HocTap/AntamNghe/antamnghe_app/lib/services/config.dart)

## Luu y

- Ban hien dang dung CORS theo env var production. Neu khong set `CORS_ALLOWED_ORIGINS`, API van chay nhung se log canh bao va mo rong origin.
- Neu muon an toan hon, sau khi deploy on dinh thi bat buoc set `CORS_ALLOWED_ORIGINS` dung domain that.
- Neu Render cap `DATABASE_URL` thay vi connection string thuong, backend da co ho tro parse gia tri nay.