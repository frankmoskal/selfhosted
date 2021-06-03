#! /usr/bin/env bash
set -euxo pipefail

###
# check for root
###
if [[ "$EUID" -ne "0" ]]; then
   printf "please run this script via sudo...\n"
   exit 1
fi

###
# add the xanmod kernel sourcelist & update keys
###
echo "deb http://deb.xanmod.org releases main" | tee "/etc/apt/sources.list.d/xanmod-kernel.list"
wget -qO - "https://dl.xanmod.org/gpg.key" | apt-key add -

###
# upgrade system to latest packages
###
apt update
apt --auto-remove -y full-upgrade

###
# install the xanmod kernel
###
apt -y install "linux-xanmod"

###
# install microcode
###
if [[ $(lscpu | grep "Vendor ID:" | awk '{print $3}') == "GenuineIntel"  ]]; then
    apt -y install "intel-microcode" \
        "iucode-tool"
else
    apt -y install "amd64-microcode"
fi

###
# enable fq-pie queuing discipline
#   https://man7.org/linux/man-pages/man8/FQ-PIE.8.html
###
echo 'net.core.default_qdisc = fq_pie' | tee "/etc/sysctl.d/90-override.conf"

###
# install docker pre-reqs
###
apt -y install "apt-transport-https" \
    "ca-certificates" \
    "curl" \
    "gnupg-agent" \
    "software-properties-common"

###
# add Docker GPG key
###
curl -fsSL "https://download.docker.com/linux/ubuntu/gpg" | apt-key add -

###
# add the docker ppa & update packages
###
add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable" -y
apt update

###
# install docker
###
apt -y install "docker-ce" \
    "docker-ce-cli" \
    "containerd.io"

###
# allow docker to run without using sudo
###
usermod -aG "docker" "$SUDO_USER"

###
# install languagetool dependencies
###
apt -y install "build-essential" \
    "cmake"

###
# install pipx & enable completions
###
sudo -i -u "$SUDO_USER" bash << EOF
python3 -m pip install "pipx"
python3 -m pipx ensurepath
printf "# pipx completions\neval \"\$(register-python-argcomplete3 pipx)\"\n" >> "$HOME/.bashrc"
EOF

###
# install direnv
###
apt -y install "direnv"
sudo -i -u "$SUDO_USER" bash << EOF
printf "# direnv\neval \"\$(direnv hook bash)\"\n" >> "$HOME/.bashrc"
EOF

###
# install docker-compose and enable daily updates
###
sudo -i -u "$SUDO_USER" bash << EOF
pipx install "docker-compose"
(crontab -l ; echo "0 5 * * * /usr/local/bin/pipx upgrade docker-compose") | sort - | uniq - | crontab -
EOF

###
# enable ssh access
###
apt -y install "openssh-server"

###
# install fzf
###
apt -y install "fzf"

###
# update swap size to 8Gb (should be 1x or 2x RAM amount)
###
swapoff -a
dd if="/dev/zero" of="/swapfile" bs="1G" count="8"
chmod "600" "/swapfile"
mkswap "/swapfile"
swapon "/swapfile"

###
# install snapd
###
apt install -y "snapd"

###
# install micro text editor
###
snap install "micro" --classic
echo "export VISUAL=micro" >> "$HOME/.bashrc"
echo "export EDITOR=micro" >> "$HOME/.bashrc"

###
# install starship
###
snap install "starship"
echo "eval \"$(starship init bash)\"" >> "$HOME/.bashrc"

###
# cleanup apt
###
apt -y autoremove --purge
apt -y clean

###
# chown the directory
###
chown -R "1000:1000" "server"

###
# reboot
###
read -rsp "restart required - press any key to reboot..."
reboot