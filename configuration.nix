# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

#==== Non-Nix Configuration files ====
# Sway      - ~/.config/sway/config
# iwd       - /var/lib/iwd
# Fuzzel    - ~/.config/fuzzel/fuzzel.ini
# Alacritty - ~/.alacritty.toml/yml
# NvChad    - ~/.config/nvim/init.lua and /lua
# Firefox   - ~/.mozilla/firefox/nl23z759.default
# i3status  - ~/.config/i3status/config
# ly (cope) - :(

{ config, lib, pkgs, ... }:

{

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # BIOS updates?
  services.fwupd.enable = true;

  #fingerprint reader
  #https://wiki.nixos.org/wiki/Fingerprint_scanner
  systemd.services.fprintd = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "simple";
  };

  services.fprintd.enable = true;

  #flaken' it up
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.hostName = "beeblebrox"; # Define your hostname.
  # Pick only one of the below networking options.
  networking.wireless.enable = false;
  networking.networkmanager.enable = false;  # Easiest to use and most distros use this by default.
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
       IPv6 = false;
      };
      Network = {
        AutoConnect = true;
      };
    };
  };

  # Set your time zone.
  time.timeZone = "America/Detroit";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mo = {
    isNormalUser = true;
    uid = 1000;
    group = "mo";
    extraGroups = [ "wheel" "video" "wireshark" "adbusers" "seat" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.bashInteractive;
    packages = with pkgs; [
      # Terminal stuff
      alacritty
      xterm
      fuzzel # dmenu
      play # play audio from the command line
      scrot # screenshot utility
      newsboat # rss reader
      clang
      clang-tools_16
      swappy # part of command line screenshot tool
      bison #for CS 4121 Prog Lang
      flex  #for CS 4121 Prog Lang
      gdb
      valgrind
      deno
      htop
      ffmpeg
      unzip
      inetutils #ftp, telnet
      alsa-utils
      zip
      fastfetch #neofetch replacement
      tmux
      nodejs_20

      # Applications
      firefox
      vlc
      libreoffice
      gimp
      obs-studio
      kdePackages.dolphin
      zoom
      imagemagick
      arduino
      discord
      
      qdirstat # spacial file viewer
      steam
      darktable
      librewolf
      jetbrains.rust-rover
      android-studio
      android-tools # android command line debugger
      freecad-wayland
      bambu-studio
      lorien
      pavucontrol # mic/speaker control tool
      ghex # hex reader (not editor?)

      # Wine tooling
      wineWowPackages.stable
      winetricks

      # Cursor
      adwaita-icon-theme
    ];
  };

  services.mysql.enable = true;
  services.mysql.package = pkgs.mariadb;
  virtualisation.docker.enable = true;
  services.tailscale.enable = false;
  programs.adb.enable = true;

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };


  users.groups.mo = {};

  fonts.packages = with pkgs; [
    nerd-fonts.code-new-roman
  ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config = {
    android_sdk.accept_license = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fish
    neovim
    vim 
    zoxide
    tree
    wget
    git
    brightnessctl
    gcc
    gnumake # make
    #switch to i3status-rust when out of unstable!
    i3status
    python3
    jdk
    rustup

    #fonts

    # For wayland/sway
    swaybg
    # this has not been set up yet
    betterlockscreen
    bc  # no clue lol
    gammastep # fractional brightness (replace xrandr)
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    xclip # command line to clipboard
    mako # notification system developed by swaywm maintainer
  ];

  systemd.user.services.dbus.environment = {
    WAYLAND_DISPLAY = "wayland-0";
    #XDG_CURRENT_DESKTOP = "sway";
  };

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };


  # Enable the gnome-keyring secrets vault. 
  # Will be exposed through DBus to programs willing to store secrets.
  services.gnome.gnome-keyring.enable = true;

  # Use gdm as the display manager (for now)
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # probably not needed since I already have my own brightness script
  # programs.light.enable = true;
  # programs.waybar.enable = true;

  # kanshi systemd service
  systemd.user.services.kanshi = {
    description = "kanshi daemon";
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kanshi}/bin/kanshi'';
    };
  };

  # Mount my home partition
  fileSystems = {
    "/home" = {
      device = "/dev/disk/by-uuid/16636c3d-89a9-4e6b-9478-8f7210d5424a";
      fsType = "ext4";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

