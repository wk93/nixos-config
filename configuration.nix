# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = "nix-command flakes";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "t480"; # Define your hostname.

  networking.wireless.iwd.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    # keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.wojtek = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    iwd
    neovim 
    wget
    curl
    wget
    tmux
    gnupg
    firefox
    alacritty
  ];

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = ["wojtek"];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "24.11";

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement = {
      enable = true;
      finegrained = true;
    };
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  programs.hyprland = {
    enable = true;
  };

  programs.lazygit.enable = true;

  programs.ssh = {
    extraConfig = ''
      Host *
          IdentityAgent ~/.1password/agent.sock
    '';
  };

  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Wojciech Kania";
        email = "wojtek@kania.sh";
        signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII7m6r15E4iMooTSqgWN3Qr0AxNEbG4pa/eH3NXPynZ0";
      };
      gpg = {
        format = "ssh";
      };
      gpg."ssh".program = "${pkgs._1password-gui}/bin/op-ssh-sign";
      commit = {
        gpgsign = true;
      };
    };
  };

  systemd.user.services."1password" = {
    description = "1Password - Password manager";
    serviceConfig.ExecStart = "1password --silent";
    serviceConfig.Restart = "always";
    wantedBy = [ "default.target" ];
  };


}

