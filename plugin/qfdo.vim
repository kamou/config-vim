
command! -complete=command -nargs=1 Qfdo call qfdo#QuickFixDo(<f-args>)
command! -complete=command -nargs=1 Qffdo call qfdo#QuickFixFileDo(<f-args>)

