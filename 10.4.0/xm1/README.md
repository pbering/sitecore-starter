# Sitecore Starter 10.4.0 XM1

## Prerequisites

- Windows 11 and Visual Studio 2022
- Docker Desktop or Docker engine
- Sitecore license file

## Usage

1. `.\init.ps1 -License C:\license\license.xml -AdminPassword b`
1. `dotnet tool restore`
1. `msbuild /v:m /p:Configuration=Debug /t:"Restore;Build" /p:DeployOnBuild=true /p:PublishProfile=DockerPublish` or publish `Platform` project from Visual Studio.
1. `docker compose up -d --build`
1. `dotnet sitecore login --authority https://id.ss1040xm1.localhost --cm https://cm-platform.ss1040xm1.localhost --allow-write true`
1. `dotnet sitecore index schema-populate`
