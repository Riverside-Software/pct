class Test4Callback implements rssw.pct.IMainCallback:

  method public void initialize():
    message "initialize".
  end method.

  method public void beforeRun():
    message "beforeRun".
  end method.

  method public void log(msg as character):
    message msg.
  end method.

  method public void afterRun(retVal as integer):
    message substitute("afterRun &1", retVal).
  end method.

end class.

