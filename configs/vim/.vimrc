" General settings ============================================================

  set t_Co=256               " enable 256-color mode
  filetype plugin indent on  " filetype detection and indentation
  syntax enable              " enable systax highlighting
  set number                 " show line numbers
  colorscheme desert


" Indentation =================================================================

  set autoindent
  set tabstop=2
  set softtabstop=2
  set shiftwidth=2
  set shiftround
  set expandtab
  set smarttab


" Search ======================================================================

  set incsearch              " search as characters are entered
  set ignorecase


" Footer ======================================================================

  set ruler                  " show line & column on right side of footer bar
  set showcmd


" Shortcuts ===================================================================

  :imap jj <Esc>


" Plugins =====================================================================

  " install vim-plug if it doesn't exist; it enables installing plugins

    if empty(glob('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
    endif


  " vim-plugs -----------------------------------------------------------------

    call plug#begin('~/.vim/plugged')
    Plug 'leafgarland/typescript-vim'
    " Plug 'Valloric/YouCompleteMe'
    " Plug 'https://github.com/w0rp/ale.git'
    " Plug 'Quramy/tsuquyomi'
    call plug#end()

