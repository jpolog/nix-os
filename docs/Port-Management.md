# Port Management Guide

This system includes a sophisticated port management system to prevent conflicts and maintain organization across development projects.

## Overview

The port management system provides:
- **Standardized port allocation** following DevOps best practices
- **Conflict detection** to identify port usage issues
- **Easy port discovery** with the `portctl` utility
- **Service categorization** for organized development

## Port Allocation Strategy

Ports are organized by service category, following RFC 6335 principles and industry standards:

### Frontend Development (3000-3999)
- **3000**: React/Next.js Development Server
- **3001**: Vue/Nuxt.js Development Server
- **3002**: Angular Development Server
- **3100**: Vite Development Server
- **3200**: Webpack Dev Server
- **3300**: Parcel Dev Server
- **3500**: Storybook

### Backend Development (4000-4999)
- **4000**: GraphQL Server
- **4001**: REST API Server
- **4100**: Express.js Server
- **4200**: Django Server
- **4300**: Flask Server
- **4400**: FastAPI Server
- **4500**: Spring Boot Server
- **4600**: Ruby on Rails Server
- **4700**: Go Server
- **4800**: Rust Server

### Database Services (5000-5999)
- **5432**: PostgreSQL (standard port)
- **5433**: PostgreSQL Secondary Instance
- **5000**: MySQL/MariaDB
- **5100**: MongoDB
- **5200**: Redis
- **5300**: Memcached
- **5400**: CouchDB
- **5500**: Cassandra
- **5600**: Neo4j
- **5700**: InfluxDB
- **5800**: Elasticsearch

### Message Queues & Streaming (6000-6999)
- **6000**: RabbitMQ Management UI
- **6100**: Apache Kafka
- **6200**: NATS
- **6300**: ActiveMQ

### DevOps Tools (7000-7999)
- **7000**: Jenkins
- **7100**: GitLab Runner
- **7200**: Prometheus
- **7300**: Grafana
- **7400**: Jaeger (Distributed Tracing)
- **7500**: Zipkin
- **7600**: Consul
- **7700**: HashiCorp Vault

### Containers & Orchestration (8000-8999)
- **8000**: Docker Registry
- **8001**: Portainer
- **8080**: Kubernetes Dashboard
- **8200**: Traefik Dashboard
- **8300**: Nginx Proxy Manager
- **8500**: ArgoCD

### Testing & Development (9000-9999)
- **9000-9099**: General test servers
- **9100**: Mock API Server
- **9200**: Selenium Grid
- **9229**: Node.js Debugger

## Using portctl

The `portctl` command provides comprehensive port management functionality.

### Basic Usage

#### List All Active Ports
```bash
portctl list
# or
ports  # alias
```

Shows all currently listening ports with summary by category.

#### Find What's Using a Port
```bash
portctl find 3000
# or
pf 3000  # alias
```

Displays process information for a specific port.

#### Kill Process on Port
```bash
portctl kill 8080
# or
pk 8080  # alias
```

Interactively kills the process using the specified port.

#### Check Port Availability
```bash
portctl check 5432
# or
pc 5432  # alias
```

Checks if a port is available or in use.

### Advanced Features

#### View Port Registry
```bash
portctl registry
```

Shows the complete port allocation registry with descriptions.

#### Search Registry
```bash
portctl search postgres
portctl search react
```

Searches the registry for service names or descriptions.

#### Show Ports in Range
```bash
portctl range 3000-3999
```

Lists all active ports within the specified range.

#### Recommend Next Available Port
```bash
portctl recommend frontend
portctl recommend backend
portctl recommend database
# or
prec frontend  # alias
```

Finds the next available port in the category and shows its standard usage.

Valid types:
- `frontend` - Frontend development (3000-3999)
- `backend` - Backend APIs (4000-4999)
- `database` - Database services (5000-5999)
- `messaging` - Message queues (6000-6999)
- `devops` - CI/CD tools (7000-7999)
- `container` - Docker/K8s (8000-8999)
- `testing` - Test servers (9000-9999)

## Best Practices

### 1. Use Standard Ports When Possible

Follow the registry for common services:
```bash
# Good - uses standard ports
npm run dev          # Defaults to 3000 (frontend)
python manage.py runserver 4200  # Django
docker run -p 5432:5432 postgres

# Bad - random ports
npm run dev -- --port 7234
python manage.py runserver 9999
```

### 2. Check Before Starting Services

Always check port availability before starting a service:
```bash
# Check if port is available
portctl check 3000

# Or get a recommendation
portctl recommend frontend
```

### 3. Document Custom Ports

If you need non-standard ports, document them in your project's README:
```markdown
## Development Ports
- API Server: 4567
- Frontend: 3456
- Database: 5678
```

### 4. Use Environment Variables

Configure ports through environment variables:
```bash
# .env file
FRONTEND_PORT=3000
API_PORT=4000
DB_PORT=5432
```

### 5. Kill Processes Properly

Don't leave development servers running:
```bash
# Find and kill properly
portctl find 3000
portctl kill 3000

# Or use Ctrl+C in the terminal
```

## Multi-Project Development

When working on multiple projects simultaneously:

### Strategy 1: Port Offsets
```bash
# Project A
Frontend: 3000
Backend:  4000
DB:       5432

# Project B  
Frontend: 3010
Backend:  4010
DB:       5433

# Project C
Frontend: 3020
Backend:  4020
DB:       5434
```

### Strategy 2: Category Blocks
```bash
# Project A - E-commerce
Frontend: 3000-3009
Backend:  4000-4009
DB:       5000-5009

# Project B - Analytics
Frontend: 3100-3109
Backend:  4100-4109
DB:       5100-5109
```

### Strategy 3: Docker Compose

Use Docker Compose with mapped ports:
```yaml
services:
  frontend:
    ports:
      - "3000:3000"  # Project A
  backend:
    ports:
      - "4000:4000"
```

## Troubleshooting

### Port Already in Use

```bash
# Find what's using the port
portctl find 3000

# Kill the process if needed
portctl kill 3000

# Or find an alternative
portctl recommend frontend
```

### Permission Denied

Ports below 1024 require root privileges:
```bash
# Use unprivileged ports instead
# Bad: port 80
# Good: port 8080
```

### Firewall Blocking

Check if the firewall is blocking the port:
```bash
# List firewall rules
sudo iptables -L -n

# For development, temporarily allow
sudo ufw allow 3000/tcp
```

### Can't Find Process

Some processes may be in TIME_WAIT state:
```bash
# Check all states
ss -tuln | grep :3000

# Wait for TIME_WAIT to clear (usually 60 seconds)
# Or use SO_REUSEADDR in your application
```

## Integration with Development Tools

### VS Code
Add to `.vscode/settings.json`:
```json
{
  "dev.ports.frontend": 3000,
  "dev.ports.backend": 4000,
  "dev.ports.database": 5432
}
```

### Docker Compose
Use port ranges in `docker-compose.yml`:
```yaml
version: '3'
services:
  app:
    ports:
      - "3000-3010:3000"  # Map range for multiple instances
```

### Nginx/Traefik
Configure reverse proxy with standard ports:
```nginx
server {
    listen 80;
    server_name app.local;
    location / {
        proxy_pass http://localhost:3000;
    }
}
```

## Quick Reference

| Command | Alias | Description |
|---------|-------|-------------|
| `portctl list` | `ports` | List all active ports |
| `portctl find <port>` | `pf <port>` | Find process on port |
| `portctl kill <port>` | `pk <port>` | Kill process on port |
| `portctl check <port>` | `pc <port>` | Check port availability |
| `portctl recommend <type>` | `prec <type>` | Get recommended port |
| `portctl registry` | - | Show port registry |
| `portctl search <query>` | - | Search registry |
| `portctl range <start-end>` | - | Show ports in range |

## See Also

- [Power User Guide](Power-User-Guide.md)
- [Scripts Documentation](Scripts.md)
- [Development Workflow](../README.md#development-workflow)
