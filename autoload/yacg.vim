" ==============================================================
" Description:  Yet another ctags generator plugin
" Author:       Alexander Skachko <alexander.skachko@gmail.com>
" Homepage:     https://github.com/lucerion/vim-yacg
" Version:      0.0.1
" Licence:      BSD-3-Clause
" ==============================================================

let s:default_ctags_bin = 'ctags'

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
  let l:command += ['--tag-relative=yes']
  let l:command += s:tags_dir_option()
  let l:command += s:defs_options()
  let l:command += s:exclude_options()
  let l:command += ['-R', '.']
  let l:command += s:rubygems_paths()
  let l:command += ['2>/dev/null']

  return join(l:command)
endfunc

func! s:tags_dir_option() abort
  let l:tags_dir_option = []

  for l:tags_dir in g:yacg_tags_directories
    if isdirectory(l:tags_dir)
      let l:tags_file = l:tags_dir.'/tags'
      call add(l:tags_dir_option, '-f '.l:tags_file)
      silent exec 'setl tags+=' . l:tags_file
    endif
  endfor

  return l:tags_dir_option
endfunc

func! s:defs_options() abort
  let l:defs_options = []
  let l:ctags_dir_path = expand(g:yacg_ctags_dir)

  if isdirectory(l:ctags_dir_path)
    let l:ctags_defs_files = split(globpath(l:ctags_dir_path, '*'), '\n')

    for l:def_file in l:ctags_defs_files
      call add(l:defs_options, '--options=' . l:def_file)
    endfor
  endif

  return l:defs_options
endfunc

func! s:exclude_options() abort
  let l:exclude_options = copy(g:yacg_ignore)

  if !g:yacg_node_modules
    call add(l:exclude_options, 'node_modules')
  endif

  return map(copy(l:exclude_options), '"--exclude=".v:val')
endfunc

func! s:rubygems_paths() abort
  if !g:yacg_rubygems
    return []
  endif

  if !filereadable('Gemfile.lock')
    return []
  endif

  silent exec '!bundle check &>/dev/null'
  redraw!
  if v:shell_error
    return []
  endif

  let l:gems_paths = system('bundle show --paths')

  return split(l:gems_paths)
endfunc

func! s:show_tags_generated_message() abort
  echo 'yacg: ctags generated'
endfunc
