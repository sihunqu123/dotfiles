

call NERDTreeAddKeyMap({
      \ 'key': 'yy1',
      \ 'callback': 'NERDTreeYankFullPath1',
      \ 'quickhelpText': 'put full path of current node into the register 1' })

call NERDTreeAddKeyMap({
      \ 'key': 'yy2',
      \ 'callback': 'NERDTreeYankFullPath2',
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

"     \ 'scope': 'Bookmark',

call NERDTreeAddKeyMap({
      \ 'key': 'f',
      \ 'callback': 'NERDRevealBookmarkCWD',
      \ 'override': '1',
      \ 'quickhelpText': 'reveal this bookmark in the tree of current root' })
"     \ 'scope': 'Bookmark' })

function! NERDSetFolderSlash()
  if isdirectory(@z)
    let @z=@z . '/'
  endif
endfunction

function! NERDRevealBookmarkCWD()
  let n = g:NERDTreeBookmark.GetSelected()
  if n != {}
    call setreg('z', n.path.str())
  endif
" call nerdtree#echo("Node full path yanked to reg:".n.path.str()."!")
" call nerdtree#echo(n.path.str())
  call NERDSetFolderSlash()
  execute 'NERDTreeFind ' . @z
endfunction

call NERDTreeAddKeyMap({
      \ 'key': 'gb',
      \ 'callback': 'NERDAdd2Bookmark',
      \ 'override': '1',
      \ 'quickhelpText': 'Add the current node to bookmark' })
"     \ 'scope': 'Bookmark' })

function! NERDAdd2Bookmark()
  call feedkeys(':Bookmark ', 'n')
endfunction

call NERDTreeAddKeyMap({
      \ 'key': 'gr',
      \ 'callback': 'NERDRevealInputBookmark',
      \ 'override': '1',
      \ 'quickhelpText': 'Reveal the current node from the tree' })
"     \ 'scope': 'Bookmark' })

function! NERDRevealInputBookmark()
  call feedkeys(':RevealBookmark ', 'n')
endfunction


call NERDTreeAddKeyMap({
      \ 'key': 'ge',
      \ 'callback': 'NERDEditB',
      \ 'override': '1',
      \ 'quickhelpText': 'Edit bookmark' })
"     \ 'scope': 'Bookmark' })

function! NERDEditB()
  execute 'EditBookmarks'
endfunction

call NERDTreeAddKeyMap({
      \ 'key': 'gu',
      \ 'callback': 'NERDReadB',
      \ 'override': '1',
      \ 'quickhelpText': 'Refresh bookmark' })

function! NERDReadB()
" call nerdtree#echo("NERDReadB")
  execute 'ReadBookmarks'
  call nerdtree#echo("ReadBookmarks done")
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
