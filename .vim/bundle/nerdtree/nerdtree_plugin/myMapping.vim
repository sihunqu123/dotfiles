call NERDTreeAddKeyMap({
      \ 'key': 'yy',
      \ 'callback': 'NERDTreeYankFullPath',
      \ 'quickhelpText': 'put full path of current node into the default register' })

function! NERDTreeYankFullPath()
  let n = g:NERDTreeFileNode.GetSelected()
  if n != {}
    call setreg('"', n.path.str())
  endif
  call nerdtree#echo("Node full path yanked!")
endfunction


call NERDTreeAddKeyMap({
      \ 'key': 'yr',
      \ 'callback': 'NERDTreeYankRelativePath',
      \ 'quickhelpText': 'put relative path of current node into the default register' })

function! NERDTreeYankRelativePath()
  let n = g:NERDTreeFileNode.GetSelected()
  if n != {}
    call setreg('"', fnamemodify(n.path.str(), ':.'))
  endif
  call nerdtree#echo("Node relative path yanked!")
endfunction
