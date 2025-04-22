#!/bin/bash

# install_rdp.sh
# One-click Remote Desktop Installation Script

# Ensure the script runs with root privileges
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with root privileges"
    echo "Usage: sudo bash $0"
    exit 1
fi

# Functions for colored text output
print_info() {
    echo -e "\e[1;34m[INFO]\e[0m $1"
}

print_success() {
    echo -e "\e[1;32m[SUCCESS]\e[0m $1"
}

print_error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
}

# Function to create new users
create_user() {
    local username=$1
    local password=$2
    local is_sudo=$3
    
    print_info "Creating new user: $username"
    adduser --gecos "" --disabled-password "$username"
    echo "$username:$password" | chpasswd
    
    # Grant sudo privileges based on selection
    if [ "$is_sudo" = "y" ]; then
        usermod -aG sudo "$username"
        print_info "Granted sudo privileges to $username"
    else
        print_info "Created regular user $username (no sudo privileges)"
    fi
    
    # Ensure user can use remote desktop
    usermod -aG ssl-cert "$username"
}

# Main installation function
main_install() {
    # Update system
    print_info "Updating system packages..."
    apt update
    apt upgrade -y

    # Install Ubuntu desktop environment
    print_info "Installing Ubuntu desktop environment..."
    DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop

    # Install XRDP
    print_info "Installing XRDP..."
    apt install -y xrdp
    systemctl enable xrdp
    systemctl start xrdp

    # Configure XRDP
    print_info "Configuring XRDP..."
    cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak
    echo "allowed_users=anybody" > /etc/X11/Xwrapper.config
    
    # Ensure ssl-cert group exists and add xrdp user to it
    addgroup --system ssl-cert || true
    usermod -aG ssl-cert xrdp
    
    # Set xrdp certificate permissions
    chown root:ssl-cert /etc/xrdp/key.pem
    chmod 640 /etc/xrdp/key.pem
    
    # Install and configure firewall
    print_info "Configuring firewall..."
    apt install -y ufw
    ufw allow 3389/tcp
    ufw --force enable

    # Performance optimization
    print_info "Installing lightweight XFCE desktop environment..."
    apt install -y xfce4
    echo "[Unit]" > /etc/systemd/system/fix-theme.service
    echo "Description=Fix GTK theme after login" >> /etc/systemd/system/fix-theme.service
    echo "After=xrdp.service" >> /etc/systemd/system/fix-theme.service
    echo "[Service]" >> /etc/systemd/system/fix-theme.service
    echo "Type=oneshot" >> /etc/systemd/system/fix-theme.service
    echo "ExecStart=/bin/sh -c 'unset DBUS_SESSION_BUS_ADDRESS; canberra-gtk-play --file=/usr/share/sounds/ubuntu/stereo/system-ready.oga'" >> /etc/systemd/system/fix-theme.service
    echo "[Install]" >> /etc/systemd/system/fix-theme.service
    echo "WantedBy=multi-user.target" >> /etc/systemd/system/fix-theme.service
    systemctl enable fix-theme.service

    # Set resource limits
    print_info "Setting system resource limits..."
    cat >> /etc/security/limits.conf << EOF
*          soft    nproc          100
*          hard    nproc          150
*          soft    nofile         4096
*          hard    nofile         8192
EOF

    # Create user configuration script
    cat > /usr/local/bin/configure_xrdp_user.sh << 'EOF'
#!/bin/bash
echo "xfce4-session" > ~/.xsession
chmod a+x ~/.xsession

# Create user config directory
mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/

# Configure XFCE session
cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml << 'INNEREOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="FailsafeSessionName" type="string" value="Failsafe"/>
  </property>
  <property name="sessions" type="empty">
    <property name="Failsafe" type="empty">
      <property name="IsFailsafe" type="bool" value="true"/>
      <property name="Count" type="int" value="5"/>
      <property name="Client0_Command" type="array">
        <value type="string" value="xfwm4"/>
      </property>
      <property name="Client1_Command" type="array">
        <value type="string" value="xfce4-panel"/>
      </property>
      <property name="Client2_Command" type="array">
        <value type="string" value="Thunar"/>
      </property>
      <property name="Client3_Command" type="array">
        <value type="string" value="xfdesktop"/>
      </property>
      <property name="Client4_Command" type="array">
        <value type="string" value="xfce4-terminal"/>
      </property>
    </property>
  </property>
</channel>
INNEREOF
EOF
    chmod +x /usr/local/bin/configure_xrdp_user.sh

    # Add to default user profile
    cat >> /etc/skel/.profile << 'EOF'
if [ ! -f ~/.xsession ]; then
    /usr/local/bin/configure_xrdp_user.sh
fi
EOF
}

# Start installation
print_info "Starting remote desktop installation..."

# Execute main installation
if main_install; then
    print_success "Basic environment installation completed!"
else
    print_error "Installation error occurred, please check logs"
    exit 1
fi

# Prompt for creating new users
while true; do
    read -p "Do you want to create a new user? (y/n): " yn
    case $yn in
        [Yy]* )
            read -p "Enter username: " username
            read -s -p "Enter password: " password
            echo
            read -p "Grant sudo privileges? (y/n): " sudo_permission
            create_user "$username" "$password" "$sudo_permission"
            su - "$username" -c "/usr/local/bin/configure_xrdp_user.sh"
            print_success "User $username created successfully!"
            read -p "Create another user? (y/n): " continue_create
            if [[ $continue_create != "y" ]]; then
                break
            fi
            ;;
        [Nn]* )
            break
            ;;
        * )
            echo "Please answer y or n"
            ;;
    esac
done

# Restart XRDP service
systemctl restart xrdp

print_success "Installation completed!"
echo "=================================================="
echo "Remote Desktop Installation Completed. Important Information:"
echo "1. RDP Port: 3389"
echo "2. Connect using your AWS instance's public IP"
echo "3. Login with created username and password"
echo "4. If connection issues occur, check:"
echo "   - AWS security group (port 3389 must be open)"
echo "   - XRDP service status: 'sudo systemctl status xrdp'"
echo "   - Logs: sudo tail -f /var/log/xrdp.log"
echo "5. All users (including non-sudo users) can use remote desktop"
echo "=================================================="
