" initial setting
if has('vim_starting')
  set encoding=utf-8
  scriptencoding utf-8
  " 利用可能な場合は true color を有効化する
  if !has('gui_running')
        \ && exists('&termguicolors')
        \ && $COLORTERM ==# 'truecolor'
    " tmux 等でも強制的に termguicolors を有効化するための設定 (Neovim では不要)
    " https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
    if !has('nvim')
      let &t_8f = "\e[38;2;%lu;%lu;%lum"
      let &t_8b = "\e[48;2;%lu;%lu;%lum"
    endif
    set termguicolors       " use truecolor in term
  endif
endif

" reset augroup
augroup MyAutoCmd
autocmd!
augroup END

"dein package manager
if &compatible
  set nocompatible
endif

set runtimepath+=$HOME/.vim/dein/repos/github.com/Shougo/dein.vim

" PATHの自動更新関数
" | 指定された path が $PATH に存在せず、ディレクトリとして存在している場合
" | のみ $PATH に加える
function! IncludePath(path)
  " define delimiter depends on platform
  if has('win16') || has('win32') || has('win64')
    let delimiter = ";"
  else
    let delimiter = ":"
  endif
  let pathlist = split($PATH, delimiter)
  if isdirectory(a:path) && index(pathlist, a:path) == -1
    let $PATH=a:path.delimiter.$PATH
  endif
endfunction

" ~/.pyenv/shims を $PATH に追加する
" これを行わないとpythonが正しく検索されない
call IncludePath(expand("~/.anyenv/envs/pyenv/shims"))

let s:dein_dir = $HOME . '/.vim/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'
"let s:toml_file = fnamemodify(expand('<sfile>'), ':h').'/.config/vim/dein.toml'
let s:toml_file = $HOME . '/.config/vim/dein.toml'
"let g:deoplete#enable_at_startup = 1

"install if dein not exists
if !isdirectory(s:dein_repo_dir)
  call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif

" load plugin
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir, [$MYVIMRC, s:toml_file])
  call dein#load_toml(s:toml_file)
  call dein#end()
  call dein#save_state()
endif

" install dipendency
if has('vim_starting') && dein#check_install()
  call dein#install()
endif


" vim editor setting
set number
set ambiwidth=double
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set hlsearch
set showcmd
set cindent
set list
set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%
set whichwrap=b,s,[,],<,>
set backspace=indent,eol,start
set tags=/home/vagrant/tags

" vertically split buffers for vimdiff
set diffopt& diffopt+=vertical

" <F1>はデフォルトで:helpにマッピングされている
nnoremap <silent> <F1> :<C-u>e ~/.vimrc<CR>
" <F10> で編集中の Vim script をソース
if !exists('*s:source_script')
  " ~/.vimrc をソースすると関数実行中に関数の上書きを行うことになりエラーとなるため
  " 'function!' による強制上書きではなく if によるガードを行っている
  function s:source_script(path) abort
    let path = expand(a:path)
    if !filereadable(path)
      return
    endif
    execute 'source' fnameescape(path)
    echomsg printf(
          \ '"%s" has sourced (%s)',
          \ simplify(fnamemodify(path, ':~:.')),
          \ strftime('%c'),
          \)
  endfunction
endif
nnoremap <silent> <F10> :<C-u>call <SID>source_script('%')<CR>

"noremap <C-g> :Gtags
"noremap <C-h> :Gtags -f %<CR>
"noremap <C-j> :GtagsCursor<CR>
"noremap <C-n> :cn<CR>
"noremap <C-p> :cp<CR>
noremap <silent> <BS><BS> :ccl<CR>
noremap <silent> ,s :vsplit<CR><C-w>l:enew<CR>
noremap <silent> ,d :windo diffthis<CR>
noremap <silent> ,t :tabnew<CR>
noremap <silent> ;s :set spelllang=en,cjk<CR>
noremap <silent> ;ns :set nospell<CR>
noremap <silent> <C-c> gt
noremap <silent> <C-x> gT
nnoremap <silent> <Esc><Esc> :<C-u>nohlsearch<CR><Left>

nnoremap gs  :<C-u>%s///g<Left><Left><Left>
vnoremap gs  :s///g<Left><Left><Left>

" diff
nnoremap ;d  :vertical diffsplit
vnoremap ;d  :<C-u>vertical diffsplit

" Gina status
noremap ;G  :<C-u>Gina

" grep検索
noremap <silent> ;g  :<C-u>Unite grep:. -buffer-name=search-buffer<CR>
noremap <silent> <space>g  :<C-u>Denite grep<CR>
noremap <silent> <space>G  :<C-u>DeniteCursorWord grep<CR>

" カーソル位置の単語をgrep検索
noremap <silent> ;w :<C-u>Unite grep:. -buffer-name=search-buffer<CR><C-R><C-W>

" grep検索結果の再呼出
noremap <silent> ;r  :<C-u>UniteResume search-buffer<CR>
noremap <silent> ;f  :<C-u>Unite file<CR>
noremap <silent> ;F  :<C-u>DeniteBufferDir file<CR>
noremap <silent> ;m  :<C-u>Denite file_mru -mode=normal<CR>

" Vaffle
noremap <silent> ;v  :<C-u>Vaffle<CR>

" easymotion
" デフォルトのキーマッピングを無効にする
let g:EasyMotion_do_mapping = 0

" <Leader>f{char} to move to {char}
"nmap f <Plug>(easymotion-s)
" f to command line motion
nmap f <Plug>(easymotion-sn)
" s{char}{char} to move to {char}{char}
nmap s <Plug>(easymotion-f2)
" Move to line
nmap <Leader>L <Plug>(easymotion-bd-jk)
" Move to word
nmap <Leader>w <Plug>(easymotion-bd-w)

nmap J <Plug>(easymotion-jumptoanywhere)


" grep に pt(platinum searcher) を使う
call denite#custom#var('grep', 'default_opts', ['-nH'])
call denite#custom#var('grep', 'recursive_opts', ['-r', '--exclude-dir=.git'])
if executable('pt')
  let g:unite_source_grep_command = 'pt'
  let g:unite_source_grep_default_opts = '--nogroup --nocolor'
  let g:unite_source_grep_recursive_opt = ''
  call denite#custom#var('grep', 'command', ['pt'])
  call denite#custom#var('grep', 'recursive_opts', [])
  call denite#custom#var('grep', 'pattern_opt', [])
  call denite#custom#var('grep', 'default_opts', ['--nogroup', '--nocolor'])
endif

" show dot files on Unite file
call unite#custom#source('file', 'matchers', "matcher_default")

" json parser
if executable('jq')
  function! s:jq(has_bang, ...) abort range
    execute 'silent' a:firstline ',' a:lastline '!jq' string(a:0 == 0 ? '.' : a:1)
    if !v:shell_error || a:has_bang
      return
    endif
    let error_lines = filter(getline('1', '$'), 'v:val =~# "^parse error: "')
    " 範囲指定している場合のために，行番号を置き換える
    let error_lines = map(error_lines, 'substitute(v:val, "line \\zs\\(\\d\\+\\)\\ze,", "\\=(submatch(1) + a:firstline - 1)", "")')
    let winheight = len(error_lines) > 10 ? 10 : len(error_lines)
    " カレントバッファがエラーメッセージになっているので，元に戻す
    undo
    " カレントバッファの下に新たにウィンドウを作り，エラーメッセージを表示するバッファを作成する
    execute 'botright' winheight 'new'
    setlocal nobuflisted bufhidden=unload buftype=nofile
    call setline(1, error_lines)
    " エラーメッセージ用バッファのundo履歴を削除(エラーメッセージをundoで消去しないため)
    let save_undolevels = &l:undolevels
    setlocal undolevels=-1
    execute "normal! a \<BS>\<Esc>"
    setlocal nomodified
    let &l:undolevels = save_undolevels
    " エラーメッセージ用バッファは読み取り専用にしておく
    setlocal readonly
  endfunction
  command! -bar -bang -range=% -nargs=? Jq  <line1>,<line2>call s:jq(<bang>0, <f-args>)
endif

syntax enable
filetype indent plugin on
set secure
silent! colorscheme iceberg
