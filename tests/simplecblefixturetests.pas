unit SimpleCbleFixtureTests;

{$mode ObjFPC}{$H+}

interface

uses
  FPCUnit, TestRegistry, DynLibs;

type
  TSimpleCbleFixtureTests = class(TTestCase)
  private
    FFixtureHandle: TLibHandle;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CopiesAndReleasesAllocatedGattRecords;
    procedure ReleasesPartialGattRecordOnError;
    procedure HandlesEmptyReadAndErrorLifetime;
    procedure InvokesCallbacksThroughCAbi;
  end;

implementation

uses
  SysUtils, SimpleBle;

type
  TFixtureReleaseCount = function(Kind: Cardinal): NativeUInt; cdecl;
  TFixtureResetCounts = procedure; cdecl;
  TFixtureInvokeCallbacks = function(Scan: TSimpleBleCallbackScanFound;
    Notify: TSimpleBleCallbackNotify; ReadValue: TSimpleBleLocalReadCallback;
    Passkey: TSimpleBlePasskeyRequestCallback; Log: TCallbackLog;
    UserData: Pointer): Boolean; cdecl;

var
  FixtureReleaseCount: TFixtureReleaseCount;
  FixtureResetCounts: TFixtureResetCounts;
  FixtureInvokeCallbacks: TFixtureInvokeCallbacks;
  ScanSeen: Boolean;
  NotifySeen: Boolean;
  ReadSeen: Boolean;
  PasskeySeen: Boolean;
  LogSeen: Boolean;
  CallbackBytes: array[0..1] of Byte = ($21, $22);

procedure ScanCallback(Adapter: TSimpleBleAdapter;
  Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;
begin
  ScanSeen := (PtrUInt(Adapter) = $12) and
    (PtrUInt(Peripheral) = $34) and (PtrUInt(UserData) = $78);
end;

procedure NotifyCallback(Peripheral: TSimpleBlePeripheral;
  Service, Characteristic: TSimpleBleUuid; Data: PByte;
  DataLength: NativeUInt; UserData: Pointer); cdecl;
begin
  NotifySeen := (PtrUInt(Peripheral) = $34) and
    (Service.Value[0] = 's') and (Characteristic.Value[0] = 'c') and
    (DataLength = 2) and (Data[0] = $21) and (Data[1] = $22) and
    (PtrUInt(UserData) = $78);
end;

function ReadCallback(Handle: TSimpleBleLocalCharacteristic;
  var DataLength: NativeUInt; UserData: Pointer): PByte; cdecl;
begin
  ReadSeen := (PtrUInt(Handle) = $56) and (PtrUInt(UserData) = $78);
  DataLength := 2;
  Result := @CallbackBytes[0];
end;

function PasskeyCallback(Handle: TSimpleBlePeripheral; Passkey: PChar;
  UserData: Pointer): Boolean; cdecl;
begin
  PasskeySeen := (PtrUInt(Handle) = $34) and
    (string(Passkey) = '123456') and (PtrUInt(UserData) = $78);
  Result := PasskeySeen;
end;

procedure LogCallback(Level: TSimpleBleLogLevel; Module, LFile: PChar;
  Line: DWord; LFunction, LMessage: PChar); cdecl;
begin
  LogSeen := (Level = SIMPLEBLE_LOG_LEVEL_INFO) and
    (string(Module) = 'fixture') and (string(LFile) = 'fixture.c') and
    (Line = 17) and (string(LFunction) = 'invoke') and
    (string(LMessage) = 'callback');
end;

procedure TSimpleCbleFixtureTests.SetUp;
var
  FixturePath: string;
begin
  inherited SetUp;
  FixturePath := GetEnvironmentVariable('SIMPLECBLE_FIXTURE_LIBRARY');
  AssertTrue('SIMPLECBLE_FIXTURE_LIBRARY must point to the test library',
    FileExists(FixturePath));
  FFixtureHandle := LoadLibrary(PChar(FixturePath));
  AssertTrue('Could not load fixture library: ' + FixturePath,
    FFixtureHandle <> 0);
  Pointer(SimpleBlePeripheralServicesGet) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_peripheral_services_get');
  Pointer(SimpleBleServiceRelease) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_service_release');
  Pointer(SimpleBlePeripheralManufacturerDataGet) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_peripheral_manufacturer_data_get');
  Pointer(SimpleBleManufacturerDataRelease) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_manufacturer_data_release');
  Pointer(SimpleBlePeripheralRead) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_peripheral_read');
  Pointer(SimpleBleFree) := GetProcedureAddress(FFixtureHandle, 'simpleble_free');
  Pointer(SimpleBleErrorCode) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_error_code');
  Pointer(SimpleBleErrorMessage) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_error_message');
  Pointer(SimpleBleErrorRelease) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_error_release');
  Pointer(FixtureReleaseCount) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_fixture_release_count');
  Pointer(FixtureResetCounts) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_fixture_reset_counts');
  Pointer(FixtureInvokeCallbacks) :=
    GetProcedureAddress(FFixtureHandle, 'simpleble_fixture_invoke_callbacks');
  AssertTrue('Fixture is missing required exports',
    Assigned(SimpleBlePeripheralServicesGet) and
    Assigned(SimpleBleServiceRelease) and
    Assigned(SimpleBlePeripheralManufacturerDataGet) and
    Assigned(SimpleBleManufacturerDataRelease) and
    Assigned(SimpleBlePeripheralRead) and Assigned(SimpleBleFree) and
    Assigned(SimpleBleErrorCode) and Assigned(SimpleBleErrorMessage) and
    Assigned(SimpleBleErrorRelease) and Assigned(FixtureReleaseCount) and
    Assigned(FixtureResetCounts) and Assigned(FixtureInvokeCallbacks));
  FixtureResetCounts();
end;

procedure TSimpleCbleFixtureTests.TearDown;
begin
  SimpleBleUnloadLibrary;
  if FFixtureHandle <> 0 then
    UnloadLibrary(FFixtureHandle);
  inherited TearDown;
end;

procedure TSimpleCbleFixtureTests.CopiesAndReleasesAllocatedGattRecords;
var
  Error: TSimpleBleError;
  Service: TSimpleBleOwnedService;
  Manufacturer: TSimpleBleOwnedManufacturerData;
begin
  Error := nil;
  Service := SimpleBleGetService(nil, 0, Error);
  AssertTrue(Error = nil);
  AssertEquals('s', Service.Uuid.Value[0]);
  AssertEquals(2, Length(Service.Data));
  AssertEquals($42, Service.Data[0]);
  AssertEquals(1, Length(Service.Characteristics));
  AssertTrue(Service.Characteristics[0].CanNotify);
  AssertEquals('d', Service.Characteristics[0].Descriptors[0].Value[0]);
  AssertEquals(1, FixtureReleaseCount(0));

  Manufacturer := SimpleBleGetManufacturerData(nil, 0, Error);
  AssertTrue(Error = nil);
  AssertEquals($1234, Manufacturer.ManufacturerId);
  AssertEquals(2, Length(Manufacturer.Data));
  AssertEquals($51, Manufacturer.Data[0]);
  AssertEquals(1, FixtureReleaseCount(1));
end;

procedure TSimpleCbleFixtureTests.ReleasesPartialGattRecordOnError;
var
  Error: TSimpleBleError;
  Info: TSimpleBleErrorInfo;
  Service: TSimpleBleOwnedService;
begin
  Error := nil;
  Service := SimpleBleGetService(nil, 1, Error);
  AssertEquals(0, Length(Service.Data));
  AssertTrue(Error <> nil);
  AssertEquals(1, FixtureReleaseCount(0));
  Info := SimpleBleTakeErrorInfo(Error);
  AssertTrue(Error = nil);
  AssertTrue(Info.HasError);
  AssertEquals(Ord(SIMPLEBLE_ERROR_OPERATION_FAILED), Ord(Info.Code));
  AssertEquals('fixture failure', Info.Message);
  AssertEquals(1, FixtureReleaseCount(3));
end;

procedure TSimpleCbleFixtureTests.HandlesEmptyReadAndErrorLifetime;
var
  Error: TSimpleBleError;
  ServiceUuid, CharacteristicUuid: TSimpleBleUuid;
  Bytes: TBytes;
  Info: TSimpleBleErrorInfo;
begin
  ServiceUuid := Default(TSimpleBleUuid);
  CharacteristicUuid := Default(TSimpleBleUuid);
  ServiceUuid.Value[0] := 's';
  CharacteristicUuid.Value[0] := 'c';
  Error := nil;
  Bytes := SimpleBleReadValue(nil, ServiceUuid, CharacteristicUuid, Error);
  AssertEquals(0, Length(Bytes));
  AssertTrue(Error = nil);
  AssertEquals(1, FixtureReleaseCount(2));

  CharacteristicUuid.Value[0] := 'x';
  Bytes := SimpleBleReadValue(nil, ServiceUuid, CharacteristicUuid, Error);
  AssertEquals(0, Length(Bytes));
  AssertTrue(Error <> nil);
  Info := SimpleBleTakeErrorInfo(Error);
  AssertEquals('fixture failure', Info.Message);
  AssertTrue(Error = nil);
  AssertEquals(1, FixtureReleaseCount(3));
end;

procedure TSimpleCbleFixtureTests.InvokesCallbacksThroughCAbi;
begin
  ScanSeen := False;
  NotifySeen := False;
  ReadSeen := False;
  PasskeySeen := False;
  LogSeen := False;
  AssertTrue(FixtureInvokeCallbacks(@ScanCallback, @NotifyCallback,
    @ReadCallback, @PasskeyCallback, @LogCallback, Pointer($78)));
  AssertTrue(ScanSeen);
  AssertTrue(NotifySeen);
  AssertTrue(ReadSeen);
  AssertTrue(PasskeySeen);
  AssertTrue(LogSeen);
end;

initialization
  RegisterTest(TSimpleCbleFixtureTests);

end.
