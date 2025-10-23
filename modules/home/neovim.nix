{ pkgs, ... }:
{
   home.packages = with pkgs; [
      neovim
      lua
      luarocks
      lua-language-server
      tree-sitter
      stylua
      nodejs
      vimPlugins.nvim-cmp
      vimPlugins.markdown-preview-nvim
      markdownlint-cli
      pyright
   ];
}
