" General settings ============================================================

  set termguicolors          " enable true color
  filetype plugin indent on  " filetype detection and indentation
  syntax enable              " enable systax highlighting
  set number                 " show line numbers
  set background=dark

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
    Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
    
    " coc extensions
    let g:coc_global_extensions = ['coc-tslint-plugin', 'coc-tsserver', 'coc-css', 'coc-html', 'coc-json', 'coc-yank', 'coc-prettier']

    Plug 'ianks/vim-tsx' " Syntax highlighting and indenting for TSX
    Plug 'leafgarland/typescript-vim' " Syntax & more for TypeScript
    Plug 'tyrannicaltoucan/vim-deep-space' " Theme
    " Plug 'https://github.com/w0rp/ale.git'
    call plug#end()

" Autocmd =====================================================================

  " by default .ts file are not identified as typescript and .tsx files are not
  " identified as typescript react file
  au BufNewFile,BufRead *.ts setlocal filetype=typescript
  au BufNewFile,BufRead *.tsx setlocal filetype=typescript.tsx

