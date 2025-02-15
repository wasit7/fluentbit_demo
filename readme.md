### **Tutorial Outline: Setting Up a Log Processing Pipeline with Nginx and Fluent Bit**

This tutorial provides a step-by-step guide to setting up **Nginx as a file server** and **Fluent Bit for log processing**. The pipeline captures and parses Nginx access logs into structured JSON format.

---

## **1. Prerequisites**
- Docker and Docker Compose installed
- Basic familiarity with Nginx and Fluent Bit
- Linux-based system (Ubuntu, macOS, or WSL for Windows)

---

## **2. Project Overview**
- **Nginx** serves files and logs HTTP requests.
- **Fluent Bit** reads and processes Nginx logs into structured JSON.
- The processed logs are stored for further analysis.

---

## **3. Directory Structure**
Before proceeding, ensure your project structure is as follows:
```
fluentbit_demo/
├── data/
│   ├── dir_a/hello_a.txt
│   ├── dir_b/hello_b.txt
│   ├── logs/access.log
│   ├── logs/error.log
│   └── output/nginx-access
├── docker-compose.yml
├── Dockerfile
├── fluentbit-config/
│   ├── fluent-bit.conf
│   └── parsers.conf
├── nginx.conf
└── restart.sh
```
---

## **4. Step-by-Step Setup**
### **Step 1: Configure Nginx as a File Server**
1. Create an `nginx.conf` file:
```nginx
http {
    # Log to /var/log/nginx
    access_log /var/log/nginx/access.log;
    error_log  /var/log/nginx/error.log warn;

    server {
        listen 80;
        server_name localhost;

        # Serve everything from /usr/share/nginx/html
        location / {
            root /usr/share/nginx/html;

            # Enable directory listing
            autoindex on;
            autoindex_exact_size off;
            autoindex_localtime on;
        }
    }
}
```
2. Ensure that `data/logs/` is writable:
```sh
mkdir -p data/logs
touch data/logs/access.log data/logs/error.log
chmod -R 777 data/logs
```

---

### **Step 2: Configure Fluent Bit**
1. Create `fluent-bit.conf`:
```
[SERVICE]
    HTTP_Server   On
    HTTP_Listen   0.0.0.0
    HTTP_Port     2020
    Reload        On
    Log_Level     debug
    Parsers_File  parsers.conf

[INPUT]
    Name          tail
    Path          /var/log/nginx/access.log
    Tag           nginx-access
    Parser        nginx_custom

[OUTPUT]
    Name          file
    Match         *
    Path          /fluent-bit/out/
    Format        plain
```

2. Define the parser in `parsers.conf`:
```ini
[PARSER]
    Name        nginx_custom
    Format      regex
    Regex       ^(?<ip>[\d\.]+)\s-\s(?<auth>\S+)\s\[(?<time>[^\]]+)\]\s"(?<method>[A-Z]+)\s(?<path>[^ ]+)\sHTTP/(?<http_version>\d\.\d)"\s(?<status>\d+)\s(?<bytes>\d+)\s"(?<referer>[^"]+)"\s"(?<agent>[^"]+)"$
```

---

### **Step 3: Create Docker Compose Configuration**
Create `docker-compose.yml`:
```yaml
services:
  nginx-file-server:
    image: nginx:alpine
    container_name: nginx-file-server
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./data:/usr/share/nginx/html:ro
      - ./data/logs:/var/log/nginx
    ports:
      - "8080:80"
    restart: always

  fluentbit:
    image: fluent/fluent-bit:latest

    container_name: fluentbit
    volumes:
      - ./fluentbit-config:/fluent-bit/etc
      - ./data/logs:/var/log/nginx:ro
      - ./data/output:/fluent-bit/out
    command: /fluent-bit/bin/fluent-bit -c /fluent-bit/etc/fluent-bit.conf
    ports:
      - "2020:2020"
    restart: always
```

---

### **Step 4: Deploy the Pipeline**
1. Start the services:
```sh
docker-compose up -d
```
2. Verify that containers are running:
```sh
docker-compose ps
```
3. Check Fluent Bit logs:
```sh
docker-compose logs fluentbit
```
4. Test the file server by opening a browser and navigating to:
```
http://localhost:8080
```
This should list the files inside `data/`.

---

### **Step 5: Validate Log Processing**
1. Generate test requests:
```sh
curl http://localhost:8080/dir_a/hello_a.txt
curl http://localhost:8080/dir_b/hello_b.txt
```
2. Check `access.log`:
```sh
docker-compose exec nginx cat /var/log/nginx/access.log
```
3. Verify structured logs:
- go to [http://localhost:8080/output/nginx-access]
Expected JSON output:
```json
{
    "ip":"192.168.64.1",
    "auth":"-",
    "method":"GET",
    "path":"/logs/access.log",
    "http_version":"1.1",
    "status":"200",
    "bytes":"3154",
    "referer":"http://localhost:8080/logs/",
    "agent":"Mozilla/5.0 (X11; Linux x86_64)"
}
```

---

### **Step 6: Restart and Cleanup**
To restart services and reload config:
```sh
./restart.sh
```
To stop and remove containers:
```sh
docker-compose down
```

---

## **Conclusion**
This tutorial covered:
1. **Setting up Nginx as a file server.**
2. **Configuring Fluent Bit to parse logs.**
3. **Deploying using Docker Compose.**
4. **Verifying structured log output.**

This setup provides a **scalable log processing pipeline** suitable for **monitoring web traffic** and **analyzing access logs**.