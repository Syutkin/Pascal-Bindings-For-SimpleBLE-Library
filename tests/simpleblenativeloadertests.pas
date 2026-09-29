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
    FTemporaryDirectory: string;
    procedure CopyFileToTemporaryDirectory(const ASourceFileName,
      ADestinationFileName: string);
    procedure CreateEmptyTemporaryFile(const AFileName: string);
    procedure CopyFixtureToTemporaryDirectory(const AFixtureFileName: string);
    procedure AssertApiCleared;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure LoadsSimpleCbleVersionOnePointTwo;
    procedure RejectsMissingDirectoryWithDiagnostic;
    procedure RejectsDirectoryWithoutNativeLibraries;
    procedure RejectsDirectoryWithoutSimpleCbleLibrary;
    procedure RejectsLibraryWithMissingRequiredSymbols;
    procedure RejectsSimpleCbleVersionOnePointOne;
    procedure FailedReloadClearsResolvedApi;
    procedure ReloadSucceedsAfterFailure;
    procedure FreeAcceptsNil;
    procedure NativeInvalidArgumentErrorLifecycle;
    procedure UnloadClearsResolvedApi;
  end;

implementation

uses
  SysUtils,
  Classes,
  SimpleBle;

procedure TSimpleBleNativeLoaderTests.CopyFileToTemporaryDirectory(
  const ASourceFileName, ADestinationFileName: string);
var
  DestinationStream: TFileStream;
  SourceStream: TFileStream;
begin
  SourceStream := TFileStream.Create(ASourceFileName, fmOpenRead or
    fmShareDenyWrite);
  try
    DestinationStream := TFileStream.Create(
      IncludeTrailingPathDelimiter(FTemporaryDirectory) +
      ADestinationFileName, fmCreate);
    try
      DestinationStream.CopyFrom(SourceStream, 0);
    finally
      DestinationStream.Free;
    end;
  finally
    SourceStream.Free;
  end;
end;

procedure TSimpleBleNativeLoaderTests.CreateEmptyTemporaryFile(
  const AFileName: string);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(
    IncludeTrailingPathDelimiter(FTemporaryDirectory) + AFileName,
    fmCreate);
  FileStream.Free;
end;

procedure TSimpleBleNativeLoaderTests.CopyFixtureToTemporaryDirectory(
  const AFixtureFileName: string);
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('Fixture library is missing: ' + AFixtureFileName,
    FileExists(AFixtureFileName));
  CopyFileToTemporaryDirectory(IncludeTrailingPathDelimiter(
    FLibraryDirectory) + SimpleBleCoreLibrary, SimpleBleCoreLibrary);
  CopyFileToTemporaryDirectory(AFixtureFileName, SimpleBleExtLibrary);
end;

procedure TSimpleBleNativeLoaderTests.AssertApiCleared;
begin
  AssertFalse('version pointer must be cleared', Assigned(SimpleBleGetVersion));
  AssertFalse('adapter pointer must be cleared', Assigned(SimpleBleAdapterGetCount));
  AssertFalse('error pointer must be cleared', Assigned(SimpleBleErrorRelease));
  AssertFalse('GATT pointer must be cleared', Assigned(SimpleBlePeripheralServicesGet));
  AssertFalse('read pointer must be cleared', Assigned(SimpleBlePeripheralRead));
  AssertFalse('callback pointer must be cleared',
    Assigned(SimpleBleLocalCharacteristicSetCallbackOnRead));
end;

procedure TSimpleBleNativeLoaderTests.SetUp;
begin
  inherited SetUp;
  FLibraryDirectory := GetEnvironmentVariable('SIMPLECBLE_LIBRARY_DIR');
  FTemporaryDirectory := IncludeTrailingPathDelimiter(GetTempDir(False)) +
    'simpleble-loader-tests-' + IntToHex(GetTickCount64, 16);
  AssertTrue('Could not create temporary loader test directory',
    ForceDirectories(FTemporaryDirectory));
end;

procedure TSimpleBleNativeLoaderTests.TearDown;
begin
  SimpleBleUnloadLibrary;
  DeleteFile(IncludeTrailingPathDelimiter(FTemporaryDirectory) +
    SimpleBleExtLibrary);
  DeleteFile(IncludeTrailingPathDelimiter(FTemporaryDirectory) +
    SimpleBleCoreLibrary);
  RemoveDir(FTemporaryDirectory);
  inherited TearDown;
end;

procedure TSimpleBleNativeLoaderTests.LoadsSimpleCbleVersionOnePointTwo;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));
  AssertTrue('simpleble_get_version was not resolved',
    Assigned(SimpleBleGetVersion));
  AssertTrue('SimpleCBLE 1.2 adapter API was not resolved',
    Assigned(SimpleBleAdapterGetConnectedPeripheralsCount));
  AssertTrue('SimpleCBLE 1.2 config API was not resolved',
    Assigned(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs));
  AssertTrue('SimpleCBLE 1.2 Dongl config API was not resolved',
    Assigned(SimpleBleConfigDonglGetUseDonglBackend));
  AssertTrue('SimpleCBLE 1.2 logging API was not resolved',
    Assigned(SimpleBleLoggingGetLevel));
  AssertEquals('Unexpected SimpleCBLE version', '1.2.0',
    string(SimpleBleGetVersion()));
end;

procedure TSimpleBleNativeLoaderTests.RejectsMissingDirectoryWithDiagnostic;
var
  MissingDirectory: string;
begin
  MissingDirectory := IncludeTrailingPathDelimiter(FLibraryDirectory) +
    'directory-that-does-not-exist';
  AssertFalse('Loading from a missing directory must fail',
    SimpleBleLoadLibrary(MissingDirectory));
  AssertTrue('Loader failure must provide a diagnostic',
    SimpleBleGetLastLoadError <> '');
end;

procedure TSimpleBleNativeLoaderTests.RejectsDirectoryWithoutNativeLibraries;
begin
  AssertFalse('An empty directory must not load as SimpleCBLE',
    SimpleBleLoadLibrary(FTemporaryDirectory));
  AssertTrue('The missing core library must be named in the diagnostic',
    Pos(SimpleBleCoreLibrary, SimpleBleGetLastLoadError) > 0);
  AssertApiCleared;
end;

procedure TSimpleBleNativeLoaderTests.RejectsDirectoryWithoutSimpleCbleLibrary;
begin
  CreateEmptyTemporaryFile(SimpleBleCoreLibrary);

  AssertFalse('A directory without SimpleCBLE must be rejected',
    SimpleBleLoadLibrary(FTemporaryDirectory));
  AssertTrue('The missing SimpleCBLE library must be named in the diagnostic',
    Pos(SimpleBleExtLibrary, SimpleBleGetLastLoadError) > 0);
  AssertApiCleared;
end;

procedure TSimpleBleNativeLoaderTests.RejectsLibraryWithMissingRequiredSymbols;
begin
  CopyFixtureToTemporaryDirectory(GetEnvironmentVariable(
    'SIMPLECBLE_FIXTURE_LIBRARY'));

  AssertFalse('A loadable library without SimpleCBLE symbols must be rejected',
    SimpleBleLoadLibrary(FTemporaryDirectory));
  AssertTrue('The first missing ABI symbol must be named',
    Pos('simpleble_adapter_is_bluetooth_enabled',
      SimpleBleGetLastLoadError) > 0);
  AssertApiCleared;
end;

procedure TSimpleBleNativeLoaderTests.RejectsSimpleCbleVersionOnePointOne;
begin
  CopyFixtureToTemporaryDirectory(GetEnvironmentVariable(
    'SIMPLECBLE_OLD_FIXTURE_LIBRARY'));
  AssertFalse('SimpleCBLE 1.1.0 must be rejected before ABI calls',
    SimpleBleLoadLibrary(FTemporaryDirectory));
  AssertTrue('Version mismatch must be reported',
    Pos('1.1.0', SimpleBleGetLastLoadError) > 0);
  AssertApiCleared;
end;

procedure TSimpleBleNativeLoaderTests.FailedReloadClearsResolvedApi;
var
  MissingDirectory: string;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));
  AssertTrue(Assigned(SimpleBleGetVersion));
  MissingDirectory := IncludeTrailingPathDelimiter(FTemporaryDirectory) +
    'missing';

  AssertFalse(SimpleBleLoadLibrary(MissingDirectory));

  AssertApiCleared;
end;

procedure TSimpleBleNativeLoaderTests.ReloadSucceedsAfterFailure;
begin
  CopyFixtureToTemporaryDirectory(GetEnvironmentVariable(
    'SIMPLECBLE_OLD_FIXTURE_LIBRARY'));
  AssertFalse(SimpleBleLoadLibrary(FTemporaryDirectory));
  AssertApiCleared;
  AssertTrue('A compatible reload must succeed after rejection',
    SimpleBleLoadLibrary(FLibraryDirectory));
  AssertTrue(Assigned(SimpleBlePeripheralServicesGet));
  AssertEquals('1.2.0', string(SimpleBleGetVersion()));
end;

procedure TSimpleBleNativeLoaderTests.FreeAcceptsNil;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));
  SimpleBleFree(nil);
end;

procedure TSimpleBleNativeLoaderTests.NativeInvalidArgumentErrorLifecycle;
var
  Error: TSimpleBleError;
  Info: TSimpleBleErrorInfo;
  Service: TSimpleBleService;
begin
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));
  Error := nil;
  Service := Default(TSimpleBleService);
  SimpleBlePeripheralServicesGet(nil, 0, Service, Error);
  try
    AssertTrue('A null peripheral must return a native error', Error <> nil);
    Info := SimpleBleTakeErrorInfo(Error);
    AssertTrue(Info.HasError);
    AssertEquals(Ord(SIMPLEBLE_ERROR_INVALID_ARGUMENT), Ord(Info.Code));
    AssertTrue('Native error message must be copied', Info.Message <> '');
    AssertTrue('Error release must clear the handle', Error = nil);
  finally
    SimpleBleServiceRelease(Service);
    if Error <> nil then
      SimpleBleErrorRelease(Error);
  end;
end;

procedure TSimpleBleNativeLoaderTests.UnloadClearsResolvedApi;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));

  SimpleBleUnloadLibrary;

  AssertApiCleared;
end;

initialization
  RegisterTest(TSimpleBleNativeLoaderTests);

end.
