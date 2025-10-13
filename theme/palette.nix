{
  colors = rec {
    # ----------------------------------------------------
    # CORE UI NEUTRALS (Ispirati a Lain: Freddo/Scuro/Caldo)
    # ----------------------------------------------------
    bg             = "#1E2025"; # Sfondo (Dark Blue/Gray - Profondità, Base00)
    bgAlt          = "#383B40"; # Sfondo secondario (Più scuro e freddo, Base01)
    overlay        = "#53565D"; # Superfici UI (Base02)
    border         = "#686D74"; # Bordi / Elementi Inattivi (Base03)
    fg             = "#D9D1C9"; # Testo principale (Grigio chiaro caldo, dai capelli, Base05)
    fgAlt          = "#968A7D"; # Testo secondario (Marrone/Grigio con sfumatura calda, Base04)

    # ----------------------------------------------------
    # ANSI palette (Base set) - Utilizza accenti Lain/Digitali
    # ----------------------------------------------------
    black          = bg; 
    blackBright    = bgAlt;
    red            = "#D43A3A"; # Rosso (Dal fuoco/rosso scuro Base08)
    redBright      = "#E64B4B"; # Rosso Vivace
    green          = "#7FBD7A"; # Verde (Successo)
    greenBright    = "#9DD48C"; # Verde Vivace
    yellow         = "#E0AF68"; # Giallo (Warning - Tonalità Oro/Arancio Base0A)
    yellowBright   = "#FFB240"; # Oro Vivace
    blue           = "#5C9BE8"; # Blu (Link - Dal blu elettrico Base0D)
    blueBright     = "#88B1E4"; # Blu Chiaro
    magenta        = "#A181C8"; # Viola (Funzioni/Keywords - Base0E)
    magentaBright  = "#C2A8E5"; # Viola Chiaro
    cyan           = "#5BC0BC"; # Ciano/Turchese (Accent Digital - Base0C)
    cyanBright     = "#86D6D3"; # Ciano/Turchese Brillante
    white          = fgAlt;
    whiteBright    = "#F4EFEB"; # (Base07)

    blueIce        = cyan;      # Mappato al nuovo accento digitale
    blueIceBright  = cyanBright;

    # ----------------------------------------------------
    # Extended purples & pinks (Manteniamo la struttura)
    # ----------------------------------------------------
    purpleDeep     = "#2D1950"; # Mantenuto Scuro
    purple         = "#8D62AA"; # Viola Ricco
    purpleBright   = "#B5658C"; # Viola-Rosa Scuro (Base0F)

    fuchsia        = "#D86B9E"; # Rosa forte
    fuchsiaBright  = "#FF88C2"; # Rosa brillante

    # ----------------------------------------------------
    # Cursor / selection
    # ----------------------------------------------------
    cursor         = yellowBright;
    selectionBg    = "#403020"; # Marrone scuro (Base03)
    selectionFg    = whiteBright;

    # ----------------------------------------------------
    # Accents & Semantics
    # ----------------------------------------------------
    accent         = cyan;      # Accent primario: il Turchese/Ciano digitale
    accent2        = yellowBright; # Accent secondario: Oro
    accent3        = purple;
    accentPink     = fuchsia;

    ok             = green;
    error          = red;
    warn           = yellowBright;
    info           = blue;
    infoStrong     = blueBright; 

    highlight      = fuchsiaBright;
    focus          = purpleBright;

    # Hyprland border semantics
    borderActive   = accent;
    borderInactive = border;
    borderUrgent   = redBright;
  };
}
