# Fabric Mirroring Demo Assets

**Objective:** This repository demonstrates how to create and configure an Azure SQL environment for showcasing Microsoft Fabric Mirroring capabilities. It provides infrastructure automation, sample data, and interactive notebooks to support end-to-end mirroring demos.

This repo contains:
- infra/main.bicep: Azure SQL Server + Database + firewall rule (publicly accessible)
- infra/deploy.ps1: PowerShell script to deploy with Azure CLI and generate .env file
- notebooks/01_create_schema.ipynb: Creates DimCountry, DimStore, DimProduct, FactSales
- notebooks/02_load_sample_data.ipynb: Loads sample data, exports countries.csv and products.csv
- notebooks/03_stream_sales.ipynb: Continuously writes to FactSales with real-time timestamps
- .env.template: Template for environment variables
- .env: Generated automatically by deployment (contains sensitive data)

## Prereqs
- Azure CLI logged in (`az login`)
- ODBC Driver 18 for SQL Server installed
- Python 3.12
- UV (Python package manager) - Install from: https://docs.astral.sh/uv/getting-started/installation/

## Deploy Azure SQL
PowerShell:

```powershell
# From infra folder - this will automatically generate .env file
./deploy.ps1 -ResourceGroupName "rg-fabric-demo" -Location "westeurope" -SqlServerName "<unique-sql-server-name>" -AdministratorLogin "sqladmin" -AdministratorPassword (Read-Host -AsSecureString "SQL admin password") -DatabaseName "fabricMirrorDemoDb" -SkuName "S3" -AllowAllInternetIPs $true
```

The deployment script will automatically generate a `.env` file with all connection details!

## Configure notebooks
✅ **No manual configuration needed!** All notebooks now read from the `.env` file automatically.

## Install Python dependencies
```powershell
# Use UV for fast, reliable Python package management
uv sync
```

Note: This will automatically create a virtual environment and install all dependencies from `pyproject.toml`.

## Run notebooks
1. 01_create_schema.ipynb
2. 02_load_sample_data.ipynb (also creates data/countries.csv)
3. 03_stream_sales.ipynb (keep running during your mirroring demo)

## Notes
- The Azure SQL Server is configured to allow all internet IPs (0.0.0.0 to 255.255.255.255) for public access.
- To restrict IPs, deploy with -AllowAllInternetIPs $false and set -StartIpAddress/-EndIpAddress.
- The deployment script assures that SQL Authentication is enabled in the SQL Server, even if it is turned off.
- The CSV files are saved at c:\VSProjects\Fabric-IPO\data\ (folder is created automatically).
- The stream notebook inserts batches continuously; stop the cell to end.
