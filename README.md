# Static Website Infrastructure Modules

This repository contains reusable Terraform modules for deploying static websites with serverless backends. These modules are designed to be imported and used by other application repositories.

## Available Modules

### Frontend Modules (`static_website/`)

#### AWS + Cloudflare Infrastructure (`static_website/`)
A module for deploying websites using AWS and Cloudflare:
- **Content Storage**: Amazon S3 with website hosting enabled
- **Content Delivery**: Cloudflare CDN with IP-restricted S3 access
- **DNS Management**: Cloudflare DNS (CNAME records)
- **SSL/TLS**: Cloudflare SSL

### Module Structure
```
.
└── static_website/                  # Root module directory
    ├── storage/                     # S3 bucket configuration
    └── dns/                         # Cloudflare DNS configuration
```

## Configuration

## License

MIT License - See [LICENSE](LICENSE) for details.