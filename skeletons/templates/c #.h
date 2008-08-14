<+let(b:uname=toupper(substitute(fnamemodify(expand('%'), ':t'), '[^A-Za-z_0-9]', '_', 'g')))+>

#ifndef <+b:uname+>
# define <+b:uname+>

# ifdef __cplusplus
extern "C" {
# endif

<+CURSOR+>

# ifdef __cplusplus
}
# endif

#endif /* !<+b:uname+> */
