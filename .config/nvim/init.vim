set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

let g:CommandTPreferredImplementation='lua'

augroup packer_user_config
  autocmd!
  autocmd BufWritePost plugins.lua source <afile> | PackerCompile
augroup end

lua require('plugins')
"lua require('config')
lua vim.lsp.set_log_level("debug")
