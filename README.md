# Sitecore Starter

Opinionated starter kits (as in copy-and-customize) with some batteries included...

## Features compared to stock Sitecore

1. Compose v2 and `Compose Specification` file format instead of legacy 2.x and 3.x versions
1. Compose includes for easier CI build parallelization
1. Central Package Management (CPM) instead of legacy Central Package Versioning (CPV)
1. NuGet Package Source Mapping for better security and faster package restore
1. NuGet lock files for stable restores across machines
1. Builds solution *outside* Docker for faster and free builds using public build agents/runners
1. Process isolation and ltsc2022 by default
1. Predefined environments for patching, ie "Development", "Staging", "Production"
1. Optimized Sitecore config
1. Traefik v3

## Changelog

### 2024-12-02

- [Fixed] Updated 'System.Security.Cryptography.Xml' that had a known moderate severity vulnerability

### 2024-10-29

- [Changed] Updated Sitecore CLI to latest v6.0.23

### 2024-07-09

- [Added] Sitecore 10.4.0 XM
- [Added] Sitecore 10.3.1 XM
