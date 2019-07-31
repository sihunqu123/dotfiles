set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'

" Plugin for fuzzy file search
Plugin 'wincent/command-t'

" Plugin for file tree
Plugin 'scrooloose/nerdtree'

" Plugin for Navigate throw quickfixlist
Plugin 'tpope/vim-unimpaired'

" Plugin for directory diff
Plugin 'will133/vim-dirdiff'

" Plugin for 'Start searching before pressing enter.' and so on.
Plugin 'tpope/vim-sensible'

" Plugin for compelte-prompt-list
Plugin 'Valloric/YouCompleteMe'

" Plugin for execute file with system default app
Plugin 'ivalkeen/nerdtree-execute'

" Plugin for statueline:  https://github.com/itchyny/lightline.vim
Plugin 'itchyny/lightline.vim'

" Plugin for javascript and typescript(tsx).
Plugin 'pangloss/vim-javascript'
Plugin 'maxmellon/vim-jsx-pretty'
Plugin 'leafgarland/typescript-vim'

" Plugin for buffer explorer
Plugin 'jlanzarotta/bufexplorer'

" Plugin for mini buffer explorer
Plugin 'fholgado/minibufexpl.vim'

" base Plugin consumed by xolox/vim-session
Plugin 'xolox/vim-misc'

" Plugin for vim session
Plugin 'xolox/vim-session'

" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


"""""""""""""""""""""""""""""
" Common Settings
"""""""""""""""""""""""""""""
syntax on
" required by YouCompleteMe
set encoding=utf-8
set showmatch
set number
set cindent
set autoindent
set confirm
set ignorecase
set smartcase
set hlsearch

set notitle

" global key
let mapleader = ","
" set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
set tabstop=2 softtabstop=2 shiftwidth=2 smarttab
set expandtab
" to make pasting from clipboard works properly
set paste
set autoindent
set backspace=indent,eol,start
set ff=unix
" set lcs=tab:>-,trail:\ ,eol:$
set list lcs=tab:»·

set laststatus=2
" set statusline=%t\ %y\ format:\ %{&ff};\ [%c,%l]


" need to check if it's macos then set the colo
colorscheme molokai
" colorscheme SolarizedDark
" for centos7
" colo desert


" Trailing space
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
" to remove trailing space
nmap <Leader>c :%s/\s\+$//g

" netrw Settings
" let g:netrw_keepdir= 0
" open in tree style
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
" open new file in the right side vertically
let g:netrw_altv = 1
let g:netrw_winsize = 25

" always open netrw when openning vim
"
" augroup ProjectDrawer
"   autocmd!
"   autocmd VimEnter * :Vexplore
" augroup END


" auto get back to the postion you left last time
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Fix the difficult-to-read default setting for diff text highlighting.  The
" " bang (!) is required since we are overwriting the DiffText setting. The highlighting
" " for "Todo" also looks nice (yellow) if you don't like the "MatchParen" colors.
" highlight! link DiffText MatchParen
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red



" adjust vim prompt menu's color if it's not clear enough
autocmd ColorScheme * highlight Pmenu ctermbg=white
autocmd ColorScheme * highlight PmenuSel ctermbg=yellow
"

"""""""""""""""""""""""""""""
" Plugin Required Setttings
"""""""""""""""""""""""""""""

" requires 'tpope/vim-sensible'
set encoding=utf-8
" Start searching before pressing enter.
set incsearch
" Always show at least one line above/below the cursor.
set scrolloff=1
" Autoload file changes. You can undo by pressing u. (not works)
" set autoread

" disable showmode since we already have plugin:  https://github.com/itchyny/lightline.vim
" requires itchyny/lightline.vim
set noshowmode

" reqires 'scrooloose/nerdtree'
nmap <silent> <Leader>r :NERDTreeFind<cr>
nmap <silent> <Leader>g :NERDTreeToggle<cr>

" for centos7
let g:NERDTreeDirArrowExpandable = '＞'
let g:NERDTreeDirArrowCollapsible = '﹀'

" requires 'wincent/command-t'
let g:CommandTWildIgnore=&wildignore . ",*/node_modules"


" NERDTREE settings
" requires 'scrooloose/nerdtree'
let g:NERDTreeWinPos = "left"
" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')

" set python3's path for YouCompleteMe
let g:ycm_server_python_interpreter="/Library/Frameworks/Python.framework/Versions/3.6/bin/python3"


" requires fholgado/minibufexpl
map <Leader>mbe :MBEOpen<cr>
map <Leader>mbc :MBEClose<cr>
map <Leader>mbt :MBEToggle<cr>


" Bundle 'bufexplorer.zip'
" Config BufExplorer
"let g:bufExplorerDefaultHelp=0       " Do not show default help.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
let g:bufExplorerSortBy='mru'        " Sort by most recently used.
" To control the size of the new horizontal split window. use: >
let g:bufExplorerSplitHorzSize=10
" To control where the new split window will be placed above or below the current window, use: >
let g:bufExplorerSplitBelow=1        " Split new window below current.
" To control whether you are taken to the active window when selecting a buffer, use: >
"jlet g:bufExplorerFindActive=0        " Do not go to active window.
let g:bufExplorerFindActive=1        " Do go to active window.

" requires winManager
"""""""""""""""""""""""""""""""

"" winManager setting

"""""""""""""""""""""""""""""""

"let g:winManagerWindowLayout = "BufExplorer,FileExplorer|TagList"
" let g:winManagerWindowLayout = "TagList|FileExplorer,BufExplorer"
let g:winManagerWindowLayout='NERDTree|TagList,BufExplorer'

let g:winManagerWidth = 30

nmap <silent> <F8> :WMToggle<cr>
map <c-w><c-f> :FirstExplorerWindow<cr>
map <c-w><c-b> :BottomExplorerWindow<cr>
map <c-w><c-t> :WMToggle<cr>

let g:AutoOpenWinManager=1
let Tlist_Exit_OnlyWindow=1





"if filereadable(expand("~/.vimrc.bundles"))
"  source ~/.vimrc.bundles
"endif















"""""""""""""""""""""""""""""""
" Heavy Customiztion
"""""""""""""""""""""""""""""""
" highlight selected text
vnoremap // y/\V<C-r>=escape(@",'/\')<CR><CR>

" hightlight current word without jumping to next match
nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>
" highlight current word and then trying to substitute it
nmap # <Space><Space>:%s/<C-r>///g<Left><Left>

" same in visualMod
xnoremap <silent> <Space> mz:call <SID>set_vsearch()<CR>:set hlsearch<CR>`z
xnoremap * :<C-u>call <SID>set_vsearch()<CR>/<C-r>/<CR>
xmap # <Space>:%s/<C-r>///g<Left><Left>

function! s:set_vsearch()
  silent normal gv"zy
  let @/ = '\V' . substitute(escape(@z, '/\'), '\n', '\\n', 'g')
endfunction

" move line
" nnoremap <C-Up> "zdd<Up>"zP
" nnoremap <C-Down> "zdd"zp
" vnoremap <C-Up> "zx<Up>"zP`[V`]
" vnoremap <C-Down> "zx"zp`[V`]
"nnoremap  "zdd<Up>"zP
"nnoremap <S-Up> dd
" move multiple line
vnoremap + "zx<Up>"zP`[V`]
vnoremap _ "zx"zp`[V`]


" typo fix
inoremap <C-t> <Esc><Left>"zx"zpa

" delete and backspace in insert and normal mode.
"imap <C-d> <Del>
imap <C-D> <C-O>x
"inoremap <C-d> <Del>
imap <C-h> <BS>

" x and s won't yank
nnoremap x "_x
nnoremap s "_s

" paste without change register
xnoremap <expr> p 'pgv"'.v:register.'y`>'


inoremap <C-]> <Esc><Right>

" <silent> menas user cannot see any iteraction when this command running.
" e.g: :%s/\s\+//g prompt, and user cannot see it.

" search text in project
nmap <Leader>h :grep -n -r --exclude-dir="node_modules" --exclude-dir="mochawesome-report" --exclude-dir="domino-iam-service" --exclude-dir="build" --exclude-dir="logs" --exclude-dir="website/node_modules" --exclude="*.swp" --exclude="*.orig" -i  ./<Left><Left><Left>

" to avoid Arrow Key not works in Vim.
"set term=ansi
" export TERM=xterm-256color
" if !has('gui_running')
"   set t_Co=256
" endif

" let g:lightline = {
"   \ 'colorscheme': 'wombat',
" \ }



"""""""""""""""""""""""""""""""
" Memo
"""""""""""""""""""""""""""""""

" vimReplace Memo
":'<,'>s/\n/\\r\\n' +\r    '/g

" vim format json Memo
" format selected content
":'<,'>!python -m json.tool
" format the whole file
":%!python -m json.tool

