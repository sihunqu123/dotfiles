" colorscheme
" if &diff
    " colorscheme evening
" endif

colo desert

execute pathogen#infect()
syntax on
filetype plugin indent on

" disable showmode since we already have plugin:  https://github.com/itchyny/lightline.vim
set noshowmode

" to make pasting from clipboard works properly
set paste
set nu
set ignorecase
set tabstop=4 softtabstop=2 shiftwidth=2 smarttab
set expandtab
set paste
set list lcs=tab:»·
"set autochdir

" global key
let mapleader = ","



" let g:netrw_keepdir= 0
" open in tree style
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
" open new file in the right side vertically
let g:netrw_altv = 1
let g:netrw_winsize = 25


" Trailing space
highlight ExtraWhitespace ctermbg=red guibg=red
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
" to remove trailing space
nmap <Leader>c :%s/\s\+$//g

" adjust vim prompt menu's color
autocmd ColorScheme * highlight Pmenu ctermbg=white
autocmd ColorScheme * highlight PmenuSel ctermbg=yellow

" always open netrw when openning vim
"
" augroup ProjectDrawer
"   autocmd!
"   autocmd VimEnter * :Vexplore
" augroup END

" command-t
" nmap <silent> <C-T> <Plug>(CommandT)
nmap <silent> <Leader>t <Plug>(CommandT)
nmap <silent> <Leader>b <Plug>(CommandTBuffer)
nmap <silent> <Leader>j <Plug>(CommandTJump)
" nmap <silent> <Leader>2 <Plug>(CommandT)

nmap <silent> <Leader>r :NERDTreeFind<cr>
nmap <silent> <Leader>g :NERDTreeToggle<cr>

let g:NERDTreeDirArrowExpandable = '＞'
let g:NERDTreeDirArrowCollapsible = '﹀'

let g:CommandTWildIgnore=&wildignore . ",*/node_modules"

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


" Not works now, don't know why
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>


" search text in project
nmap <Leader>h :grep -n -r --exclude-dir="node_modules" --exclude-dir="mochawesome-report" --exclude-dir="domino-iam-service" --exclude-dir="build" --exclude-dir="logs" --exclude="*.swp" --exclude="*.orig" -i  ./<Left><Left><Left>


" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %

" to avoid Arrow Key not works in Vim.
set term=ansi
" export TERM=xterm-256color
" if !has('gui_running')
"   set t_Co=256
" endif

let g:lightline = {
  \ 'colorscheme': 'wombat',
\ }





" vimReplace Memo
":'<,'>s/\n/\\r\\n' +\r    '/g






