unit SimpleBle;

{$mode ObjFPC}{$H+}
{$macro on}

{ Lazarus / Free Pascal bindings for the cross-platform SimpleBLE library.

  Original Pascal bindings are Copyright (c) 2022-2023 Erik Lins.
    https://github.com/eriklins/Pascal-Bindings-For-SimpleBLE-Library

  Modifications are Copyright (c) 2026 Andrey Syutkin.
    https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library

  The Pascal bindings and modifications are released under the MIT License.

  The native SimpleBLE library has its own BUSL-1.1/commercial licensing terms.
    https://github.com/simpleble/simpleble
}

{$IFNDEF SIMPLEBLE_STATIC}
  {$DEFINE DYNAMIC_LOADING}
{$ENDIF}


interface

uses
  {$IFDEF DYNAMIC_LOADING}
  Classes, SysUtils, DynLibs;
  {$ELSE}
  Classes, SysUtils;
  {$ENDIF}

const
  {$IFDEF WINDOWS}
    SimpleBleExtLibrary = 'simplecble.dll';
    SimpleBleCoreLibrary = 'simpleble.dll';
  {$ELSE}
    {$IFDEF DARWIN}
      SimpleBleExtLibrary = 'libsimplecble.dylib';
      SimpleBleCoreLibrary = 'libsimpleble.dylib';
    {$ELSE}
      SimpleBleExtLibrary = 'libsimplecble.so';
      SimpleBleCoreLibrary = 'libsimpleble.so';
    {$ENDIF}
  {$ENDIF}

{$PACKRECORDS C}
{$PACKENUM 4}

const
  SIMPLEBLE_UUID_STR_LEN = 37;
  SIMPLEBLE_LOCAL_CHARACTERISTIC_READ = 1 shl 0;
  SIMPLEBLE_LOCAL_CHARACTERISTIC_WRITE_REQUEST = 1 shl 1;
  SIMPLEBLE_LOCAL_CHARACTERISTIC_WRITE_COMMAND = 1 shl 2;
  SIMPLEBLE_LOCAL_CHARACTERISTIC_NOTIFY = 1 shl 3;
  SIMPLEBLE_LOCAL_CHARACTERISTIC_INDICATE = 1 shl 4;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DISABLED = -1;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_BALANCED = 0;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_HIGH = 1;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_LOW_POWER = 2;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DCK = 3;

type
  TSimpleBleError = Pointer; // opaque simpleble_error_t*
  TSimpleBleErr = (
    SIMPLEBLE_ERROR_INVALID_ARGUMENT = 0,
    SIMPLEBLE_ERROR_OUT_OF_MEMORY = 1,
    SIMPLEBLE_ERROR_OBJECT_NOT_INITIALIZED = 2,
    SIMPLEBLE_ERROR_INVALID_BACKEND_REFERENCE = 3,
    SIMPLEBLE_ERROR_PERIPHERAL_NOT_CONNECTED = 4,
    SIMPLEBLE_ERROR_GATT_SERVICE_NOT_FOUND = 5,
    SIMPLEBLE_ERROR_GATT_CHARACTERISTIC_NOT_FOUND = 6,
    SIMPLEBLE_ERROR_GATT_DESCRIPTOR_NOT_FOUND = 7,
    SIMPLEBLE_ERROR_OPERATION_NOT_SUPPORTED = 8,
    SIMPLEBLE_ERROR_OPERATION_FAILED = 9,
    SIMPLEBLE_ERROR_WINRT_ACCESS_DENIED = 10,
    SIMPLEBLE_ERROR_WINRT_EXCEPTION = 11,
    SIMPLEBLE_ERROR_CORE_BLUETOOTH_EXCEPTION = 12,
    SIMPLEBLE_ERROR_UNCLASSIFIED_EXCEPTION = 13
  );
  TSimpleBleUuid = record
    Value: array[0..SIMPLEBLE_UUID_STR_LEN - 1] of Char;
  end;
  PSimpleBleDescriptor = ^TSimpleBleDescriptor;
  TSimpleBleDescriptor = record
    Uuid: TSimpleBleUuid;
  end;
  PSimpleBleCharacteristic = ^TSimpleBleCharacteristic;
  TSimpleBleCharacteristic = record
    Uuid: TSimpleBleUuid;
    CanRead: Boolean;
    CanWriteRequest: Boolean;
    CanWriteCommand: Boolean;
    CanNotify: Boolean;
    CanIndicate: Boolean;
    DescriptorCount: NativeUInt;
    Descriptors: PSimpleBleDescriptor;
  end;
  TSimpleBleService = record
    Uuid: TSimpleBleUuid;
    DataLength: NativeUInt;
    Data: PByte;
    CharacteristicCount: NativeUInt;
    Characteristics: PSimpleBleCharacteristic;
  end;
  TSimpleBleManufacturerData = record
    ManufacturerId: UInt16;
    DataLength: NativeUInt;
    Data: PByte;
  end;
  TSimpleBleBackend = Pointer;
  TSimpleBleAdapter = Pointer;
  TSimpleBlePeripheral = Pointer;
  TSimpleBleLocalPeripheral = Pointer;
  TSimpleBleLocalService = Pointer;
  TSimpleBleLocalCharacteristic = Pointer;
  TSimpleBleOs = (SIMPLEBLE_OS_WINDOWS = 0, SIMPLEBLE_OS_MACOS = 1,
    SIMPLEBLE_OS_LINUX = 2, SIMPLEBLE_OS_IOS = 3,
    SIMPLEBLE_OS_ANDROID = 4, SIMPLEBLE_OS_UNKNOWN = 5);
  TSimpleBleAddressType = (SIMPLEBLE_ADDRESS_TYPE_PUBLIC = 0,
    SIMPLEBLE_ADDRESS_TYPE_RANDOM = 1, SIMPLEBLE_ADDRESS_TYPE_UNSPECIFIED = 2);
  TSimpleBleLocalCharacteristicCapabilities = type UInt32;
  TSimpleBleConfigAndroidConnectionPriority = type LongInt;
  TSimpleBleLogLevel = (SIMPLEBLE_LOG_LEVEL_NONE = 0,
    SIMPLEBLE_LOG_LEVEL_FATAL = 1, SIMPLEBLE_LOG_LEVEL_ERROR = 2,
    SIMPLEBLE_LOG_LEVEL_WARN = 3, SIMPLEBLE_LOG_LEVEL_INFO = 4,
    SIMPLEBLE_LOG_LEVEL_DEBUG = 5, SIMPLEBLE_LOG_LEVEL_VERBOSE = 6);

  TSimpleBleCallbackScanStart = procedure(Adapter: TSimpleBleAdapter; UserData: Pointer); cdecl;
  TSimpleBleCallbackScanStop = TSimpleBleCallbackScanStart;
  TSimpleBleCallbackScanFound = procedure(Adapter: TSimpleBleAdapter; Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;
  TSimpleBleCallbackScanUpdated = TSimpleBleCallbackScanFound;
  TSimpleBleCallbackOnConnected = procedure(Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;
  TSimpleBleCallbackOnDisconnected = TSimpleBleCallbackOnConnected;
  TSimpleBleCallbackNotify = procedure(Peripheral: TSimpleBlePeripheral; Service: TSimpleBleUuid;
    Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt; UserData: Pointer); cdecl;
  TSimpleBleCallbackIndicate = TSimpleBleCallbackNotify;
  TCallbackLog = procedure(Level: TSimpleBleLogLevel; Module: PChar;
    LFile: PChar; Line: DWord; LFunction: PChar; LMessage: PChar); cdecl;
  TSimpleBleLocalClientCallback = procedure(Handle: TSimpleBleLocalPeripheral; ClientAddress: PChar; UserData: Pointer); cdecl;
  TSimpleBleLocalReadCallback = function(Handle: TSimpleBleLocalCharacteristic; var DataLength: NativeUInt; UserData: Pointer): PByte; cdecl;
  TSimpleBleLocalWriteCallback = procedure(Handle: TSimpleBleLocalCharacteristic; Data: PByte; DataLength: NativeUInt; UserData: Pointer); cdecl;
  TSimpleBleLocalCharacteristicCallback = procedure(Handle: TSimpleBleLocalCharacteristic; UserData: Pointer); cdecl;
  TSimpleBlePasskeyRequestCallback = function(Handle: TSimpleBlePeripheral; Passkey: PChar; UserData: Pointer): Boolean; cdecl;
  TSimpleBlePasskeyDisplayCallback = procedure(Handle: TSimpleBlePeripheral; Passkey: PChar; UserData: Pointer); cdecl;
  TSimpleBleNumericComparisonCallback = function(Handle: TSimpleBlePeripheral; Passkey: PChar; UserData: Pointer): Boolean; cdecl;

procedure SimpleBlePinLibrary();

{$IFDEF DYNAMIC_LOADING}
function SimpleBleLoadLibrary(dllPath: string = ''): Boolean;
procedure SimpleBleUnloadLibrary();
function SimpleBleGetLastLoadError(): string;
{$ENDIF}

{$IFDEF DYNAMIC_LOADING}
var
  // adapter.h
  SimpleBleAdapterIsBluetoothEnabled: function(var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBleAdapterGetCount: function(var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleAdapterGetHandle: function(Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleAdapter; cdecl;
  SimpleBleAdapterReleaseHandle: procedure(Handle: TSimpleBleAdapter); cdecl;
  SimpleBleAdapterUnderlying: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): Pointer; cdecl;
  SimpleBleAdapterIdentifier: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): PChar; cdecl;
  SimpleBleAdapterAddress: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): PChar; cdecl;
  SimpleBleAdapterPowerOn: procedure(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl;
  SimpleBleAdapterPowerOff: procedure(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl;
  SimpleBleAdapterIsPowered: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBleAdapterSetCallbackOnPowerOn: procedure(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl;
  SimpleBleAdapterSetCallbackOnPowerOff: procedure(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl;
  SimpleBleAdapterScanStart: procedure(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl;
  SimpleBleAdapterScanStop: procedure(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl;
  SimpleBleAdapterScanIsActive: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBleAdapterScanFor: procedure(Handle: TSimpleBleAdapter; TimeoutMs: LongInt; var OutError: TSimpleBleError); cdecl;
  SimpleBleAdapterScanGetResultsCount: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleAdapterScanGetResultsHandle: function(Handle: TSimpleBleAdapter; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl;
  SimpleBleAdapterGetPairedPeripheralsCount: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleAdapterGetPairedPeripheralsHandle: function(Handle: TSimpleBleAdapter; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl;
  SimpleBleAdapterGetConnectedPeripheralsCount: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleAdapterGetConnectedPeripheralsHandle: function(Handle: TSimpleBleAdapter; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl;
  SimpleBleAdapterSetCallbackOnScanStart: procedure(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl;
  SimpleBleAdapterSetCallbackOnScanStop: procedure(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl;
  SimpleBleAdapterSetCallbackOnScanUpdated: procedure(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanFound; Userdata: Pointer); cdecl;
  SimpleBleAdapterSetCallbackOnScanFound: procedure(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanFound; Userdata: Pointer); cdecl;
  SimpleBleAdapterCreateLocalPeripheral: function(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): TSimpleBleLocalPeripheral; cdecl;

  // advanced.h
  SimpleBleAdvancedDonglSetPasskeyRequestCallback: procedure(Handle: TSimpleBlePeripheral; Callback: TSimpleBlePasskeyRequestCallback; Userdata: Pointer; var OutError: TSimpleBleError); cdecl;
  SimpleBleAdvancedDonglSetPasskeyDisplayCallback: procedure(Handle: TSimpleBlePeripheral; Callback: TSimpleBlePasskeyDisplayCallback; Userdata: Pointer; var OutError: TSimpleBleError); cdecl;
  SimpleBleAdvancedDonglSetNumericComparisonCallback: procedure(Handle: TSimpleBlePeripheral; Callback: TSimpleBleNumericComparisonCallback; Userdata: Pointer; var OutError: TSimpleBleError); cdecl;
  {$IFDEF LINUX}
  {$IFNDEF ANDROID}
  SimpleBleAdvancedLinuxSetAdvertisementLocalName: procedure(Handle: TSimpleBleLocalPeripheral; LocalName: PChar; var OutError: TSimpleBleError); cdecl;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
  SimpleBleAdvancedMacosSetAdvertisementLocalName: procedure(Handle: TSimpleBleLocalPeripheral; LocalName: PChar; var OutError: TSimpleBleError); cdecl;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
  SimpleBleAdvancedMacosRetrieveCachedPeripheral: function(Handle: TSimpleBleAdapter; Identifier: PChar; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
  SimpleBleAdvancedIosSetAdvertisementLocalName: procedure(Handle: TSimpleBleLocalPeripheral; LocalName: PChar; var OutError: TSimpleBleError); cdecl;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
  SimpleBleAdvancedIosRetrieveCachedPeripheral: function(Handle: TSimpleBleAdapter; Identifier: PChar; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF ANDROID}
  SimpleBleAdvancedAndroidGetJvm: function(var OutError: TSimpleBleError): Pointer; cdecl;
  {$ENDIF}
  {$IFDEF ANDROID}
  SimpleBleAdvancedAndroidSetJvm: procedure(Jvm: Pointer; var OutError: TSimpleBleError); cdecl;
  {$ENDIF}
  {$IFDEF ANDROID}
  SimpleBleAdvancedAndroidSetContext: procedure(Context: Pointer; var OutError: TSimpleBleError); cdecl;
  {$ENDIF}

  // backend.h
  SimpleBleBackendGetCount: function(var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleBackendGetHandle: function(Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleBackend; cdecl;
  SimpleBleBackendReleaseHandle: procedure(Handle: TSimpleBleBackend); cdecl;
  SimpleBleBackendIdentifier: function(Handle: TSimpleBleBackend; var OutError: TSimpleBleError): PChar; cdecl;
  SimpleBleBackendIsBluetoothEnabled: function(Handle: TSimpleBleBackend; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBleBackendGetAdaptersCount: function(Handle: TSimpleBleBackend; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleBackendGetAdaptersHandle: function(Handle: TSimpleBleBackend; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleAdapter; cdecl;

  // config.h
  SimpleBleConfigResetAll: procedure(); cdecl;
  SimpleBleConfigSimpleBluezReset: procedure(); cdecl;
  SimpleBleConfigSimpleBluezGetUseSystemBus: function(): Boolean; cdecl;
  SimpleBleConfigSimpleBluezSetUseSystemBus: procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigSimpleBluezGetConnectionTimeoutMs: function(): Int64; cdecl;
  SimpleBleConfigSimpleBluezSetConnectionTimeoutMs: procedure(TimeoutMs: Int64); cdecl;
  SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs: function(): Int64; cdecl;
  SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs: procedure(TimeoutMs: Int64); cdecl;
  SimpleBleConfigWinRtReset: procedure(); cdecl;
  SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment: function(): Boolean; cdecl;
  SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment: procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread: function(): Boolean; cdecl;
  SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread: procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigWinRtGetUseDeferredDisconnect: function(): Boolean; cdecl;
  SimpleBleConfigWinRtSetUseDeferredDisconnect: procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigCoreBluetoothReset: procedure(); cdecl;
  SimpleBleConfigAndroidReset: procedure(); cdecl;
  SimpleBleConfigAndroidGetConnectionPriority: function(): TSimpleBleConfigAndroidConnectionPriority; cdecl;
  SimpleBleConfigAndroidSetConnectionPriority: procedure(Priority: TSimpleBleConfigAndroidConnectionPriority); cdecl;
  SimpleBleConfigSetAndroidConnectionPriority: procedure(Priority: LongInt); cdecl;
  SimpleBleConfigDonglReset: procedure(); cdecl;
  SimpleBleConfigDonglGetUseDonglBackend: function(): Boolean; cdecl;
  SimpleBleConfigDonglSetUseDonglBackend: procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigDonglGetAutoUpdate: function(): Boolean; cdecl;
  SimpleBleConfigDonglSetAutoUpdate: procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigDonglGetForceUpdate: function(): Boolean; cdecl;
  SimpleBleConfigDonglSetForceUpdate: procedure(Enabled: Boolean); cdecl;

  // error.h
  SimpleBleErrorCode: function(Error: TSimpleBleError): TSimpleBleErr; cdecl;
  SimpleBleErrorMessage: function(Error: TSimpleBleError): PChar; cdecl;
  SimpleBleErrorRelease: procedure(var Error: TSimpleBleError); cdecl;

  // local characteristic.h
  SimpleBleLocalCharacteristicReleaseHandle: procedure(Handle: TSimpleBleLocalCharacteristic); cdecl;
  SimpleBleLocalCharacteristicUuid: procedure(Handle: TSimpleBleLocalCharacteristic; var OutUuid: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl;
  SimpleBleLocalCharacteristicCapabilities: function(Handle: TSimpleBleLocalCharacteristic; var OutError: TSimpleBleError): UInt32; cdecl;
  SimpleBleLocalCharacteristicValue: function(Handle: TSimpleBleLocalCharacteristic; var DataLength: NativeUInt; var OutError: TSimpleBleError): PByte; cdecl;
  SimpleBleLocalCharacteristicSetValue: procedure(Handle: TSimpleBleLocalCharacteristic; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl;
  SimpleBleLocalCharacteristicSetCallbackOnRead: procedure(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalReadCallback; Userdata: Pointer); cdecl;
  SimpleBleLocalCharacteristicSetCallbackOnWrite: procedure(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalWriteCallback; Userdata: Pointer); cdecl;
  SimpleBleLocalCharacteristicSetCallbackOnSubscribed: procedure(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalCharacteristicCallback; Userdata: Pointer); cdecl;
  SimpleBleLocalCharacteristicSetCallbackOnUnsubscribed: procedure(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalCharacteristicCallback; Userdata: Pointer); cdecl;

  // local peripheral.h
  SimpleBleLocalPeripheralReleaseHandle: procedure(Handle: TSimpleBleLocalPeripheral); cdecl;
  SimpleBleLocalPeripheralUnderlying: function(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): Pointer; cdecl;
  SimpleBleLocalPeripheralAddAdvertisedService: procedure(Handle: TSimpleBleLocalPeripheral; Service: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl;
  SimpleBleLocalPeripheralAddService: function(Handle: TSimpleBleLocalPeripheral; Uuid: TSimpleBleUuid; var OutError: TSimpleBleError): TSimpleBleLocalService; cdecl;
  SimpleBleLocalPeripheralServicesCount: function(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleLocalPeripheralServicesGet: function(Handle: TSimpleBleLocalPeripheral; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleLocalService; cdecl;
  SimpleBleLocalPeripheralRemoveAllServices: procedure(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError); cdecl;
  SimpleBleLocalPeripheralStart: procedure(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError); cdecl;
  SimpleBleLocalPeripheralStop: procedure(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError); cdecl;
  SimpleBleLocalPeripheralIsStarted: function(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBleLocalPeripheralIsAdvertising: function(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBleLocalPeripheralSetCallbackOnClientConnected: procedure(Handle: TSimpleBleLocalPeripheral; Callback: TSimpleBleLocalClientCallback; Userdata: Pointer); cdecl;
  SimpleBleLocalPeripheralSetCallbackOnClientDisconnected: procedure(Handle: TSimpleBleLocalPeripheral; Callback: TSimpleBleLocalClientCallback; Userdata: Pointer); cdecl;

  // local service.h
  SimpleBleLocalServiceReleaseHandle: procedure(Handle: TSimpleBleLocalService); cdecl;
  SimpleBleLocalServiceCharacteristicsCount: function(Handle: TSimpleBleLocalService; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBleLocalServiceCharacteristicsGet: function(Handle: TSimpleBleLocalService; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleLocalCharacteristic; cdecl;
  SimpleBleLocalServiceUuid: procedure(Handle: TSimpleBleLocalService; var OutUuid: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl;
  SimpleBleLocalServiceAddCharacteristic: function(Handle: TSimpleBleLocalService; Uuid: TSimpleBleUuid; Capabilities: TSimpleBleLocalCharacteristicCapabilities; var OutError: TSimpleBleError): TSimpleBleLocalCharacteristic; cdecl;

  // logging.h
  SimpleBleLoggingSetLevel: procedure(Level: TSimpleBleLogLevel); cdecl;
  SimpleBleLoggingGetLevel: function(): TSimpleBleLogLevel; cdecl;
  SimpleBleLoggingSetCallback: procedure(Callback: TCallbackLog); cdecl;
  SimpleBleLoggingHasCallback: function(): Boolean; cdecl;
  SimpleBleLoggingLogDefaultStdout: procedure(); cdecl;
  SimpleBleLoggingLogDefaultFile: procedure(); cdecl;
  SimpleBleLoggingLogDefaultFilePath: procedure(Path: PChar); cdecl;

  // peripheral.h
  SimpleBlePeripheralReleaseHandle: procedure(Handle: TSimpleBlePeripheral); cdecl;
  SimpleBlePeripheralUnderlying: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Pointer; cdecl;
  SimpleBlePeripheralIdentifier: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): PChar; cdecl;
  SimpleBlePeripheralAddress: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): PChar; cdecl;
  SimpleBlePeripheralAddressType: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): TSimpleBleAddressType; cdecl;
  SimpleBlePeripheralRssi: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Int16; cdecl;
  SimpleBlePeripheralTxPower: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Int16; cdecl;
  SimpleBlePeripheralMtu: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): UInt16; cdecl;
  SimpleBlePeripheralConnect: procedure(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralDisconnect: procedure(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralIsConnected: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBlePeripheralIsConnectable: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBlePeripheralIsPaired: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Boolean; cdecl;
  SimpleBlePeripheralUnpair: procedure(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralServicesCount: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBlePeripheralServicesGet: procedure(Handle: TSimpleBlePeripheral; Index: NativeUInt; var OutService: TSimpleBleService; var OutError: TSimpleBleError); cdecl;
  SimpleBleServiceRelease: procedure(var Service: TSimpleBleService); cdecl;
  SimpleBlePeripheralManufacturerDataCount: function(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): NativeUInt; cdecl;
  SimpleBlePeripheralManufacturerDataGet: procedure(Handle: TSimpleBlePeripheral; Index: NativeUInt; var OutData: TSimpleBleManufacturerData; var OutError: TSimpleBleError); cdecl;
  SimpleBleManufacturerDataRelease: procedure(var Data: TSimpleBleManufacturerData); cdecl;
  SimpleBlePeripheralRead: function(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; var DataLength: NativeUInt; var OutError: TSimpleBleError): PByte; cdecl;
  SimpleBlePeripheralWriteRequest: procedure(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralWriteCommand: procedure(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralNotify: procedure(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackNotify; Userdata: Pointer; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralIndicate: procedure(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackNotify; Userdata: Pointer; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralUnsubscribe: procedure(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralReadDescriptor: function(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; var DataLength: NativeUInt; var OutError: TSimpleBleError): PByte; cdecl;
  SimpleBlePeripheralWriteDescriptor: procedure(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl;
  SimpleBlePeripheralSetCallbackOnConnected: procedure(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnConnected; Userdata: Pointer); cdecl;
  SimpleBlePeripheralSetCallbackOnDisconnected: procedure(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnConnected; Userdata: Pointer); cdecl;

  // utils.h
  SimpleBleGetOperatingSystem: function(): TSimpleBleOs; cdecl;
  SimpleBleGetVersion: function(): PChar; cdecl;

  // free.h
  SimpleBleFree: procedure(Handle: Pointer); cdecl;

{$ELSE}
  // adapter.h
function SimpleBleAdapterIsBluetoothEnabled(var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_is_bluetooth_enabled';
function SimpleBleAdapterGetCount(var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_count';
function SimpleBleAdapterGetHandle(Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleAdapter; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_handle';
procedure SimpleBleAdapterReleaseHandle(Handle: TSimpleBleAdapter); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_release_handle';
function SimpleBleAdapterUnderlying(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): Pointer; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_underlying';
function SimpleBleAdapterIdentifier(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_identifier';
function SimpleBleAdapterAddress(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_address';
procedure SimpleBleAdapterPowerOn(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_power_on';
procedure SimpleBleAdapterPowerOff(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_power_off';
function SimpleBleAdapterIsPowered(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_is_powered';
procedure SimpleBleAdapterSetCallbackOnPowerOn(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_power_on';
procedure SimpleBleAdapterSetCallbackOnPowerOff(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_power_off';
procedure SimpleBleAdapterScanStart(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_start';
procedure SimpleBleAdapterScanStop(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_stop';
function SimpleBleAdapterScanIsActive(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_is_active';
procedure SimpleBleAdapterScanFor(Handle: TSimpleBleAdapter; TimeoutMs: LongInt; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_for';
function SimpleBleAdapterScanGetResultsCount(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_get_results_count';
function SimpleBleAdapterScanGetResultsHandle(Handle: TSimpleBleAdapter; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_get_results_handle';
function SimpleBleAdapterGetPairedPeripheralsCount(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_paired_peripherals_count';
function SimpleBleAdapterGetPairedPeripheralsHandle(Handle: TSimpleBleAdapter; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_paired_peripherals_handle';
function SimpleBleAdapterGetConnectedPeripheralsCount(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_connected_peripherals_count';
function SimpleBleAdapterGetConnectedPeripheralsHandle(Handle: TSimpleBleAdapter; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_connected_peripherals_handle';
procedure SimpleBleAdapterSetCallbackOnScanStart(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_start';
procedure SimpleBleAdapterSetCallbackOnScanStop(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_stop';
procedure SimpleBleAdapterSetCallbackOnScanUpdated(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanFound; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_updated';
procedure SimpleBleAdapterSetCallbackOnScanFound(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanFound; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_found';
function SimpleBleAdapterCreateLocalPeripheral(Handle: TSimpleBleAdapter; var OutError: TSimpleBleError): TSimpleBleLocalPeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_create_local_peripheral';

  // advanced.h
procedure SimpleBleAdvancedDonglSetPasskeyRequestCallback(Handle: TSimpleBlePeripheral; Callback: TSimpleBlePasskeyRequestCallback; Userdata: Pointer; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_dongl_set_passkey_request_callback';
procedure SimpleBleAdvancedDonglSetPasskeyDisplayCallback(Handle: TSimpleBlePeripheral; Callback: TSimpleBlePasskeyDisplayCallback; Userdata: Pointer; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_dongl_set_passkey_display_callback';
procedure SimpleBleAdvancedDonglSetNumericComparisonCallback(Handle: TSimpleBlePeripheral; Callback: TSimpleBleNumericComparisonCallback; Userdata: Pointer; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_dongl_set_numeric_comparison_callback';
  {$IFDEF LINUX}
  {$IFNDEF ANDROID}
procedure SimpleBleAdvancedLinuxSetAdvertisementLocalName(Handle: TSimpleBleLocalPeripheral; LocalName: PChar; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_linux_set_advertisement_local_name';
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
procedure SimpleBleAdvancedMacosSetAdvertisementLocalName(Handle: TSimpleBleLocalPeripheral; LocalName: PChar; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_macos_set_advertisement_local_name';
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
function SimpleBleAdvancedMacosRetrieveCachedPeripheral(Handle: TSimpleBleAdapter; Identifier: PChar; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_macos_retrieve_cached_peripheral';
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
procedure SimpleBleAdvancedIosSetAdvertisementLocalName(Handle: TSimpleBleLocalPeripheral; LocalName: PChar; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_ios_set_advertisement_local_name';
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
function SimpleBleAdvancedIosRetrieveCachedPeripheral(Handle: TSimpleBleAdapter; Identifier: PChar; var OutError: TSimpleBleError): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_ios_retrieve_cached_peripheral';
  {$ENDIF}
  {$ENDIF}
  {$IFDEF ANDROID}
function SimpleBleAdvancedAndroidGetJvm(var OutError: TSimpleBleError): Pointer; cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_android_get_jvm';
  {$ENDIF}
  {$IFDEF ANDROID}
procedure SimpleBleAdvancedAndroidSetJvm(Jvm: Pointer; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_android_set_jvm';
  {$ENDIF}
  {$IFDEF ANDROID}
procedure SimpleBleAdvancedAndroidSetContext(Context: Pointer; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_advanced_android_set_context';
  {$ENDIF}

  // backend.h
function SimpleBleBackendGetCount(var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_backend_get_count';
function SimpleBleBackendGetHandle(Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleBackend; cdecl; external SimpleBleExtLibrary name 'simpleble_backend_get_handle';
procedure SimpleBleBackendReleaseHandle(Handle: TSimpleBleBackend); cdecl; external SimpleBleExtLibrary name 'simpleble_backend_release_handle';
function SimpleBleBackendIdentifier(Handle: TSimpleBleBackend; var OutError: TSimpleBleError): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_backend_identifier';
function SimpleBleBackendIsBluetoothEnabled(Handle: TSimpleBleBackend; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_backend_is_bluetooth_enabled';
function SimpleBleBackendGetAdaptersCount(Handle: TSimpleBleBackend; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_backend_get_adapters_count';
function SimpleBleBackendGetAdaptersHandle(Handle: TSimpleBleBackend; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleAdapter; cdecl; external SimpleBleExtLibrary name 'simpleble_backend_get_adapters_handle';

  // config.h
procedure SimpleBleConfigResetAll(); cdecl; external SimpleBleExtLibrary name 'simpleble_config_reset_all';
procedure SimpleBleConfigSimpleBluezReset(); cdecl; external SimpleBleExtLibrary name 'simpleble_config_simplebluez_reset';
function SimpleBleConfigSimpleBluezGetUseSystemBus(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_config_simplebluez_get_use_system_bus';
procedure SimpleBleConfigSimpleBluezSetUseSystemBus(Enabled: Boolean); cdecl; external SimpleBleExtLibrary name 'simpleble_config_simplebluez_set_use_system_bus';
function SimpleBleConfigSimpleBluezGetConnectionTimeoutMs(): Int64; cdecl; external SimpleBleExtLibrary name 'simpleble_config_simplebluez_get_connection_timeout_ms';
procedure SimpleBleConfigSimpleBluezSetConnectionTimeoutMs(TimeoutMs: Int64); cdecl; external SimpleBleExtLibrary name 'simpleble_config_simplebluez_set_connection_timeout_ms';
function SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs(): Int64; cdecl; external SimpleBleExtLibrary name 'simpleble_config_simplebluez_get_disconnection_timeout_ms';
procedure SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs(TimeoutMs: Int64); cdecl; external SimpleBleExtLibrary name 'simpleble_config_simplebluez_set_disconnection_timeout_ms';
procedure SimpleBleConfigWinRtReset(); cdecl; external SimpleBleExtLibrary name 'simpleble_config_winrt_reset';
function SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_config_winrt_get_experimental_use_own_mta_apartment';
procedure SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment(Enabled: Boolean); cdecl; external SimpleBleExtLibrary name 'simpleble_config_winrt_set_experimental_use_own_mta_apartment';
function SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_config_winrt_get_experimental_reinitialize_winrt_apartment_on_main_thread';
procedure SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread(Enabled: Boolean); cdecl; external SimpleBleExtLibrary name 'simpleble_config_winrt_set_experimental_reinitialize_winrt_apartment_on_main_thread';
function SimpleBleConfigWinRtGetUseDeferredDisconnect(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_config_winrt_get_use_deferred_disconnect';
procedure SimpleBleConfigWinRtSetUseDeferredDisconnect(Enabled: Boolean); cdecl; external SimpleBleExtLibrary name 'simpleble_config_winrt_set_use_deferred_disconnect';
procedure SimpleBleConfigCoreBluetoothReset(); cdecl; external SimpleBleExtLibrary name 'simpleble_config_corebluetooth_reset';
procedure SimpleBleConfigAndroidReset(); cdecl; external SimpleBleExtLibrary name 'simpleble_config_android_reset';
function SimpleBleConfigAndroidGetConnectionPriority(): TSimpleBleConfigAndroidConnectionPriority; cdecl; external SimpleBleExtLibrary name 'simpleble_config_android_get_connection_priority';
procedure SimpleBleConfigAndroidSetConnectionPriority(Priority: TSimpleBleConfigAndroidConnectionPriority); cdecl; external SimpleBleExtLibrary name 'simpleble_config_android_set_connection_priority';
procedure SimpleBleConfigSetAndroidConnectionPriority(Priority: LongInt); cdecl; external SimpleBleExtLibrary name 'simpleble_config_set_android_connection_priority';
procedure SimpleBleConfigDonglReset(); cdecl; external SimpleBleExtLibrary name 'simpleble_config_dongl_reset';
function SimpleBleConfigDonglGetUseDonglBackend(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_config_dongl_get_use_dongl_backend';
procedure SimpleBleConfigDonglSetUseDonglBackend(Enabled: Boolean); cdecl; external SimpleBleExtLibrary name 'simpleble_config_dongl_set_use_dongl_backend';
function SimpleBleConfigDonglGetAutoUpdate(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_config_dongl_get_auto_update';
procedure SimpleBleConfigDonglSetAutoUpdate(Enabled: Boolean); cdecl; external SimpleBleExtLibrary name 'simpleble_config_dongl_set_auto_update';
function SimpleBleConfigDonglGetForceUpdate(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_config_dongl_get_force_update';
procedure SimpleBleConfigDonglSetForceUpdate(Enabled: Boolean); cdecl; external SimpleBleExtLibrary name 'simpleble_config_dongl_set_force_update';

  // error.h
function SimpleBleErrorCode(Error: TSimpleBleError): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_error_code';
function SimpleBleErrorMessage(Error: TSimpleBleError): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_error_message';
procedure SimpleBleErrorRelease(var Error: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_error_release';

  // local characteristic.h
procedure SimpleBleLocalCharacteristicReleaseHandle(Handle: TSimpleBleLocalCharacteristic); cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_release_handle';
procedure SimpleBleLocalCharacteristicUuid(Handle: TSimpleBleLocalCharacteristic; var OutUuid: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_uuid';
function SimpleBleLocalCharacteristicCapabilities(Handle: TSimpleBleLocalCharacteristic; var OutError: TSimpleBleError): UInt32; cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_capabilities';
function SimpleBleLocalCharacteristicValue(Handle: TSimpleBleLocalCharacteristic; var DataLength: NativeUInt; var OutError: TSimpleBleError): PByte; cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_value';
procedure SimpleBleLocalCharacteristicSetValue(Handle: TSimpleBleLocalCharacteristic; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_set_value';
procedure SimpleBleLocalCharacteristicSetCallbackOnRead(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalReadCallback; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_set_callback_on_read';
procedure SimpleBleLocalCharacteristicSetCallbackOnWrite(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalWriteCallback; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_set_callback_on_write';
procedure SimpleBleLocalCharacteristicSetCallbackOnSubscribed(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalCharacteristicCallback; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_set_callback_on_subscribed';
procedure SimpleBleLocalCharacteristicSetCallbackOnUnsubscribed(Handle: TSimpleBleLocalCharacteristic; Callback: TSimpleBleLocalCharacteristicCallback; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_local_characteristic_set_callback_on_unsubscribed';

  // local peripheral.h
procedure SimpleBleLocalPeripheralReleaseHandle(Handle: TSimpleBleLocalPeripheral); cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_release_handle';
function SimpleBleLocalPeripheralUnderlying(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): Pointer; cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_underlying';
procedure SimpleBleLocalPeripheralAddAdvertisedService(Handle: TSimpleBleLocalPeripheral; Service: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_add_advertised_service';
function SimpleBleLocalPeripheralAddService(Handle: TSimpleBleLocalPeripheral; Uuid: TSimpleBleUuid; var OutError: TSimpleBleError): TSimpleBleLocalService; cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_add_service';
function SimpleBleLocalPeripheralServicesCount(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_services_count';
function SimpleBleLocalPeripheralServicesGet(Handle: TSimpleBleLocalPeripheral; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleLocalService; cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_services_get';
procedure SimpleBleLocalPeripheralRemoveAllServices(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_remove_all_services';
procedure SimpleBleLocalPeripheralStart(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_start';
procedure SimpleBleLocalPeripheralStop(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_stop';
function SimpleBleLocalPeripheralIsStarted(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_is_started';
function SimpleBleLocalPeripheralIsAdvertising(Handle: TSimpleBleLocalPeripheral; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_is_advertising';
procedure SimpleBleLocalPeripheralSetCallbackOnClientConnected(Handle: TSimpleBleLocalPeripheral; Callback: TSimpleBleLocalClientCallback; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_set_callback_on_client_connected';
procedure SimpleBleLocalPeripheralSetCallbackOnClientDisconnected(Handle: TSimpleBleLocalPeripheral; Callback: TSimpleBleLocalClientCallback; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_local_peripheral_set_callback_on_client_disconnected';

  // local service.h
procedure SimpleBleLocalServiceReleaseHandle(Handle: TSimpleBleLocalService); cdecl; external SimpleBleExtLibrary name 'simpleble_local_service_release_handle';
function SimpleBleLocalServiceCharacteristicsCount(Handle: TSimpleBleLocalService; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_local_service_characteristics_count';
function SimpleBleLocalServiceCharacteristicsGet(Handle: TSimpleBleLocalService; Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleLocalCharacteristic; cdecl; external SimpleBleExtLibrary name 'simpleble_local_service_characteristics_get';
procedure SimpleBleLocalServiceUuid(Handle: TSimpleBleLocalService; var OutUuid: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_local_service_uuid';
function SimpleBleLocalServiceAddCharacteristic(Handle: TSimpleBleLocalService; Uuid: TSimpleBleUuid; Capabilities: TSimpleBleLocalCharacteristicCapabilities; var OutError: TSimpleBleError): TSimpleBleLocalCharacteristic; cdecl; external SimpleBleExtLibrary name 'simpleble_local_service_add_characteristic';

  // logging.h
procedure SimpleBleLoggingSetLevel(Level: TSimpleBleLogLevel); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_set_level';
function SimpleBleLoggingGetLevel(): TSimpleBleLogLevel; cdecl; external SimpleBleExtLibrary name 'simpleble_logging_get_level';
procedure SimpleBleLoggingSetCallback(Callback: TCallbackLog); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_set_callback';
function SimpleBleLoggingHasCallback(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_logging_has_callback';
procedure SimpleBleLoggingLogDefaultStdout(); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_log_default_stdout';
procedure SimpleBleLoggingLogDefaultFile(); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_log_default_file';
procedure SimpleBleLoggingLogDefaultFilePath(Path: PChar); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_log_default_file_path';

  // peripheral.h
procedure SimpleBlePeripheralReleaseHandle(Handle: TSimpleBlePeripheral); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_release_handle';
function SimpleBlePeripheralUnderlying(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Pointer; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_underlying';
function SimpleBlePeripheralIdentifier(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_identifier';
function SimpleBlePeripheralAddress(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_address';
function SimpleBlePeripheralAddressType(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): TSimpleBleAddressType; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_address_type';
function SimpleBlePeripheralRssi(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Int16; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_rssi';
function SimpleBlePeripheralTxPower(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Int16; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_tx_power';
function SimpleBlePeripheralMtu(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): UInt16; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_mtu';
procedure SimpleBlePeripheralConnect(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_connect';
procedure SimpleBlePeripheralDisconnect(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_disconnect';
function SimpleBlePeripheralIsConnected(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_is_connected';
function SimpleBlePeripheralIsConnectable(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_is_connectable';
function SimpleBlePeripheralIsPaired(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_is_paired';
procedure SimpleBlePeripheralUnpair(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_unpair';
function SimpleBlePeripheralServicesCount(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_services_count';
procedure SimpleBlePeripheralServicesGet(Handle: TSimpleBlePeripheral; Index: NativeUInt; var OutService: TSimpleBleService; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_services_get';
procedure SimpleBleServiceRelease(var Service: TSimpleBleService); cdecl; external SimpleBleExtLibrary name 'simpleble_service_release';
function SimpleBlePeripheralManufacturerDataCount(Handle: TSimpleBlePeripheral; var OutError: TSimpleBleError): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_manufacturer_data_count';
procedure SimpleBlePeripheralManufacturerDataGet(Handle: TSimpleBlePeripheral; Index: NativeUInt; var OutData: TSimpleBleManufacturerData; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_manufacturer_data_get';
procedure SimpleBleManufacturerDataRelease(var Data: TSimpleBleManufacturerData); cdecl; external SimpleBleExtLibrary name 'simpleble_manufacturer_data_release';
function SimpleBlePeripheralRead(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; var DataLength: NativeUInt; var OutError: TSimpleBleError): PByte; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_read';
procedure SimpleBlePeripheralWriteRequest(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_write_request';
procedure SimpleBlePeripheralWriteCommand(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_write_command';
procedure SimpleBlePeripheralNotify(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackNotify; Userdata: Pointer; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_notify';
procedure SimpleBlePeripheralIndicate(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackNotify; Userdata: Pointer; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_indicate';
procedure SimpleBlePeripheralUnsubscribe(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_unsubscribe';
function SimpleBlePeripheralReadDescriptor(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; var DataLength: NativeUInt; var OutError: TSimpleBleError): PByte; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_read_descriptor';
procedure SimpleBlePeripheralWriteDescriptor(Handle: TSimpleBlePeripheral; Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt; var OutError: TSimpleBleError); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_write_descriptor';
procedure SimpleBlePeripheralSetCallbackOnConnected(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnConnected; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_set_callback_on_connected';
procedure SimpleBlePeripheralSetCallbackOnDisconnected(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnConnected; Userdata: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_set_callback_on_disconnected';

  // utils.h
function SimpleBleGetOperatingSystem(): TSimpleBleOs; cdecl; external SimpleBleExtLibrary name 'simpleble_get_operating_system';
function SimpleBleGetVersion(): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_get_version';

  // free.h
procedure SimpleBleFree(Handle: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_free';

{$ENDIF}

implementation

{$IFNDEF DYNAMIC_LOADING}
procedure SimpleBlePinLibrary();
begin
end;
{$ENDIF}

{$IFDEF DYNAMIC_LOADING}

var
  hCoreLib: TLibHandle = 0;
  hLib: TLibHandle = 0;
  LastLoadError: string = '';
  LibraryPinned: Boolean = False;


{ Clear the pointers to the functions and procedures }
procedure ClearPointers;
begin
  { functions from SimpleBLE adapter.h }
  pointer(SimpleBleAdapterIsBluetoothEnabled) := Nil;
  pointer(SimpleBleAdapterGetCount) := Nil;
  pointer(SimpleBleAdapterGetHandle) := Nil;
  pointer(SimpleBleAdapterReleaseHandle) := Nil;
  pointer(SimpleBleAdapterUnderlying) := Nil;
  pointer(SimpleBleAdapterIdentifier) := Nil;
  pointer(SimpleBleAdapterAddress) := Nil;
  pointer(SimpleBleAdapterPowerOn) := Nil;
  pointer(SimpleBleAdapterPowerOff) := Nil;
  pointer(SimpleBleAdapterIsPowered) := Nil;
  pointer(SimpleBleAdapterSetCallbackOnPowerOn) := Nil;
  pointer(SimpleBleAdapterSetCallbackOnPowerOff) := Nil;
  pointer(SimpleBleAdapterScanStart) := Nil;
  pointer(SimpleBleAdapterScanStop) := Nil;
  pointer(SimpleBleAdapterScanIsActive) := Nil;
  pointer(SimpleBleAdapterScanFor) := Nil;
  pointer(SimpleBleAdapterScanGetResultsCount) := Nil;
  pointer(SimpleBleAdapterScanGetResultsHandle) := Nil;
  pointer(SimpleBleAdapterGetPairedPeripheralsCount) := Nil;
  pointer(SimpleBleAdapterGetPairedPeripheralsHandle) := Nil;
  pointer(SimpleBleAdapterGetConnectedPeripheralsCount) := Nil;
  pointer(SimpleBleAdapterGetConnectedPeripheralsHandle) := Nil;
  pointer(SimpleBleAdapterSetCallbackOnScanStart) := Nil;
  pointer(SimpleBleAdapterSetCallbackOnScanStop) := Nil;
  pointer(SimpleBleAdapterSetCallbackOnScanUpdated) := Nil;
  pointer(SimpleBleAdapterSetCallbackOnScanFound) := Nil;

  { functions from SimpleBLE peripheral.h }
  pointer(SimpleBlePeripheralReleaseHandle) := Nil;
  pointer(SimpleBlePeripheralUnderlying) := Nil;
  pointer(SimpleBlePeripheralIdentifier) := Nil;
  pointer(SimpleBlePeripheralAddress) := Nil;
  pointer(SimpleBlePeripheralAddressType) := Nil;
  pointer(SimpleBlePeripheralRssi) := Nil;
  pointer(SimpleBlePeripheralTxPower) := Nil;
  pointer(SimpleBlePeripheralMtu) := Nil;
  pointer(SimpleBlePeripheralConnect) := Nil;
  pointer(SimpleBlePeripheralDisconnect) := Nil;
  pointer(SimpleBlePeripheralIsConnected) := Nil;
  pointer(SimpleBlePeripheralIsConnectable) := Nil;
  pointer(SimpleBlePeripheralIsPaired) := Nil;
  pointer(SimpleBlePeripheralUnpair) := Nil;
  pointer(SimpleBlePeripheralServicesCount) := Nil;
  pointer(SimpleBlePeripheralServicesGet) := Nil;
  pointer(SimpleBlePeripheralManufacturerDataCount) := Nil;
  pointer(SimpleBlePeripheralManufacturerDataGet) := Nil;
  pointer(SimpleBlePeripheralRead) := Nil;
  pointer(SimpleBlePeripheralWriteRequest) := Nil;
  pointer(SimpleBlePeripheralWriteCommand) := Nil;
  pointer(SimpleBlePeripheralNotify) := Nil;
  pointer(SimpleBlePeripheralIndicate) := Nil;
  pointer(SimpleBlePeripheralUnsubscribe) := Nil;
  pointer(SimpleBlePeripheralReadDescriptor) := Nil;
  pointer(SimpleBlePeripheralWriteDescriptor) := Nil;
  pointer(SimpleBlePeripheralSetCallbackOnConnected) := Nil;
  pointer(SimpleBlePeripheralSetCallbackOnDisconnected) := Nil;

  { functions from SimpleBLE simpleble.h }
  pointer(SimpleBleFree) := Nil;

  { functions from SimpleBLE logging.h }
  pointer(SimpleBleLoggingSetLevel) := Nil;
  pointer(SimpleBleLoggingSetCallback) := Nil;
  pointer(SimpleBleLoggingGetLevel) := Nil;
  pointer(SimpleBleLoggingHasCallback) := Nil;
  pointer(SimpleBleLoggingLogDefaultStdout) := Nil;
  pointer(SimpleBleLoggingLogDefaultFile) := Nil;
  pointer(SimpleBleLoggingLogDefaultFilePath) := Nil;

  { functions from SimpleBLE config.h }
  pointer(SimpleBleConfigResetAll) := Nil;
  pointer(SimpleBleConfigSimpleBluezReset) := Nil;
  pointer(SimpleBleConfigSimpleBluezGetUseSystemBus) := Nil;
  pointer(SimpleBleConfigSimpleBluezSetUseSystemBus) := Nil;
  pointer(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs) := Nil;
  pointer(SimpleBleConfigSimpleBluezSetConnectionTimeoutMs) := Nil;
  pointer(SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs) := Nil;
  pointer(SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs) := Nil;
  pointer(SimpleBleConfigWinRtReset) := Nil;
  pointer(SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment) := Nil;
  pointer(SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment) := Nil;
  pointer(SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread) := Nil;
  pointer(SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread) := Nil;
  pointer(SimpleBleConfigWinRtGetUseDeferredDisconnect) := Nil;
  pointer(SimpleBleConfigWinRtSetUseDeferredDisconnect) := Nil;
  pointer(SimpleBleConfigCoreBluetoothReset) := Nil;
  pointer(SimpleBleConfigAndroidReset) := Nil;
  pointer(SimpleBleConfigAndroidGetConnectionPriority) := Nil;
  pointer(SimpleBleConfigAndroidSetConnectionPriority) := Nil;
  pointer(SimpleBleConfigSetAndroidConnectionPriority) := Nil;
  pointer(SimpleBleConfigDonglReset) := Nil;
  pointer(SimpleBleConfigDonglGetUseDonglBackend) := Nil;
  pointer(SimpleBleConfigDonglSetUseDonglBackend) := Nil;
  pointer(SimpleBleConfigDonglGetAutoUpdate) := Nil;
  pointer(SimpleBleConfigDonglSetAutoUpdate) := Nil;
  pointer(SimpleBleConfigDonglGetForceUpdate) := Nil;
  pointer(SimpleBleConfigDonglSetForceUpdate) := Nil;

  { functions from SimpleBLE utils.h }
  pointer(SimpleBleGetOperatingSystem) := Nil;
  pointer(SimpleBleGetVersion) := Nil;
  
end;


{ Load the DLL file with an optional path specified }
function SimpleBleLoadLibrary(dllPath:string=''): Boolean;
begin
  Result := False;
  SimpleBleUnloadLibrary;
  LastLoadError := '';
  if dllPath <> '' then begin
    if not DirectoryExists(dllPath) then
    begin
      LastLoadError := 'Library directory does not exist: ' + dllPath;
      exit;
    end;
    if rightstr(dllPath,1) <> DirectorySeparator then dllPath := dllPath + DirectorySeparator;
    if not FileExists(dllPath + SimpleBleCoreLibrary) then
    begin
      LastLoadError := 'Native library not found: ' + dllPath + SimpleBleCoreLibrary;
      exit;
    end;
    if not FileExists(dllPath + SimpleBleExtLibrary) then
    begin
      LastLoadError := 'Native library not found: ' + dllPath + SimpleBleExtLibrary;
      exit;
    end;
    hCoreLib := LoadLibrary(PChar(dllPath + SimpleBleCoreLibrary));
    if hCoreLib = 0 then
    begin
      LastLoadError := 'Failed to load native library: ' + dllPath + SimpleBleCoreLibrary;
      exit;
    end;
    hLib := LoadLibrary(PChar(dllPath + SimpleBleExtLibrary));
  end else begin
    hCoreLib := LoadLibrary(PChar(SimpleBleCoreLibrary));
    if hCoreLib = 0 then
    begin
      LastLoadError := 'Failed to load native library: ' + SimpleBleCoreLibrary;
      exit;
    end;
    hLib := LoadLibrary(PChar(SimpleBleExtLibrary));
  end;
  if hLib = 0 then
  begin
    LastLoadError := 'Failed to load native library: ' + SimpleBleExtLibrary;
    UnloadLibrary(hCoreLib);
    hCoreLib := 0;
    exit;
  end;

  try
    { functions from SimpleBLE adapter.h }
    pointer(SimpleBleAdapterIsBluetoothEnabled) := GetProcedureAddress(hLib, 'simpleble_adapter_is_bluetooth_enabled');
    pointer(SimpleBleAdapterGetCount) := GetProcedureAddress(hLib, 'simpleble_adapter_get_count');
    pointer(SimpleBleAdapterGetHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_get_handle');
    pointer(SimpleBleAdapterReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_release_handle');
    pointer(SimpleBleAdapterUnderlying) := GetProcedureAddress(hLib, 'simpleble_adapter_underlying');
    pointer(SimpleBleAdapterIdentifier) := GetProcedureAddress(hLib, 'simpleble_adapter_identifier');
    pointer(SimpleBleAdapterAddress) := GetProcedureAddress(hLib, 'simpleble_adapter_address');
    pointer(SimpleBleAdapterPowerOn) := GetProcedureAddress(hLib, 'simpleble_adapter_power_on');
    pointer(SimpleBleAdapterPowerOff) := GetProcedureAddress(hLib, 'simpleble_adapter_power_off');
    pointer(SimpleBleAdapterIsPowered) := GetProcedureAddress(hLib, 'simpleble_adapter_is_powered');
    pointer(SimpleBleAdapterSetCallbackOnPowerOn) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_power_on');
    pointer(SimpleBleAdapterSetCallbackOnPowerOff) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_power_off');
    pointer(SimpleBleAdapterScanStart) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_start');
    pointer(SimpleBleAdapterScanStop) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_stop');
    pointer(SimpleBleAdapterScanIsActive) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_is_active');
    pointer(SimpleBleAdapterScanFor) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_for');
    pointer(SimpleBleAdapterScanGetResultsCount) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_get_results_count');
    pointer(SimpleBleAdapterScanGetResultsHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_get_results_handle');
    pointer(SimpleBleAdapterGetPairedPeripheralsCount) := GetProcedureAddress(hLib, 'simpleble_adapter_get_paired_peripherals_count');
    pointer(SimpleBleAdapterGetPairedPeripheralsHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_get_paired_peripherals_handle');
    pointer(SimpleBleAdapterGetConnectedPeripheralsCount) := GetProcedureAddress(hLib, 'simpleble_adapter_get_connected_peripherals_count');
    pointer(SimpleBleAdapterGetConnectedPeripheralsHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_get_connected_peripherals_handle');
    pointer(SimpleBleAdapterSetCallbackOnScanStart) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_start');
    pointer(SimpleBleAdapterSetCallbackOnScanStop) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_stop');
    pointer(SimpleBleAdapterSetCallbackOnScanUpdated) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_updated');
    pointer(SimpleBleAdapterSetCallbackOnScanFound) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_found');

    { functions from SimpleBLE peripheral.h }
    pointer(SimpleBlePeripheralReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_peripheral_release_handle');
    pointer(SimpleBlePeripheralUnderlying) := GetProcedureAddress(hLib, 'simpleble_peripheral_underlying');
    pointer(SimpleBlePeripheralIdentifier) := GetProcedureAddress(hLib, 'simpleble_peripheral_identifier');
    pointer(SimpleBlePeripheralAddress) := GetProcedureAddress(hLib, 'simpleble_peripheral_address');
    pointer(SimpleBlePeripheralAddressType) := GetProcedureAddress(hLib, 'simpleble_peripheral_address_type');
    pointer(SimpleBlePeripheralRssi) := GetProcedureAddress(hLib, 'simpleble_peripheral_rssi');
    pointer(SimpleBlePeripheralTxPower) := GetProcedureAddress(hLib, 'simpleble_peripheral_tx_power');
    pointer(SimpleBlePeripheralMtu) := GetProcedureAddress(hLib, 'simpleble_peripheral_mtu');
    pointer(SimpleBlePeripheralConnect) := GetProcedureAddress(hLib, 'simpleble_peripheral_connect');
    pointer(SimpleBlePeripheralDisconnect) := GetProcedureAddress(hLib, 'simpleble_peripheral_disconnect');
    pointer(SimpleBlePeripheralIsConnected) := GetProcedureAddress(hLib, 'simpleble_peripheral_is_connected');
    pointer(SimpleBlePeripheralIsConnectable) := GetProcedureAddress(hLib, 'simpleble_peripheral_is_connectable');
    pointer(SimpleBlePeripheralIsPaired) := GetProcedureAddress(hLib, 'simpleble_peripheral_is_paired');
    pointer(SimpleBlePeripheralUnpair) := GetProcedureAddress(hLib, 'simpleble_peripheral_unpair');
    pointer(SimpleBlePeripheralServicesCount) := GetProcedureAddress(hLib, 'simpleble_peripheral_services_count');
    pointer(SimpleBlePeripheralServicesGet) := GetProcedureAddress(hLib, 'simpleble_peripheral_services_get');
    pointer(SimpleBlePeripheralManufacturerDataCount) := GetProcedureAddress(hLib, 'simpleble_peripheral_manufacturer_data_count');
    pointer(SimpleBlePeripheralManufacturerDataGet) := GetProcedureAddress(hLib, 'simpleble_peripheral_manufacturer_data_get');
    pointer(SimpleBlePeripheralRead) := GetProcedureAddress(hLib, 'simpleble_peripheral_read');
    pointer(SimpleBlePeripheralWriteRequest) := GetProcedureAddress(hLib, 'simpleble_peripheral_write_request');
    pointer(SimpleBlePeripheralWriteCommand) := GetProcedureAddress(hLib, 'simpleble_peripheral_write_command');
    pointer(SimpleBlePeripheralNotify) := GetProcedureAddress(hLib, 'simpleble_peripheral_notify');
    pointer(SimpleBlePeripheralIndicate) := GetProcedureAddress(hLib, 'simpleble_peripheral_indicate');
    pointer(SimpleBlePeripheralUnsubscribe) := GetProcedureAddress(hLib, 'simpleble_peripheral_unsubscribe');
    pointer(SimpleBlePeripheralReadDescriptor) := GetProcedureAddress(hLib, 'simpleble_peripheral_read_descriptor');
    pointer(SimpleBlePeripheralWriteDescriptor) := GetProcedureAddress(hLib, 'simpleble_peripheral_write_descriptor');
    pointer(SimpleBlePeripheralSetCallbackOnConnected) := GetProcedureAddress(hLib, 'simpleble_peripheral_set_callback_on_connected');
    pointer(SimpleBlePeripheralSetCallbackOnDisconnected) := GetProcedureAddress(hLib, 'simpleble_peripheral_set_callback_on_disconnected');

    { functions from SimpleBLE simpleble.h }
    pointer(SimpleBleFree) := GetProcedureAddress(hLib, 'simpleble_free');

    { functions from SimpleBLE logging.h }
    pointer(SimpleBleLoggingSetLevel) := GetProcedureAddress(hLib, 'simpleble_logging_set_level');
    pointer(SimpleBleLoggingSetCallback) := GetProcedureAddress(hLib, 'simpleble_logging_set_callback');
    pointer(SimpleBleLoggingGetLevel) := GetProcedureAddress(hLib, 'simpleble_logging_get_level');
    pointer(SimpleBleLoggingHasCallback) := GetProcedureAddress(hLib, 'simpleble_logging_has_callback');
    pointer(SimpleBleLoggingLogDefaultStdout) := GetProcedureAddress(hLib, 'simpleble_logging_log_default_stdout');
    pointer(SimpleBleLoggingLogDefaultFile) := GetProcedureAddress(hLib, 'simpleble_logging_log_default_file');
    pointer(SimpleBleLoggingLogDefaultFilePath) := GetProcedureAddress(hLib, 'simpleble_logging_log_default_file_path');

    { functions from SimpleBLE config.h }
    pointer(SimpleBleConfigResetAll) := GetProcedureAddress(hLib, 'simpleble_config_reset_all');
    pointer(SimpleBleConfigSimpleBluezReset) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_reset');
    pointer(SimpleBleConfigSimpleBluezGetUseSystemBus) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_get_use_system_bus');
    pointer(SimpleBleConfigSimpleBluezSetUseSystemBus) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_set_use_system_bus');
    pointer(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_get_connection_timeout_ms');
    pointer(SimpleBleConfigSimpleBluezSetConnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_set_connection_timeout_ms');
    pointer(SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_get_disconnection_timeout_ms');
    pointer(SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_set_disconnection_timeout_ms');
    pointer(SimpleBleConfigWinRtReset) := GetProcedureAddress(hLib, 'simpleble_config_winrt_reset');
    pointer(SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment) := GetProcedureAddress(hLib, 'simpleble_config_winrt_get_experimental_use_own_mta_apartment');
    pointer(SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment) := GetProcedureAddress(hLib, 'simpleble_config_winrt_set_experimental_use_own_mta_apartment');
    pointer(SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread) := GetProcedureAddress(hLib, 'simpleble_config_winrt_get_experimental_reinitialize_winrt_apartment_on_main_thread');
    pointer(SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread) := GetProcedureAddress(hLib, 'simpleble_config_winrt_set_experimental_reinitialize_winrt_apartment_on_main_thread');
    pointer(SimpleBleConfigWinRtGetUseDeferredDisconnect) := GetProcedureAddress(hLib, 'simpleble_config_winrt_get_use_deferred_disconnect');
    pointer(SimpleBleConfigWinRtSetUseDeferredDisconnect) := GetProcedureAddress(hLib, 'simpleble_config_winrt_set_use_deferred_disconnect');
    pointer(SimpleBleConfigCoreBluetoothReset) := GetProcedureAddress(hLib, 'simpleble_config_corebluetooth_reset');
    pointer(SimpleBleConfigAndroidReset) := GetProcedureAddress(hLib, 'simpleble_config_android_reset');
    pointer(SimpleBleConfigAndroidGetConnectionPriority) := GetProcedureAddress(hLib, 'simpleble_config_android_get_connection_priority');
    pointer(SimpleBleConfigAndroidSetConnectionPriority) := GetProcedureAddress(hLib, 'simpleble_config_android_set_connection_priority');
    pointer(SimpleBleConfigSetAndroidConnectionPriority) := GetProcedureAddress(hLib, 'simpleble_config_set_android_connection_priority');
    pointer(SimpleBleConfigDonglReset) := GetProcedureAddress(hLib, 'simpleble_config_dongl_reset');
    pointer(SimpleBleConfigDonglGetUseDonglBackend) := GetProcedureAddress(hLib, 'simpleble_config_dongl_get_use_dongl_backend');
    pointer(SimpleBleConfigDonglSetUseDonglBackend) := GetProcedureAddress(hLib, 'simpleble_config_dongl_set_use_dongl_backend');
    pointer(SimpleBleConfigDonglGetAutoUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_get_auto_update');
    pointer(SimpleBleConfigDonglSetAutoUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_set_auto_update');
    pointer(SimpleBleConfigDonglGetForceUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_get_force_update');
    pointer(SimpleBleConfigDonglSetForceUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_set_force_update');

    { functions from SimpleBLE utils.h }
    pointer(SimpleBleGetOperatingSystem) := GetProcedureAddress(hLib, 'simpleble_get_operating_system');
	pointer(SimpleBleGetVersion) := GetProcedureAddress(hLib, 'simpleble_get_version');
	
  except
    LastLoadError := 'Unexpected error while resolving SimpleCBLE symbols';
    SimpleBleUnloadLibrary;
    exit;
  end;

  if 
    { functions from SimpleBLE adapter.h }
    (pointer(SimpleBleAdapterIsBluetoothEnabled) = Nil) or
    (pointer(SimpleBleAdapterGetCount) = Nil) or
    (pointer(SimpleBleAdapterGetHandle) = Nil) or
    (pointer(SimpleBleAdapterReleaseHandle) = Nil) or
    (pointer(SimpleBleAdapterUnderlying) = Nil) or
    (pointer(SimpleBleAdapterIdentifier) = Nil) or
    (pointer(SimpleBleAdapterAddress) = Nil) or
    (pointer(SimpleBleAdapterPowerOn) = Nil) or
    (pointer(SimpleBleAdapterPowerOff) = Nil) or
    (pointer(SimpleBleAdapterIsPowered) = Nil) or
    (pointer(SimpleBleAdapterSetCallbackOnPowerOn) = Nil) or
    (pointer(SimpleBleAdapterSetCallbackOnPowerOff) = Nil) or
    (pointer(SimpleBleAdapterScanStart) = Nil) or
    (pointer(SimpleBleAdapterScanStop) = Nil) or
    (pointer(SimpleBleAdapterScanIsActive) = Nil) or
    (pointer(SimpleBleAdapterScanFor) = Nil) or
    (pointer(SimpleBleAdapterScanGetResultsCount) = Nil) or
    (pointer(SimpleBleAdapterScanGetResultsHandle) = Nil) or
    (pointer(SimpleBleAdapterGetPairedPeripheralsCount) = Nil) or
    (pointer(SimpleBleAdapterGetPairedPeripheralsHandle) = Nil) or
    (pointer(SimpleBleAdapterGetConnectedPeripheralsCount) = Nil) or
    (pointer(SimpleBleAdapterGetConnectedPeripheralsHandle) = Nil) or
    (pointer(SimpleBleAdapterSetCallbackOnScanStart) = Nil) or
    (pointer(SimpleBleAdapterSetCallbackOnScanStop) = Nil) or
    (pointer(SimpleBleAdapterSetCallbackOnScanUpdated) = Nil) or
    (pointer(SimpleBleAdapterSetCallbackOnScanFound) = Nil) or

    { functions from SimpleBLE peripheral.h }
    (pointer(SimpleBlePeripheralReleaseHandle) = Nil) or
    (pointer(SimpleBlePeripheralUnderlying) = Nil) or
    (pointer(SimpleBlePeripheralIdentifier) = Nil) or
    (pointer(SimpleBlePeripheralAddress) = Nil) or
    (pointer(SimpleBlePeripheralAddressType) = Nil) or
    (pointer(SimpleBlePeripheralRssi) = Nil) or
    (pointer(SimpleBlePeripheralTxPower) = Nil) or
    (pointer(SimpleBlePeripheralMtu) = Nil) or
    (pointer(SimpleBlePeripheralConnect) = Nil) or
    (pointer(SimpleBlePeripheralDisconnect) = Nil) or
    (pointer(SimpleBlePeripheralIsConnected) = Nil) or
    (pointer(SimpleBlePeripheralIsConnectable) = Nil) or
    (pointer(SimpleBlePeripheralIsPaired) = Nil) or
    (pointer(SimpleBlePeripheralUnpair) = Nil) or
    (pointer(SimpleBlePeripheralServicesCount) = Nil) or
    (pointer(SimpleBlePeripheralServicesGet) = Nil) or
    (pointer(SimpleBlePeripheralManufacturerDataCount) = Nil) or
    (pointer(SimpleBlePeripheralManufacturerDataGet) = Nil) or
    (pointer(SimpleBlePeripheralRead) = Nil) or
    (pointer(SimpleBlePeripheralWriteRequest) = Nil) or
    (pointer(SimpleBlePeripheralWriteCommand) = Nil) or
    (pointer(SimpleBlePeripheralNotify) = Nil) or
    (pointer(SimpleBlePeripheralIndicate) = Nil) or
    (pointer(SimpleBlePeripheralUnsubscribe) = Nil) or
    (pointer(SimpleBlePeripheralReadDescriptor) = Nil) or
    (pointer(SimpleBlePeripheralWriteDescriptor) = Nil) or
    (pointer(SimpleBlePeripheralSetCallbackOnConnected) = Nil) or
    (pointer(SimpleBlePeripheralSetCallbackOnDisconnected) = Nil) or

    { functions from SimpleBLE simpleble.h }
    (pointer(SimpleBleFree) = Nil) or

    { functions from SimpleBLE logging.h }
    (pointer(SimpleBleLoggingSetLevel) = Nil) or
    (pointer(SimpleBleLoggingSetCallback) = Nil) or
    (pointer(SimpleBleLoggingGetLevel) = Nil) or
    (pointer(SimpleBleLoggingHasCallback) = Nil) or
    (pointer(SimpleBleLoggingLogDefaultStdout) = Nil) or
    (pointer(SimpleBleLoggingLogDefaultFile) = Nil) or
    (pointer(SimpleBleLoggingLogDefaultFilePath) = Nil) or

    { functions from SimpleBLE config.h }
    (pointer(SimpleBleConfigResetAll) = Nil) or
    (pointer(SimpleBleConfigSimpleBluezReset) = Nil) or
    (pointer(SimpleBleConfigSimpleBluezGetUseSystemBus) = Nil) or
    (pointer(SimpleBleConfigSimpleBluezSetUseSystemBus) = Nil) or
    (pointer(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs) = Nil) or
    (pointer(SimpleBleConfigSimpleBluezSetConnectionTimeoutMs) = Nil) or
    (pointer(SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs) = Nil) or
    (pointer(SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs) = Nil) or
    (pointer(SimpleBleConfigWinRtReset) = Nil) or
    (pointer(SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment) = Nil) or
    (pointer(SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment) = Nil) or
    (pointer(SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread) = Nil) or
    (pointer(SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread) = Nil) or
    (pointer(SimpleBleConfigWinRtGetUseDeferredDisconnect) = Nil) or
    (pointer(SimpleBleConfigWinRtSetUseDeferredDisconnect) = Nil) or
    (pointer(SimpleBleConfigCoreBluetoothReset) = Nil) or
    (pointer(SimpleBleConfigAndroidReset) = Nil) or
    (pointer(SimpleBleConfigAndroidGetConnectionPriority) = Nil) or
    (pointer(SimpleBleConfigAndroidSetConnectionPriority) = Nil) or
    (pointer(SimpleBleConfigSetAndroidConnectionPriority) = Nil) or
    (pointer(SimpleBleConfigDonglReset) = Nil) or
    (pointer(SimpleBleConfigDonglGetUseDonglBackend) = Nil) or
    (pointer(SimpleBleConfigDonglSetUseDonglBackend) = Nil) or
    (pointer(SimpleBleConfigDonglGetAutoUpdate) = Nil) or
    (pointer(SimpleBleConfigDonglSetAutoUpdate) = Nil) or
    (pointer(SimpleBleConfigDonglGetForceUpdate) = Nil) or
    (pointer(SimpleBleConfigDonglSetForceUpdate) = Nil) or

    { functions from SimpleBLE utils.h }
    (pointer(SimpleBleGetOperatingSystem) = Nil) or
	(pointer(SimpleBleGetVersion) = Nil)

  then
  begin
    LastLoadError := 'SimpleCBLE 1.1.0 is missing one or more required symbols';
    SimpleBleUnloadLibrary;
    exit;
  end;
  result:=true;
end;


function SimpleBleGetLastLoadError(): string;
begin
  Result := LastLoadError;
end;


{ Keep the native libraries mapped until process termination. This is needed
  when a native backend retains callbacks whose code belongs to SimpleCBLE. }
procedure SimpleBlePinLibrary();
begin
  LibraryPinned := True;
end;


{ Unload the DLL }
procedure SimpleBleUnloadLibrary();
begin
  ClearPointers;
  if LibraryPinned then
    exit;
  if hLib <> 0 then
  begin
    UnloadLibrary(hLib);
    hLib := 0;
  end;
  if hCoreLib <> 0 then
  begin
    UnloadLibrary(hCoreLib);
    hCoreLib := 0;
  end;
end;

{$ENDIF}

{$IFDEF DYNAMIC_LOADING}
finalization
  SimpleBleUnloadLibrary;
{$ENDIF}

end.
