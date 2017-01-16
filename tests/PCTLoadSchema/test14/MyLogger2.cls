ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.*.

CLASS MyLogger2 INHERITS rssw.pct.AbstractLoadLogger:
  METHOD PUBLIC OVERRIDE VOID AddIndex(pcAction as char, pcTable as char, h as handle, piArea as int):
    THIS-OBJECT:AddIndex(pcAction, pcTable, h, piArea, FALSE).
  END METHOD.

  METHOD PUBLIC OVERRIDE VOID AddIndex(pcAction as char, pcTable as char, h as handle, piArea as int,piPrimary as log):
    OUTPUT TO VALUE("NewIndexes.txt") APPEND.
    PUT UNFORMATTED SUBSTITUTE("NEW INDEX &1 &2", h:buffer-field('_Index-name'):buffer-value) SKIP.
    OUTPUT CLOSE.
  END METHOD.

END CLASS.
