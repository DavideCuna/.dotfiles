{ lib, ... }:
let
  inherit (lib) mkOption types;
in {
  options.colorscheme = {
    accent   = mkOption { type = types.str; default = "#a8733f"; };
    brown    = mkOption { type = types.str; default = "#6e3b1e"; };
    rust     = mkOption { type = types.str; default = "#b94c2b"; };
    dark     = mkOption { type = types.str; default = "#191411"; };
    metal    = mkOption { type = types.str; default = "#7e7e7e"; };
    bg       = mkOption { type = types.str; default = "#191411"; };
    bgAlt    = mkOption { type = types.str; default = "#26211c"; };
    fg       = mkOption { type = types.str; default = "#e7e0d7"; };
    warning  = mkOption { type = types.str; default = "#b94c2b"; };
    critical = mkOption { type = types.str; default = "#a80000"; };
  };

  # Valori effettivi della palette (puoi cambiarli qui)
  config.colorscheme = {
    accent   = "#a8733f";
    brown    = "#6e3b1e";
    rust     = "#b94c2b";
    dark     = "#191411";
    metal    = "#7e7e7e";
    bg       = "#191411";
    bgAlt    = "#26211c";
    fg       = "#e7e0d7";
    warning  = "#b94c2b";
    critical = "#a80000";
  };
}
