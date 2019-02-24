set number
let mapleader = ","

set clipboard=unnamed

" Refresh externally changed files"
set autoread
set mouse=a

" Enable per project vimrc file"
set exrc
set backspace=indent,eol,start

nmap <LEADER>[ :tabprev<CR>
nmap <LEADER>] :tabnext<CR>

map <LEADER>q :bd<CR>

" Omni complete"
filetype plugin on
set omnifunc=syntaxcomplete#Complete

" Vim split
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

:nmap <C-c> "*yy
:vmap <C-c> "+y
:nmap <LEADER>p "*p

" Open vim split to the right and bottom
set splitbelow
set splitright

" Vundel configuratio

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim'

"Color schemes
Bundle 'altercation/vim-colors-solarized'
Plugin 'lifepillar/vim-solarized8'
Plugin 'morhetz/gruvbox'
Plugin 'jacoborus/tender.vim'

Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'ryanoasis/vim-devicons'

Plugin 'mhinz/vim-signify'
Plugin 'rizzatti/dash.vim'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-abolish'
Plugin 'scrooloose/nerdtree'
Plugin 'bkad/CamelCaseMotion'
Plugin 'scrooloose/nerdcommenter'
Plugin 'EasyMotion'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'tpope/vim-surround'
Plugin 'terryma/vim-multiple-cursors'

Plugin 'fatih/vim-go'
Plugin 'avakhov/vim-yaml'
Plugin 'elixir-lang/vim-elixir'
Plugin 'slashmili/alchemist.vim'
Plugin 'larrylv/ycm-elixir'
Plugin 'elmcast/elm-vim'

Plugin 'Valloric/YouCompleteMe'

Plugin 'klen/python-mode'
Plugin 'davidhalter/jedi-vim'

Plugin 'sudar/vim-arduino-syntax'

let g:pymode_rope = 0
let g:pymode_rope_lookup_project = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_lint_ignore = "E,W"

let g:jedi#use_tabs_not_buffers = 1

call vundle#end()

syntax enable
if (has("termguicolors"))
    set termguicolors
"    set t_8f=[38;2;%lu;%lu;%lum
"    set t_8f=[48;2;%lu;%lu;%lum


    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

endif

let macvim_skip_colorscheme=1

let hour = strftime("%H") " Set the background light from 7am to 7pm
if 7 <= hour && hour < 8
    set background=light
    colorscheme solarized8_light_high
else " Set to dark from 7pm to 7am
    set background=dark
    colorscheme solarized8_dark_high
endif


"colorscheme tender


let g:airline_powerline_fonts = 1
let g:airline_theme = 'papercolor'
let g:airline#extensions#whitespace#checks = [ ]
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_tab_nr = 1
let g:airline#extensions#tabline#show_tabs = 1
let g:airline#extensions#tabline#tab_nr_type = 2
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9

set list
set listchars=trail:•
set expandtab

filetype plugin indent on 
filetype plugin on

autocmd FileType ruby setlocal shiftwidth=2 tabstop=2
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab

autocmd BufWritePre * %s/\s\+$//e

" Remove esc timeout"
set timeout
set ttimeoutlen=0

" Ctrl P custom ignore"
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](\.git|deps|node_modules|_build)$',
  \ 'file': '\v\.(DS_Store)$',
  \ 'link': 'some_bad_symbolic_links',
  \ }


let g:ctrlp_prompt_mappings = {
  \ 'AcceptSelection("e")': ['<c-t>'],
  \ 'OpenMulti()': ['<cr>']
  \ }
let g:ctrlp_arg_map = 1
" let g:wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
" let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:10,results:10'
" " let g:ctrlp_open_new_file = 'v'



"let g:ctrlp_prompt_mappings = {
" \ 'AcceptSelection("e")': ['<c-t>'],
" \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
" \ }

" Elixir do/end"
inoremap do<cr> do<cr>end<c-o>O
inoremap -><cr> -><cr>end<c-o>O

" Elm autosave and autocomplete"
let g:elm_format_autosave = 1
let g:ycm_semantic_triggers = {
     \ 'elm' : ['.'],
     \}
" inoremap . .<C-x><C-m>

" Make commands
nnoremap <C-b> :make<CR>

let g:pymode_rope_lookup_project = 0
let g:pymode_folding = 0

" Ctrl-Space for completion
inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
            \ "\<lt>C-n>" :
            \ "\<lt>C-x>\<lt>C-o><c-r>=pumvisible() ?" .
            \ "\"\\<lt>c-n>\\<lt>c-p>\\<lt>c-n>\" :" .
            \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"
imap <C-@> <C-Space>

" Disable unsafe commands in project specific vimrc files"
set secure

" Fuzzy finder
set rtp+=/usr/local/opt/fzf


" Set highlight search
set hlsearch
set ignorecase smartcase
set incsearch
nnoremap <CR> :noh<CR><CR>

" nmap <silent> :nohlsearch<CR>
"hi CursorLine cterm=NONE ctermbg=DarkCyan ctermfg=white guibg=darkred guifg=white
"hi LineNr ctermbg=None

