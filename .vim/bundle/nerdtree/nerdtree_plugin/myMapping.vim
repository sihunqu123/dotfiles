call NERDTreeAddKeyMap({
      \ 'key': 'yy1',
      \ 'callback': 'NERDTreeYankFullPath1',
      \ 'quickhelpText': 'put full path of current node into the register 1' })

call NERDTreeAddKeyMap({
      \ 'key': 'yy2',
      \ 'callback': 'NERDTreeYankFullPath3',
      \ 'quickhelpText': 'put full path of current node into the register 2' })

call NERDTreeAddKeyMap({
      \ 'key': 'yy3',
      \ 'callback': 'NERDTreeYankFullPath3',
      \ 'quickhelpText': 'put full path of current node into the register 3' })

call NERDTreeAddKeyMap({
      \ 'key': 'yy4',
      \ 'callback': 'NERDTreeYankFullPath4',
      \ 'quickhelpText': 'put full path of current node into the register 4' })

function! NERDTreeYankFullPath(param1)
  let n = g:NERDTreeFileNode.GetSelected()
  if n != {}
    call setreg(a:param1, n.path.str())
  endif
  call nerdtree#echo("Node full path yanked to reg:".a:param1."!")
endfunction


function! NERDTreeYankFullPath1()
  call NERDTreeYankFullPath("1")
endfunction

function! NERDTreeYankFullPath2()
  call NERDTreeYankFullPath("2")
endfunction

function! NERDTreeYankFullPath3()
  call NERDTreeYankFullPath("3")
endfunction

function! NERDTreeYankFullPath4()
  call NERDTreeYankFullPath("4")
endfunction


call NERDTreeAddKeyMap({
      \ 'key': 'yr1',
      \ 'callback': 'NERDTreeYankRelativePath1',
      \ 'quickhelpText': 'put relative path of current node into the register 1' })
call NERDTreeAddKeyMap({
      \ 'key': 'yr2',
      \ 'callback': 'NERDTreeYankRelativePath2',
      \ 'quickhelpText': 'put relative path of current node into the register 2' })
call NERDTreeAddKeyMap({
      \ 'key': 'yr3',
      \ 'callback': 'NERDTreeYankRelativePath3',
      \ 'quickhelpText': 'put relative path of current node into the register 3' })
call NERDTreeAddKeyMap({
      \ 'key': 'yr4',
      \ 'callback': 'NERDTreeYankRelativePath4',
      \ 'quickhelpText': 'put relative path of current node into the register 4' })

function! NERDTreeYankRelativePath(param1)
  let n = g:NERDTreeFileNode.GetSelected()
  if n != {}
    call setreg(a:param1, fnamemodify(n.path.str(), ':.'))
  endif
  call nerdtree#echo("Node relative path yanked to reg:".a:param1."!")
endfunction

function! NERDTreeYankRelativePath1()
  call NERDTreeYankRelativePath("1")
endfunction

function! NERDTreeYankRelativePath2()
  call NERDTreeYankRelativePath("2")
endfunction

function! NERDTreeYankRelativePath3()
  call NERDTreeYankRelativePath("3")
endfunction

function! NERDTreeYankRelativePath4()
  call NERDTreeYankRelativePath("4")
endfunction



"call NERDTreeAddKeyMap({
"      \ 'key': 'yy',
"      \ 'callback': 'NERDTreeYankFullPath',
"      \ 'quickhelpText': 'put full path of current node into the default register' })
"
"function! NERDTreeYankFullPath()
"  let n = g:NERDTreeFileNode.GetSelected()
"  if n != {}
"    call setreg('"', n.path.str())
"  endif
"  call nerdtree#echo("Node full path yanked!")
"endfunction
"
"
"call NERDTreeAddKeyMap({
"      \ 'key': 'yr',
"      \ 'callback': 'NERDTreeYankRelativePath',
"      \ 'quickhelpText': 'put relative path of current node into the default register' })
"
"function! NERDTreeYankRelativePath()
"  let n = g:NERDTreeFileNode.GetSelected()
"  if n != {}
"    call setreg('"', fnamemodify(n.path.str(), ':.'))
"  endif
"  call nerdtree#echo("Node relative path yanked!")
"endfunction
