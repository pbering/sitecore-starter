# Sitecore Starter

Opinionated starter kits (as in copy-and-customize) with some batteries included...

## Features compared to stock Sitecore

1. Compose v2 and `Compose Specification` file format instead of legacy 2.x and 3.x versions
1. Compose includes for easier CI build parallelization
1. Central Package Management (CPM) instead of legacy Central Package Versioning (CPV)
1. NuGet Package Source Mapping
1. NuGet lock files
1. Builds solution *outside* Docker for faster and free builds using public build agents/runners
1. Predefined environments for patching, ie "Development", "Staging", "Production"
1. Optimized Sitecore config
1. Traefik v3

## Changelog

### 2024-05-24

- [Added] Sitecore 10.4.0 XM
