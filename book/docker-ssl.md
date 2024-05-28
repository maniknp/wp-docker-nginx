
### SSL Certificates

For testing purposes, you can create a self-signed certificate using OpenSSL:

```sh
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
```

**Create a self-signed certificate using OpenSSL ( In current directory)**
```bash
mkdir -p server/nginx/ssl
```
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout server/nginx/ssl/nginx.key -out server/nginx/ssl/nginx.crt
```

## Windows: Install  `openssl`


To reinstall Chocolatey, set up the environment, and verify the installation, you can follow these steps:

1. **Remove the existing Chocolatey installation**:
   Open PowerShell with administrative privileges and run:
   ```powershell
   Remove-Item -Recurse -Force C:\ProgramData\chocolatey
   ```

2. **Install Chocolatey**:
   Open PowerShell with administrative privileges and run:
   ```powershell
   Set-ExecutionPolicy Bypass -Scope Process -Force; 
   [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
   iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
   ```

3. **Verify Chocolatey installation**:
   After installation, verify that Chocolatey is installed correctly:
   ```powershell
   choco -v
   ```

4. **Install OpenSSL using Chocolatey**:
   ```powershell
   choco install openssl -y
   ```

5. **Ensure OpenSSL is added to PATH**:
   Open PowerShell with administrative privileges and run:
   ```powershell
   $env:Path += ";C:\Program Files\OpenSSL-Win64\bin"
   [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)
   ```

6. **Verify OpenSSL installation**:
   To verify that OpenSSL is installed and available in your PATH, run:
   ```powershell
   openssl version
   ```
