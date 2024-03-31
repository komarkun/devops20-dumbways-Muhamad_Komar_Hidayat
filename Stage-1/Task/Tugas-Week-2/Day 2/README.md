# Sumary Day 2 Week 2

## Manage Server w/ Terminal

- Accessing the Server:

Establishing a secure connection to the server using SSH (Secure Shell) protocol.

```bash
ssh username@server_ip_address
```

- User Management:

Creating, modifying, and deleting user accounts, managing permissions, and setting up authentication methods like SSH keys.

```bash
# Creating a new user:
sudo adduser new_username

# Adding the user to a group:
sudo usermod -aG groupname username

# Generating SSH keys:
ssh-keygen -t rsa
```

- File System Operations:

Navigating the file system, creating, deleting, copying, moving files and directories, and managing permissions.

```bash
# Creating a directory:
mkdir directory_name

# Copying a file:
cp source_file destination_directory

#Changing file permissions:
chmod permissions filename
```

- Package Management:

Installing, updating, and removing software packages using package managers like apt (for Debian/Ubuntu) or yum/dnf (for Red Hat/CentOS).

- Updating package lists:

```bash
sudo apt update
```

Installing a package:

```bash
sudo apt install package_name
```

- Process Management:

Monitoring running processes, starting, stopping, and restarting services or applications.

Listing running processes:

```bash
ps aux
```

Restarting a service:

```bash
sudo systemctl restart service_name
```

- Network Configuration:

Configuring network interfaces, IP addresses, DNS settings, and firewall rules.

- System Monitoring and Logging:

Checking system resource usage, monitoring logs for errors or suspicious activities.

Checking network interfaces:

```bash
ip addr show
```

Adding an IP address:

```bash
sudo ip addr add ip_address dev interface_name
```

- System Monitoring and Logging:

Checking system resource usage:

```bash
top
```

Viewing system logs:

```bash
tail -f /var/log/syslog
```
