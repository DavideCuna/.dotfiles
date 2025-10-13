{ pkgs, ... }: 
 
{

  stylix.enable = true;

  stylix.base16Scheme = {
	base00 = "#191411"; # dark
	base01 = "#26211c"; # bg-alt
	base02 = "#6e3b1e"; # brown
	base03 = "#7e7e7e"; # metal
	base04 = "#e7e0d7"; # fg
	base05 = "#a8733f"; # accent
	base06 = "#b94c2b"; # rust
	base07 = "#a80000"; # critical
	base08 = "#f19618"; # cursor (dall'esempio di kitty)
	base09 = "#e5e1cf"; # foreground kitty
	base0A = "#fff778"; # yellow (waybar)
	base0B = "#b8cc52"; # green (waybar)
	base0C = "#95e5cb"; # aqua (waybar)
	base0D = "#36a3d9"; # blue (waybar)
	base0E = "#f07078"; # magenta (waybar)
	base0F = "#ff3333"; # red (waybar)
  };
  
  # stylix.image = "/home/davide/Pictures/wallpapers/lain5.jpg";
 
}
