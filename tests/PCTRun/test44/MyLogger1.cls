class MyLogger1 implements rssw.pct.IMainCallback:
  
  method public void initialize():
    output to value("Logger1.init.txt").
    output close.
  end method.

  method public void beforeRun():
    output to value("Logger1.beforeRun.txt").
    output close.  
  end method.
  
  method public void afterRun(retVal as integer):
    output to value("Logger1.afterRun." + string(retVal) + ".txt").
    output close.

  end method.

  method public void log(msg as character):
    output to value("Logger1.log." + msg + ".txt").
    output close.
  end method.

end class.
