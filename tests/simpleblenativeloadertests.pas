unit SimpleBleNativeLoaderTests;

{$mode ObjFPC}{$H+}

interface

uses
  FPCUnit,
  TestRegistry;

type
  TSimpleBleNativeLoaderTests = class(TTestCase)
  private
    FLibraryDirectory: string;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure LoadsSimpleCBleVersionOne;
    procedure UnloadClearsResolvedApi;
  end;

implementation

uses
  SysUtils,
  SimpleBle;

procedure TSimpleBleNativeLoaderTests.SetUp;
begin
  inherited SetUp;
  FLibraryDirectory := GetEnvironmentVariable('SIMPLECBLE_LIBRARY_DIR');
end;

procedure TSimpleBleNativeLoaderTests.TearDown;
begin
  SimpleBleUnloadLibrary;
  inherited TearDown;
end;

procedure TSimpleBleNativeLoaderTests.LoadsSimpleCBleVersionOne;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));
  AssertTrue('simpleble_get_version was not resolved',
    Assigned(SimpleBleGetVersion));
  AssertEquals('Unexpected SimpleCBLE version', '1.0.0',
    string(SimpleBleGetVersion()));
end;

procedure TSimpleBleNativeLoaderTests.UnloadClearsResolvedApi;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));

  SimpleBleUnloadLibrary;

  AssertFalse('API pointer must be cleared after unload',
    Assigned(SimpleBleGetVersion));
end;

initialization
  RegisterTest(TSimpleBleNativeLoaderTests);

end.
