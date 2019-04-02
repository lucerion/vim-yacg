" ==============================================================
" Description:  Yet another ctags generator plugin
" Author:       Alexander Skachko <alexander.skachko@gmail.com>
" Homepage:     https://github.com/lucerion/vim-yacg
" Version:      0.0.1
" Licence:      BSD-3-Clause
" ==============================================================

if exists('g:loaded_yacg') || &compatible || v:version < 700
  finish
endif
let g:loaded_yacg = 1

if !exists('g:yacg_ctags_binary')
  let g:yacg_ctags_binary = 'ctags'
endif

if !exists('g:yacg_ctags_custom_languages')
  let g:yacg_ctags_custom_languages = ['elixir', 'javascript']
endif

if !exists('g:yacg_tags_directories')
  let g:yacg_tags_directories = ['.git', '.hg', '.svn', '.bzr', '_darcs', 'CVS']
endif

if !exists('g:yacg_execute_async')
  let g:yacg_execute_async = 1
endif

if !exists('g:yacg_ignore')
  let g:yacg_ignore = []
endif

if !exists('g:yacg_node_modules')
  let g:yacg_node_modules = 0
endif

if !exists('g:yacg_rubygems')
  let g:yacg_rubygems = 0
endif

if !exists('g:yacg_auto_generate')
  let g:yacg_auto_generate = 0
endif

if g:yacg_auto_generate
  augroup YacgAutoGenerate
    autocmd!
    autocmd BufEnter,BufWritePost * call yacg#generate()
  augroup END
endif

comm! GenerateTags call yacg#generate()
