if &diff
    colorscheme evening
endif
set nu
set ignorecase
set tabstop=4 softtabstop=2 expandtab shiftwidth=2 smarttab

set list lcs=tab:»·,trail:·

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

