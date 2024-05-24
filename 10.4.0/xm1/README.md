# Sitecore Starter 10.4.0 XM1

## Prerequisites

- Windows 11 and Visual Studio 2022
- Docker Desktop or Docker engine
- Sitecore license file

## Running

1. Run `.\init.ps1 -License C:\license\license.xml -AdminPassword b`
1. Run `dotnet tool restore`
1. Run `nuget restore && msbuild /v:m /p:Configuration=Debug /p:DeployOnBuild=true /p:PublishProfile=DockerPublish` or publish `Platform` project from Visual Studio.
1. Run `docker compose up -d --build`
1. Run `dotnet sitecore login --authority https://id.ss1040xm1.localhost --cm https://cm-platform.ss1040xm1.localhost --allow-write true`
1. Run `dotnet sitecore index schema-populate`
