# Local Development Setup

Prerequisites and local services for workspace development.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 22+ | `brew install node@22` |
| pnpm | 9+ | `npm install -g pnpm` |
| Docker Desktop | Latest | [docker.com](https://docker.com) |
| Caddy | Latest | `brew install caddy` |
| yq | Latest | `brew install yq` |

## PostgreSQL

```bash
# Install
brew install postgresql@15
brew services start postgresql@15

# Create database for each project
createdb {project}
```

### Troubleshooting PostgreSQL

```bash
# Check if running
brew services list | grep postgresql

# View logs
tail -f /opt/homebrew/var/log/postgresql@15.log

# Restart
brew services restart postgresql@15

# Verify database exists
psql -l | grep {project}
```

## Redis (Optional)

Only needed for projects using job queues (BullMQ):

```bash
brew install redis
brew services start redis
```

## Local HTTPS with Caddy

The workspace uses Caddy for local HTTPS development with auto-generated certificates.

### Setup

```bash
# Start Caddy (from workspace root)
caddy start --config .caddy

# Trust Caddy's root CA (one time, requires sudo)
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain \
  ~/Library/Application\ Support/Caddy/pki/authorities/local/root.crt

# Restart browser after trusting the certificate
```

### Dev Server Commands

```bash
bin/dev              # All projects
bin/dev {project}    # Single project
bin/dev stop         # Stop all
bin/dev status       # Check status
```

### Domain Pattern

Each project gets a `.dev` domain based on its name:

```
https://{project}.dev → localhost:{port}
```

Ports are assigned in `.workspace.yml` starting from 3000.

### Hosts File

Add each project to `/etc/hosts`:

```bash
# Add entries for your projects
sudo tee -a /etc/hosts << 'EOF'
127.0.0.1 {project1}.dev
127.0.0.1 {project2}.dev
EOF
```

Or use dnsmasq for wildcard `.dev` resolution.

## Database Setup (Per Project)

```bash
cd {project}

# Generate database client and push schema
pnpm db:generate   # Generates Drizzle client
pnpm db:push       # Push schema to database

# Database studio (optional)
pnpm db:studio     # Opens Drizzle Studio
```

## Environment Variables

Copy `.env.example` to `.env.local`:

```bash
cp .env.example .env.local
```

Generate NextAuth secret:
```bash
openssl rand -base64 32
```

## Quick Start Checklist

- [ ] Install prerequisites (Node, pnpm, Caddy, yq)
- [ ] Add domains to `/etc/hosts`
- [ ] Start Caddy: `caddy start --config .caddy`
- [ ] Trust Caddy CA (see "Local HTTPS with Caddy" section)
- [ ] Start PostgreSQL: `brew services start postgresql@15`
- [ ] Create project database: `createdb {project}`
- [ ] Copy `.env.example` to `.env.local`
- [ ] Generate `NEXTAUTH_SECRET`: `openssl rand -base64 32`
- [ ] Set up service credentials (OAuth, Stripe, etc.)
- [ ] Run database setup: `pnpm db:generate && pnpm db:push`
- [ ] Start dev server: `bin/dev {project}`
