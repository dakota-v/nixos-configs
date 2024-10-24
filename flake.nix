{
  description = "dakota-nix config";

  inputs = {
        # Default to the nixos-unstable branch
    nixpkgs-stable.url="github:nixos/nixpkgs/nixos-24.05";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-software-center.url = "github:snowfallorg/nix-software-center";
    nixos-conf-editor.url = "github:snowfallorg/nixos-conf-editor";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs@{
    self,
    nix-software-center,
    nixos-conf-editor,
    nixpkgs,
    nixpkgs-stable,
    home-manager,
    ...
  }: {
    nixosConfigurations = {
      # TODO please change the hostname to your own
      dakota-nix = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ({pkgs, ...}: {
            environment.systemPackages = with pkgs; [
              inputs.nix-software-center.packages.${system}.nix-software-center
              inputs.nixos-conf-editor.packages.${system}.nixos-conf-editor
          ];
          
        })
        ./configuration.nix
          # make home-manager as a module of nixos
          # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            # TODO replace ryan with your own username
            home-manager.users.dakota = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
          }
        ];
      };
    };
  };
}
