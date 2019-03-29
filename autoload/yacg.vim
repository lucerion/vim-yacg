" ==============================================================
" Description:  Yet another ctags generator plugin
" Author:       Alexander Skachko <alexander.skachko@gmail.com>
" Homepage:     https://github.com/lucerion/vim-yacg
" Version:      0.0.1
" Licence:      BSD-3-Clause
" ==============================================================

let s:default_ctags_bin = 'ctags'
let s:ctags_defs_dir = expand('<sfile>:p:h') . '/../ctags_custom_languages'

func! yacg#generate() abort
  let l:ctags_bin = s:ctags_bin()
  if !len(l:ctags_bin)
    echoerr 'ctags is not installed!'
    return
  endif

  let l:command = s:command(l:ctags_bin)
  if g:yacg_execute_async && (v:version >= 800)
    call s:generate_async(l:command)
  else
    call s:generate(l:command)
  endif
endfunc

func! s:generate(command) abort
  call system(a:command)
  call s:show_tags_generated_message()
endfunc

func! s:generate_async(command) abort
  call job_start([&shell, &shellcmdflag, a:command], {
    \ 'exit_cb': function('s:generate_async_exit_callback')
    \ })
endfunc

func! s:generate_async_exit_callback(job, status) abort
  call s:show_tags_generated_message()
endfunc

func! s:ctags_bin() abort
  if executable(g:yacg_ctags_binary)
    return g:yacg_ctags_binary
  endif

  if executable(s:default_ctags_bin)
    return s:default_ctags_bin
  endif

  return ''
endfunc

func! s:command(ctags_bin) abort
  let l:command  = [a:ctags_bin]
  let l:command += s:ctags_options()
  let l:command += ['2>/dev/null']

  return join(l:command)
endfunc

func! s:ctags_options() abort
  let l:ctags_options  = ['-R']
  let l:ctags_options += s:tags_dir_option()
  let l:ctags_options += s:defs_options()

  return l:ctags_options
endfunc

func! s:tags_dir_option() abort
  let l:tags_dir_option = []

  for l:tags_dir in g:yacg_tags_directories
    if isdirectory(l:tags_dir)
      let l:tags_dir_option = ['-f ' . l:tags_dir . '/tags']
    endif
  endfor

  return l:tags_dir_option
endfunc

func! s:defs_options() abort
  let l:ctags_defs_files = split(globpath(s:ctags_defs_dir, '*'), '\n')
  let l:ctags_defs_langs = map(copy(l:ctags_defs_files), 'fnamemodify(v:val, ":p:t")')
  let l:defs_options = []

  for l:lang in g:yacg_ctags_custom_languages
    if index(l:ctags_defs_langs, l:lang) >= 0
      call add(l:defs_options, '--options=' . s:ctags_defs_dir . '/' . l:lang)
    endif
  endfor

  return l:defs_options
endfunc

func! s:show_tags_generated_message() abort
  echo 'yacg: ctags generated'
endfunc
