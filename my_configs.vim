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
let g:tex_fold_enabled=1
let g:markdown_folding = 1
let g:tex_fold_enabled = 1
let g:vimsyn_folding = 'af'
let g:xml_syntax_folding = 1
let g:javaScript_fold = 1
let g:sh_fold_enabled= 7
let g:ruby_fold = 1
let g:perl_fold = 1
let g:perl_fold_blocks = 1
let g:r_syntax_folding = 1
let g:rust_fold = 1
let g:php_folding = 1

set complete+=k
set complete-=i
set spelllang=en_us
set dictionary+=/usr/share/dict/words,~/.dict
set thesaurus+=$HOME/.vim_runtime/wordlists/thesaurus.txt
set swapfile
map <F2> a<C-R>=strftime("%m/%d/%y")<CR><Esc>
map π :CtrlPCmdPalette<CR>
set spellfile=~/.dict.en.utf-8.add
map <silent> <F11>
\    :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>
set gfn=Monospace\ 12
set listchars=trail:c

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
autocmd FileType text,markdown,mail setlocal diffopt+=iwhite,icase 
autocmd FileType text,markdown,mail setlocal formatoptions+=nt 
autocmd FileType text,markdown,mail setlocal spell 
autocmd FileType text,markdown setlocal nolist  " list disables linebreak 
autocmd FileType text,markdown setlocal textwidth=0 
autocmd FileType text,markdown setlocal wrapmargin=0

""""""""""""""""""""""""""""""
" => Mail section
"""""""""""""""""""""""""""""""
autocmd FileType mail setlocal tw=0 nocursorline
autocmd FileType mail let g:nerdtree_tabs_open_on_gui_startup = 0

""""""""""""""""""""""""""""""
" => TeX section
"""""""""""""""""""""""""""""""
" autocmd FileType tex,plaintex setlocal textwidth=78 
autocmd FileType tex,plaintex setlocal formatoptions+=t, noexpandtab
autocmd FileType tex,plaintex setlocal spell
autocmd FileType tex,plaintex setlocal foldmethod=syntax
autocmd FileType tex,plaintex syntax spell toplevel
" search in a singe file. This will confuse latex-suite. Set your grep program
" to alway generate a file-name.
autocmd FileType tex,plaintex syntax region texZone start='\\begin\s*{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin\s*{.*}{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\end\s*{' end='}'
autocmd FileType tex,plaintex setlocal grepprg=grep\ -nH\ $*
autocmd FileType tex,plaintex syntax region texZone start='\\begin{lstlisting}' end='\\end{lstlisting}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{minted}' end='\\end{minted}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{javacode}' end='\\end{javacode}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{javacode\*}' end='\\end{javacode\*}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{pythoncode}' end='\\end{pythoncode}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{pythoncode\*}' end='\\end{pythoncode\*}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{diffcode}' end='\\end{diffcode}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{diffcode\*}' end='\\end{diffcode\*}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{csharpcode}' end='\\end{csharpcode}'
autocmd FileType tex,plaintex syntax region texZone start='\\begin{csharpcode\*}' end='\\end{csharpcode\*}'
autocmd FileType tex,plaintex syntax region texZone start='\\mintinline{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\javainline{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\jl{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\csharpinline{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\pythoninline{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\lstinline{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\url{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\httplink{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\href{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\cite{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\citep{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\citet{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\citeauthor{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='\\citetitle{' end='}'
autocmd FileType tex,plaintex syntax region texZone start='%' end='\n'
autocmd FileType tex,plaintex syntax region texRefZone start='\\lref{' end='}'
autocmd FileType tex,plaintex syntax region texRefZone start='\\Lref{' end='}'

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
" au VimEnter * if &filetype == "tex" | nnoremap k gk
" au VimEnter * if &filetype == "tex" | nnoremap j gj
" au VimEnter * if &filetype == "tex" | nnoremap 0 g0
" au VimEnter * if &filetype == "tex" | nnoremap $ g$
" au VimEnter * if &filetype == "tex" | nnoremap ^ g^

augroup END
"
"======
"
let g:Tex_ViewRule_pdf = 'evince'
filetype indent on
let g:tex_flavor='latex'
let g:syntastic_tex_checkers = ["chktex"]
let g:LatexBox_split_type = "new"
let g:tex_nospell=0
let g:tex_comment_nospell= 1
let g:tex_verbspell= 0

""""""""""""""""""""""""""""""
" => Java section
"""""""""""""""""""""""""""""""
au FileType java setl fp=astyle\ --mode=java\ --indent=tab
au Filetype java setl makeprg=javac\ %
au Filetype java setl diffopt+=iwhite, number

""""""""""""""""""""""""""""""
" => Ruby section
"""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
" => Groovy section
"""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""
" => AspectJ section
"""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.aj, setf aj 

""""""""""""""""""""""""""""""
" => CSV section
"""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.csv, setf csv
autocmd FileType csv setlocal nowrap

" => Log section
"""""""""""""""""""""""""""""""
au BufNewFile,BufRead *.log, setf log
au FileType log setl nowrap

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
    autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|todo\|FIXME\|CHANGED\|XXX\|BUG\|HACK\)')
    autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\)')
  endif
endif

let g:netrw_browsex_viewer= "/usr/bin/xdg-open"
colorscheme PaperColor
