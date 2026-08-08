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
    AssertEquals('simpleble_characteristic_t', 648,
      SizeOf(TSimpleBleCharacteristic));
    AssertEquals('characteristic.descriptor_count', 48,
      PtrUInt(@Characteristic.DescriptorCount) - PtrUInt(@Characteristic));
    AssertEquals('characteristic.descriptors', 56,
      PtrUInt(@Characteristic.Descriptors) - PtrUInt(@Characteristic));
    AssertEquals('simpleble_service_t', 10456, SizeOf(TSimpleBleService));
    AssertEquals('service.data_length', 40,
      PtrUInt(@Service.DataLength) - PtrUInt(@Service));
    AssertEquals('service.data', 48, PtrUInt(@Service.Data) - PtrUInt(@Service));
    AssertEquals('service.characteristic_count', 80,
      PtrUInt(@Service.CharacteristicCount) - PtrUInt(@Service));
    AssertEquals('service.characteristics', 88,
      PtrUInt(@Service.Characteristics) - PtrUInt(@Service));
    AssertEquals('simpleble_manufacturer_data_t', 48,
      SizeOf(TSimpleBleManufacturerData));
    AssertEquals('manufacturer_data.data_length', 8,
      PtrUInt(@ManufacturerData.DataLength) - PtrUInt(@ManufacturerData));
    AssertEquals('manufacturer_data.data', 16,
      PtrUInt(@ManufacturerData.Data) - PtrUInt(@ManufacturerData));
  {$ELSE}
    AssertEquals('simpleble_characteristic_t', 640,
      SizeOf(TSimpleBleCharacteristic));
    AssertEquals('characteristic.descriptor_count', 44,
      PtrUInt(@Characteristic.DescriptorCount) - PtrUInt(@Characteristic));
    AssertEquals('characteristic.descriptors', 48,
      PtrUInt(@Characteristic.Descriptors) - PtrUInt(@Characteristic));
    AssertEquals('simpleble_service_t', 10316, SizeOf(TSimpleBleService));
    AssertEquals('service.data_length', 40,
      PtrUInt(@Service.DataLength) - PtrUInt(@Service));
    AssertEquals('service.data', 44, PtrUInt(@Service.Data) - PtrUInt(@Service));
    AssertEquals('service.characteristic_count', 72,
      PtrUInt(@Service.CharacteristicCount) - PtrUInt(@Service));
    AssertEquals('service.characteristics', 76,
      PtrUInt(@Service.Characteristics) - PtrUInt(@Service));
    AssertEquals('simpleble_manufacturer_data_t', 36,
      SizeOf(TSimpleBleManufacturerData));
    AssertEquals('manufacturer_data.data_length', 4,
      PtrUInt(@ManufacturerData.DataLength) - PtrUInt(@ManufacturerData));
    AssertEquals('manufacturer_data.data', 8,
      PtrUInt(@ManufacturerData.Data) - PtrUInt(@ManufacturerData));
  {$ENDIF}
end;

procedure TSimpleCbleAbiTests.EnumsMatchCAbi;
begin
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
  Notify: TSimpleBleCallbackNotify;
  Log: TCallbackLog;
begin
  Scan := @ScanCallback;
  Notify := @DataCallback;
  Log := @LogCallback;
  AssertTrue(Assigned(Scan));
  AssertTrue(Assigned(Notify));
  AssertTrue(Assigned(Log));
end;

initialization
  RegisterTest(TSimpleCbleAbiTests);

end.
