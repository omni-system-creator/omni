$ErrorActionPreference = "Stop"
$rootDir = "d:\Development\OMS"
$releaseDir = "$rootDir\private\o"

Write-Host "1. Cleaning release directory: $releaseDir"
if (Test-Path $releaseDir) { Remove-Item $releaseDir -Recurse -Force }
New-Item -ItemType Directory -Path $releaseDir | Out-Null
New-Item -ItemType Directory -Path "$releaseDir\backend" | Out-Null
New-Item -ItemType Directory -Path "$releaseDir\frontend" | Out-Null

Write-Host "2. Building Backend (Release)..."
dotnet publish "$rootDir\backend\omsapi\omsapi.csproj" -c Release -o "$releaseDir\backend"
if ($LASTEXITCODE -ne 0) { throw "Backend build failed" }

Write-Host "3. Building Frontend (Production)..."
Push-Location "$rootDir\frontend"
try {
    if (-not (Test-Path "node_modules")) {
        Write-Host "Installing frontend dependencies..."
        npm install
    }
    npm run build
    if ($LASTEXITCODE -ne 0) { throw "Frontend build failed" }
}
finally {
    Pop-Location
}

Write-Host "4. Copying Frontend Artifacts..."
Copy-Item "$rootDir\frontend\dist" -Destination "$releaseDir\frontend\dist" -Recurse
Copy-Item "$rootDir\frontend\nginx.conf" -Destination "$releaseDir\frontend\nginx.conf"

Write-Host "5. Generating Dockerfiles..."
# Backend Dockerfile (Runtime only)
$backendDockerfile = @"
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY . .
EXPOSE 80
ENTRYPOINT ["dotnet", "omsapi.dll"]
"@
Set-Content -Path "$releaseDir\backend\Dockerfile" -Value $backendDockerfile

# Frontend Dockerfile (Static only)
$frontendDockerfile = @"
FROM nginx:alpine
COPY ./dist /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
"@
Set-Content -Path "$releaseDir\frontend\Dockerfile" -Value $frontendDockerfile

Write-Host "6. Generating docker-compose.yml..."
$dockerCompose = @"
version: '3.3'
services:
  # Backend Service
  backend:
    build: ./backend
    container_name: o-backend
    restart: always
    environment:
      - DatabaseType=mysql
      - ConnectionStrings__DefaultConnection_mysql=Server=host.docker.internal;Database=o;User=o;Password=xxxxxx;
      - ASPNETCORE_ENVIRONMENT=Production
    ports:
      - "5016:80"
    volumes:
      - ./uploads:/app/uploads
      - ./logs:/app/Logs
    extra_hosts:
      - "host.docker.internal:host-gateway"

  # Frontend Service
  frontend:
    build: ./frontend
    container_name: o-frontend
    restart: always
    ports:
      - "8080:80"
    depends_on:
      - backend

networks:
  default:
    driver: bridge
"@
Set-Content -Path "$releaseDir\docker-compose.yml" -Value $dockerCompose

Write-Host "7. Creating Deployment Instructions..."
# Copy from template instead of embedding string to avoid syntax issues
if (Test-Path "$rootDir\DEPLOY_TEMPLATE.md") {
    Copy-Item "$rootDir\DEPLOY_TEMPLATE.md" -Destination "$releaseDir\DEPLOY.md"
} else {
    Write-Warning "DEPLOY_TEMPLATE.md not found! DEPLOY.md will be missing in release."
}

Write-Host "--------------------------------------------------------"
Write-Host "Release Build Complete!"
Write-Host "Artifacts are located in: $releaseDir"
Write-Host "You can zip this folder and deploy it to your server."
Write-Host "--------------------------------------------------------"
