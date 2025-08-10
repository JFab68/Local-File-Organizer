# Local File Organizer - Deployment Guide

## Table of Contents
- [Deployment Overview](#deployment-overview)
- [Security Considerations](#security-considerations)
- [Production Setup](#production-setup)
- [Docker Deployment](#docker-deployment)
- [Server Deployment](#server-deployment)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Scaling Considerations](#scaling-considerations)

## Deployment Overview

### Deployment Types

**Personal Desktop (Recommended)**
- Best for individual users
- Full AI model capabilities
- No network dependencies
- Simple setup and maintenance

**Shared Server**
- Multiple users on single system
- Centralized model management
- Resource sharing considerations
- User isolation required

**Enterprise Environment**
- Network security compliance
- Centralized logging and monitoring
- Integration with existing systems
- Compliance and audit requirements

**Cloud Deployment**
- Scalable compute resources
- Storage and bandwidth considerations
- Cost optimization for AI models
- Security and data privacy

## Security Considerations

### Pre-Deployment Security Checklist

**Critical Security Fixes Required**:
```python
# 1. Add path validation to main.py
import os
from pathlib import Path

def validate_path(user_path, base_path="/safe/directory"):
    """Validate user-provided paths against directory traversal"""
    try:
        resolved_path = Path(user_path).resolve()
        base_resolved = Path(base_path).resolve()
        resolved_path.relative_to(base_resolved)
        return str(resolved_path)
    except ValueError:
        raise ValueError("Path outside allowed directory")

# 2. Implement proper logging instead of print statements
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('organizer.log'),
        logging.StreamHandler()
    ]
)

# 3. Add file size validation
MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB
def validate_file_size(file_path):
    if os.path.getsize(file_path) > MAX_FILE_SIZE:
        raise ValueError(f"File too large: {file_path}")
```

### Network Security
```bash
# Firewall rules (if network access needed)
# Block all unnecessary ports
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Only allow SSH if remote access needed
sudo ufw allow ssh

# Monitor network connections
netstat -tlnp | grep python
```

### File System Security
```bash
# Set restrictive permissions
chmod 750 /path/to/application
chown -R organizer_user:organizer_group /path/to/application

# Create dedicated user
sudo useradd -r -s /bin/false organizer_service
sudo usermod -a -G organizer_group organizer_service

# Secure model storage
chmod 700 ~/.nexa/models/
```

### Environment Isolation
```bash
# Use dedicated Python environment
conda create --name prod_file_organizer python=3.12
conda activate prod_file_organizer

# Install only required packages
pip install --no-deps -r requirements.txt

# Set environment variables
export PYTHONPATH=/path/to/application
export NEXA_MODEL_PATH=/secure/models/directory
```

## Production Setup

### System Requirements (Production)
```yaml
Minimum:
  CPU: 4 cores, 2.5GHz
  RAM: 16GB
  Storage: 50GB SSD
  OS: Ubuntu 20.04 LTS / CentOS 8 / Windows Server 2019

Recommended:
  CPU: 8+ cores, 3.0GHz
  RAM: 32GB
  Storage: 100GB+ NVMe SSD
  GPU: Optional (NVIDIA RTX 3060+ or better)
  OS: Ubuntu 22.04 LTS
```

### Production Configuration

**1. Create Production Config**
```python
# config.py
import os
from pathlib import Path

class ProductionConfig:
    # Security
    MAX_FILE_SIZE = 100 * 1024 * 1024  # 100MB
    ALLOWED_EXTENSIONS = {'.pdf', '.docx', '.txt', '.jpg', '.png', '.xlsx'}
    SAFE_BASE_PATH = Path("/opt/file_organizer/data")
    
    # Performance
    MAX_CONCURRENT_FILES = 5
    MODEL_CACHE_SIZE = "8GB"
    TIMEOUT_SECONDS = 300
    
    # Logging
    LOG_LEVEL = "INFO"
    LOG_FILE = "/var/log/file_organizer/app.log"
    AUDIT_LOG = "/var/log/file_organizer/audit.log"
    
    # Models
    MODEL_PATH = "/opt/file_organizer/models"
    TEXT_MODEL = "Llama3.2-3B-Instruct:q3_K_M"
    VISION_MODEL = "llava-v1.6-vicuna-7b:q4_0"
```

**2. Service Configuration**
```bash
# Create systemd service
sudo tee /etc/systemd/system/file-organizer.service << EOF
[Unit]
Description=Local File Organizer Service
After=network.target

[Service]
Type=simple
User=organizer_service
Group=organizer_group
WorkingDirectory=/opt/file_organizer
Environment=PATH=/opt/conda/envs/prod_file_organizer/bin:/usr/local/bin:/usr/bin:/bin
Environment=PYTHONPATH=/opt/file_organizer
ExecStart=/opt/conda/envs/prod_file_organizer/bin/python main.py --service-mode
Restart=always
RestartSec=10

# Security
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/opt/file_organizer/data /var/log/file_organizer

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable file-organizer
sudo systemctl start file-organizer
```

**3. Log Rotation**
```bash
# Configure logrotate
sudo tee /etc/logrotate.d/file-organizer << EOF
/var/log/file_organizer/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 0640 organizer_service organizer_group
    postrotate
        systemctl reload file-organizer
    endscript
}
EOF
```

## Docker Deployment

### Dockerfile
```dockerfile
FROM python:3.12-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    tesseract-ocr \
    libtesseract-dev \
    cmake \
    build-essential \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create application user
RUN useradd -r -u 1000 organizer

# Set working directory
WORKDIR /app

# Copy requirements and install Python packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Install Nexa SDK
RUN pip install nexaai --prefer-binary \
    --index-url https://nexaai.github.io/nexa-sdk/whl/cpu \
    --extra-index-url https://pypi.org/simple --no-cache-dir

# Copy application code
COPY --chown=organizer:organizer . .

# Create directories
RUN mkdir -p /app/data /app/models /app/logs && \
    chown -R organizer:organizer /app

# Switch to non-root user
USER organizer

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD python diagnostic_simple.py || exit 1

# Set environment variables
ENV PYTHONPATH=/app
ENV NEXA_MODEL_PATH=/app/models
ENV PYTHONUNBUFFERED=1

# Expose port (if web interface added)
# EXPOSE 8080

CMD ["python", "main.py"]
```

### Docker Compose
```yaml
version: '3.8'

services:
  file-organizer:
    build: .
    container_name: file_organizer
    restart: unless-stopped
    
    volumes:
      # Mount data directories
      - ./data:/app/data
      - ./models:/app/models
      - ./logs:/app/logs
      # Mount input/output directories
      - /host/documents:/app/input:ro
      - /host/organized:/app/output
    
    environment:
      - NEXA_MODEL_PATH=/app/models
      - LOG_LEVEL=INFO
      - MAX_FILE_SIZE=104857600  # 100MB
    
    # Resource limits
    deploy:
      resources:
        limits:
          memory: 8G
          cpus: '4.0'
        reservations:
          memory: 4G
          cpus: '2.0'
    
    # Security
    user: "1000:1000"
    read_only: true
    tmpfs:
      - /tmp
    
    # Logging
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "5"

volumes:
  models:
  logs:
```

### Docker Deployment Commands
```bash
# Build and run
docker-compose build
docker-compose up -d

# Check status
docker-compose ps
docker-compose logs -f file-organizer

# Update
docker-compose pull
docker-compose up -d --force-recreate

# Backup models and data
docker run --rm -v file_organizer_models:/models -v $(pwd):/backup alpine tar czf /backup/models_backup.tar.gz -C /models .
```

## Server Deployment

### Ubuntu/Debian Server Setup
```bash
#!/bin/bash
# Production deployment script for Ubuntu

# 1. System preparation
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y \
    python3.12 python3.12-venv python3.12-dev \
    tesseract-ocr libtesseract-dev \
    cmake build-essential curl git \
    nginx supervisor htop iotop

# 2. Create application user
sudo useradd -r -s /bin/false -d /opt/file_organizer organizer_service
sudo mkdir -p /opt/file_organizer/{app,data,models,logs}
sudo chown -R organizer_service:organizer_service /opt/file_organizer

# 3. Install application
cd /opt/file_organizer/app
sudo -u organizer_service git clone https://github.com/QiuYannnn/Local-File-Organizer.git .

# 4. Python environment
sudo -u organizer_service python3.12 -m venv venv
sudo -u organizer_service ./venv/bin/pip install -r requirements.txt
sudo -u organizer_service ./venv/bin/pip install nexaai

# 5. Configuration
sudo tee /opt/file_organizer/app/config.py << 'EOF'
import os
BASE_DIR = "/opt/file_organizer"
DATA_DIR = f"{BASE_DIR}/data"
MODEL_DIR = f"{BASE_DIR}/models"
LOG_DIR = f"{BASE_DIR}/logs"
MAX_FILE_SIZE = 100 * 1024 * 1024
EOF

# 6. Systemd service
sudo cp deployment/file-organizer.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable file-organizer

# 7. Log rotation
sudo cp deployment/file-organizer.logrotate /etc/logrotate.d/file-organizer

# 8. Firewall
sudo ufw enable
sudo ufw default deny incoming
sudo ufw allow ssh

echo "Deployment complete. Start with: sudo systemctl start file-organizer"
```

### CentOS/RHEL Server Setup
```bash
#!/bin/bash
# Production deployment script for CentOS/RHEL

# 1. Enable repositories
sudo dnf install -y epel-release
sudo dnf config-manager --set-enabled powertools

# 2. Install dependencies
sudo dnf install -y \
    python3.12 python3.12-pip python3.12-devel \
    tesseract tesseract-devel \
    cmake gcc gcc-c++ git

# 3. SELinux configuration (if enabled)
sudo setsebool -P httpd_can_network_connect 1
sudo semanage fcontext -a -t admin_home_exec_t "/opt/file_organizer/app(/.*)?"
sudo restorecon -R /opt/file_organizer/

# Continue with similar steps as Ubuntu...
```

## Monitoring & Maintenance

### Application Monitoring
```python
# monitoring.py
import psutil
import time
import logging
from pathlib import Path

class SystemMonitor:
    def __init__(self, log_file="/var/log/file_organizer/monitor.log"):
        logging.basicConfig(filename=log_file, level=logging.INFO)
        self.logger = logging.getLogger(__name__)
    
    def check_system_health(self):
        # CPU usage
        cpu_percent = psutil.cpu_percent(interval=1)
        
        # Memory usage
        memory = psutil.virtual_memory()
        memory_percent = memory.percent
        
        # Disk usage
        disk = psutil.disk_usage('/opt/file_organizer')
        disk_percent = disk.percent
        
        # Log metrics
        self.logger.info(f"CPU: {cpu_percent}%, Memory: {memory_percent}%, Disk: {disk_percent}%")
        
        # Alerts
        if memory_percent > 90:
            self.logger.warning(f"High memory usage: {memory_percent}%")
        
        if disk_percent > 85:
            self.logger.warning(f"High disk usage: {disk_percent}%")
        
        return {
            'cpu_percent': cpu_percent,
            'memory_percent': memory_percent,
            'disk_percent': disk_percent
        }

# Run monitoring
if __name__ == "__main__":
    monitor = SystemMonitor()
    while True:
        monitor.check_system_health()
        time.sleep(60)  # Check every minute
```

### Log Monitoring
```bash
# Monitor application logs
sudo tail -f /var/log/file_organizer/app.log

# Monitor system resource usage
htop

# Monitor disk I/O
iotop

# Monitor network connections
netstat -tlnp | grep python

# Check service status
systemctl status file-organizer

# View recent service logs
journalctl -u file-organizer -n 50 -f
```

### Automated Backup
```bash
#!/bin/bash
# backup.sh - Backup critical application data

BACKUP_DIR="/backup/file_organizer"
DATE=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup models (if not using shared storage)
tar -czf "$BACKUP_DIR/models_$DATE.tar.gz" -C /opt/file_organizer/models .

# Backup configuration
tar -czf "$BACKUP_DIR/config_$DATE.tar.gz" -C /opt/file_organizer/app config.py

# Backup logs (last 7 days)
find /var/log/file_organizer -name "*.log" -mtime -7 -exec tar -czf "$BACKUP_DIR/logs_$DATE.tar.gz" {} +

# Cleanup old backups
find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

# Log backup completion
logger "File Organizer backup completed: $DATE"
```

### Health Checks
```bash
#!/bin/bash
# health_check.sh

# Check if service is running
if ! systemctl is-active --quiet file-organizer; then
    echo "CRITICAL: File organizer service is not running"
    exit 2
fi

# Check if diagnostic passes
cd /opt/file_organizer/app
if ! timeout 30 python diagnostic_simple.py > /dev/null 2>&1; then
    echo "WARNING: Diagnostic test failed"
    exit 1
fi

# Check disk space
DISK_USAGE=$(df /opt/file_organizer | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    echo "CRITICAL: Disk usage is $DISK_USAGE%"
    exit 2
fi

# Check memory usage
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ "$MEMORY_USAGE" -gt 95 ]; then
    echo "CRITICAL: Memory usage is $MEMORY_USAGE%"
    exit 2
fi

echo "OK: All health checks passed"
exit 0
```

## Scaling Considerations

### Horizontal Scaling
```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: file-organizer
spec:
  replicas: 3
  selector:
    matchLabels:
      app: file-organizer
  template:
    metadata:
      labels:
        app: file-organizer
    spec:
      containers:
      - name: file-organizer
        image: file-organizer:latest
        resources:
          requests:
            memory: "4Gi"
            cpu: "2"
          limits:
            memory: "8Gi"
            cpu: "4"
        volumeMounts:
        - name: models
          mountPath: /app/models
          readOnly: true
        - name: data
          mountPath: /app/data
      volumes:
      - name: models
        persistentVolumeClaim:
          claimName: models-pvc
      - name: data
        persistentVolumeClaim:
          claimName: data-pvc
```

### Performance Optimization
```python
# performance_config.py
class PerformanceConfig:
    # Model optimization
    MODEL_QUANTIZATION = "q3_K_M"  # Smaller, faster models
    BATCH_PROCESSING = True
    MAX_BATCH_SIZE = 10
    
    # Resource limits
    MAX_MEMORY_PER_PROCESS = "4GB"
    MAX_CPU_CORES = 4
    
    # Caching
    ENABLE_MODEL_CACHE = True
    CACHE_SIZE_GB = 2
    
    # Processing optimization
    PARALLEL_FILE_READING = True
    ASYNC_PROCESSING = True
    PIPELINE_STAGES = 3
```

### Load Balancing
```nginx
# /etc/nginx/sites-available/file-organizer
upstream file_organizer_backend {
    least_conn;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

server {
    listen 80;
    server_name file-organizer.example.com;
    
    location / {
        proxy_pass http://file_organizer_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # File upload size limit
    client_max_body_size 100M;
    
    # Timeouts for long-running AI processing
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;
}
```

---

**Important Notes**:
1. Always test deployments in a staging environment first
2. Implement the security fixes mentioned in the audit before production deployment
3. Monitor resource usage closely, especially during AI model operations
4. Consider using CPU-only mode for better resource predictability
5. Regular backups are essential due to large AI model downloads

For additional deployment assistance, refer to the [Troubleshooting Guide](TROUBLESHOOTING_GUIDE.md) and [Setup Guide](SETUP_GUIDE.md).