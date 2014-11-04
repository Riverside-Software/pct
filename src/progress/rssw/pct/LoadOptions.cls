ROUTINE-LEVEL ON ERROR UNDO, THROW.

USING Progress.Lang.* FROM PROPATH.
USING OpenEdge.DataAdmin.Binding.IDataDefinitionLoader FROM PROPATH.
USING OpenEdge.DataAdmin.Binding.DataDefinitionOptions FROM PROPATH.

CLASS rssw.pct.LoadOptions INHERITS DataDefinitionOptions:

  CONSTRUCTOR PUBLIC LoadOptions (logger AS OpenEdge.DataAdmin.Binding.IDataDefinitionLoader):
    SUPER (logger).
  END CONSTRUCTOR.

  CONSTRUCTOR PUBLIC LoadOptions (  ):
    THIS-OBJECT(?).
  END CONSTRUCTOR.

END CLASS.
