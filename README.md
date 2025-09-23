# food_ordering

A new Flutter project.

## Documentation

- Backend configuration (step-by-step): `docs/BACKEND_SETUP.md`
- Database configuration (step-by-step): `docs/DATABASE_SETUP.md`

## Azure Deployment Notes

- Host backend on Azure App Service (.NET 7).
- Enable WebSockets and Always On.
- Set App Settings:
  - `ConnectionStrings__AzureSql` = your Azure SQL connection string
  - `ASPNETCORE_ENVIRONMENT` = Production
  - `Cors__AllowedOrigins` = ["https://<your-frontend-domain>","http://localhost:5277","http://10.0.2.2:5277"]
- Point Flutter to your App Service URL in `lib/config/app_config.dart` by setting `useAzure = true` and updating `azureBaseUrl`.


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
