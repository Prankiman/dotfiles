#!/bin/sh

set -x
echo ${USER}
echo ${HOME}

command_exists() {
    command -v "$1" >"/dev/null" 2>&1
}

package_installed() {
    pacman -Q "$1" >"/dev/null" 2>&1
}

install_from_aur() {
    if ! command_exists "yay"; then
        git clone "https://aur.archlinux.org/yay.git" "/tmp/yay"
        cd "/tmp/yay" && makepkg -sirc --noconfirm
    fi
}

# Assumes 'sudo' command exists
install_basic_packages() {
    dependencies=($(< "./basic_dependencies"))

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
    yay_dependencies=($(< "./yay_dependencies"))

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
    :
}

link_dotfile(){
    if ! ln -s "${HOME}/dotfiles/${1}" "${HOME}/${1}"; then
        read -p "Remove file and link? (y/n) " choice
        if [ "$choice" = "y" ]; then
            rm "${HOME}/${1}"
            ln -s "${HOME}/dotfiles/${1}" "${HOME}/${1}"
        fi
    fi
}

link_dotfiles(){
    dotfiles=(".zprofile" ".zshrc" ".p10k.zsh" ".gitconfig" ".git-credentials" ".vimrc")

    for dotfile  in "${dotfiles[@]}"; do
        link_dotfile "$dotfile"
    done
}

add_user_to_groups(){
    sudo usermod -aG audio video wheel ${USER}
}

set_shell(){
    chsh -s "/usr/bin/zsh"
    sudo chsh -s "/usr/bin/zsh"
}

install_vimrc_config(){
    git clone --depth=1 "https://github.com/amix/vimrc.git" "${HOME}/.vim_runtime"
    sh "${HOME}/.vim_runtime/install_awesome_vimrc.sh"
    mkdir -p "${HOME}/.vim_runtime/pack/plugins/start"
}

yay -Syyu --noconfirm --disable-download-timeout

install_basic_packages
install_from_aur
install_yay_packages
update_configs
add_user_to_groups
set_shell
install_vimrc_config
start_daemons
link_dotfiles

echo "your done! reboot your system"
