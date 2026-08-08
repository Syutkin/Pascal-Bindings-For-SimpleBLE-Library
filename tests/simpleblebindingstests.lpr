program SimpleBleBindingsTests;

{$mode ObjFPC}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  consoletestrunner,
  SimpleCbleAbiTests,
  SimpleBleNativeLoaderTests;

var
  Runner: TTestRunner;
begin
  Runner := TTestRunner.Create(nil);
  try
    Runner.Initialize;
    Runner.Run;
  finally
    Runner.Free;
  end;
end.
