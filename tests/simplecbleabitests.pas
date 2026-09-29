unit SimpleCbleAbiTests;

{$mode ObjFPC}{$H+}

interface

uses
  FPCUnit,
  TestRegistry;

type
  TSimpleCbleAbiTests = class(TTestCase)
  published
    procedure RecordLayoutsMatchCAbi;
    procedure EnumsMatchCAbi;
    procedure CallbackDeclarationsMatchCAbi;
  end;

implementation

uses
  SimpleBle;

procedure ScanCallback(AAdapter: TSimpleBleAdapter;
  APeripheral: TSimpleBlePeripheral; AUserData: Pointer); cdecl;
begin
end;

procedure DataCallback(APeripheral: TSimpleBlePeripheral;
  AService: TSimpleBleUuid; ACharacteristic: TSimpleBleUuid; AData: PByte;
  ADataLength: NativeUInt; AUserData: Pointer); cdecl;
begin
end;

procedure LogCallback(ALevel: TSimpleBleLogLevel; AModule: PChar;
  AFile: PChar; ALine: DWord; AFunction: PChar; AMessage: PChar); cdecl;
begin
end;

procedure ScanStateCallback(AAdapter: TSimpleBleAdapter;
  AUserData: Pointer); cdecl;
begin
end;

procedure ConnectedCallback(APeripheral: TSimpleBlePeripheral;
  AUserData: Pointer); cdecl;
begin
end;

procedure LocalClientCallback(AHandle: TSimpleBleLocalPeripheral;
  AAddress: PChar; AUserData: Pointer); cdecl;
begin
end;

function LocalReadCallback(AHandle: TSimpleBleLocalCharacteristic;
  var ADataLength: NativeUInt; AUserData: Pointer): PByte; cdecl;
begin
  ADataLength := 0;
  Result := nil;
end;

procedure LocalWriteCallback(AHandle: TSimpleBleLocalCharacteristic;
  AData: PByte; ADataLength: NativeUInt; AUserData: Pointer); cdecl;
begin
end;

procedure LocalCharacteristicCallback(AHandle: TSimpleBleLocalCharacteristic;
  AUserData: Pointer); cdecl;
begin
end;

function PasskeyCallback(AHandle: TSimpleBlePeripheral; APasskey: PChar;
  AUserData: Pointer): Boolean; cdecl;
begin
  Result := True;
end;

procedure PasskeyDisplayCallback(AHandle: TSimpleBlePeripheral;
  APasskey: PChar; AUserData: Pointer); cdecl;
begin
end;

procedure TSimpleCbleAbiTests.RecordLayoutsMatchCAbi;
var
  Characteristic: TSimpleBleCharacteristic;
  Service: TSimpleBleService;
  ManufacturerData: TSimpleBleManufacturerData;
begin
  AssertEquals('simpleble_err_t', 4, SizeOf(TSimpleBleErr));
  AssertEquals('simpleble_os_t', 4, SizeOf(TSimpleBleOs));
  AssertEquals('simpleble_address_type_t', 4, SizeOf(TSimpleBleAddressType));
  AssertEquals('C bool', 1, SizeOf(Boolean));
  AssertEquals('simpleble_adapter_t', SizeOf(Pointer),
    SizeOf(TSimpleBleAdapter));
  AssertEquals('simpleble_peripheral_t', SizeOf(Pointer),
    SizeOf(TSimpleBlePeripheral));
  AssertEquals('simpleble_uuid_t', 37, SizeOf(TSimpleBleUuid));
  AssertEquals('simpleble_descriptor_t', 37, SizeOf(TSimpleBleDescriptor));

  {$IFDEF CPU64}
    AssertEquals('simpleble_characteristic_t', 64,
      SizeOf(TSimpleBleCharacteristic));
    AssertEquals('characteristic.descriptor_count', 48,
      PtrUInt(@Characteristic.DescriptorCount) - PtrUInt(@Characteristic));
    AssertEquals('characteristic.descriptors', 56,
      PtrUInt(@Characteristic.Descriptors) - PtrUInt(@Characteristic));
    AssertEquals('simpleble_service_t', 72, SizeOf(TSimpleBleService));
    AssertEquals('service.data_length', 40,
      PtrUInt(@Service.DataLength) - PtrUInt(@Service));
    AssertEquals('service.data', 48, PtrUInt(@Service.Data) - PtrUInt(@Service));
    AssertEquals('service.characteristic_count', 56,
      PtrUInt(@Service.CharacteristicCount) - PtrUInt(@Service));
    AssertEquals('service.characteristics', 64,
      PtrUInt(@Service.Characteristics) - PtrUInt(@Service));
    AssertEquals('simpleble_manufacturer_data_t', 24,
      SizeOf(TSimpleBleManufacturerData));
    AssertEquals('manufacturer_data.data_length', 8,
      PtrUInt(@ManufacturerData.DataLength) - PtrUInt(@ManufacturerData));
    AssertEquals('manufacturer_data.data', 16,
      PtrUInt(@ManufacturerData.Data) - PtrUInt(@ManufacturerData));
  {$ELSE}
    AssertEquals('simpleble_characteristic_t', 52,
      SizeOf(TSimpleBleCharacteristic));
    AssertEquals('characteristic.descriptor_count', 44,
      PtrUInt(@Characteristic.DescriptorCount) - PtrUInt(@Characteristic));
    AssertEquals('characteristic.descriptors', 48,
      PtrUInt(@Characteristic.Descriptors) - PtrUInt(@Characteristic));
    AssertEquals('simpleble_service_t', 56, SizeOf(TSimpleBleService));
    AssertEquals('service.data_length', 40,
      PtrUInt(@Service.DataLength) - PtrUInt(@Service));
    AssertEquals('service.data', 44, PtrUInt(@Service.Data) - PtrUInt(@Service));
    AssertEquals('service.characteristic_count', 48,
      PtrUInt(@Service.CharacteristicCount) - PtrUInt(@Service));
    AssertEquals('service.characteristics', 52,
      PtrUInt(@Service.Characteristics) - PtrUInt(@Service));
    AssertEquals('simpleble_manufacturer_data_t', 12,
      SizeOf(TSimpleBleManufacturerData));
    AssertEquals('manufacturer_data.data_length', 4,
      PtrUInt(@ManufacturerData.DataLength) - PtrUInt(@ManufacturerData));
    AssertEquals('manufacturer_data.data', 8,
      PtrUInt(@ManufacturerData.Data) - PtrUInt(@ManufacturerData));
  {$ENDIF}
end;

procedure TSimpleCbleAbiTests.EnumsMatchCAbi;
begin
  AssertEquals('SIMPLEBLE_ERROR_INVALID_ARGUMENT', 0,
    Ord(SIMPLEBLE_ERROR_INVALID_ARGUMENT));
  AssertEquals('SIMPLEBLE_ERROR_UNCLASSIFIED_EXCEPTION', 13,
    Ord(SIMPLEBLE_ERROR_UNCLASSIFIED_EXCEPTION));
  AssertEquals('SIMPLEBLE_LOCAL_CHARACTERISTIC_READ', 1,
    SIMPLEBLE_LOCAL_CHARACTERISTIC_READ);
  AssertEquals('SIMPLEBLE_LOCAL_CHARACTERISTIC_INDICATE', 16,
    SIMPLEBLE_LOCAL_CHARACTERISTIC_INDICATE);
  AssertEquals('simpleble_log_level_t', 4, SizeOf(TSimpleBleLogLevel));
  AssertEquals('SIMPLEBLE_LOG_LEVEL_VERBOSE', 6,
    Ord(SIMPLEBLE_LOG_LEVEL_VERBOSE));
  AssertEquals('SIMPLEBLE_OS_IOS', 3, Ord(SIMPLEBLE_OS_IOS));
  AssertEquals('SIMPLEBLE_OS_ANDROID', 4, Ord(SIMPLEBLE_OS_ANDROID));
  AssertEquals('SIMPLEBLE_OS_UNKNOWN', 5, Ord(SIMPLEBLE_OS_UNKNOWN));
  AssertEquals('Android priority ABI', 4,
    SizeOf(TSimpleBleConfigAndroidConnectionPriority));
  AssertEquals('Android disabled priority', -1,
    SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DISABLED);
  AssertEquals('Android DCK priority', 3,
    SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DCK);
end;

procedure TSimpleCbleAbiTests.CallbackDeclarationsMatchCAbi;
var
  Scan: TSimpleBleCallbackScanFound;
  ScanUpdated: TSimpleBleCallbackScanUpdated;
  ScanStart: TSimpleBleCallbackScanStart;
  ScanStop: TSimpleBleCallbackScanStop;
  Connected: TSimpleBleCallbackOnConnected;
  Disconnected: TSimpleBleCallbackOnDisconnected;
  Notify: TSimpleBleCallbackNotify;
  Indicate: TSimpleBleCallbackIndicate;
  Log: TCallbackLog;
  LocalClient: TSimpleBleLocalClientCallback;
  LocalRead: TSimpleBleLocalReadCallback;
  LocalWrite: TSimpleBleLocalWriteCallback;
  LocalCharacteristic: TSimpleBleLocalCharacteristicCallback;
  PasskeyRequest: TSimpleBlePasskeyRequestCallback;
  PasskeyDisplay: TSimpleBlePasskeyDisplayCallback;
  NumericComparison: TSimpleBleNumericComparisonCallback;
begin
  Scan := @ScanCallback;
  ScanUpdated := @ScanCallback;
  ScanStart := @ScanStateCallback;
  ScanStop := @ScanStateCallback;
  Connected := @ConnectedCallback;
  Disconnected := @ConnectedCallback;
  Notify := @DataCallback;
  Indicate := @DataCallback;
  Log := @LogCallback;
  LocalClient := @LocalClientCallback;
  LocalRead := @LocalReadCallback;
  LocalWrite := @LocalWriteCallback;
  LocalCharacteristic := @LocalCharacteristicCallback;
  PasskeyRequest := @PasskeyCallback;
  PasskeyDisplay := @PasskeyDisplayCallback;
  NumericComparison := @PasskeyCallback;
  AssertTrue(Assigned(Scan));
  AssertTrue(Assigned(ScanUpdated));
  AssertTrue(Assigned(ScanStart));
  AssertTrue(Assigned(ScanStop));
  AssertTrue(Assigned(Connected));
  AssertTrue(Assigned(Disconnected));
  AssertTrue(Assigned(Notify));
  AssertTrue(Assigned(Indicate));
  AssertTrue(Assigned(Log));
  AssertTrue(Assigned(LocalClient));
  AssertTrue(Assigned(LocalRead));
  AssertTrue(Assigned(LocalWrite));
  AssertTrue(Assigned(LocalCharacteristic));
  AssertTrue(Assigned(PasskeyRequest));
  AssertTrue(Assigned(PasskeyDisplay));
  AssertTrue(Assigned(NumericComparison));
end;

initialization
  RegisterTest(TSimpleCbleAbiTests);

end.
