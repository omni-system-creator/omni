# Use Microsoft's official .NET SDK image to build the project
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy the csproj file and restore dependencies
COPY ["omsapi.csproj", "./"]
RUN dotnet restore "omsapi.csproj"

# Copy the rest of the code
COPY . .

# Build the application
RUN dotnet build "omsapi.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "omsapi.csproj" -c Release -o /app/publish

# Build the runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
EXPOSE 80
ENTRYPOINT ["dotnet", "omsapi.dll"]
