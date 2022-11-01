" Vim ftplugin for mail
" Last change: 2022 Nov 1
" Maintainer: David Nebauer
" License: GNU Affero General Public License v3.0

" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

let s:save_cpo = &cpoptions
set cpoptions&vim

" Documentation    {{{1

""
" @section Introduction, intro
" @library
" @order credits intro usage config autocmds-mail autocmds-notmuch-compose
" This plugin enables completion of email addresses using a neomutt alias
" file.
"
" The plugin assumes a single file is used to store all emails harvested from
" the user's maildirs. The file stores one email address per line in standard
" neomutt alias definitions, for example:
" >
"     alias johnno John Citizen <john@isp.com> # personal email
" <
" The default location of the aliases file is `~/.config/neomutt/aliases` but
" this can be changed by the |g:dn_neomutt_alias_file| variable.

""
" @section Credits
" This plugin is based on a plugin by Aaron D. Borden at
" https://github.com/adborden/vim-notmuch-address.

""
" @section Usage
" The plugin hooks into vim's user defined completion in buffers with the
" |filetype| "mail" or "notmuch-compose". On any address line (To:, Cc:,
" etc.) use |ctrl-x_ctrl-u| to activate the completion.

""
" @setting g:dn_neomutt_alias_file
" The path to a file containing one email address per line in standard neomutt
" alias definitions. If not set, the default filepath is
" `$HOME/.config/neomutt/aliases`.

" }}}1

" Script functions

" s:extract_address(key, val)    {{{1

""
" @private
" Used as the second argument to a |map()| function call that strips
" extraneous content from each line from the aliases file. Each line is
" expected to be a standard neomutt alias definition, for example:
" >
"     alias johnno John Citizen <john@isp.com> # personal email
" <
" The alias keyword ('alias'), alias key (e.g., 'johnno') and any terminal
" comment (e.g., '# personal email') are stripped, leaving only the email
" phrase and address:
" >
"     John Citizen <john@isp.com>
" <
" The {key} is ignored while the {val} is operated on by the |substitute()|
" function.
function! s:extract_address(key, val) abort
    let l:pattern = '^alias \S\+ \([^<]\+<[^>]\+>\)\p*$'
    let l:sub = '\1'
    let l:flags = ''
    return substitute(a:val, l:pattern, l:sub, l:flags)
endfunction
" }}}1

" Public functions

" dn#neomutt#address#completion(findstart, base)    {{{1

""
" @public
" A completion function for email addresses. See |complete-functions| for
" details on how these functions are called by vim. Of particular note is that
" the function is called twice for each completion: firstly to find at which
" column completion starts ({findstart} is set to 1 and {base} is empty), and
" secondly to get a list of matches ({findstart} is set to 0 and {base} is the
" match string extracted by vim based on the return value from the first
" function call).
"
" The function extracts all alias definitions from the aliases file (either
" the default alias file or one defined on |g:dn_neomutt_alias_file|). Email
" phrases and addresses are then extracted from the alias definitions and
" completion is performed upon them.
"
" @throws NoFile if unable to locate the neomutt aliases file
" @throws NoAliases if no email addresses are found in the aliases file
function! dn#neomutt#address#completion(findstart, base)
    let curline = getline('.')
    if curline =~? '^From: ' || curline =~? '^To: ' || curline =~? '^Cc: '
                \ || curline =~? '^Bcc: '
        if a:findstart
            " first call: find where match text, i.e., email address, starts
            let l:header_limit = stridx(curline, ': ') + 2
            let l:start = col('.') - 1
            while l:start > l:header_limit && curline[l:start - 2] !=# ','
                let l:start -= 1
            endwhile
            return l:start
        else
            " second call: get completion matches
            " - get location of aliases file
            let l:aliases_file = $HOME . '/.config/neomutt/aliases'
            if exists('g:dn_neomutt_alias_file') && g:dn_neomutt_alias_file
                let l:aliases_file = g:dn_neomutt_alias_file
            endif
            " - check that the aliases file exists
            if ! filereadable(l:aliases_file)
                let l:msg = 'ERROR(NoFile): Cannot locate neomutt aliases '
                            \ . 'file: ' . l:aliases_file
                throw l:msg
            endif
            " - slurp alias definitions
            let matches = readfile(l:aliases_file)
            if empty(matches)
                let l:msg = 'ERROR(NoAliases): No addresses found in '
                            \ . 'aliases file: ' . l:aliases_file
                throw l:msg
            endif
            " - extract email phrase and address
            call map(matches, function('s:extract_address'))

            for m in matches
                if complete_check()
                    break
                endif

                call complete_add(m)
            endfor
            return []
        endif
    endif
endfunction
" }}}1

" Control statements    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo
" }}}1

" vim: set foldmethod=marker :
