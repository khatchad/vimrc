" Author: w0rp <devw0rp@gmail.com>
" Description: Linter registration and lazy-loading
"   Retrieves linters as requested by the engine, loading them if needed.

let s:runtime_loaded_map = {}
let s:linters = {}

" Default filetype aliases.
" The user defined aliases will be merged with this Dictionary.
"
" NOTE: Update the g:ale_linter_aliases documentation when modifying this.
let s:default_ale_linter_aliases = {
\   'Dockerfile': 'dockerfile',
\   'bash': 'sh',
\   'csh': 'sh',
\   'javascriptreact': ['javascript', 'jsx'],
\   'plaintex': 'tex',
\   'ps1': 'powershell',
\   'rmarkdown': 'r',
\   'rmd': 'r',
\   'systemverilog': 'verilog',
\   'typescriptreact': ['typescript', 'tsx'],
\   'vader': ['vim', 'vader'],
\   'verilog_systemverilog': ['verilog_systemverilog', 'verilog'],
\   'vimwiki': 'markdown',
\   'vue': ['vue', 'javascript'],
\   'xsd': ['xsd', 'xml'],
\   'xslt': ['xslt', 'xml'],
\   'zsh': 'sh',
\}

" Default linters to run for particular filetypes.
" The user defined linter selections will be merged with this Dictionary.
"
" No linters are used for plaintext files by default.
"
" Only cargo and rls are enabled for Rust by default.
" rpmlint is disabled by default because it can result in code execution.
" hhast is disabled by default because it executes code in the project root.
"
" NOTE: Update the g:ale_linters documentation when modifying this.
let s:default_ale_linters = {
\   'apkbuild': ['apkbuild_lint', 'secfixes_check'],
\   'astro': ['eslint'],
\   'csh': ['shell'],
\   'elixir': ['credo', 'dialyxir', 'dogma'],
\   'go': ['gofmt', 'golangci-lint', 'gopls', 'govet'],
\   'groovy': ['npm-groovy-lint'],
\   'hack': ['hack'],
\   'help': [],
\   'inko': ['inko'],
\   'json': ['biome', 'jsonlint', 'spectral', 'vscodejson'],
\   'json5': [],
\   'jsonc': ['biome'],
\   'perl': ['perlcritic'],
\   'perl6': [],
\   'python': ['flake8', 'mypy', 'pylint', 'pyright', 'ruff'],
\   'rust': ['analyzer', 'cargo'],
\   'spec': [],
\   'text': [],
\   'vader': ['vimls'],
\   'vue': ['eslint', 'vls'],
\   'zsh': ['shell'],
\   'v': ['v'],
\   'yaml': ['actionlint', 'spectral', 'yaml-language-server', 'yamllint'],
\}

" Testing/debugging helper to unload all linters.
function! ale#linter#Reset() abort
    let s:runtime_loaded_map = {}
    let s:linters = {}
endfunction

" Return a reference to the linters loaded.
" This is only for tests.
" Do not call this function.
function! ale#linter#GetLintersLoaded() abort
    " This command will throw from the sandbox.
    let &l:equalprg=&l:equalprg

    return s:linters
endfunction

function! s:IsCallback(value) abort
    return type(a:value) is v:t_string || type(a:value) is v:t_func
endfunction

function! s:IsBoolean(value) abort
    return type(a:value) is v:t_number && (a:value == 0 || a:value == 1)
endfunction

function! ale#linter#PreProcess(filetype, linter) abort
    if type(a:linter) isnot v:t_dict
        throw 'The linter object must be a Dictionary'
    endif

    let l:obj = {
    \   'name': get(a:linter, 'name'),
    \   'lsp': get(a:linter, 'lsp', ''),
    \}

    if type(l:obj.name) isnot v:t_string
        throw '`name` must be defined to name the linter'
    endif

    let l:needs_address = l:obj.lsp is# 'socket'
    let l:needs_executable = l:obj.lsp isnot# 'socket'
    let l:needs_command = l:obj.lsp isnot# 'socket'
    let l:needs_lsp_details = !empty(l:obj.lsp)

    if empty(l:obj.lsp)
        let l:obj.callback = get(a:linter, 'callback')

        if !s:IsCallback(l:obj.callback)
            throw '`callback` must be defined with a callback to accept output'
        endif
    endif

    if index(['', 'socket', 'stdio', 'tsserver'], l:obj.lsp) < 0
        throw '`lsp` must be either `''lsp''`, `''stdio''`, `''socket''` or `''tsserver''` if defined'
    endif

    if !l:needs_executable
        if has_key(a:linter, 'executable')
            throw '`executable` cannot be used when lsp == ''socket'''
        endif
    elseif has_key(a:linter, 'executable')
        let l:obj.executable = a:linter.executable

        if type(l:obj.executable) isnot v:t_string
        \&& type(l:obj.executable) isnot v:t_func
            throw '`executable` must be a String or Function if defined'
        endif
    else
        throw '`executable` must be defined'
    endif

    if !l:needs_command
        if has_key(a:linter, 'command')
            throw '`command` cannot be used when lsp == ''socket'''
        endif
    elseif has_key(a:linter, 'command')
        let l:obj.command = a:linter.command

        if type(l:obj.command) isnot v:t_string
        \&& type(l:obj.command) isnot v:t_func
            throw '`command` must be a String or Function if defined'
        endif
    else
        throw '`command` must be defined'
    endif

    if !l:needs_address
        if has_key(a:linter, 'address')
            throw '`address` cannot be used when lsp != ''socket'''
        endif
    elseif has_key(a:linter, 'address')
        if type(a:linter.address) isnot v:t_string
        \&& type(a:linter.address) isnot v:t_func
            throw '`address` must be a String or Function if defined'
        endif

        let l:obj.address = a:linter.address

        if has_key(a:linter, 'cwd')
            throw '`cwd` makes no sense for socket LSP connections'
        endif
    else
        throw '`address` must be defined for getting the LSP address'
    endif

    if has_key(a:linter, 'cwd')
        let l:obj.cwd = a:linter.cwd

        if type(l:obj.cwd) isnot v:t_string
        \&& type(l:obj.cwd) isnot v:t_func
            throw '`cwd` must be a String or Function if defined'
        endif
    endif

    if l:needs_lsp_details
        " Default to using the filetype as the language.
        let l:obj.language = get(a:linter, 'language', a:filetype)

        if type(l:obj.language) isnot v:t_string
        \&& type(l:obj.language) isnot v:t_func
            throw '`language` must be a String or Function if defined'
        endif

        if has_key(a:linter, 'project_root')
            let l:obj.project_root = a:linter.project_root

            if type(l:obj.project_root) isnot v:t_string
            \&& type(l:obj.project_root) isnot v:t_func
                throw '`project_root` must be a String or Function'
            endif
        else
            throw '`project_root` must be defined for LSP linters'
        endif

        if has_key(a:linter, 'completion_filter')
            let l:obj.completion_filter = a:linter.completion_filter

            if !s:IsCallback(l:obj.completion_filter)
                throw '`completion_filter` must be a callback'
            endif
        endif

        if has_key(a:linter, 'initialization_options')
            let l:obj.initialization_options = a:linter.initialization_options

            if type(l:obj.initialization_options) isnot v:t_dict
            \&& type(l:obj.initialization_options) isnot v:t_func
                throw '`initialization_options` must be a Dictionary or Function if defined'
            endif
        endif

        if has_key(a:linter, 'lsp_config')
            if type(a:linter.lsp_config) isnot v:t_dict
            \&& type(a:linter.lsp_config) isnot v:t_func
                throw '`lsp_config` must be a Dictionary or Function if defined'
            endif

            let l:obj.lsp_config = a:linter.lsp_config
        endif
    endif

    let l:obj.output_stream = get(a:linter, 'output_stream', 'stdout')

    if type(l:obj.output_stream) isnot v:t_string
    \|| index(['stdout', 'stderr', 'both'], l:obj.output_stream) < 0
        throw "`output_stream` must be 'stdout', 'stderr', or 'both'"
    endif

    " An option indicating that this linter should only be run against the
    " file on disk.
    let l:obj.lint_file = get(a:linter, 'lint_file', 0)

    if !s:IsBoolean(l:obj.lint_file) && type(l:obj.lint_file) isnot v:t_func
        throw '`lint_file` must be `0`, `1`, or a Function'
    endif

    " An option indicating that the buffer should be read.
    let l:obj.read_buffer = get(a:linter, 'read_buffer', 1)

    if !s:IsBoolean(l:obj.read_buffer)
        throw '`read_buffer` must be `0` or `1`'
    endif

    let l:obj.aliases = get(a:linter, 'aliases', [])

    if type(l:obj.aliases) isnot v:t_list
    \|| len(filter(copy(l:obj.aliases), 'type(v:val) isnot v:t_string')) > 0
        throw '`aliases` must be a List of String values'
    endif

    return l:obj
endfunction

function! ale#linter#Define(filetype, linter) abort
    " This command will throw from the sandbox.
    let &l:equalprg=&l:equalprg

    let l:new_linter = ale#linter#PreProcess(a:filetype, a:linter)

    if !has_key(s:linters, a:filetype)
        let s:linters[a:filetype] = []
    endif

    " Remove previously defined linters with the same name.
    call filter(s:linters[a:filetype], 'v:val.name isnot# a:linter.name')
    call add(s:linters[a:filetype], l:new_linter)
endfunction

" Prevent any linters from being loaded for a given filetype.
function! ale#linter#PreventLoading(filetype) abort
    let s:runtime_loaded_map[a:filetype] = 1
endfunction

function! ale#linter#GetAll(filetypes) abort
    " Don't return linters in the sandbox.
    " Otherwise a sandboxed script could modify them.
    if ale#util#InSandbox()
        return []
    endif

    let l:combined_linters = []

    for l:filetype in a:filetypes
        " Load linters from runtimepath if we haven't done that yet.
        if !has_key(s:runtime_loaded_map, l:filetype)
            execute 'silent! runtime! ale_linters/' . l:filetype . '/*.vim'

            let s:runtime_loaded_map[l:filetype] = 1
        endif

        call extend(l:combined_linters, get(s:linters, l:filetype, []))
    endfor

    return l:combined_linters
endfunction

function! s:GetAliasedFiletype(original_filetype) abort
    let l:buffer_aliases = get(b:, 'ale_linter_aliases', {})

    " b:ale_linter_aliases can be set to a List or String.
    if type(l:buffer_aliases) is v:t_list
    \|| type(l:buffer_aliases) is v:t_string
        return l:buffer_aliases
    endif

    " Check for aliased filetypes first in a buffer variable,
    " then the global variable,
    " then in the default mapping,
    " otherwise use the original filetype.
    for l:dict in [
    \   l:buffer_aliases,
    \   g:ale_linter_aliases,
    \   s:default_ale_linter_aliases,
    \]
        if has_key(l:dict, a:original_filetype)
            return l:dict[a:original_filetype]
        endif
    endfor

    return a:original_filetype
endfunction

function! ale#linter#ResolveFiletype(original_filetype) abort
    let l:filetype = s:GetAliasedFiletype(a:original_filetype)

    if type(l:filetype) isnot v:t_list
        return [l:filetype]
    endif

    return l:filetype
endfunction

function! s:GetLinterNames(original_filetype) abort
    let l:buffer_ale_linters = get(b:, 'ale_linters', {})

    " b:ale_linters can be set to 'all'
    if l:buffer_ale_linters is# 'all'
        return 'all'
    endif

    " b:ale_linters can be set to a List.
    if type(l:buffer_ale_linters) is v:t_list
        return l:buffer_ale_linters
    endif

    " Try to get a buffer-local setting for the filetype
    if has_key(l:buffer_ale_linters, a:original_filetype)
        return l:buffer_ale_linters[a:original_filetype]
    endif

    " Try to get a global setting for the filetype
    if has_key(g:ale_linters, a:original_filetype)
        return g:ale_linters[a:original_filetype]
    endif

    " If the user has configured ALE to only enable linters explicitly, then
    " don't enable any linters by default.
    if g:ale_linters_explicit
        return []
    endif

    " Try to get a default setting for the filetype
    if has_key(s:default_ale_linters, a:original_filetype)
        return s:default_ale_linters[a:original_filetype]
    endif

    return 'all'
endfunction

function! ale#linter#Get(original_filetypes) abort
    let l:possibly_duplicated_linters = []

    " Handle dot-separated filetypes.
    for l:original_filetype in split(a:original_filetypes, '\.')
        let l:filetype = ale#linter#ResolveFiletype(l:original_filetype)
        let l:linter_names = s:GetLinterNames(l:original_filetype)
        let l:all_linters = ale#linter#GetAll(l:filetype)
        let l:filetype_linters = []

        if type(l:linter_names) is v:t_string && l:linter_names is# 'all'
            let l:filetype_linters = l:all_linters
        elseif type(l:linter_names) is v:t_list
            " Select only the linters we or the user has specified.
            for l:linter in l:all_linters
                let l:name_list = [l:linter.name] + l:linter.aliases

                for l:name in l:name_list
                    if index(l:linter_names, l:name) >= 0
                        call add(l:filetype_linters, l:linter)
                        break
                    endif
                endfor
            endfor
        endif

        call extend(l:possibly_duplicated_linters, l:filetype_linters)
    endfor

    let l:name_list = []
    let l:combined_linters = []

    " Make sure we override linters so we don't get two with the same name,
    " like 'eslint' for both 'javascript' and 'typescript'
    "
    " Note that the reverse calls here modify the List variables.
    for l:linter in reverse(l:possibly_duplicated_linters)
        if index(l:name_list, l:linter.name) < 0
            call add(l:name_list, l:linter.name)
            call add(l:combined_linters, l:linter)
        endif
    endfor

    return reverse(l:combined_linters)
endfunction

" Given a buffer and linter, get the executable String for the linter.
function! ale#linter#GetExecutable(buffer, linter) abort
    let l:Executable = a:linter.executable

    return type(l:Executable) is v:t_func
    \   ? l:Executable(a:buffer)
    \   : l:Executable
endfunction

function! ale#linter#GetCwd(buffer, linter) abort
    let l:Cwd = get(a:linter, 'cwd', v:null)

    return type(l:Cwd) is v:t_func ? l:Cwd(a:buffer) : l:Cwd
endfunction

" Given a buffer and linter, get the command String for the linter.
function! ale#linter#GetCommand(buffer, linter) abort
    let l:Command = a:linter.command

    return type(l:Command) is v:t_func ? l:Command(a:buffer) : l:Command
endfunction

" Given a buffer and linter, get the address for connecting to the server.
function! ale#linter#GetAddress(buffer, linter) abort
    let l:Address = a:linter.address

    return type(l:Address) is v:t_func ? l:Address(a:buffer) : l:Address
endfunction
