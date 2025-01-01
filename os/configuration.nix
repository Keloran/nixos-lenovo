{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
  ./hardware-configuration.nix
  ];

  # Actual 1 liners
  time.timeZone = "Europe/London";
  console.keyMap = "uk";
  hardware.pulseaudio.enable = false;

  system = {
    stateVersion = "24.11";
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      channel = "https://channels.nixos.org/nixos-24.11";
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
      };
      efi = {
        canTouchEfiVariables = true;
      };
    };
  };

  networking = {
    hostName = "nixos";
    networkmanager = {
      enable = true;
    };
  };

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  services = {
    getty = {
      autologinUser = "keloran";
    };
    xserver = {
      enable = true;
      xkb = {
        layout = "gb";
        variant = "";
      };
      desktopManager = {
        pantheon = {
          enable = true;
        };
      };
      displayManager = {
        lightdm = {
          enable = true;
        };
      };
    };
    printing = {
      enable = false;
    };
    flatpak = {
      enable = true;
    };
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse = {
        enable = true;
      };
    };
    openssh = {
      enable = true;
    };
    locate = {
      enable = true;
      package = pkgs.mlocate;
      interval = "hourly";
      localuser = null;
    };
    gnome = {
      gnome-keyring = {
        enable = lib.mkForce false;
      };
    };
  };

  nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs; in {
    settings = {
      experimental-features = "nix-command flakes";
      nix-path = config.nix.nixPath;
      allowed-users = [
        "@wheel"
      ];
    };
    channel.enable = false;
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  users = {
    users = {
      keloran = {
        isNormalUser = true;
        description = "Keloran";
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
      };
    };
  };

  environment = {
    systemPackages = with pkgs; [
      gnome-keyring
      libgnome-keyring
      home-manager
    ];
    shellAliases = {
      vi = "nvim";
    };
    etc = {
      "1password/custom_allowed_browsers" = {
        text = ''
          google-chrome-stable
          zen-bin
          chrome
        '';
        mode = "0755";
      };
    };
    variables = {
      EDITOR = "nvim";
    };
  };

  programs = {
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [
        "keloran"
      ];
    };
    _1password = {
      enable = true;
    };
  };

  security = {
    rtkit = {
      enable = true;
    };
    pam = {
      services = {
        login = {
          u2fAuth = true;
          enableGnomeKeyring = lib.mkForce false;
        };
        sudo = {
          u2fAuth = true;
        };
        polkit-1 = {
          u2fAuth = true;
        };
      };
    };
  };

  systemd = {
    services = {
      flatpak-repo = {
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.flatpak ];
        script = ''
          flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        ''; 
      };
    };
  };
}
