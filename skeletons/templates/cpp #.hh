<+let(b:uname=toupper(substitute(fnamemodify(expand('%'), ':t'), '[^A-Za-z_0-9]', '_', 'g')))+>

#ifndef <+b:uname+>
# define <+b:uname+>

<+CURSOR+>

#endif /* !<+b:uname+> */
