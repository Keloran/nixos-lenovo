{
  description = "Flakiest OS";

  inputs = {
    nixpkgs = {
      url = "github:nixos/nixpkgs/nixos-24.11";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs = {
        nixpkgs = {
          follows = "nixpkgs";
	};
      };
    };
    _1password-shell-plugins = {
      url = "github:1Password/shell-plugins";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: let inherit (self) outputs; in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
	modules = [
          ./os/configuration.nix

          home-manager.nixosModules.home-manager {
	    home-manager = {
	      useUserPackages = true;
	      extraSpecialArgs = {inherit inputs outputs;};
	      users = {
	        keloran = import ./home-manager/home.nix;
	      };
	    };
	  }
        ];
      };
    };
  };
}

