#!/bin/sh

echo -e "\x1b[1;30;47mBuilding Flake and NixOs Config in $(pwd)\x1b[0m"
echo -e '\x1b[1;32;49mUpdating Channel\x1b[0m'
nixos-rebuild switch --upgrade

echo -e '\x1b[0;32mUpdating Flake Lockfile\x1b[0m'
nix flake update

echo -e '\x1b[0;32mUpdating System\x1b[0m'
nixos-rebuild switch --upgrade --flake .
git commit -a -S
git push

echo -e "Do you wish to reboot [y/N]:\c"
read  ans

if [[ "$ans" = "y" ]] || [[ "$ans" = "Y" ]]; then
        reboot
else
	echo -e "Completed"
fi
