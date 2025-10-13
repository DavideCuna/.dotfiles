{

  description = "Flake DC";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ...}:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      nixos = lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix

	# Home Manager
	  home-manager.nixosModules.home-manager
	           {
	             home-manager.useGlobalPkgs = true;
	             home-manager.useUserPackages = true;
	             home-manager.users.davide = import ./home.nix;
	           }
        ];
      };
    };
    homeConfigurations = {
      davide = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [ 
          ./home.nix
        ];
        username = "davide";
        homeDirectory = "/home/davide/";
      };
    };
  };
}
