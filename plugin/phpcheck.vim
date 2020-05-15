if exists('g:loaded_phpcheck') || &cp
    finish
endif
let g:loaded_phpcheck = 1

let g:phpcheck_phpstan_bin = get(g:, 'phpcheck_phpstan_bin', 'phpstan')
let g:phpcheck_phpmd_bin = get(g:, 'phpcheck_phpmd_bin', 'phpmd')

" A ruleset filename or a comma-separated string of rulesetfilenames.
" Available rulesets: cleancode, codesize, controversial, design, naming,
" unusedcode.
let g:phpcheck_phpmd_ruleset = get(g:, 'phpcheck_phpmd_ruleset', 'unusedcode')

function! PhpStanCheck(...)
    let level_cmd = ''
    if a:0 > 0
        let level_cmd = ' --level='.a:1
    endif

    if exists('g:phpcheck_phpstan_bin') && !empty(g:phpcheck_phpstan_bin)
        let phpstan_bin = g:phpcheck_phpstan_bin
    else
        let phpstan_bin = system('which phpstan')
    endif
    if empty(phpstan_bin)
        echom 'error: could not detect executable phpstan bin'
        return 1
    elseif !executable(phpstan_bin)
        echom 'error: "'.phpstan_bin.'" is not executable'
        return 1
    endif

    let phpstan_config = $PHPSTAN_CONFIG
    if empty(phpstan_config)
        echom 'env PHPSTAN_CONFIG is not defined. use "config.neon"'
        let phpstan_config = 'config.neon'
    endif
    if !filereadable(phpstan_config)
        echom 'error: could not find phpstan config file "'.phpstan_config.'"'
        return 1
    endif

    let fname = expand('%:p')
    if !filereadable(fname)
        echom 'error: no file "'.fname.'" or is not readable'
        return 1
    endif

    call setqflist([])

    " TODO: add g:phpcheck_detect_phpstan_autoloader (key --autoload)
    " TODO: add g:phpcheck_phpstan_add_options
    " TODO: add g:phpcheck_detect_phpstan_config (key -c)
    let phpstan_command = phpstan_bin.' analyse'.
        \ ' --configuration='.phpstan_config.
        \ level_cmd.
        \ ' --error-format=raw --no-progress'.
        \ ' -- '.fname
    let phpstan_out = split(system('! '.phpstan_command), '\n')
    let filtered_out = filter(phpstan_out, '!empty(v:val)')
    if empty(filtered_out)
        cclose
        echom 'phpstan: no issues'
        return 0
    endif
    let errors_list = []
    for line in filtered_out
        let match = matchlist(line, '^\([^:]\+\):\(\d\+\):\(.*\)$')
        if empty(match)
            continue
        endif
        call add(errors_list, {
            \ 'filename': match[1],
            \ 'lnum': match[2],
            \ 'text': match[3],
            \ 'type': 'E'
        \ })
    endfor

    call setqflist(sort(errors_list, 's:sortErrors'))
    copen
endfunction

function! PhpMdCheck()
    let fname = expand('%:p')
    if !filereadable(fname)
        echom 'error: no file "'.fname.'" or is not readable'
        return 1
    endif

    call setqflist([])

    if exists('g:phpcheck_phpmd_bin') && !empty(g:phpcheck_phpmd_bin)
        let phpmd_bin = g:phpcheck_phpmd_bin
    else
        let phpmd_bin = system('which phpmd')
    endif
    if empty(phpmd_bin)
        echom 'error: could not detect executable phpmd bin'
        return 1
    elseif !executable(phpmd_bin)
        echom 'error: "'.phpmd_bin.'" is not executable'
        return 1
    endif

    let phpmd_out = split(system(
            \ '! '.phpmd_bin.
            \ ' '.fname.
            \ ' text '.g:phpcheck_phpmd_ruleset
        \ ), '\n')
    let filtered_out = filter(phpmd_out, '!empty(v:val)')
    if empty(filtered_out)
        cclose
        echom 'phpmd: no issues'
        return 0
    endif
    let errors_list = []
    for line in filtered_out
        let match = matchlist(line, '^\([^:]\+\):\(\d\+\)\s\+\(.*\)$')
        if empty(match)
            continue
        endif
        call add(errors_list, {
            \ 'filename': match[1],
            \ 'lnum': match[2],
            \ 'text': match[3],
            \ 'type': 'E'
        \ })
    endfor

    call setqflist(sort(errors_list, 's:sortErrors'))
    copen
endfunction

function! s:sortErrors(i1, i2)
    if a:i1.text > a:i2.text
        return 1
    elseif a:i1.text < a:i2.text
        return -1
    endif
    return 0
endfunction

nnoremap <silent> <Leader>ps :<C-U>call PhpStanCheck()<CR>
nnoremap <silent> <Leader>pm :<C-U>call PhpMdCheck()<CR>
