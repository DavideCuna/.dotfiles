{
  description = "Flake DC";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
       home-manager = {
         url = "github:nix-community/home-manager/release-25.05";
         inputs.nixpkgs.follows = "nixpkgs";
       };
    
       hyprland = {
         url = "github:hyprwm/Hyprland";
         inputs.nixpkgs.follows = "nixpkgs";
       };
  };


  outputs = { self, nixpkgs, home-manager, hyprland, ... }: 
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};
    in 
    {
      # Configurazione NixOS principale
      nixosConfigurations = {
        nixos = lib.nixosSystem {
          inherit system;
          
          modules = [
            ./configuration.nix
            
            # Integrazione di Home Manager in NixOS
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                
                users.davide = import ./home.nix;
              };
            }
          ];
        };
      };

      # Configurazione standalone di Home Manager (opzionale)
      homeConfigurations = {
        davide = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          
          modules = [ ./home.nix ];
          
          extraSpecialArgs = {
            username = "davide";
            homeDirectory = "/home/davide";
          };
        };
      };
    };
}
