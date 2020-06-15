{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "jordan";
  home.homeDirectory = "/home/jordan";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;

  }

  programs.vim = {
    enable = true;
    plugins = [
      "vim-autoformat"
      "vim-airline"
      "vim-airline-themes"
      "nerdtree"
      "fzf-vim"
      "vim-commentary"
      "vim-surround"
      "vim-snipmate"
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
