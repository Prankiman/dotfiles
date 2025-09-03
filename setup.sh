#!/bin/sh

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    pacman -Q "$1" >/dev/null 2>&1
}

install_from_aur() {
    if ! command_exists "yay"; then
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay && makepkg -sirc --noconfirm
    fi
}

# Assumes 'sudo' command exists
install_basic_packages() {
    dependencies=("os-prober" "gcc" "python" "git" "gdb" "wget" "zsh" "curl" "go" "sed" "plocate" "make" "nvm" "cmake" "net-tools" "unzip" "p7zip" "docker" "sddm" "plasma-desktop" "filelight" "firefox" "dolphin" "okular" "konsole" "pipewire" "pipewire-pulse" "bluez" "networkmanager" "wireshark-qt"  "python-pip" "python-pipx" "wl-clipboard")
    
    # Install missing dependencies
    for dependency in "${dependencies[@]}"; do
        if ! command_exists "$dependency"; then
            if ! package_installed "$dependency"; then
                sudo pacman -S --disable-download-timeout --noconfirm "$dependency"
            fi
        fi
    done
}


install_yay_packages() {
    yay_dependencies=("zsh-theme-powerlevel10k-git" "tt" "neofetch" )
    
    for dependency in "${yay_dependencies[@]}"; do
        if ! command_exists "$dependency"; then
            if ! package_installed "$dependency"; then
                yay -S --noconfirm "$dependency"
            fi
        fi
    done
}

start_daemons(){
	sudo systemctl enable NetworkManager
	sudo systemctl enable sddm	
}

# for updating files in ${HOME}/.config
update_configs() {
    # update configs here
}

link_dotfiles(){
	ln -s ~/dotfiles/.bashrc ~/.bashrc
	ln -s ~/dotfiles/.bash_profile  ~/.bash_profile
	ln -s ~/dotfiles/.zcompdump ~/.zcompdump
	ln -s ~/dotfiles/.zprofile ~/.zprofile
	ln -s ~/dotfiles/.zshrc ~/.zshrc
	ln -s ~/dotfiles/.p10k.zsh ~/.p10k.zsh
	ln -s ~/dotfiles/.gitconfig ~/.gitconfig
	ln -s ~/dotfiles/.git-credentials ~/.git-credentials
	ln -s ~/dotfiles/.vim ~/.vim
}

add_user_to_groups(){
	sudo usermod -aG audio video wheel ${USER}
}

set_shell(){
	chsh -s /usr/bin/zsh
	sudo chsh -s /usr/bin/zsh
}

yay -Syyu --noconfirm --disable-download-timeout

install_basic_packages
install_from_aur
install_yay_packages
update_configs
link_dotfiles
add_user_to_groups
set_shell

echo "your done! reboot your system"
