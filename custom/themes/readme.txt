# TN Ad Link

TN Ad Link (Tennessee Ad Link) is an advertising server network based on Revive Adserver, providing localized ad serving solutions for Tennessee businesses, publishers, and advertisers.

## Features

- Self-hosted ad serving platform
- Tennessee-focused targeting options
- Custom plugins for local business integration
- Comprehensive analytics for advertisers
- Easy-to-use interface for publishers

## Technology Stack

- **Hosting**: Render
- **Database**: Supabase (PostgreSQL)
- **Ad Server**: Custom-enhanced Revive Adserver
- **Version Control**: GitHub

## Repository Structure

```
tnadlink/
├── .github/workflows/         # GitHub Actions workflows
├── docker/                    # Docker configuration files
│   ├── Dockerfile             # Main application Dockerfile
│   └── php.ini                # PHP configuration
├── config/                    # Configuration templates
│   └── database.conf.php      # Database configuration template
├── scripts/                   # Deployment and utility scripts
│   ├── wait-for-db.php        # Wait for database connection
│   ├── create-schema.php      # Create database schema
│   ├── install.php            # Installation script
│   ├── apply-branding.php     # Apply TN Ad Link branding
│   ├── check-updates.php      # Check for updates
│   └── deploy.sh              # Deployment script
├── custom/                    # Custom TN Ad Link enhancements
│   └── themes/                # TN Ad Link themes and branding
├── docs/                      # Documentation (to be added)
├── .gitignore                 # Git ignore file
├── render.yaml                # Render configuration
└── README.md                  # Project documentation
```

## Deployment Instructions

### Prerequisites

1. A Render account
2. A Supabase account with PostgreSQL database
3. The tnadlink.com domain configured with DNS settings pointing to Render

### Setting up the Repository

1. Fork or clone this repository
2. Configure the following environment variables in your Render dashboard:
   - `SUPABASE_DB_HOST`: Your Supabase database host
   - `SUPABASE_DB_PORT`: Your Supabase database port (usually 5432)
   - `SUPABASE_DB_USER`: Your Supabase database user
   - `SUPABASE_DB_PASSWORD`: Your Supabase database password
   - `SUPABASE_DB_NAME`: Your Supabase database name
   - `SUPABASE_DB_SCHEMA`: Schema name (default: tnadlink)
   - `ADMIN_EMAIL`: Admin email address
   - `ADMIN_USERNAME`: Admin username
   - `ADMIN_PASSWORD`: Admin password
   - `SITE_URL`: https://tnadlink.com
   - `SITE_NAME`: TN Ad Link

### Setting up Continuous Deployment

1. Configure GitHub repository secrets for CI/CD:
   - `RENDER_SERVICE_ID`: Your Render service ID
   - `RENDER_API_KEY`: Your Render API key
   - `SLACK_WEBHOOK`: (Optional) Slack webhook URL for notifications

2. Push to the main branch to trigger deployment

## Local Development

For local development:

1. Clone this repository
2. Copy `.env.example` to `.env` and configure environment variables
3. Run Docker Compose:
   ```bash
   docker-compose up -d
   ```
4. Access the platform at http://localhost:8080

## Customization

The TN Ad Link platform includes custom branding and Tennessee-specific enhancements built on top of Revive Adserver:

- **Tennessee Branding**: Custom color scheme based on the Tennessee flag
- **Local Targeting**: Geo-targeting specific to Tennessee regions
- **Custom Plugins**: Support for local business categories
- **Tennessee Ad Formats**: Standard ad formats optimized for local businesses

## Maintenance

Regular maintenance tasks:

1. Backup the Supabase database regularly
2. Check for Revive Adserver updates
3. Monitor server performance and logs
4. Review security settings

## License

This project is based on Revive Adserver which is licensed under the GNU General Public License v2.0.

## Contact

For support or inquiries, contact admin@tnadlink.com
