#!/bin/bash

set -e

COWRIE_USER="cowrie"
COWRIE_HOME="/home/$COWRIE_USER"
COWRIE_DIR="$COWRIE_HOME/cowrie"

# Step 1: Install system dependencies
echo "[+] Installing system dependencies..."
apt-get update
apt-get install -y git python3-pip python3-venv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind iptables-persistent

# Step 2: Create cowrie user
echo "[+] Creating user '$COWRIE_USER'..."
adduser --disabled-password --gecos "" $COWRIE_USER

# Step 3: Clone Cowrie
echo "[+] Cloning Cowrie repository..."
sudo -u $COWRIE_USER git clone https://github.com/cowrie/cowrie.git $COWRIE_DIR

# Step 4: Set up Python virtual environment
echo "[+] Setting up Python virtual environment..."
sudo -u $COWRIE_USER bash -c "
  cd $COWRIE_DIR
  python3 -m venv cowrie-env
  source cowrie-env/bin/activate
  pip install --upgrade pip
  pip install --upgrade -r requirements.txt
"

# Step 5: Configure Cowrie (default is fine)
echo "[+] Using default Cowrie configuration..."

# Step 6: Move real SSH server to port 22222 to avoid conflict
echo "[+] Reconfiguring SSHD to use port 22222..."
SSHD_CONFIG="/etc/ssh/sshd_config"
if grep -q "^#Port 22" $SSHD_CONFIG || grep -q "^Port 22" $SSHD_CONFIG; then
  sed -i 's/^#\?Port 22/Port 22222/' $SSHD_CONFIG
else
  echo "Port 22222" >> $SSHD_CONFIG
fi

# Allow the new SSH port through the firewall (if ufw is installed)
if command -v ufw >/dev/null; then
  echo "[+] Allowing SSH on port 22222 in UFW..."
  ufw allow 22222/tcp
fi

# Restart SSH service
echo "[+] Restarting SSH service..."
systemctl restart ssh

# Step 7: Start Cowrie
echo "[+] Starting Cowrie..."
sudo -u $COWRIE_USER bash -c "
  cd $COWRIE_DIR
  bin/cowrie start
"

# Step 8: Redirect port 22 to Cowrie (port 2222)
echo "[+] Setting iptables to redirect port 22 to Cowrie port 2222..."
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222

# Step 9: Save iptables rule
echo "[+] Saving iptables rules..."
netfilter-persistent save

echo "[✓] Cowrie installed, real SSH moved to port 22222, and port 22 now redirects to Cowrie!"
echo ">> Use 'ssh user@host -p 22222' to log in via SSH."
