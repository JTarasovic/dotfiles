syntax on
filetype plugin indent on

" Plugins (vim-plug)
call plug#begin('~/.vim/plugged')

" colorschemes
Plug 'flazz/vim-colorschemes'
Plug 'vim-airline/vim-airline-themes'
Plug 'arcticicestudio/nord-vim'

" lsp
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'hrsh7th/nvim-cmp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'lukas-reineke/lsp-format.nvim'

" utilities / generic
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'Raimondi/delimitMate'
Plug 'godlygeek/tabular'

Plug 'ctrlpvim/ctrlp.vim'

" nerdtree / directory
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" appearance
Plug 'vim-airline/vim-airline'
Plug 'ap/vim-css-color'
Plug 'ryanoasis/vim-devicons'

call plug#end()

" set variables and such
set termguicolors
set nocompatible                    " ignore backwards compatibility - ignored by neovim
set tabstop=4                       " by default tabs are 4 spaces
set softtabstop=4
set shiftwidth=4
set expandtab                       " and expand them
set clipboard+=unnamedplus          " use system clipboard always

set backspace=indent,eol,start      " allow backspacing over everything in insert mode
set fillchars+=stl:\ ,stlnc:\
set t_Co=256
set encoding=utf-8                  " neovim won't let one of these be changes after it's been set
set termencoding=utf-8              " so it pitches a fit if you source this from a running instance
set laststatus=2
set noshowmode
set history=50                      " keep 50 lines of command line history
set ruler                           " show the cursor position all the time
set showcmd                         " display incomplete commands
set incsearch                       " do incremental searching
set hlsearch                        " turn on highlighting during searches
set number                          " show line numbers
set background=dark
set mouse=a
set backup                          " keep a backup file (restore to previous version)
set undofile                        " keep an undo file (undo changes after closing)

if has('nvim')
    set inccommand=split            " shows :s preview in split
endif

" move temporary files out of working directory
set backupdir=~/.local/share/nvim/backup//

if has('langmap') && exists('+langnoremap')
    set langnoremap
endif

" VARIABLES
" nerdtree-git-status
let g:NERDTreeGitStatusUseNerdFonts = 1

" airline
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
let g:airline_theme = 'nord'

" MAPS
map Q gq                                        " Don't use Ex mode, use Q for formatting
" nmap <space> :set hlsearch! hlsearch?<CR>       " clear highlighted search
inoremap jj <esc>l                              " escape insert mode if you type jj
" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" location and quick fix helpers
" noremap [l :lprevious<CR>
" noremap ]l :lnext<CR>
" noremap [L :lfirst<CR>
" noremap ]L :llast<CR>
" noremap [q :cprevious<CR>
" noremap ]q :cnext<CR>
" noremap [Q :cfirst<CR>
" noremap ]Q :clast<CR>

nnoremap <silent> <C-_> :let @/ = ""<CR>

" custom functions
if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis | wincmd p | diffthis
endif

augroup general
        au!
        au BufWritePost .vimrc source %
        au BufWritePost init.vim source %       " for neovim
        " au BufWritePost * Neomake

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        au BufReadPost *
            \ if line("'\"") >= 1 && line("'\"") <= line("$") |  exe "normal! g`\"" | endif
augroup END

colorscheme nord

runtime config.lua
