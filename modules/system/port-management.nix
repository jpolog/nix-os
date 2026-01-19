{ config, pkgs, lib, ... }:

{
  # Port Management System
  # Standardized port allocation for development services
  # Based on DevOps best practices and Port Registry RFC 6335
  
  # Port Allocation Strategy:
  # 3000-3999: Frontend Development (Web apps, React, Vue, etc.)
  # 4000-4999: Backend Development (APIs, Node.js, etc.)
  # 5000-5999: Databases (PostgreSQL, Redis, MongoDB, etc.)
  # 6000-6999: Message Queues & Streaming (RabbitMQ, Kafka, etc.)
  # 7000-7999: DevOps Tools (CI/CD, monitoring, etc.)
  # 8000-8999: Containers & Orchestration (Docker, K8s dashboards, etc.)
  # 9000-9999: Testing & Development (Test servers, mock APIs, etc.)
  
  environment.systemPackages = with pkgs; [
    # Port scanning and management
    iproute2      # Socket statistics (ss command - modern netstat)
    nmap          # Network mapper
    wireshark     # GUI packet analyzer
  ];
  
  # Create port management configuration
  environment.etc."port-registry.yaml".text = ''
    # Port Registry for Development
    # This file documents standard port allocations
    
    frontend:
      range: "3000-3999"
      services:
        - port: 3000
          name: "React/Next.js Development Server"
          description: "Primary frontend development port"
        - port: 3001
          name: "Vue/Nuxt.js Development Server"
          description: "Secondary frontend framework"
        - port: 3002
          name: "Angular Development Server"
          description: "Angular CLI dev server"
        - port: 3100
          name: "Vite Development Server"
          description: "Modern build tool"
        - port: 3200
          name: "Webpack Dev Server"
          description: "Module bundler"
        - port: 3300
          name: "Parcel Dev Server"
          description: "Zero config bundler"
        - port: 3500
          name: "Storybook"
          description: "UI component development"
    
    backend:
      range: "4000-4999"
      services:
        - port: 4000
          name: "GraphQL Server"
          description: "GraphQL API endpoint"
        - port: 4001
          name: "REST API Server"
          description: "Primary REST API"
        - port: 4100
          name: "Express.js Server"
          description: "Node.js backend"
        - port: 4200
          name: "Django Server"
          description: "Python web framework"
        - port: 4300
          name: "Flask Server"
          description: "Lightweight Python framework"
        - port: 4400
          name: "FastAPI Server"
          description: "Modern Python API framework"
        - port: 4500
          name: "Spring Boot Server"
          description: "Java backend"
        - port: 4600
          name: "Ruby on Rails Server"
          description: "Ruby backend"
        - port: 4700
          name: "Go Server"
          description: "Go backend service"
        - port: 4800
          name: "Rust Server"
          description: "Rust backend service"
    
    database:
      range: "5000-5999"
      services:
        - port: 5432
          name: "PostgreSQL"
          description: "Primary SQL database"
        - port: 5433
          name: "PostgreSQL Secondary"
          description: "Secondary instance"
        - port: 5000
          name: "MySQL/MariaDB"
          description: "Alternative SQL database"
        - port: 5100
          name: "MongoDB"
          description: "Document database"
        - port: 5200
          name: "Redis"
          description: "Key-value cache/store"
        - port: 5300
          name: "Memcached"
          description: "Memory cache"
        - port: 5400
          name: "CouchDB"
          description: "Document database"
        - port: 5500
          name: "Cassandra"
          description: "Wide-column store"
        - port: 5600
          name: "Neo4j"
          description: "Graph database"
        - port: 5700
          name: "InfluxDB"
          description: "Time-series database"
        - port: 5800
          name: "Elasticsearch"
          description: "Search engine"
    
    messaging:
      range: "6000-6999"
      services:
        - port: 6000
          name: "RabbitMQ Management"
          description: "Message broker UI"
        - port: 6100
          name: "Kafka"
          description: "Event streaming"
        - port: 6200
          name: "NATS"
          description: "Cloud-native messaging"
        - port: 6300
          name: "ActiveMQ"
          description: "Message broker"
    
    devops:
      range: "7000-7999"
      services:
        - port: 7000
          name: "Jenkins"
          description: "CI/CD server"
        - port: 7100
          name: "GitLab Runner"
          description: "CI runner"
        - port: 7200
          name: "Prometheus"
          description: "Monitoring system"
        - port: 7300
          name: "Grafana"
          description: "Metrics visualization"
        - port: 7400
          name: "Jaeger"
          description: "Distributed tracing"
        - port: 7500
          name: "Zipkin"
          description: "Distributed tracing"
        - port: 7600
          name: "Consul"
          description: "Service mesh"
        - port: 7700
          name: "Vault"
          description: "Secrets management"
    
    containers:
      range: "8000-8999"
      services:
        - port: 8000
          name: "Docker Registry"
          description: "Container registry"
        - port: 8001
          name: "Portainer"
          description: "Container management UI"
        - port: 8080
          name: "Kubernetes Dashboard"
          description: "K8s web UI"
        - port: 8200
          name: "Traefik Dashboard"
          description: "Reverse proxy UI"
        - port: 8300
          name: "Nginx Proxy Manager"
          description: "Proxy management"
        - port: 8500
          name: "ArgoCD"
          description: "GitOps CD tool"
    
    testing:
      range: "9000-9999"
      services:
        - port: 9000
          name: "Test Server 1"
          description: "General testing"
        - port: 9001
          name: "Test Server 2"
          description: "General testing"
        - port: 9100
          name: "Mock API Server"
          description: "API mocking"
        - port: 9200
          name: "Selenium Grid"
          description: "Browser automation"
        - port: 9229
          name: "Node.js Debugger"
          description: "Node debugging port"
  '';
  
  # Create port management helper scripts (defined in scripts/)
  # The actual scripts will be created in the scripts/ directory
}
