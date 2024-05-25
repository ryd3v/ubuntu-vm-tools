# XRDP Setup Script with GNOME Desktop for Ubuntu

This script automates the installation and configuration of XRDP with the GNOME desktop environment on an Ubuntu system. It includes necessary checks for root privileges and ensures that the system is updated and upgraded before proceeding. The script also configures various settings to optimize XRDP performance and usability.

## Features

- Checks if the script is run with root privileges
- Updates and upgrades the system packages
- Checks if a reboot is required before proceeding
- Installs necessary virtualization tools
- Installs the GNOME desktop environment
- Installs and configures XRDP
- Modifies XRDP configuration for vsock, security, and encryption settings
- Creates and configures a custom startup script for XRDP sessions
- Updates `sesman.ini` and `Xwrapper.config` for XRDP settings
- Blacklists `vmw_vsock_vmci_transport` module if not already blacklisted
- Ensures `hv_sock` module is loaded
- Adds a polkit configuration file to allow color management actions for all users
- Reloads systemd daemon and starts XRDP services

## Usage

### Prerequisites

- Ensure you have root privileges to run the script.

### Steps

1. **Make the Script Executable:**
    ```sh
    chmod +x setup.sh
    ```

3. **Run the Script with Superuser Privileges:**
    ```sh
    sudo ./setup.sh
    ```

4. **Reboot Your Machine:**
    After the script completes, reboot your machine to begin using XRDP with the GNOME desktop environment.
