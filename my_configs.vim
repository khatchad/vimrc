" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

" Display incomplete commands
set showcmd	

" Don't use Ex mode, use Q for formatting
map Q gq

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

set foldmethod=syntax
set foldlevelstart=1

let javaScript_fold=1         " JavaScript
let perl_fold=1               " Perl
let php_folding=1             " PHP
let r_syntax_folding=1        " R
let ruby_fold=1               " Ruby
let sh_fold_enabled=1         " sh
let vimsyn_folding='af'       " Vim script
let xml_syntax_folding=1      " XML

set complete+=k
set spelllang=en_us
set dictionary+=/usr/share/dict/words,~/.dict
set thesaurus+=$HOME/Library/Dictionaries/mthesaur.txt
set swapfile
map <F2> a<C-R>=strftime("%m/%d/%y")<CR><Esc>
map π :CtrlPCmdPalette<CR>
set cursorline
set spellfile=~/.dict.en.utf-8.add

""""""""""""""""""""""""""""""
" => Reread vimrc
"""""""""""""""""""""""""""""""
augroup myvimrc
    au!
    au BufWritePost .vimrc,_vimrc,vimrc,.gvimrc,_gvimrc,gvimrc so $MYVIMRC | if has('gui_running') | so $MYGVIMRC | endif
augroup END

""""""""""""""""""""""""""""""
" => Text section
"""""""""""""""""""""""""""""""
autocmd FileType text,markdown setlocal diffopt+=iwhite,icase 
autocmd FileType text,markdown setlocal formatoptions+=nt 
autocmd FileType text,markdown setlocal spell 
autocmd FileType text,markdown setlocal nolist  " list disables linebreak 
autocmd FileType text,markdown setlocal textwidth=0 
autocmd FileType text,markdown setlocal wrapmargin=0

""""""""""""""""""""""""""""""
" => TeX section
"""""""""""""""""""""""""""""""
autocmd FileType tex,plaintex setlocal textwidth=78 
autocmd FileType tex,plaintex setlocal formatoptions+=ta 
autocmd FileType tex,plaintex setlocal spell
" search in a singe file. This will confuse latex-suite. Set your grep program
" to alway generate a file-name.
autocmd FileType tex,plaintex setlocal grepprg=grep\ -nH\ $*

"===== For custom mappings
augroup MyTeXIMAPs
au VimEnter * if &filetype == "tex" | imap <D-b> <Plug>Tex_MathBF| endif
au VimEnter * if &filetype == "tex" | imap <D-c> <Plug>Tex_MathCal| endif
au VimEnter * if &filetype == "tex" | imap <D-l> <Plug>Tex_LeftRight| endif
au VimEnter * if &filetype == "tex" | imap <D-i> <Plug>Tex_InsertItemOnThisLine| endif
au VimEnter * if &filetype == "tex" | imap <D-u> <Plug>Tex_InsertItemOnThisLine| endif
au VimEnter * if &filetype == "tex" | imap <D-y> <Plug>Tex_InsertItemOnNextLine| endif
" Note that <C-CR> is mapped to Tex_InsertItemOnNextLine
au VimEnter * if &filetype == "tex" | imap <C-b> <Plug>Tex_MathBF| endif
au VimEnter * if &filetype == "tex" | imap <C-c> <Plug>Tex_MathCal| endif
au VimEnter * if &filetype == "tex" | imap <C-l> <Plug>Tex_LeftRight| endif
au VimEnter * if &filetype == "tex" | imap <C-u> <Plug>Tex_InsertItemOnThisLine| endif
au VimEnter * if &filetype == "tex" | imap <C-y> <Plug>Tex_InsertItemOnNextLine| endif
au VimEnter * if &filetype == "tex" | imap <A-u> <Plug>Tex_InsertItemOnThisLine| endif
au VimEnter * if &filetype == "tex" | imap <A-y> <Plug>Tex_InsertItemOnNextLine| endif
augroup END
"
"======
"
let g:Tex_ViewRule_pdf = 'Skim'
let g:tex_flavor='latex'

""""""""""""""""""""""""""""""
" => Java section
"""""""""""""""""""""""""""""""
au FileType java setl fp=astyle\ --mode=java\ --indent=tab
au Filetype java setl makeprg=javac\ *.java
au Filetype java setl diffopt+=iwhite

""""""""""""""""""""""""""""""
" => AspectJ section
"""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.aj, setf aj 

""""""""""""""""""""""""""""""
" => Markdown section
"""""""""""""""""""""""""""""""
au BufRead,BufNewFile *.md set filetype=markdown

""""""""""""""""""""""""""""""
" => XML section
"""""""""""""""""""""""""""""""
au FileType xml setl fp=tidy\ -q\ -i\ -wrap\ -xml
au FileType xml XMLns xsl xsl
au FileType xml XMLent

""""""""""""""""""""""""""""""
" => HTML section
"""""""""""""""""""""""""""""""
au FileType html setl fp=tidy\ -q\ -i\ -wrap

""""""""""""""""""""""""""""""
" => Javascript section
"""""""""""""""""""""""""""""""
au FileType javascript setl fp=json_xs\ -f\ json\ -t\ json-pretty

""""""""""""""""""""""""""""""
" => C++ section
"""""""""""""""""""""""""""""""
au FileType cpp setl fp=astyle\ --mode=c\ --indent=tab 

""""""""""""""""""""""""""""""
" => C section
"""""""""""""""""""""""""""""""
au FileType c setl fp=astyle\ --mode=c\ --indent=tab\ \colorcolumn=80

""""""""""""""""""""""""""""""
" => Python section
"""""""""""""""""""""""""""""""
au FileType python setl fp=astyle\ --mode=python\ --indent=tab

""""""""""""""""""""""""""""""
" => Help section
"""""""""""""""""""""""""""""""
au FileType help setl nospell

""""""""""""""""""""""""""""""
" => Highlight TODO, FIXME, NOTE, etc.
"""""""""""""""""""""""""""""""
if has("autocmd")
  if v:version > 701
    autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|XXX\|BUG\|HACK\)')
    autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\)')
  endif
endif