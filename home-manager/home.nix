{ inputs, lib, pkgs, ... }:

{
  imports = [
    inputs._1password-shell-plugins.hmModules.default
  ];

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "keloran";
    homeDirectory = "/home/keloran";
    stateVersion = "24.11";

    packages = with pkgs; [
      zip
      unzip
      yq
      jq
      fastfetch
      ripgrep
      fzf
      htop
      btop
      mlocate
      lm_sensors
      usbutils
      go
      google-chrome
      rustc
      pnpm
      nodejs_22
      gotools
      nerdfonts
      pciutils
    ];
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    _1password-shell-plugins = {
      enable = true;
      plugins = with pkgs; [
        gh
	awscli2
	cachix
      ];
    };
    ssh = {
      enable = true;
      matchBlocks = {
        "*" = {
	  extraOptions = {
	    identityAgent = "~/.1password/agent.sock";
	  };
	};
      };
    };
    git = {
      enable = true;
      userName = "keloran";
      userEmail = "keloran@chewedfeed.com";
      extraConfig = {
        gpg = {
	  format = "ssh";
	};
	"gpg \"ssh\"" = {
	  program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
 	};
	commit = {
	  gpgsign = true;
	};
	user = {
	  signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOxKs7zVMUjUHGzMLNAQA3GTRzQIucJZkrvhFsaRvdAw";
	};
      };
    };
    home-manager = {
      enable = true;
    };
    alacritty = {
      enable = true;
    };
  };

  systemd = {
    user = {
      startServices = "sd-switch";
    };
  };
}
