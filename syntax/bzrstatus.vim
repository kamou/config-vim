
if has("syntax") && exists("g:syntax_on")

  syn match bzrstatusHeader /^bzr .*/
  syn region bzrstatusError start='bzr: ERROR: ' end='$'

  syn region bzrstatusAdded    start='^[-+R ]N[* ]' end='$' contains=bzrstatusAddedFlag,bzrstatusRenameSign
  syn region bzrstatusRemoved  start='^[-+R ]D[* ]' end='$' contains=bzrstatusRemovedFlag,bzrstatusRenameSign
  syn region bzrstatusModified start='^[-+R ]M[* ]' end='$' contains=bzrstatusModifiedFlag,bzrstatusRenameSign
  syn region bzrstatusUnknown start='^?' end='$' contains=bzrstatusUnknownFlag
  syn match bzrstatusAddedFlag contained /^[-+R ]N[* ]/
  syn match bzrstatusRemovedFlag contained /^[-+R ]D[* ]/
  syn match bzrstatusModifiedFlag contained /^[-+R ]M[* ]/
  syn match bzrstatusRenameSign contained / => /
  syn match bzrstatusUnknownFlag contained /^?/

  syn region bzrstatusConflict start='^C  ' end='$' contains=bzrstatusConflictType
  syn region bzrstatusConflictType start='^C  ' end=' in ' contains=bzrstatusConflictFlag
  syn match bzrstatusConflictFlag contained /^C/

  syn region bzrstatusPending start='^P[. ]' end='$' contains=bzrstatusPendingHeader keepend
  syn region bzrstatusPendingHeader contained start='^P[. ]' end='\d\{4\}-\d\{2\}-\d\{2\}' contains=bzrstatusPendingFlag,bzrstatusPendingDate keepend
  syn match bzrstatusPendingFlag contained /^P[. ]/
  syn match bzrstatusPendingDate contained /\d\{4\}-\d\{2\}-\d\{2\}/

  hi def link bzrstatusHeader Label
  hi def link bzrstatusError ErrorMsg

  hi def link bzrstatusAdded Normal
  hi def link bzrstatusRemoved Normal
  hi def link bzrstatusModified Normal
  hi def link bzrstatusUnknown Comment
  hi def link bzrstatusAddedFlag DiffAdd
  hi def link bzrstatusRemovedFlag DiffDelete
  hi def link bzrstatusModifiedFlag DiffChange
  hi def link bzrstatusRenameSign Special
  hi def link bzrstatusUnknownFlag SpecialChar

  hi def link bzrstatusConflict Normal
  hi def link bzrstatusConflictType Type
  hi def link bzrstatusConflictFlag Error

  hi def link bzrstatusPending Comment
  hi def link bzrstatusPendingFlag Todo
  hi def link bzrstatusPendingHeader Statement
  hi def link bzrstatusPendingDate Number

end

