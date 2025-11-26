{ pkgs, ... }:
{
   home.packages = with pkgs; [
      kitty
      zsh
      oh-my-zsh
      git
      tmux
      htop
      neofetch
      curl
      wget
      fzf
      zip
      unzip
      avrdude
      flutter
   ];
}
