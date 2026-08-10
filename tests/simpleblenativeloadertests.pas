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
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure LoadsSimpleCBleVersionOne;
    procedure RejectsMissingDirectoryWithDiagnostic;
    procedure RejectsDirectoryWithoutNativeLibraries;
    procedure RejectsDirectoryWithoutSimpleCbleLibrary;
    procedure RejectsLibraryWithMissingRequiredSymbols;
    procedure FailedReloadClearsResolvedApi;
    procedure FreeAcceptsNil;
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

procedure TSimpleBleNativeLoaderTests.LoadsSimpleCBleVersionOne;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));
  AssertTrue('simpleble_get_version was not resolved',
    Assigned(SimpleBleGetVersion));
  AssertTrue('SimpleCBLE 1.0 adapter API was not resolved',
    Assigned(SimpleBleAdapterGetConnectedPeripheralsCount));
  AssertTrue('SimpleCBLE 1.0 config API was not resolved',
    Assigned(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs));
  AssertTrue('SimpleCBLE 1.0 logging API was not resolved',
    Assigned(SimpleBleLoggingGetLevel));
  AssertEquals('Unexpected SimpleCBLE version', '1.0.0',
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
  AssertFalse('Failed loading must leave API pointers cleared',
    Assigned(SimpleBleGetVersion));
end;

procedure TSimpleBleNativeLoaderTests.RejectsDirectoryWithoutSimpleCbleLibrary;
begin
  CreateEmptyTemporaryFile(SimpleBleCoreLibrary);

  AssertFalse('A directory without SimpleCBLE must be rejected',
    SimpleBleLoadLibrary(FTemporaryDirectory));
  AssertTrue('The missing SimpleCBLE library must be named in the diagnostic',
    Pos(SimpleBleExtLibrary, SimpleBleGetLastLoadError) > 0);
  AssertFalse('Failed loading must leave API pointers cleared',
    Assigned(SimpleBleGetVersion));
end;

procedure TSimpleBleNativeLoaderTests.RejectsLibraryWithMissingRequiredSymbols;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  CopyFileToTemporaryDirectory(IncludeTrailingPathDelimiter(
    FLibraryDirectory) + SimpleBleCoreLibrary, SimpleBleCoreLibrary);
  CopyFileToTemporaryDirectory(IncludeTrailingPathDelimiter(
    FLibraryDirectory) + SimpleBleCoreLibrary, SimpleBleExtLibrary);

  AssertFalse('A loadable library without SimpleCBLE symbols must be rejected',
    SimpleBleLoadLibrary(FTemporaryDirectory));
  AssertTrue('Missing required symbols must be reported',
    Pos('required symbols', SimpleBleGetLastLoadError) > 0);
  AssertFalse('Rejected libraries must leave API pointers cleared',
    Assigned(SimpleBleGetVersion));
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

  AssertFalse('A failed reload must clear the previously resolved API',
    Assigned(SimpleBleGetVersion));
  AssertFalse('A failed reload must clear adapter API pointers',
    Assigned(SimpleBleAdapterGetCount));
end;

procedure TSimpleBleNativeLoaderTests.FreeAcceptsNil;
begin
  AssertTrue('SIMPLECBLE_LIBRARY_DIR must point to the native libraries',
    FLibraryDirectory <> '');
  AssertTrue('SimpleCBLE could not be loaded from ' + FLibraryDirectory,
    SimpleBleLoadLibrary(FLibraryDirectory));
  SimpleBleFree(nil);
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
