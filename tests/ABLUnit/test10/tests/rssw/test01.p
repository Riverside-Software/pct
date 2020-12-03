@Before.
procedure setup-context:
  log-manager:write-message("Entering setup-context").
end procedure.

@Test.
procedure test01:
  log-manager:write-message("Entering test01").
end procedure.

@Test.
procedure test02:
  log-manager:write-message("Entering test02").
end procedure.

@Ignore.
procedure anotherProc:
  log-manager:write-message("Entering anotherProc").
end procedure.

@After.
procedure destroy-context:
  define variable iCnt as integer no-undo.

  log-manager:write-message("Entering destroy-context").

  run anotherProc in this-procedure.

  catch eErr as Progress.Lang.Error :
    do iCnt = 1 to eErr:NumMessages:
      log-manager:write-message(eErr:GetMessage(iCnt)).
    end.
  end catch.
  finally:
    log-manager:write-message("Leaving destroy-context").
  end finally.

end procedure.
