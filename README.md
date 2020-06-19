# home-manager

A collection of nix files and configurations for managing my home folder.

# Installation

* Install [nix](https://nixos.org/download.html)
* Install [home-manager](https://github.com/rycee/home-manager)
* Clone the repository
* Remove auto configured folder
* Link the configuration directory to the repository folder
* Run the switch

Or in code format:

```bash
curl -L https://nixos.org/nix/install | sh

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update

git clone git@github.com:jhuizy/home-manager

rm -rf ~/.config/nixpkgs

cd home-manager
ln -s $PWD ~/.config/nixpkgs

home-manager switch
```

# Everyday usage

## Adding a NPM package

1. Add the package name to [node/node-packages.json](./node/node-packages.json)
2. Regenerate relevant `nix` files `cd node && nix-shell -p nodePackages.node2nix --command "node2nix -i ./node-packages.json -o node-packages.nix"`
3. Add reference to the new package in `home.nix` (eg. `home.packages = [ extraNodePackages.<package name> ];`)