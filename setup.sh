#!/bin/bash

# Check if the script is run with root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo 'This script must be run with root privileges' >&2
    exit 1
fi

# Update and upgrade the system
apt update && apt upgrade -y

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
    echo "A reboot is required in order to proceed with the install." >&2
    echo "Please reboot and re-run this script to finish the install." >&2
    exit 1
fi

# Install necessary tools
apt install linux-tools-virtual -y
apt install linux-cloud-tools-virtual -y

# Install GNOME desktop environment
apt install ubuntu-desktop -y

# Install XRDP
apt install xrdp -y

# Stop XRDP services before making changes
systemctl stop xrdp
systemctl stop xrdp-sesman

# Modify XRDP configuration
sed -i_orig -e 's/port=3389/port=vsock:\/\/-1:3389/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/security_layer=negotiate/security_layer=rdp/g' /etc/xrdp/xrdp.ini
sed -i_orig -e 's/crypt_level=high/crypt_level=none/g' /etc/xrdp/xrdp.ini

# Append the content to /etc/xrdp/startubuntu.sh
cat >> /etc/xrdp/startubuntu.sh << 'EOF'
#!/bin/sh
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
exec /etc/xrdp/startwm.sh
EOF

# Make the /etc/xrdp/startubuntu.sh script executable
chmod +x /etc/xrdp/startubuntu.sh
echo "Script /etc/xrdp/startubuntu.sh has been created and made executable."

# Modify sesman.ini to use startubuntu.sh
sed -i_orig -e 's/startwm/startubuntu/g' /etc/xrdp/sesman.ini
sed -i -e 's/FuseMountName=thinclient_drives/FuseMountName=shared-drives/g' /etc/xrdp/sesman.ini

# Modify Xwrapper.config to allow anybody to start X
sed -i_orig -e 's/allowed_users=console/allowed_users=anybody/g' /etc/X11/Xwrapper.config

# Check if the blacklist file exists and create it if it doesn't
if [ ! -e /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf ]; then
  echo "blacklist vmw_vsock_vmci_transport" > /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf
  echo "Blacklist file /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf created."
else
  echo "Blacklist file /etc/modprobe.d/blacklist-vmw_vsock_vmci_transport.conf already exists."
fi

# Check if the hv_sock module load file exists and create it if it doesn't
if [ ! -e /etc/modules-load.d/hv_sock.conf ]; then
  echo "hv_sock" > /etc/modules-load.d/hv_sock.conf
  echo "Module load file /etc/modules-load.d/hv_sock.conf created."
else
  echo "Module load file /etc/modules-load.d/hv_sock.conf already exists."
fi

# Create the directory and add the polkit configuration file
mkdir -p /etc/polkit-1/localauthority/50-local.d/
cat > /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla << 'EOF'
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

echo "Polkit configuration file /etc/polkit-1/localauthority/50-local.d/45-allow-colord.pkla has been created."

# Reload the systemd daemon and start XRDP services
systemctl daemon-reload
systemctl start xrdp
systemctl enable xrdp

echo "Install is complete."
echo "Reboot your machine to begin using XRDP."
