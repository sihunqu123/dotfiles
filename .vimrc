" use this to debug vimrc
"set verbose=9


set nocompatible              " be iMproved, required
set statusline+=%F
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
"Plugin 'tpope/vim-fugitive'

" Plugin for reopen lastest closed tab
" usage: Ctrl+W u
Plugin 'AndrewRadev/undoquit.vim'

" Plugin for fuzzy file search
" Way to build: {
"   cd ~/.vim/bundle/command-t/ruby/command-t/ext/command-t && \
"   ruby extconf.rb && \
"   make
" }
Plugin 'wincent/command-t'

" Plugin for merge all windows of a tab into current tab
" usage: Tabmerge 3 right
" to merge all buffers in tab 3 into current tab
Plugin 'vim-scripts/Tabmerge'

" Plugin for resolving conflicts during three-way merges.
" usage: Tabmerge 3 right
" for more info: :help splice
Plugin 'sjl/splice.vim'

" Plugin for showing marks
" usage:
"  mx           Toggle mark 'x' and display it in the leftmost column
"  dmx          Remove mark 'x' where x is a-zA-Z
"
"  m,           Place the next available mark
"  m.           If no mark on line, place the next available mark. Otherwise, remove (first) existing mark.
"  m-           Delete all marks from the current line
"  m<Space>     Delete all marks from the current buffer
"  ]`           Jump to next mark
"  [`           Jump to prev mark
"  ]'           Jump to start of next line containing a mark
"  ['           Jump to start of prev line containing a mark
"  `]           Jump by alphabetical order to next mark
"  `[           Jump by alphabetical order to prev mark
"  ']           Jump by alphabetical order to start of next line having a mark
"  '[           Jump by alphabetical order to start of prev line having a mark
"  m/           Open location list and display marks from current buffer. this
"                 list might be all blank when quickfix list used(]q, [q);
"
"  m[0-9]       Toggle the corresponding marker !@#$%^&*()
"  m<S-[0-9]>   Remove all markers of the same type (S -> shift)
"  ]-           Jump to next line having a marker of the same type
"  [-           Jump to prev line having a marker of the same type
"  ]=           Jump to next line having a marker of any type
"  [=           Jump to prev line having a marker of any type
"  m?           same with m/
"  m<BS>        Remove all markers
" :SignatureToggle
" :SignatureRefresh
Plugin 'kshenoy/vim-signature'

" show relative line number
" usage:
"  :RltvNmbr  相対行数表示を有効にする。
"  :RltvNmbr!  相対行数表示を無効にする。
"  :RN 相対行数表示の有効、無効を切り替える。
Plugin 'vim-scripts/RltvNmbr.vim'


" Plugin for file tree
Plugin 'scrooloose/nerdtree'

" Plugin for multiple-nodes operations in nerdtree
" PS: Only work with vim opened via `vim {filename}`
"     and will NOT work for vim opened via `vim .`
" t Open selected files in tabs.
" dd  Delete selected files from disk. If open in Vim, they remain open.
" m Move the selected files to another directory. If open in Vim, the buffer will points to its old location.
" c Copy selected files to another directory.
Plugin 'PhilRunninger/nerdtree-visual-selection'

" Plugin for showing file git status in nerdtree
Plugin 'Xuyuanp/nerdtree-git-plugin'

" Plugin for execute file with system default app
Plugin 'ivalkeen/nerdtree-execute'

" Plugin for Navigate throw quickfixlist
Plugin 'tpope/vim-unimpaired'

" Plugin for directory diff
Plugin 'will133/vim-dirdiff'

" Plugin for 'Start searching before pressing enter.' and so on.
Plugin 'tpope/vim-sensible'

" Plugin for displaying colorful file that can be viewed via cat/less.
" Usage: To toggle the ANSIColor, :AnsiEsc
" Note: This will only works on the current active window. Which means the
"   other windows(can be switched via `Ctlr+w w`) and other tabs are still unchanged.
Plugin 'powerman/vim-plugin-AnsiEsc'

Plugin 'mhinz/vim-grepper'

" Install vim-maktaba plugin for plugin developers - used in foldcol
Plugin 'google/vim-maktaba'
" Install foldcol - folding columns using <ctrl-v> visual mark, then :VFoldCol
" ctrl + v to select, then :VFoldCol to fold, and :VFoldClear to unfold all.
" refer:
" https://itectec.com/unixlinux/vim-hide-first-n-letters-of-all-lines-in-a-file/
Plugin 'paulhybryant/foldcol'

" Plugin for compelte-prompt-list
Plugin 'Valloric/YouCompleteMe'

" Plugin for statueline:  https://github.com/itchyny/lightline.vim
Plugin 'itchyny/lightline.vim'

" Plugin to Adds file type icons to Vim plugins such as: NERDTree, vim-airline, CtrlP, unite, Denite, lightline, vim-startify and many more
"   to make this plugin works, pls download `Inconsolata Nerd Font Monoa` from
"     https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Inconsolata/complete
"     or `DejaVu Sans Mono Nerd Font Complete Mono.ttf` is better
"     https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/DejaVuSansMono/Regular/complete
"   and put add it to your font. e.g. for windows, copy it into `C:\Windows\Fonts`
Plugin 'ryanoasis/vim-devicons'


" :IndentLinesToggle toggles lines on and off.
Plugin 'Yggdroot/indentLine'


" show colorful json grammar
"Plugin 'elzr/vim-json'

" Plugin for javascript and typescript(tsx).
Plugin 'pangloss/vim-javascript'
Plugin 'maxmellon/vim-jsx-pretty'
Plugin 'leafgarland/typescript-vim'

" Plugin for buffer explorer
" usage:
"   \<Leader\>be normal open
"   \<Leader\>bt toggle open / close
"   \<Leader\>bs force horizontal split open
"   \<Leader\>bv force vertical split open
" other usage could be found via pressing F1 in bufexplorer window
Plugin 'jlanzarotta/bufexplorer'

" Plugin for mini buffer explorer
" to show all buffers in one line in the bottom of tab 1
"Plugin 'fholgado/minibufexpl.vim'

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

" will never check the gui_running, since will never use the gvim. {
"if has("gui_running")
" echo "yes, we have a GUI, which means I am in gvim"
"else
" echo "Boring old console, which means I am in tty(console) vim mode"
"endif
"}

""""""" deal with OS. {
" refer: https://vi.stackexchange.com/questions/2572/detect-os-in-vimscript/2577#2577
if !exists("g:os")
    if has("win64") || has("win32") || has("win16")
        let g:os = "Windows"
    else
        let g:os = substitute(system('uname'), '\n', '', '')
    endif
endif

" then we use folowing to judge OS.
"if has("gui_running")
"    if g:os == "Darwin"
"        set guifont=Fira\ Mono:h12
"    elseif g:os == "Linux"
"        set guifont=Fira\ Mono\ 10
"    elseif g:os == "Windows"
"        set guifont=Fira_Mono:h12:cANSI
"    endif
"endif
"}

syntax on
" required by YouCompleteMe
set encoding=utf-8
set showmatch
set number
"或者设置相对行号
" set relativenumber
set cindent
set autoindent
set confirm
set ignorecase
set smartcase
set hlsearch
set cmdheight=2

"The 'textwidth' option can be used to automatically break a line before it gets too long. Set the 'textwidth' option to the desired maximum line length.
"If you then type more characters (not spaces or tabs), the last word will be put on a new line (unless it is the only word on the line). If you set
"'textwidth' to 0, this feature is disabled.
set textwidth=0

" display number of search matches & index of a current match
" refer: https://github.com/google/vim-searchindex
set shortmess-=S
" For example, save the files in a local directory if it exists. This is more
" friendly if you often move your working directory around, and want to take
" these files with you.
set backupdir=.backup/,~/.backup/,/tmp//
set directory=.swp/,~/.swp/,/tmp//
set undodir=.undo/,~/.undo/,/tmp//

set notitle
" enable the xml tag matching in xml/html files
runtime macros/matchit.vim

" global key
let mapleader = ","
" set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab
set tabstop=2 softtabstop=2 shiftwidth=2 smarttab
set expandtab
" to make pasting from clipboard works properly. PS: we comment out `set paste` since it would reset the `set expandtab`
"set paste
" able to move cursor to all place even when this column doesn't exit
set virtualedit=all
set backspace=indent,eol,start
set ff=unix
" set lcs=tab:>-,trail:\ ,eol:$
set list lcs=tab:»·

" Open new split panes to right and bottom, which feels more natural than Vim's default
set splitbelow
set splitright
" prevent flashing screen, which is bad for eyes. {
"set novisualbell
set visualbell
set t_vb=
"}


"设置当请行有下划线(white background)
set cursorline
"au ColorScheme * hi! Cursorline cterm=bold ctermbg=236 guibg=Grey90
au ColorScheme * hi! Cursorline cterm=bold ctermbg=4 guibg=Grey90
"  line number of cursor
au ColorScheme * hi! CursorLineNr cterm=bold ctermfg=159 ctermbg=236 guibg=Grey90

"设置光标列(the whole column is white background)
set cursorcolumn
au ColorScheme * hi! CursorColumn cterm=bold ctermfg=250 ctermbg=232 guibg=Grey90

" need to check if it's macos then set the colo
colorscheme molokai
" colorscheme SolarizedDark
" for centos7
" colo desert


"""""""""""""""""""""""""""""" Trailing space{
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
" to remove trailing space
nmap <Leader>c :%s/\s\+$//g
"}

" Status Line {
" set laststatus=2                             " always show statusbar
" set statusline=
" set statusline+=%-10.3n\                     " buffer number
" set statusline+=%f\                          " filename
" set statusline+=%h%m%r%w                     " status flags
" set statusline+=\[%{strlen(&ft)?&ft:'none'}] " file type
" set statusline+=%=                           " right align remainder
" set statusline+=0x%-8B                       " character value
" set statusline+=%-14(%l,%c%V%)               " line, character
" set statusline+=%<%P                         " file position
"}

" Triger `autoread` when files changes on disk
" https://unix.stackexchange.com/questions/149209/refresh-changed-content-of-file-opened-in-vim/383044#383044
" https://vi.stackexchange.com/questions/13692/prevent-focusgained-autocmd-running-in-command-line-editing-mode
" When changes determined, then use :DiffSaved to diff the change between vim and external program
" autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
autocmd InsertEnter *
  \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif

" Notification after file change
" The first command selects a particular highlight mode for any subsequent echo calls. When echo is called the message will be displayed on the status line with approriate color and/or format (in my case white on yellow text). Don't forget the second echohl to return to regular highlighting.
" https://vi.stackexchange.com/questions/13091/autocmd-event-for-autoread
"autocmd FileChangedShellPost *
"  \ echohl WarningMsg | echo "File changed on disk. It's dirty buffer" | echohl None
"  \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None

"autocmd FocusGained,BufEnter,CursorHold,CursorHoldI *
"        \ if mode() !~ '\v(c|r.?|!|t)' && getcmdwintype() == '' | checktime | endif


" show changes before save
" usage: run :DiffSaved
" refer: https://stackoverflow.com/questions/749297/can-i-see-changes-before-i-save-my-file-in-vim
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()


" netrw Settings
"g:netrw_alto    control above/below splitting
"g:netrw_altv    control right/left splitting
"g:netrw_preview control horizontal vs vertical splitting
"g:netrw_winsize control initial sizing

" let g:netrw_keepdir= 0
" open in tree style
let g:netrw_liststyle = 3

" g:netrw_browse_split          when browsing, <cr> will open the file by:
"                               =0: re-using the same window
"                               =1: horizontally splitting the window first
"                               =2: vertically   splitting the window first
"                               =3: open file in new tab
"                               =4: act like "P" (ie. open previous window)
"                                   Note that g:netrw_preview may be used
"                                   to get vertical splitting instead of
"                                   horizontal splitting.
"
let g:netrw_browse_split = 4
" open new file in the right side vertically
" g:netrw_altv                  change from left splitting to right splitting
let g:netrw_altv = 1
let g:netrw_winsize = 25

"                                 netrw-quickmap netrw-quickmaps
" QUICK REFERENCE: MAPS                           netrw-browse-maps {{{2
"
"           ---                   -----------------                       ----
"           Map                   Quick Explanation                       Link
"           ---                   -----------------                       ----
"          <F1>   Causes Netrw to issue help
"          <cr>   Netrw will enter the directory or read the file      netrw-cr
"          <del>  Netrw will attempt to remove the file/directory      netrw-del
"            -    Makes Netrw go up one directory                      netrw--
"            a    Toggles between normal display,                      netrw-a
"                 hiding (suppress display of files matching g:netrw_list_hide)
"                 showing (display only files which match g:netrw_list_hide)
"            c    Make browsing directory the current directory        netrw-c
"            C    Setting the editing window                           netrw-C
"            d    Make a directory                                     netrw-d
"            D    Attempt to remove the file(s)/directory(ies)         netrw-D
"            gb   Go to previous bookmarked directory                  netrw-gb
"            gh   Quick hide/unhide of dot-files                       netrw-gh
"          <c-h>  Edit file hiding list                             netrw-ctrl-h
"            i    Cycle between thin, long, wide, and tree listings    netrw-i
"          <c-l>  Causes Netrw to refresh the directory listing     netrw-ctrl-l
"            mb   Bookmark current directory                           netrw-mb
"            mc   Copy marked files to marked-file target directory    netrw-mc
"            md   Apply diff to marked files (up to 3)                 netrw-md
"            me   Place marked files on arg list and edit them         netrw-me
"            mf   Mark a file                                          netrw-mf
"            mh   Toggle marked file suffices' presence on hiding list netrw-mh
"            mm   Move marked files to marked-file target directory    netrw-mm
"            mp   Print marked files                                   netrw-mp
"            mr   Mark files satisfying a shell-style regexp         netrw-mr
"            mt   Current browsing directory becomes markfile target   netrw-mt
"            mT   Apply ctags to marked files                          netrw-mT
"            mu   Unmark all marked files                              netrw-mu
"            mx   Apply arbitrary shell command to marked files        netrw-mx
"            mz   Compress/decompress marked files                     netrw-mz
"            o    Enter the file/directory under the cursor in a new   netrw-o
"                 browser window.  A horizontal split is used.
"            O    Obtain a file specified by cursor                    netrw-O
"            p    Preview the file                                     netrw-p
"            P    Browse in the previously used window                 netrw-P
"            qb   List bookmarked directories and history              netrw-qb
"            qf   Display information on file                          netrw-qf
"            r    Reverse sorting order                                netrw-r
"            R    Rename the designed file(s)/directory(ies)           netrw-R
"            s    Select sorting style: by name, time, or file size    netrw-s
"            S    Specify suffix priority for name-sorting             netrw-S
"            t    Enter the file/directory under the cursor in a new tabnetrw-t
"            u    Change to recently-visited directory                 netrw-u
"            U    Change to subsequently-visited directory             netrw-U
"            v    Enter the file/directory under the cursor in a new   netrw-v
"                 browser window.  A vertical split is used.
"            x    View file with an associated program                 netrw-x
"            X    Execute filename under cursor via system()           netrw-X
"
"            %    Open a new file in netrw's current directory         netrw-%

" always open netrw when openning vim
"
" augroup ProjectDrawer
"   autocmd!
"   autocmd VimEnter * :Vexplore
" augroup END


" 'let' form set expandtab
" let &expandtab=1


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


" highlight the current confirming replacing word.   below lines are both good
"highlight IncSearch cterm=bold ctermfg=red ctermbg=green term=underline guibg=green
highlight IncSearch cterm=reverse term=underline guibg=green
autocmd ColorScheme * highlight IncSearch cterm=reverse term=underline guibg=green

" adjust vim prompt menu's color if it's not clear enough
autocmd ColorScheme * highlight Pmenu ctermbg=white ctermfg=blue
autocmd ColorScheme * highlight PmenuSel ctermbg=yellow ctermfg=red



" highlight will take effect initially but won't take effect after ASNI plugin break the color.
" autocmd highlight won't take effect initially but will take effect after ASNI plugin break the color.
" that's why I add both highlight and autocmd are specified in vimrc

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

" reqires 'scrooloose/nerdtree'
nmap <silent> <Leader>r :NERDTreeFind<cr>
nmap <silent> <Leader>g :NERDTreeToggle<cr>


" reqires 'powerman/vim-plugin-AnsiEsc'
" show colorful ANSI in vim
nmap <silent> <Leader>a :AnsiEsc<cr>


" reqires 'Yggdroot/indentLine'
" toggles indent lines on and off
nmap <silent> <Leader>i :IndentLinesToggle<cr>

" for windows
"let g:NERDTreeDirArrowExpandable = '＞'
"let g:NERDTreeDirArrowCollapsible = '﹀'

" requires 'wincent/command-t'
let g:CommandTWildIgnore=&wildignore . ",*/node_modules"


" requires 'Yggdroot/indentLine'
let g:indentLine_char_list = ['|', '¦', '┆', '┊']
" quotes disappeared in json files
"1. If your vim is 8.1.2060+, let g:vim_json_conceal = 0 should be enough.
"2. otherwise,
":e $VIMRUNTIME/syntax/json.vim
":g/if has('conceal')/s//& \&\& 0/
":wq
"3. If you are using other syntax plugin for json, please turn to that plugin for help. e.g.
"Plugin 'elzr/vim-json'
" refer:
"https://github.com/Yggdroot/indentLine/issues/140#issuecomment-624662832
let g:vim_json_syntax_conceal = 0
let g:indentLine_enabled = 1
let g:vim_json_syntax_conceal = 0
let g:vim_json_conceal = 0


" NERDTREE settings
" requires 'scrooloose/nerdtree'
let g:NERDTreeWinPos = "left"
" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

" call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
" call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
" call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
" call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
" call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
" call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
" call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
" call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
" call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
" call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
" call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
" call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
" call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')

" variable scope test {
let g:aaa="value of aaa"
" this aaa will be printed out
"echo aaa

" will print
" ➜  atlas-ui git:(upload) ✗ vim Jenkinsfile
" value of aaa before
" linux
" linux bbb
" Press ENTER or type command to continue
"if g:os == "Darwin"
"  echo aaa . " before"
"  let g:aaa="mac"
"elseif g:os == "Linux"
"  echo aaa . " before"
"  let g:aaa="linux"
"" even when the bbb is defined inside a if statement, bbb can still be accessed by outside
"  let g:bbb="linux bbb"
"elseif g:os == "Windows"
"  echo aaa . " before"
"  let g:aaa="windows"
"endif
"
"echo aaa
"echo bbb
"}



" required by vim-devicons{
" for windows client
set guifont=Inconsolata_Nerd_Font_Mono:h11
" for linux client
"set guifont=Inconsolata_Nerd_Font_Mono\ 11
let g:webdevicons_enable_nerdtree = 1
" whether or not to show the nerdtree brackets around flags
let g:webdevicons_conceal_nerdtree_brackets = 1
"}



" set python3's path for YouCompleteMe {
" this only used by MacOS.
if g:os == "Darwin"
  let g:ycm_server_python_interpreter="/Library/Frameworks/Python.framework/Versions/3.6/bin/python3"
endif
"}


""""""""""""" lightline.vim settings {
set laststatus=2
" only `seoul256` can display correctly without change the .zshrc
" \ 'colorscheme': 'ayu_dark' best

let g:lightline = {
  \ 'colorscheme': 'default',
  \ 'active': {
  \   'left': [ [ 'mode', 'paste' ],
  \             [ 'readonly', 'filename', 'modified', 'helloworld', 'bufnumber' ] ],
  \   'right': [ [ 'lineinfo' ],
  \              [ 'percent' ],
  \              [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex', 'charOffset0x' ] ]
  \ },
  \ 'component': {
  \   'helloworld': 'Hello, world!',
  \   'filename': '%f',
  \   'bufnumber': 'buf: %n',
  \   'charOffset': 'offset: %o',
  \   'charOffset0x': 'offset: %O'
  \ },
\ }

" overwrite the tabline style with ayu_dark's
" refer: https://github.com/itchyny/lightline.vim/issues/431
let s:palette_from = g:lightline#colorscheme#ayu_dark#palette
let s:palette = g:lightline#colorscheme#default#palette
let s:palette.tabline.tabsel = s:palette_from.tabline.tabsel
let s:palette.tabline.left = s:palette_from.tabline.left
let s:palette.tabline.middle = s:palette_from.tabline.middle
let s:palette.tabline.right = s:palette_from.tabline.right


"This plugin has own colorscheme for tab colors. If you want to use the default tabline, disable the tabline of this plugin:     'enable': { 'tabline': 0 },
"  \ 'enable': { 'tabline': 0 },
" refer: https://github.com/itchyny/lightline.vim/issues/589

" disable showmode since we already have plugin:  https://github.com/itchyny/lightline.vim
" requires itchyny/lightline.vim
set noshowmode

"}



" won't works when `lightline.vim` is working
" set statusline=%t\ %y\ format:\ %{&ff};\ [%c,%l]

" show full filepath
" won't works when `lightline.vim` is working
"set statusline+=%F

""""""" mhinz/vim-grepper {
" In cases where the arguments don't come last, use $* as a placeholder:
" 'grepprg': 'grep -Rn $* .'
let g:grepper = {
    \ 'jump': 1,
    \ 'quickfix': 0,
    \ 'highlight': 1,
    \ 'grep': {
    \   'grepprg':    'grep -Rni $* $.'
    \ },
    \ 'tools': ['grep', 'git']
  \ }

nmap <Leader>* :Grepper -noprompt -highlight -open -noquickfix -tool grep -grepprg grep -n -r -i <C-R>=expand("<cword>")<CR> %<Left><Left><Left>

" }
""""""""""""" undoquit.vim settings {
nnoremap <c-w>c :call undoquit#SaveWindowQuitHistory()<cr><c-w>c
"}


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






"""""" reset the background of normal to none, so that vim's backgroundColor still behave good in gnuScreen
"""""" I want transparent background instead of the black background from the theme
highlight Normal ctermbg=none
highlight NonText ctermbg=none
autocmd ColorScheme * highlight Normal ctermbg=None
autocmd ColorScheme * highlight NonText ctermbg=None









"""""""""""""""""""""""""""""""
" Heavy Customiztion
"""""""""""""""""""""""""""""""
" highlight selected text; // now we use `space space` to to this instad.
"vnoremap // y/\V<C-r>=escape(@",'/\')<CR><CR>

" hightlight current word without jumping to next match
nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>
"nnoremap <silent> <Space><Space> "zyiw:let @/ = '\<' . @z . '\>'<CR>:set hlsearch<CR>:lvim <C-r>z %<CR>
" highlight current word and then trying to substitute it [replace]
nmap # <Space><Space>:%s/<C-r>///g<Left><Left>

" same in visualMod
xnoremap <silent> <Space> mz:call <SID>set_vsearch()<CR>:set hlsearch<CR>`z:lvim <C-r>z %<CR>
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
"imap <C-D> <C-O>x
"inoremap <C-d> <Del>
"imap <C-h> <BS>

" x and s won't yank
nnoremap x "_x
nnoremap s "_s

" paste without change register
"xnoremap <expr> p 'pgv"'.v:register.'y`>'


inoremap <C-]> <Esc><Right>

" <silent> menas user cannot see any iteraction when this command running.
" e.g: :%s/\s\+//g prompt, and user cannot see it.

" search text in project {
" use this to grep only specific file type. (when --exclude used, --include will be ignored)
" --include="*.js"
" --include=\*.{py,pl,sh}
"nmap <Leader>h :grep -n -r --color=always --exclude-dir="node_modules" --exclude-dir="mochawesome-report" --exclude-dir="domino-iam-service" --exclude-dir="build" --exclude-dir="logs" --exclude-dir="website/node_modules" --exclude-dir="dist" --exclude-dir=".nyc_output" --exclude-dir=".tmp" --exclude-dir="coverage" --exclude="*.swp" --exclude="*.orig" -i  ./<Left><Left><Left>
" we only use the Grepper to highlight the grep result.
nmap <Leader>h :Grepper -noprompt -highlight -open -quickfix -tool grep -grepprg grep -n -r --exclude-dir="node_modules" --exclude-dir="mochawesome-report" --exclude-dir="domino-iam-service" --exclude-dir="build" --exclude-dir="logs" --exclude-dir="website/node_modules" --exclude-dir="dist" --exclude-dir=".nyc_output" --exclude-dir=".tmp" --exclude-dir="coverage" --exclude="*.swp" --exclude="*.orig" -i  ./<Left><Left><Left>

"}

" to avoid Arrow Key not works in Vim.
"set term=ansi

" export TERM=xterm-256color
"if !has('gui_running')
"  set t_Co=256
"endif

" let g:lightline = {
"   \ 'colorscheme': 'wombat',
" \ }

"""""""""""""""""" to switch back to the last active tab {
" refer: https://stackoverflow.com/questions/2119754/switch-to-last-active-tab-in-vim
if !exists('g:lasttab')
  let g:lasttab = 1
endif
nmap <Leader>` :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()
"}

""""""""""""""""""" Ngb to jump to buffer number N. {
" The following lets you type Ngb to jump to buffer number N (a number from 1 to 99). For example, typing 12gb would jump to buffer 12.
" refer: https://vim.fandom.com/wiki/Easier_buffer_switching

let c = 1
while c <= 99
  execute "nnoremap " . c . "gb :" . c . "b\<CR>"
  let c += 1
endwhile
"}




" 在vimrc配置文件中，增加以下两条命令，可以在屏幕底部启用wildmenu菜单显示：
" 启用wildmenu菜单之后，在命令行中，第一次点击Tab时，
" 将列示所有可能与已输入字符相匹配的命令列表；第二次点击Tab时，则将在显示的wildmenu中遍历匹配项；然后点击回车键做出选择。
"set wildmenu
"set wildmode=list:longest,full
" refer: https://yyq123.blogspot.com/2012/08/vim-manipulate-directory.html
" auto-complete for buffer name. {
"you can use the Buffers menu to conveniently access buffers (tear off the menu to make an always-visible list).
"Or, put the following in your vimrc:
"set wildchar=<Tab> wildmenu wildmode=full
set wildchar=<Tab> wildmenu wildmode=list:longest,full
"Now, pressing Tab on the command line will show a menu to complete buffer and file names.
"}

" Buffers - explore/next/previous: F12, Shift-F12. {
nnoremap <silent> <F12> :bn<CR>
nnoremap <silent> <S-F12> :bp<CR>
"}


" After this, you will see the list of jumps and be asked to select a jump. {
" If you type 4 and press Enter, it will take you back to the 4th jump.
" If you type +4 and press Enter, it will take you forward to the 4th jump in the list.
" If you press Escape, nothing happens.
function! GotoJump()
  jumps
  let j = input("Please select your jump: ")
  if j != ''
    let pattern = '\v\c^\+'
    if j =~ pattern
      let j = substitute(j, pattern, '', 'g')
      execute "normal " . j . "\<c-i>"
    else
      execute "normal " . j . "\<c-o>"
    endif
  endif
endfunction
nmap <Leader>j :call GotoJump()<CR>
" You can also use g; and g, to move backward and forward in your edit locations.
" Remember, jumps only works in one tab, it won't across tabs
" refer: https://vim.fandom.com/wiki/Jumping_to_previously_visited_locations
"}

"""""""" auto reload this config after editing this file in this vim instance. {
augroup reloadvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END
"}

" paste without change {
"vnoremap <leader>p "_dP
vnoremap <leader>p "0p
noremap <leader>p "0p
"}


"""""""""""""""""""""""""""""""
" Memo
"""""""""""""""""""""""""""""""

" vimReplace Memo
":'<,'>s/\n/\\r\\n' +\r    '/g
" including $,{,}, They are all plain text.
":'<,'>s/123/${all plainTxt}/g

" vim format json Memo
" format selected content
":'<,'>!python -m json.tool
" format the whole file
":%!python -m json.tool


"function! MergeTab()
"    let bufnums = tabpagebuflist()
"    hide tabclose
"    topleft vsplit
"    for n in bufnums
"        execute 'sbuffer ' . n
"        wincmd _
"    endfor
"    wincmd t
"    quit
"    wincmd =
"endfunction
"command! MergeTab call MergeTab()
"
"
" press  g* to search without \< \>
"
"
"""""""""""""""""""
" To convert to unix
""""""""""""""""""
" find . -mindepth 0 -maxdepth 999 -type f |grep -i -P "\.(js|html|json|css|sh)$" | xargs -L 1 -I % sed -i -z 's/\r//g' %
"
"
" :set ff?
" To convert dos to unix:
" way1
" :e ++ff=unix
" Remeber the ^M should be Ctrl+V, then Ctrl + M
" :%s/\^M//g
" :wq
"
" :e    -> reload
" ++  -> force
" ff .   -> fileformat
"
"
"
" for multi-highlight(filePosition: ~/.vim/plugin/highlights.vim):
"
" ##########################################################################
" Type '\m' to toggle mapping of keypad on/off (assuming \ leader).        #
" Type '-0' to remove the highlight of current word/selection              #
" Type '-1' to highlight currnet work/selection with colorSchme 1          #
" Type '-2' to highlight currnet work/selection with colorSchme 2          #
" Type '-\d' to highlight currnet work/selection with colorSchme n         #
" Type '-f' to find the next match; '-F' to find backwards.                #
" Can also type '-n' or '-N' for search; then n or N will find next.       #
" Type '-s' to save multi-match of current window                          #
" Type '-r' to restore the saved multi-match to current window             #
" ##########################################################################

