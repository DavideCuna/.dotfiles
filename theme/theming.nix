{ config, pkgs, nix-colors, ... }@args:

let
  # 1. Importa la palette personalizzata
  myPalette = import ./palette.nix;
  
  # 2. Converte la palette nel formato accettato da nix-colors
  customColorScheme = nix-colors.lib.mkScheme myPalette.name myPalette;

  # 3. Definisce un set di colori semplificati per un accesso più facile e chiaro
  # L'attributo config.colorScheme.palette viene generato da nix-colors dopo l'import
  c = config.colorScheme.palette;
  
  simpleColors = {
    Background = c.base00;
    Foreground = c.base05;
    Accent = c.base0d;      # Blu come accento principale
    Secondary = c.base0c;   # Ciano/Turchese come accento secondario
    Error = c.base08;       # Rosso
    Surface = c.base02;     # Superfici UI
    Inactive = c.base03;    # Testo/Elementi inattivi
  };
  
in
{
  # =========================================================================
  # A. CONFIGURAZIONE NIXOS (Generale / System-Wide)
  # =========================================================================
  imports = [
    # Abilita il modulo principale di nix-colors
    nix-colors.nixosModules.default
  ];

  # Imposta la tua palette come schema di colori globale
  colorScheme = customColorScheme;

  # =========================================================================
  # B. CONFIGURAZIONE HOME MANAGER (Applicazioni Utente)
  # =========================================================================
  # Assumi che l'utente sia 'user' (adatta se necessario)
  home-manager.users.davide = {
    config,
    pkgs,
    ...
  }: {
    # Non è necessario impostare colorScheme qui se è già impostato a livello di sistema,
    # ma devi importare i moduli di nix-colors per usare config.colorScheme.palette.
    imports = [
      nix-colors.homeManagerModules.default
    ];

    # Esempio 1: Terminale Alacritty
    programs.kitty = {
      enable = true;
      settings = {
        font.family = "Iosefka Term"; # Sostituisci con il tuo font
        colors.primary = {
          background = simpleColors.Background;
          foreground = simpleColors.Foreground;
        };
        # Sfrutta i colori accentati
        colors.normal = {
          black = simpleColors.Inactive;
          red = simpleColors.Error;
          green = c.base0b;
          yellow = c.base0a;
          blue = simpleColors.Accent;
          magenta = c.base0e;
          cyan = simpleColors.Secondary;
          white = simpleColors.Foreground;
        };
      };
    };

    # Esempio 2: Prompt della Shell (se usi Starship)
    programs.zsh = {
      enable = true;
      settings = {
        format = "$all";
        palette = {
          # Puoi usare i tuoi nomi semplici qui
          bg = simpleColors.Background;
          fg = simpleColors.Foreground;
          acc = simpleColors.Accent;
        };
        character = {
          success_symbol = "[❯](bold fg:acc)";
          error_symbol = "[❯](bold fg:Error)";
        };
      };
    };
  };
}
