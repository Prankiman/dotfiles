#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias sudo='doas'
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias update-grub='grub-mkconfig -o /boot/grub/grub.cfg'
PS1='[\u@\h \W]\$ '

set -o vi
