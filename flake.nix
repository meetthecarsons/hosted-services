{
  description = "Dev tooling for hosted-services (pre-commit hooks, sops/age)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              pre-commit
              sops
              age
              shfmt
              shellcheck
              yamllint
              hadolint
              detect-secrets
            ];
          };
        }
      );
    };
}
