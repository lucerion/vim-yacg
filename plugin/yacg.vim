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

comm! GenerateTags call yacg#generate()
