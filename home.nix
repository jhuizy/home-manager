{ config, pkgs, ... }:
let
  mac-cleanup = pkgs.stdenv.mkDerivation {
    name = "mac-cleanup";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "fwartner";
      repo = "mac-cleanup";
      rev = "1b08c31f268cab08e53886f5fdcdb503563c4430";
      sha256 = "1hmcj5jg1m7p67zf2rvj1rmm7hwwp8x6389yn07fv0v1z871bada";
    };

    doCheck = false;

    installPhase = ''
      mkdir -p $out/bin
      cp cleanup.sh $out/bin/mac-cleanup
    '';
  };

  assume-role = pkgs.buildGoPackage rec {
    name = "assume-role";
    goPackagePath = "main";
    src = pkgs.fetchFromGitHub {
      owner = "remind101";
      repo = "assume-role";
      rev = "06a34b06d24a610291bb0952f2a24341e67a9b6e";
      sha256 = "1yd4c8d09sgrz5bqxpqxl9xhgar92rd54yxqlx48qyvl381nkzrr";
    };
    postInstall = ''
      mv $out/bin/main $out/bin/assume-role
    '';
  };
  extraNodePackages = import ./node/default.nix { };

in
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jordan";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/jordan" else "/home/jordan";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  home.packages = with pkgs; [
    cachix
    nixpkgs-fmt
    awscli
    jq
    coreutils
    git

    nodejs
    go
    gitAndTools.gh
    assume-role
    extraNodePackages.aws-azure-login
    tree
    mac-cleanup
  ];

  home.sessionVariables = {
    XDG_RUNTIME_DIR = "$HOME/.run";
    XDG_CACHE_DIR = "$HOME/.cache";
  };

  programs.git = {
    enable = true;
    userName = "Jordan Huizenga";
    userEmail = "jhuizenga99@gmail.com";
    aliases = {
      st = "status";
      pu = "push";
      cm = "commit -m";
      ca = "commit --amend";
      ds = "diff --staged";
      di = "diff";
    };
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    shellAliases = {
      assume-role-shell = "function(){eval $(command assume-role $@);}";
      mux = "tmuxinator";
      tma = "tmux attach -d -t";
      tmn = "tmux new-sesion";
      git-tmux = "tmux new -s $(basename $(pwd))";
      gi = "function gi() { curl -sLw \"\n\" https://www.gitignore.io/api/$@ ;}";
      gp = "git push";
    };
    initExtra = ''
      bindkey '^R' history-incremental-search-backward
      bindkey "^[[1;5C" forward-word
      bindkey "^[[1;5D" backward-word

      source ~/.nix-profile/etc/profile.d/nix.sh

      source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

    '';
    plugins = [
      {
        name = "zsh-fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions";
      }
    ];
    oh-my-zsh = {
      enable = true;
      theme = "lambda";
      plugins = [
        "git"
        "docker"
        "aws"
        "cabal"
      ];
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";

    sensibleOnTop = false;

    # Work-around for a lack of XDG_RUNTIME_DIR 
    # See https://github.com/rycee/home-manager/issues/1270
    secureSocket = pkgs.stdenv.hostPlatform.isLinux;

    extraConfig = ''
      set -g default-terminal "screen-256color"
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Smart pane switching with awareness of Vim splits.
      # See: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
      bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
      bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
      bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"
      bind-key -T copy-mode-vi C-h select-pane -L
      bind-key -T copy-mode-vi C-j select-pane -D
      bind-key -T copy-mode-vi C-k select-pane -U
      bind-key -T copy-mode-vi C-l select-pane -R

      bind-key -n C-_ resize-pane -D 10
      bind-key -n C-= resize-pane -U 10

      # Allows me to use mouse
      set -g mouse on
    '';
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-autoformat
      vim-airline
      vim-airline-themes
      nerdtree
      fzf-vim
      vim-commentary
      vim-surround
      vim-snipmate
    ];
    settings = { ignorecase = true; };
    extraConfig = ''
      syntax on

      " Theme
      syntax enable

      ""show me the numbers
      set number

      ""stop wrapping my words
      set nowrap

      "make commands easier to input
      map ; :

      ""reaching for esc is hard
      imap kj <Esc>

      "rebind ex mode to replay q macro
      map Q @q
      "
      ""leader
      map <space> \

      "make changing panes easier
      map <leader>o <C-W><C-W>
      map `o <C-W><C-W>
      "
      ""closing easier
      " map <leader>q :q<cr>

      "want some familiar keybindings
      map <leader>n :NERDTreeToggle<cr>
      map <C-P> :FZF <cr>
      map <leader>/ :Ack 
      map <leader>gb :Gblame<cr>
      map <leader>gd :Gdiff<cr>

      " easy align
      xmap ga <Plug>(EasyAlign)
      nmap ga <Plug>(EasyAlign)

      ""make opening splits easy
      map <leader>v :vsplit<cr><C-W><C-W>
      map <leader>s :split<cr><C-W><C-W>
      map <leader>z :ZoomWin<cr><C-W><C-W>
      map <leader>u :MundoToggle<cr><C-W><C-W>
      map <leader>b :BuffergatorToggle<cr><C-W><C-W>
      map <leader>c :Commentary<cr><C-W><C-W>

      let NERDTreeShowHidden=1
      let NERDTreeDirArrowExpandable = '+'
      let NERDTreeDirArrowCollapsible = '-'

      " Stop making big tabs
      set tabstop=2
      set shiftwidth=2
    '';
  };


}
