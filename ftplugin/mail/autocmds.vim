" Control statements    {{{1
set encoding=utf-8
scriptencoding utf-8

""
" @setting b:disable_dn_neomutt_mail_completion
" If this buffer variable exists and is set to a true value, e.g., "1",
" neomutt address completion will be disabled for the "mail" filetype.

if exists('b:disable_dn_neomutt_mail_completion')
            \ && b:disable_dn_neomutt_mail_completion
    finish
endif
if exists('b:loaded_dn_neomutt_mail_completion')
    finish
endif
let b:loaded_dn_neomutt_mail_completion = 1

let s:save_cpo = &cpoptions
set cpoptions&vim

" Documentation    {{{1
" - vimdoc does not automatically generate autocmds section

""
" @section Autocommands, autocmds
" The @function(dn#neomutt#address#completion) provides email address
" completion for "mail" filetypes using email addresses from the neomutt
" aliases file. The autocmd responsible for this completion behaviour can be
" found in the "dn_neomutt_address_mail" autocmd group (see |autocmd-groups|)
" and can be viewed (see |autocmd-list|).

" }}}1

" Autocommands

" Set completion function    {{{1

augroup dn_neomutt_address_mail
    au!
    au FileType mail setlocal completefunc=dn#neomutt#address#completion
augroup END

" Control statements    {{{1
let &cpoptions = s:save_cpo
unlet s:save_cpo
" }}}1

" vim: set foldmethod=marker :
