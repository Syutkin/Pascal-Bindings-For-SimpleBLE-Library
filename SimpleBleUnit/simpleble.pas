unit SimpleBle;

{$mode ObjFPC}{$H+}
{$macro on}
{$pointermath on}

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
  { Version of these Pascal bindings. Available without loading native code.
    Example: Log('SimpleBlePascal ' + SimpleBlePascalVersion). }
  SimpleBlePascalVersion = '1.2.0';
  { Minimum supported SimpleCBLE version. The loader accepts this version and
    newer versions when required symbols exist. Starting with the next major
    version it also reports a warning, since symbol checks cannot prove that
    native types and function signatures are still ABI-compatible. After a
    successful load, SimpleBleGetVersion reports the actual native version. }
  SimpleBleMinimumNativeVersion = '1.2.0';

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

  ESimpleBleInvalidNativeData = class(Exception);

  TSimpleBleOwnedCharacteristic = record
    Uuid: TSimpleBleUuid;
    CanRead: Boolean;
    CanWriteRequest: Boolean;
    CanWriteCommand: Boolean;
    CanNotify: Boolean;
    CanIndicate: Boolean;
    Descriptors: array of TSimpleBleUuid;
  end;

  TSimpleBleOwnedService = record
    Uuid: TSimpleBleUuid;
    Data: TBytes;
    Characteristics: array of TSimpleBleOwnedCharacteristic;
  end;

  TSimpleBleOwnedManufacturerData = record
    ManufacturerId: UInt16;
    Data: TBytes;
  end;

  TSimpleBleErrorInfo = record
    HasError: Boolean;
    Code: TSimpleBleErr;
    Message: string;
  end;

procedure SimpleBlePinLibrary();

{$IFDEF DYNAMIC_LOADING}
function SimpleBleLoadLibrary(dllPath: string = ''): Boolean;
procedure SimpleBleUnloadLibrary();
function SimpleBleGetLastLoadError(): string;
{ Empty for versions below the next major release. A nonempty warning does not
  make SimpleBleLoadLibrary fail; callers should include it in diagnostics. }
function SimpleBleGetLastLoadWarning(): string;
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

{ These helpers return Pascal-owned copies. Take/Fetch functions release native
  allocations even when copying raises an exception or the C call fails. }
function SimpleBleCopyBufferAndFree(var Buffer: PByte;
  DataLength: NativeUInt): TBytes;
function SimpleBleCopyService(const Source: TSimpleBleService): TSimpleBleOwnedService;
function SimpleBleTakeService(var Source: TSimpleBleService): TSimpleBleOwnedService;
function SimpleBleGetService(Handle: TSimpleBlePeripheral; Index: NativeUInt;
  var OutError: TSimpleBleError): TSimpleBleOwnedService;
function SimpleBleCopyManufacturerData(
  const Source: TSimpleBleManufacturerData): TSimpleBleOwnedManufacturerData;
function SimpleBleTakeManufacturerData(
  var Source: TSimpleBleManufacturerData): TSimpleBleOwnedManufacturerData;
function SimpleBleGetManufacturerData(Handle: TSimpleBlePeripheral;
  Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleOwnedManufacturerData;
function SimpleBleReadValue(Handle: TSimpleBlePeripheral;
  Service, Characteristic: TSimpleBleUuid;
  var OutError: TSimpleBleError): TBytes;
function SimpleBleReadDescriptorValue(Handle: TSimpleBlePeripheral;
  Service, Characteristic, Descriptor: TSimpleBleUuid;
  var OutError: TSimpleBleError): TBytes;
function SimpleBleCopyErrorInfo(const Error: TSimpleBleError): TSimpleBleErrorInfo;
function SimpleBleTakeErrorInfo(var Error: TSimpleBleError): TSimpleBleErrorInfo;

implementation

function CheckedArrayLength(Count: NativeUInt; Data: Pointer): SizeInt;
begin
  if Count > NativeUInt(High(SizeInt)) then
    raise ESimpleBleInvalidNativeData.Create('Native array length exceeds SizeInt');
  if (Count <> 0) and (Data = nil) then
    raise ESimpleBleInvalidNativeData.Create('Native array has a null pointer');
  Result := SizeInt(Count);
end;

function SimpleBleCopyBufferAndFree(var Buffer: PByte;
  DataLength: NativeUInt): TBytes;
begin
  Result := nil;
  try
    SetLength(Result, CheckedArrayLength(DataLength, Buffer));
    if DataLength <> 0 then
      Move(Buffer^, Result[0], SizeInt(DataLength));
  finally
    if Buffer <> nil then
      SimpleBleFree(Buffer);
    Buffer := nil;
  end;
end;

function SimpleBleCopyService(
  const Source: TSimpleBleService): TSimpleBleOwnedService;
var
  Characteristic: TSimpleBleCharacteristic;
  CharacteristicIndex: SizeInt;
  DescriptorIndex: SizeInt;
  OwnedCharacteristic: ^TSimpleBleOwnedCharacteristic;
begin
  Result := Default(TSimpleBleOwnedService);
  Result.Uuid := Source.Uuid;
  SetLength(Result.Data, CheckedArrayLength(Source.DataLength, Source.Data));
  if Source.DataLength <> 0 then
    Move(Source.Data^, Result.Data[0], SizeInt(Source.DataLength));

  SetLength(Result.Characteristics,
    CheckedArrayLength(Source.CharacteristicCount, Source.Characteristics));
  for CharacteristicIndex := 0 to High(Result.Characteristics) do
  begin
    Characteristic := Source.Characteristics[CharacteristicIndex];
    OwnedCharacteristic := @Result.Characteristics[CharacteristicIndex];
    OwnedCharacteristic^.Uuid := Characteristic.Uuid;
    OwnedCharacteristic^.CanRead := Characteristic.CanRead;
    OwnedCharacteristic^.CanWriteRequest := Characteristic.CanWriteRequest;
    OwnedCharacteristic^.CanWriteCommand := Characteristic.CanWriteCommand;
    OwnedCharacteristic^.CanNotify := Characteristic.CanNotify;
    OwnedCharacteristic^.CanIndicate := Characteristic.CanIndicate;
    SetLength(OwnedCharacteristic^.Descriptors,
      CheckedArrayLength(Characteristic.DescriptorCount,
        Characteristic.Descriptors));
    for DescriptorIndex := 0 to High(OwnedCharacteristic^.Descriptors) do
      OwnedCharacteristic^.Descriptors[DescriptorIndex] :=
        Characteristic.Descriptors[DescriptorIndex].Uuid;
  end;
end;

function SimpleBleTakeService(
  var Source: TSimpleBleService): TSimpleBleOwnedService;
begin
  try
    Result := SimpleBleCopyService(Source);
  finally
    SimpleBleServiceRelease(Source);
  end;
end;

function SimpleBleGetService(Handle: TSimpleBlePeripheral; Index: NativeUInt;
  var OutError: TSimpleBleError): TSimpleBleOwnedService;
var
  Source: TSimpleBleService;
begin
  Source := Default(TSimpleBleService);
  try
    SimpleBlePeripheralServicesGet(Handle, Index, Source, OutError);
    if OutError = nil then
      Result := SimpleBleCopyService(Source)
    else
      Result := Default(TSimpleBleOwnedService);
  finally
    SimpleBleServiceRelease(Source);
  end;
end;

function SimpleBleCopyManufacturerData(
  const Source: TSimpleBleManufacturerData): TSimpleBleOwnedManufacturerData;
begin
  Result := Default(TSimpleBleOwnedManufacturerData);
  Result.ManufacturerId := Source.ManufacturerId;
  SetLength(Result.Data, CheckedArrayLength(Source.DataLength, Source.Data));
  if Source.DataLength <> 0 then
    Move(Source.Data^, Result.Data[0], SizeInt(Source.DataLength));
end;

function SimpleBleTakeManufacturerData(
  var Source: TSimpleBleManufacturerData): TSimpleBleOwnedManufacturerData;
begin
  try
    Result := SimpleBleCopyManufacturerData(Source);
  finally
    SimpleBleManufacturerDataRelease(Source);
  end;
end;

function SimpleBleGetManufacturerData(Handle: TSimpleBlePeripheral;
  Index: NativeUInt; var OutError: TSimpleBleError): TSimpleBleOwnedManufacturerData;
var
  Source: TSimpleBleManufacturerData;
begin
  Source := Default(TSimpleBleManufacturerData);
  try
    SimpleBlePeripheralManufacturerDataGet(Handle, Index, Source, OutError);
    if OutError = nil then
      Result := SimpleBleCopyManufacturerData(Source)
    else
      Result := Default(TSimpleBleOwnedManufacturerData);
  finally
    SimpleBleManufacturerDataRelease(Source);
  end;
end;

function SimpleBleReadValue(Handle: TSimpleBlePeripheral;
  Service, Characteristic: TSimpleBleUuid;
  var OutError: TSimpleBleError): TBytes;
var
  Buffer: PByte;
  DataLength: NativeUInt;
begin
  DataLength := 0;
  Buffer := SimpleBlePeripheralRead(Handle, Service, Characteristic,
    DataLength, OutError);
  try
    if OutError = nil then
      Result := SimpleBleCopyBufferAndFree(Buffer, DataLength)
    else
      Result := nil;
  finally
    if Buffer <> nil then
      SimpleBleFree(Buffer);
  end;
end;

function SimpleBleReadDescriptorValue(Handle: TSimpleBlePeripheral;
  Service, Characteristic, Descriptor: TSimpleBleUuid;
  var OutError: TSimpleBleError): TBytes;
var
  Buffer: PByte;
  DataLength: NativeUInt;
begin
  DataLength := 0;
  Buffer := SimpleBlePeripheralReadDescriptor(Handle, Service, Characteristic,
    Descriptor, DataLength, OutError);
  try
    if OutError = nil then
      Result := SimpleBleCopyBufferAndFree(Buffer, DataLength)
    else
      Result := nil;
  finally
    if Buffer <> nil then
      SimpleBleFree(Buffer);
  end;
end;

function SimpleBleCopyErrorInfo(
  const Error: TSimpleBleError): TSimpleBleErrorInfo;
var
  MessageText: PChar;
begin
  Result := Default(TSimpleBleErrorInfo);
  if Error = nil then
    Exit;
  Result.HasError := True;
  Result.Code := SimpleBleErrorCode(Error);
  MessageText := SimpleBleErrorMessage(Error);
  if MessageText <> nil then
    Result.Message := string(MessageText);
end;

function SimpleBleTakeErrorInfo(var Error: TSimpleBleError): TSimpleBleErrorInfo;
begin
  try
    Result := SimpleBleCopyErrorInfo(Error);
  finally
    SimpleBleErrorRelease(Error);
  end;
end;

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
  LastLoadWarning: string = '';
  LibraryPinned: Boolean = False;


{ Clear the pointers to the functions and procedures }
procedure ClearPointers;
begin
  Pointer(SimpleBleAdapterIsBluetoothEnabled) := nil;
  Pointer(SimpleBleAdapterGetCount) := nil;
  Pointer(SimpleBleAdapterGetHandle) := nil;
  Pointer(SimpleBleAdapterReleaseHandle) := nil;
  Pointer(SimpleBleAdapterUnderlying) := nil;
  Pointer(SimpleBleAdapterIdentifier) := nil;
  Pointer(SimpleBleAdapterAddress) := nil;
  Pointer(SimpleBleAdapterPowerOn) := nil;
  Pointer(SimpleBleAdapterPowerOff) := nil;
  Pointer(SimpleBleAdapterIsPowered) := nil;
  Pointer(SimpleBleAdapterSetCallbackOnPowerOn) := nil;
  Pointer(SimpleBleAdapterSetCallbackOnPowerOff) := nil;
  Pointer(SimpleBleAdapterScanStart) := nil;
  Pointer(SimpleBleAdapterScanStop) := nil;
  Pointer(SimpleBleAdapterScanIsActive) := nil;
  Pointer(SimpleBleAdapterScanFor) := nil;
  Pointer(SimpleBleAdapterScanGetResultsCount) := nil;
  Pointer(SimpleBleAdapterScanGetResultsHandle) := nil;
  Pointer(SimpleBleAdapterGetPairedPeripheralsCount) := nil;
  Pointer(SimpleBleAdapterGetPairedPeripheralsHandle) := nil;
  Pointer(SimpleBleAdapterGetConnectedPeripheralsCount) := nil;
  Pointer(SimpleBleAdapterGetConnectedPeripheralsHandle) := nil;
  Pointer(SimpleBleAdapterSetCallbackOnScanStart) := nil;
  Pointer(SimpleBleAdapterSetCallbackOnScanStop) := nil;
  Pointer(SimpleBleAdapterSetCallbackOnScanUpdated) := nil;
  Pointer(SimpleBleAdapterSetCallbackOnScanFound) := nil;
  Pointer(SimpleBleAdapterCreateLocalPeripheral) := nil;
  Pointer(SimpleBleAdvancedDonglSetPasskeyRequestCallback) := nil;
  Pointer(SimpleBleAdvancedDonglSetPasskeyDisplayCallback) := nil;
  Pointer(SimpleBleAdvancedDonglSetNumericComparisonCallback) := nil;
  {$IFDEF LINUX}
  {$IFNDEF ANDROID}
  Pointer(SimpleBleAdvancedLinuxSetAdvertisementLocalName) := nil;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
  Pointer(SimpleBleAdvancedMacosSetAdvertisementLocalName) := nil;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
  Pointer(SimpleBleAdvancedMacosRetrieveCachedPeripheral) := nil;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
  Pointer(SimpleBleAdvancedIosSetAdvertisementLocalName) := nil;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
  Pointer(SimpleBleAdvancedIosRetrieveCachedPeripheral) := nil;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF ANDROID}
  Pointer(SimpleBleAdvancedAndroidGetJvm) := nil;
  {$ENDIF}
  {$IFDEF ANDROID}
  Pointer(SimpleBleAdvancedAndroidSetJvm) := nil;
  {$ENDIF}
  {$IFDEF ANDROID}
  Pointer(SimpleBleAdvancedAndroidSetContext) := nil;
  {$ENDIF}
  Pointer(SimpleBleBackendGetCount) := nil;
  Pointer(SimpleBleBackendGetHandle) := nil;
  Pointer(SimpleBleBackendReleaseHandle) := nil;
  Pointer(SimpleBleBackendIdentifier) := nil;
  Pointer(SimpleBleBackendIsBluetoothEnabled) := nil;
  Pointer(SimpleBleBackendGetAdaptersCount) := nil;
  Pointer(SimpleBleBackendGetAdaptersHandle) := nil;
  Pointer(SimpleBleConfigResetAll) := nil;
  Pointer(SimpleBleConfigSimpleBluezReset) := nil;
  Pointer(SimpleBleConfigSimpleBluezGetUseSystemBus) := nil;
  Pointer(SimpleBleConfigSimpleBluezSetUseSystemBus) := nil;
  Pointer(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs) := nil;
  Pointer(SimpleBleConfigSimpleBluezSetConnectionTimeoutMs) := nil;
  Pointer(SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs) := nil;
  Pointer(SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs) := nil;
  Pointer(SimpleBleConfigWinRtReset) := nil;
  Pointer(SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment) := nil;
  Pointer(SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment) := nil;
  Pointer(SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread) := nil;
  Pointer(SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread) := nil;
  Pointer(SimpleBleConfigWinRtGetUseDeferredDisconnect) := nil;
  Pointer(SimpleBleConfigWinRtSetUseDeferredDisconnect) := nil;
  Pointer(SimpleBleConfigCoreBluetoothReset) := nil;
  Pointer(SimpleBleConfigAndroidReset) := nil;
  Pointer(SimpleBleConfigAndroidGetConnectionPriority) := nil;
  Pointer(SimpleBleConfigAndroidSetConnectionPriority) := nil;
  Pointer(SimpleBleConfigSetAndroidConnectionPriority) := nil;
  Pointer(SimpleBleConfigDonglReset) := nil;
  Pointer(SimpleBleConfigDonglGetUseDonglBackend) := nil;
  Pointer(SimpleBleConfigDonglSetUseDonglBackend) := nil;
  Pointer(SimpleBleConfigDonglGetAutoUpdate) := nil;
  Pointer(SimpleBleConfigDonglSetAutoUpdate) := nil;
  Pointer(SimpleBleConfigDonglGetForceUpdate) := nil;
  Pointer(SimpleBleConfigDonglSetForceUpdate) := nil;
  Pointer(SimpleBleErrorCode) := nil;
  Pointer(SimpleBleErrorMessage) := nil;
  Pointer(SimpleBleErrorRelease) := nil;
  Pointer(SimpleBleLocalCharacteristicReleaseHandle) := nil;
  Pointer(SimpleBleLocalCharacteristicUuid) := nil;
  Pointer(SimpleBleLocalCharacteristicCapabilities) := nil;
  Pointer(SimpleBleLocalCharacteristicValue) := nil;
  Pointer(SimpleBleLocalCharacteristicSetValue) := nil;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnRead) := nil;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnWrite) := nil;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnSubscribed) := nil;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnUnsubscribed) := nil;
  Pointer(SimpleBleLocalPeripheralReleaseHandle) := nil;
  Pointer(SimpleBleLocalPeripheralUnderlying) := nil;
  Pointer(SimpleBleLocalPeripheralAddAdvertisedService) := nil;
  Pointer(SimpleBleLocalPeripheralAddService) := nil;
  Pointer(SimpleBleLocalPeripheralServicesCount) := nil;
  Pointer(SimpleBleLocalPeripheralServicesGet) := nil;
  Pointer(SimpleBleLocalPeripheralRemoveAllServices) := nil;
  Pointer(SimpleBleLocalPeripheralStart) := nil;
  Pointer(SimpleBleLocalPeripheralStop) := nil;
  Pointer(SimpleBleLocalPeripheralIsStarted) := nil;
  Pointer(SimpleBleLocalPeripheralIsAdvertising) := nil;
  Pointer(SimpleBleLocalPeripheralSetCallbackOnClientConnected) := nil;
  Pointer(SimpleBleLocalPeripheralSetCallbackOnClientDisconnected) := nil;
  Pointer(SimpleBleLocalServiceReleaseHandle) := nil;
  Pointer(SimpleBleLocalServiceCharacteristicsCount) := nil;
  Pointer(SimpleBleLocalServiceCharacteristicsGet) := nil;
  Pointer(SimpleBleLocalServiceUuid) := nil;
  Pointer(SimpleBleLocalServiceAddCharacteristic) := nil;
  Pointer(SimpleBleLoggingSetLevel) := nil;
  Pointer(SimpleBleLoggingGetLevel) := nil;
  Pointer(SimpleBleLoggingSetCallback) := nil;
  Pointer(SimpleBleLoggingHasCallback) := nil;
  Pointer(SimpleBleLoggingLogDefaultStdout) := nil;
  Pointer(SimpleBleLoggingLogDefaultFile) := nil;
  Pointer(SimpleBleLoggingLogDefaultFilePath) := nil;
  Pointer(SimpleBlePeripheralReleaseHandle) := nil;
  Pointer(SimpleBlePeripheralUnderlying) := nil;
  Pointer(SimpleBlePeripheralIdentifier) := nil;
  Pointer(SimpleBlePeripheralAddress) := nil;
  Pointer(SimpleBlePeripheralAddressType) := nil;
  Pointer(SimpleBlePeripheralRssi) := nil;
  Pointer(SimpleBlePeripheralTxPower) := nil;
  Pointer(SimpleBlePeripheralMtu) := nil;
  Pointer(SimpleBlePeripheralConnect) := nil;
  Pointer(SimpleBlePeripheralDisconnect) := nil;
  Pointer(SimpleBlePeripheralIsConnected) := nil;
  Pointer(SimpleBlePeripheralIsConnectable) := nil;
  Pointer(SimpleBlePeripheralIsPaired) := nil;
  Pointer(SimpleBlePeripheralUnpair) := nil;
  Pointer(SimpleBlePeripheralServicesCount) := nil;
  Pointer(SimpleBlePeripheralServicesGet) := nil;
  Pointer(SimpleBleServiceRelease) := nil;
  Pointer(SimpleBlePeripheralManufacturerDataCount) := nil;
  Pointer(SimpleBlePeripheralManufacturerDataGet) := nil;
  Pointer(SimpleBleManufacturerDataRelease) := nil;
  Pointer(SimpleBlePeripheralRead) := nil;
  Pointer(SimpleBlePeripheralWriteRequest) := nil;
  Pointer(SimpleBlePeripheralWriteCommand) := nil;
  Pointer(SimpleBlePeripheralNotify) := nil;
  Pointer(SimpleBlePeripheralIndicate) := nil;
  Pointer(SimpleBlePeripheralUnsubscribe) := nil;
  Pointer(SimpleBlePeripheralReadDescriptor) := nil;
  Pointer(SimpleBlePeripheralWriteDescriptor) := nil;
  Pointer(SimpleBlePeripheralSetCallbackOnConnected) := nil;
  Pointer(SimpleBlePeripheralSetCallbackOnDisconnected) := nil;
  Pointer(SimpleBleGetOperatingSystem) := nil;
  Pointer(SimpleBleGetVersion) := nil;
  Pointer(SimpleBleFree) := nil;
end;

function ResolveRequiredSymbols: Boolean;
begin
  Result := False;
  Pointer(SimpleBleAdapterIsBluetoothEnabled) := GetProcedureAddress(hLib, 'simpleble_adapter_is_bluetooth_enabled');
  if Pointer(SimpleBleAdapterIsBluetoothEnabled) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_is_bluetooth_enabled';
    Exit;
  end;
  Pointer(SimpleBleAdapterGetCount) := GetProcedureAddress(hLib, 'simpleble_adapter_get_count');
  if Pointer(SimpleBleAdapterGetCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_get_count';
    Exit;
  end;
  Pointer(SimpleBleAdapterGetHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_get_handle');
  if Pointer(SimpleBleAdapterGetHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_get_handle';
    Exit;
  end;
  Pointer(SimpleBleAdapterReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_release_handle');
  if Pointer(SimpleBleAdapterReleaseHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_release_handle';
    Exit;
  end;
  Pointer(SimpleBleAdapterUnderlying) := GetProcedureAddress(hLib, 'simpleble_adapter_underlying');
  if Pointer(SimpleBleAdapterUnderlying) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_underlying';
    Exit;
  end;
  Pointer(SimpleBleAdapterIdentifier) := GetProcedureAddress(hLib, 'simpleble_adapter_identifier');
  if Pointer(SimpleBleAdapterIdentifier) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_identifier';
    Exit;
  end;
  Pointer(SimpleBleAdapterAddress) := GetProcedureAddress(hLib, 'simpleble_adapter_address');
  if Pointer(SimpleBleAdapterAddress) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_address';
    Exit;
  end;
  Pointer(SimpleBleAdapterPowerOn) := GetProcedureAddress(hLib, 'simpleble_adapter_power_on');
  if Pointer(SimpleBleAdapterPowerOn) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_power_on';
    Exit;
  end;
  Pointer(SimpleBleAdapterPowerOff) := GetProcedureAddress(hLib, 'simpleble_adapter_power_off');
  if Pointer(SimpleBleAdapterPowerOff) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_power_off';
    Exit;
  end;
  Pointer(SimpleBleAdapterIsPowered) := GetProcedureAddress(hLib, 'simpleble_adapter_is_powered');
  if Pointer(SimpleBleAdapterIsPowered) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_is_powered';
    Exit;
  end;
  Pointer(SimpleBleAdapterSetCallbackOnPowerOn) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_power_on');
  if Pointer(SimpleBleAdapterSetCallbackOnPowerOn) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_set_callback_on_power_on';
    Exit;
  end;
  Pointer(SimpleBleAdapterSetCallbackOnPowerOff) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_power_off');
  if Pointer(SimpleBleAdapterSetCallbackOnPowerOff) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_set_callback_on_power_off';
    Exit;
  end;
  Pointer(SimpleBleAdapterScanStart) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_start');
  if Pointer(SimpleBleAdapterScanStart) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_scan_start';
    Exit;
  end;
  Pointer(SimpleBleAdapterScanStop) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_stop');
  if Pointer(SimpleBleAdapterScanStop) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_scan_stop';
    Exit;
  end;
  Pointer(SimpleBleAdapterScanIsActive) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_is_active');
  if Pointer(SimpleBleAdapterScanIsActive) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_scan_is_active';
    Exit;
  end;
  Pointer(SimpleBleAdapterScanFor) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_for');
  if Pointer(SimpleBleAdapterScanFor) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_scan_for';
    Exit;
  end;
  Pointer(SimpleBleAdapterScanGetResultsCount) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_get_results_count');
  if Pointer(SimpleBleAdapterScanGetResultsCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_scan_get_results_count';
    Exit;
  end;
  Pointer(SimpleBleAdapterScanGetResultsHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_scan_get_results_handle');
  if Pointer(SimpleBleAdapterScanGetResultsHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_scan_get_results_handle';
    Exit;
  end;
  Pointer(SimpleBleAdapterGetPairedPeripheralsCount) := GetProcedureAddress(hLib, 'simpleble_adapter_get_paired_peripherals_count');
  if Pointer(SimpleBleAdapterGetPairedPeripheralsCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_get_paired_peripherals_count';
    Exit;
  end;
  Pointer(SimpleBleAdapterGetPairedPeripheralsHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_get_paired_peripherals_handle');
  if Pointer(SimpleBleAdapterGetPairedPeripheralsHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_get_paired_peripherals_handle';
    Exit;
  end;
  Pointer(SimpleBleAdapterGetConnectedPeripheralsCount) := GetProcedureAddress(hLib, 'simpleble_adapter_get_connected_peripherals_count');
  if Pointer(SimpleBleAdapterGetConnectedPeripheralsCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_get_connected_peripherals_count';
    Exit;
  end;
  Pointer(SimpleBleAdapterGetConnectedPeripheralsHandle) := GetProcedureAddress(hLib, 'simpleble_adapter_get_connected_peripherals_handle');
  if Pointer(SimpleBleAdapterGetConnectedPeripheralsHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_get_connected_peripherals_handle';
    Exit;
  end;
  Pointer(SimpleBleAdapterSetCallbackOnScanStart) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_start');
  if Pointer(SimpleBleAdapterSetCallbackOnScanStart) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_set_callback_on_scan_start';
    Exit;
  end;
  Pointer(SimpleBleAdapterSetCallbackOnScanStop) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_stop');
  if Pointer(SimpleBleAdapterSetCallbackOnScanStop) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_set_callback_on_scan_stop';
    Exit;
  end;
  Pointer(SimpleBleAdapterSetCallbackOnScanUpdated) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_updated');
  if Pointer(SimpleBleAdapterSetCallbackOnScanUpdated) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_set_callback_on_scan_updated';
    Exit;
  end;
  Pointer(SimpleBleAdapterSetCallbackOnScanFound) := GetProcedureAddress(hLib, 'simpleble_adapter_set_callback_on_scan_found');
  if Pointer(SimpleBleAdapterSetCallbackOnScanFound) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_set_callback_on_scan_found';
    Exit;
  end;
  Pointer(SimpleBleAdapterCreateLocalPeripheral) := GetProcedureAddress(hLib, 'simpleble_adapter_create_local_peripheral');
  if Pointer(SimpleBleAdapterCreateLocalPeripheral) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_adapter_create_local_peripheral';
    Exit;
  end;
  Pointer(SimpleBleAdvancedDonglSetPasskeyRequestCallback) := GetProcedureAddress(hLib, 'simpleble_advanced_dongl_set_passkey_request_callback');
  if Pointer(SimpleBleAdvancedDonglSetPasskeyRequestCallback) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_dongl_set_passkey_request_callback';
    Exit;
  end;
  Pointer(SimpleBleAdvancedDonglSetPasskeyDisplayCallback) := GetProcedureAddress(hLib, 'simpleble_advanced_dongl_set_passkey_display_callback');
  if Pointer(SimpleBleAdvancedDonglSetPasskeyDisplayCallback) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_dongl_set_passkey_display_callback';
    Exit;
  end;
  Pointer(SimpleBleAdvancedDonglSetNumericComparisonCallback) := GetProcedureAddress(hLib, 'simpleble_advanced_dongl_set_numeric_comparison_callback');
  if Pointer(SimpleBleAdvancedDonglSetNumericComparisonCallback) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_dongl_set_numeric_comparison_callback';
    Exit;
  end;
  {$IFDEF LINUX}
  {$IFNDEF ANDROID}
  Pointer(SimpleBleAdvancedLinuxSetAdvertisementLocalName) := GetProcedureAddress(hLib, 'simpleble_advanced_linux_set_advertisement_local_name');
  if Pointer(SimpleBleAdvancedLinuxSetAdvertisementLocalName) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_linux_set_advertisement_local_name';
    Exit;
  end;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
  Pointer(SimpleBleAdvancedMacosSetAdvertisementLocalName) := GetProcedureAddress(hLib, 'simpleble_advanced_macos_set_advertisement_local_name');
  if Pointer(SimpleBleAdvancedMacosSetAdvertisementLocalName) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_macos_set_advertisement_local_name';
    Exit;
  end;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFNDEF IOS}
  Pointer(SimpleBleAdvancedMacosRetrieveCachedPeripheral) := GetProcedureAddress(hLib, 'simpleble_advanced_macos_retrieve_cached_peripheral');
  if Pointer(SimpleBleAdvancedMacosRetrieveCachedPeripheral) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_macos_retrieve_cached_peripheral';
    Exit;
  end;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
  Pointer(SimpleBleAdvancedIosSetAdvertisementLocalName) := GetProcedureAddress(hLib, 'simpleble_advanced_ios_set_advertisement_local_name');
  if Pointer(SimpleBleAdvancedIosSetAdvertisementLocalName) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_ios_set_advertisement_local_name';
    Exit;
  end;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF DARWIN}
  {$IFDEF IOS}
  Pointer(SimpleBleAdvancedIosRetrieveCachedPeripheral) := GetProcedureAddress(hLib, 'simpleble_advanced_ios_retrieve_cached_peripheral');
  if Pointer(SimpleBleAdvancedIosRetrieveCachedPeripheral) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_ios_retrieve_cached_peripheral';
    Exit;
  end;
  {$ENDIF}
  {$ENDIF}
  {$IFDEF ANDROID}
  Pointer(SimpleBleAdvancedAndroidGetJvm) := GetProcedureAddress(hLib, 'simpleble_advanced_android_get_jvm');
  if Pointer(SimpleBleAdvancedAndroidGetJvm) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_android_get_jvm';
    Exit;
  end;
  {$ENDIF}
  {$IFDEF ANDROID}
  Pointer(SimpleBleAdvancedAndroidSetJvm) := GetProcedureAddress(hLib, 'simpleble_advanced_android_set_jvm');
  if Pointer(SimpleBleAdvancedAndroidSetJvm) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_android_set_jvm';
    Exit;
  end;
  {$ENDIF}
  {$IFDEF ANDROID}
  Pointer(SimpleBleAdvancedAndroidSetContext) := GetProcedureAddress(hLib, 'simpleble_advanced_android_set_context');
  if Pointer(SimpleBleAdvancedAndroidSetContext) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_advanced_android_set_context';
    Exit;
  end;
  {$ENDIF}
  Pointer(SimpleBleBackendGetCount) := GetProcedureAddress(hLib, 'simpleble_backend_get_count');
  if Pointer(SimpleBleBackendGetCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_backend_get_count';
    Exit;
  end;
  Pointer(SimpleBleBackendGetHandle) := GetProcedureAddress(hLib, 'simpleble_backend_get_handle');
  if Pointer(SimpleBleBackendGetHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_backend_get_handle';
    Exit;
  end;
  Pointer(SimpleBleBackendReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_backend_release_handle');
  if Pointer(SimpleBleBackendReleaseHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_backend_release_handle';
    Exit;
  end;
  Pointer(SimpleBleBackendIdentifier) := GetProcedureAddress(hLib, 'simpleble_backend_identifier');
  if Pointer(SimpleBleBackendIdentifier) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_backend_identifier';
    Exit;
  end;
  Pointer(SimpleBleBackendIsBluetoothEnabled) := GetProcedureAddress(hLib, 'simpleble_backend_is_bluetooth_enabled');
  if Pointer(SimpleBleBackendIsBluetoothEnabled) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_backend_is_bluetooth_enabled';
    Exit;
  end;
  Pointer(SimpleBleBackendGetAdaptersCount) := GetProcedureAddress(hLib, 'simpleble_backend_get_adapters_count');
  if Pointer(SimpleBleBackendGetAdaptersCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_backend_get_adapters_count';
    Exit;
  end;
  Pointer(SimpleBleBackendGetAdaptersHandle) := GetProcedureAddress(hLib, 'simpleble_backend_get_adapters_handle');
  if Pointer(SimpleBleBackendGetAdaptersHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_backend_get_adapters_handle';
    Exit;
  end;
  Pointer(SimpleBleConfigResetAll) := GetProcedureAddress(hLib, 'simpleble_config_reset_all');
  if Pointer(SimpleBleConfigResetAll) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_reset_all';
    Exit;
  end;
  Pointer(SimpleBleConfigSimpleBluezReset) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_reset');
  if Pointer(SimpleBleConfigSimpleBluezReset) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_simplebluez_reset';
    Exit;
  end;
  Pointer(SimpleBleConfigSimpleBluezGetUseSystemBus) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_get_use_system_bus');
  if Pointer(SimpleBleConfigSimpleBluezGetUseSystemBus) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_simplebluez_get_use_system_bus';
    Exit;
  end;
  Pointer(SimpleBleConfigSimpleBluezSetUseSystemBus) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_set_use_system_bus');
  if Pointer(SimpleBleConfigSimpleBluezSetUseSystemBus) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_simplebluez_set_use_system_bus';
    Exit;
  end;
  Pointer(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_get_connection_timeout_ms');
  if Pointer(SimpleBleConfigSimpleBluezGetConnectionTimeoutMs) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_simplebluez_get_connection_timeout_ms';
    Exit;
  end;
  Pointer(SimpleBleConfigSimpleBluezSetConnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_set_connection_timeout_ms');
  if Pointer(SimpleBleConfigSimpleBluezSetConnectionTimeoutMs) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_simplebluez_set_connection_timeout_ms';
    Exit;
  end;
  Pointer(SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_get_disconnection_timeout_ms');
  if Pointer(SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_simplebluez_get_disconnection_timeout_ms';
    Exit;
  end;
  Pointer(SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs) := GetProcedureAddress(hLib, 'simpleble_config_simplebluez_set_disconnection_timeout_ms');
  if Pointer(SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_simplebluez_set_disconnection_timeout_ms';
    Exit;
  end;
  Pointer(SimpleBleConfigWinRtReset) := GetProcedureAddress(hLib, 'simpleble_config_winrt_reset');
  if Pointer(SimpleBleConfigWinRtReset) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_winrt_reset';
    Exit;
  end;
  Pointer(SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment) := GetProcedureAddress(hLib, 'simpleble_config_winrt_get_experimental_use_own_mta_apartment');
  if Pointer(SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_winrt_get_experimental_use_own_mta_apartment';
    Exit;
  end;
  Pointer(SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment) := GetProcedureAddress(hLib, 'simpleble_config_winrt_set_experimental_use_own_mta_apartment');
  if Pointer(SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_winrt_set_experimental_use_own_mta_apartment';
    Exit;
  end;
  Pointer(SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread) := GetProcedureAddress(hLib, 'simpleble_config_winrt_get_experimental_reinitialize_winrt_apartment_on_main_thread');
  if Pointer(SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_winrt_get_experimental_reinitialize_winrt_apartment_on_main_thread';
    Exit;
  end;
  Pointer(SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread) := GetProcedureAddress(hLib, 'simpleble_config_winrt_set_experimental_reinitialize_winrt_apartment_on_main_thread');
  if Pointer(SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_winrt_set_experimental_reinitialize_winrt_apartment_on_main_thread';
    Exit;
  end;
  Pointer(SimpleBleConfigWinRtGetUseDeferredDisconnect) := GetProcedureAddress(hLib, 'simpleble_config_winrt_get_use_deferred_disconnect');
  if Pointer(SimpleBleConfigWinRtGetUseDeferredDisconnect) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_winrt_get_use_deferred_disconnect';
    Exit;
  end;
  Pointer(SimpleBleConfigWinRtSetUseDeferredDisconnect) := GetProcedureAddress(hLib, 'simpleble_config_winrt_set_use_deferred_disconnect');
  if Pointer(SimpleBleConfigWinRtSetUseDeferredDisconnect) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_winrt_set_use_deferred_disconnect';
    Exit;
  end;
  Pointer(SimpleBleConfigCoreBluetoothReset) := GetProcedureAddress(hLib, 'simpleble_config_corebluetooth_reset');
  if Pointer(SimpleBleConfigCoreBluetoothReset) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_corebluetooth_reset';
    Exit;
  end;
  Pointer(SimpleBleConfigAndroidReset) := GetProcedureAddress(hLib, 'simpleble_config_android_reset');
  if Pointer(SimpleBleConfigAndroidReset) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_android_reset';
    Exit;
  end;
  Pointer(SimpleBleConfigAndroidGetConnectionPriority) := GetProcedureAddress(hLib, 'simpleble_config_android_get_connection_priority');
  if Pointer(SimpleBleConfigAndroidGetConnectionPriority) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_android_get_connection_priority';
    Exit;
  end;
  Pointer(SimpleBleConfigAndroidSetConnectionPriority) := GetProcedureAddress(hLib, 'simpleble_config_android_set_connection_priority');
  if Pointer(SimpleBleConfigAndroidSetConnectionPriority) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_android_set_connection_priority';
    Exit;
  end;
  Pointer(SimpleBleConfigSetAndroidConnectionPriority) := GetProcedureAddress(hLib, 'simpleble_config_set_android_connection_priority');
  if Pointer(SimpleBleConfigSetAndroidConnectionPriority) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_set_android_connection_priority';
    Exit;
  end;
  Pointer(SimpleBleConfigDonglReset) := GetProcedureAddress(hLib, 'simpleble_config_dongl_reset');
  if Pointer(SimpleBleConfigDonglReset) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_dongl_reset';
    Exit;
  end;
  Pointer(SimpleBleConfigDonglGetUseDonglBackend) := GetProcedureAddress(hLib, 'simpleble_config_dongl_get_use_dongl_backend');
  if Pointer(SimpleBleConfigDonglGetUseDonglBackend) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_dongl_get_use_dongl_backend';
    Exit;
  end;
  Pointer(SimpleBleConfigDonglSetUseDonglBackend) := GetProcedureAddress(hLib, 'simpleble_config_dongl_set_use_dongl_backend');
  if Pointer(SimpleBleConfigDonglSetUseDonglBackend) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_dongl_set_use_dongl_backend';
    Exit;
  end;
  Pointer(SimpleBleConfigDonglGetAutoUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_get_auto_update');
  if Pointer(SimpleBleConfigDonglGetAutoUpdate) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_dongl_get_auto_update';
    Exit;
  end;
  Pointer(SimpleBleConfigDonglSetAutoUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_set_auto_update');
  if Pointer(SimpleBleConfigDonglSetAutoUpdate) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_dongl_set_auto_update';
    Exit;
  end;
  Pointer(SimpleBleConfigDonglGetForceUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_get_force_update');
  if Pointer(SimpleBleConfigDonglGetForceUpdate) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_dongl_get_force_update';
    Exit;
  end;
  Pointer(SimpleBleConfigDonglSetForceUpdate) := GetProcedureAddress(hLib, 'simpleble_config_dongl_set_force_update');
  if Pointer(SimpleBleConfigDonglSetForceUpdate) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_config_dongl_set_force_update';
    Exit;
  end;
  Pointer(SimpleBleErrorCode) := GetProcedureAddress(hLib, 'simpleble_error_code');
  if Pointer(SimpleBleErrorCode) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_error_code';
    Exit;
  end;
  Pointer(SimpleBleErrorMessage) := GetProcedureAddress(hLib, 'simpleble_error_message');
  if Pointer(SimpleBleErrorMessage) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_error_message';
    Exit;
  end;
  Pointer(SimpleBleErrorRelease) := GetProcedureAddress(hLib, 'simpleble_error_release');
  if Pointer(SimpleBleErrorRelease) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_error_release';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_release_handle');
  if Pointer(SimpleBleLocalCharacteristicReleaseHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_release_handle';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicUuid) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_uuid');
  if Pointer(SimpleBleLocalCharacteristicUuid) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_uuid';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicCapabilities) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_capabilities');
  if Pointer(SimpleBleLocalCharacteristicCapabilities) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_capabilities';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicValue) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_value');
  if Pointer(SimpleBleLocalCharacteristicValue) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_value';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicSetValue) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_set_value');
  if Pointer(SimpleBleLocalCharacteristicSetValue) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_set_value';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnRead) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_set_callback_on_read');
  if Pointer(SimpleBleLocalCharacteristicSetCallbackOnRead) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_set_callback_on_read';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnWrite) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_set_callback_on_write');
  if Pointer(SimpleBleLocalCharacteristicSetCallbackOnWrite) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_set_callback_on_write';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnSubscribed) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_set_callback_on_subscribed');
  if Pointer(SimpleBleLocalCharacteristicSetCallbackOnSubscribed) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_set_callback_on_subscribed';
    Exit;
  end;
  Pointer(SimpleBleLocalCharacteristicSetCallbackOnUnsubscribed) := GetProcedureAddress(hLib, 'simpleble_local_characteristic_set_callback_on_unsubscribed');
  if Pointer(SimpleBleLocalCharacteristicSetCallbackOnUnsubscribed) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_characteristic_set_callback_on_unsubscribed';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_release_handle');
  if Pointer(SimpleBleLocalPeripheralReleaseHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_release_handle';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralUnderlying) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_underlying');
  if Pointer(SimpleBleLocalPeripheralUnderlying) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_underlying';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralAddAdvertisedService) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_add_advertised_service');
  if Pointer(SimpleBleLocalPeripheralAddAdvertisedService) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_add_advertised_service';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralAddService) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_add_service');
  if Pointer(SimpleBleLocalPeripheralAddService) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_add_service';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralServicesCount) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_services_count');
  if Pointer(SimpleBleLocalPeripheralServicesCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_services_count';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralServicesGet) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_services_get');
  if Pointer(SimpleBleLocalPeripheralServicesGet) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_services_get';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralRemoveAllServices) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_remove_all_services');
  if Pointer(SimpleBleLocalPeripheralRemoveAllServices) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_remove_all_services';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralStart) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_start');
  if Pointer(SimpleBleLocalPeripheralStart) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_start';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralStop) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_stop');
  if Pointer(SimpleBleLocalPeripheralStop) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_stop';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralIsStarted) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_is_started');
  if Pointer(SimpleBleLocalPeripheralIsStarted) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_is_started';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralIsAdvertising) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_is_advertising');
  if Pointer(SimpleBleLocalPeripheralIsAdvertising) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_is_advertising';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralSetCallbackOnClientConnected) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_set_callback_on_client_connected');
  if Pointer(SimpleBleLocalPeripheralSetCallbackOnClientConnected) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_set_callback_on_client_connected';
    Exit;
  end;
  Pointer(SimpleBleLocalPeripheralSetCallbackOnClientDisconnected) := GetProcedureAddress(hLib, 'simpleble_local_peripheral_set_callback_on_client_disconnected');
  if Pointer(SimpleBleLocalPeripheralSetCallbackOnClientDisconnected) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_peripheral_set_callback_on_client_disconnected';
    Exit;
  end;
  Pointer(SimpleBleLocalServiceReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_local_service_release_handle');
  if Pointer(SimpleBleLocalServiceReleaseHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_service_release_handle';
    Exit;
  end;
  Pointer(SimpleBleLocalServiceCharacteristicsCount) := GetProcedureAddress(hLib, 'simpleble_local_service_characteristics_count');
  if Pointer(SimpleBleLocalServiceCharacteristicsCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_service_characteristics_count';
    Exit;
  end;
  Pointer(SimpleBleLocalServiceCharacteristicsGet) := GetProcedureAddress(hLib, 'simpleble_local_service_characteristics_get');
  if Pointer(SimpleBleLocalServiceCharacteristicsGet) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_service_characteristics_get';
    Exit;
  end;
  Pointer(SimpleBleLocalServiceUuid) := GetProcedureAddress(hLib, 'simpleble_local_service_uuid');
  if Pointer(SimpleBleLocalServiceUuid) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_service_uuid';
    Exit;
  end;
  Pointer(SimpleBleLocalServiceAddCharacteristic) := GetProcedureAddress(hLib, 'simpleble_local_service_add_characteristic');
  if Pointer(SimpleBleLocalServiceAddCharacteristic) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_local_service_add_characteristic';
    Exit;
  end;
  Pointer(SimpleBleLoggingSetLevel) := GetProcedureAddress(hLib, 'simpleble_logging_set_level');
  if Pointer(SimpleBleLoggingSetLevel) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_logging_set_level';
    Exit;
  end;
  Pointer(SimpleBleLoggingGetLevel) := GetProcedureAddress(hLib, 'simpleble_logging_get_level');
  if Pointer(SimpleBleLoggingGetLevel) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_logging_get_level';
    Exit;
  end;
  Pointer(SimpleBleLoggingSetCallback) := GetProcedureAddress(hLib, 'simpleble_logging_set_callback');
  if Pointer(SimpleBleLoggingSetCallback) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_logging_set_callback';
    Exit;
  end;
  Pointer(SimpleBleLoggingHasCallback) := GetProcedureAddress(hLib, 'simpleble_logging_has_callback');
  if Pointer(SimpleBleLoggingHasCallback) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_logging_has_callback';
    Exit;
  end;
  Pointer(SimpleBleLoggingLogDefaultStdout) := GetProcedureAddress(hLib, 'simpleble_logging_log_default_stdout');
  if Pointer(SimpleBleLoggingLogDefaultStdout) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_logging_log_default_stdout';
    Exit;
  end;
  Pointer(SimpleBleLoggingLogDefaultFile) := GetProcedureAddress(hLib, 'simpleble_logging_log_default_file');
  if Pointer(SimpleBleLoggingLogDefaultFile) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_logging_log_default_file';
    Exit;
  end;
  Pointer(SimpleBleLoggingLogDefaultFilePath) := GetProcedureAddress(hLib, 'simpleble_logging_log_default_file_path');
  if Pointer(SimpleBleLoggingLogDefaultFilePath) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_logging_log_default_file_path';
    Exit;
  end;
  Pointer(SimpleBlePeripheralReleaseHandle) := GetProcedureAddress(hLib, 'simpleble_peripheral_release_handle');
  if Pointer(SimpleBlePeripheralReleaseHandle) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_release_handle';
    Exit;
  end;
  Pointer(SimpleBlePeripheralUnderlying) := GetProcedureAddress(hLib, 'simpleble_peripheral_underlying');
  if Pointer(SimpleBlePeripheralUnderlying) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_underlying';
    Exit;
  end;
  Pointer(SimpleBlePeripheralIdentifier) := GetProcedureAddress(hLib, 'simpleble_peripheral_identifier');
  if Pointer(SimpleBlePeripheralIdentifier) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_identifier';
    Exit;
  end;
  Pointer(SimpleBlePeripheralAddress) := GetProcedureAddress(hLib, 'simpleble_peripheral_address');
  if Pointer(SimpleBlePeripheralAddress) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_address';
    Exit;
  end;
  Pointer(SimpleBlePeripheralAddressType) := GetProcedureAddress(hLib, 'simpleble_peripheral_address_type');
  if Pointer(SimpleBlePeripheralAddressType) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_address_type';
    Exit;
  end;
  Pointer(SimpleBlePeripheralRssi) := GetProcedureAddress(hLib, 'simpleble_peripheral_rssi');
  if Pointer(SimpleBlePeripheralRssi) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_rssi';
    Exit;
  end;
  Pointer(SimpleBlePeripheralTxPower) := GetProcedureAddress(hLib, 'simpleble_peripheral_tx_power');
  if Pointer(SimpleBlePeripheralTxPower) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_tx_power';
    Exit;
  end;
  Pointer(SimpleBlePeripheralMtu) := GetProcedureAddress(hLib, 'simpleble_peripheral_mtu');
  if Pointer(SimpleBlePeripheralMtu) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_mtu';
    Exit;
  end;
  Pointer(SimpleBlePeripheralConnect) := GetProcedureAddress(hLib, 'simpleble_peripheral_connect');
  if Pointer(SimpleBlePeripheralConnect) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_connect';
    Exit;
  end;
  Pointer(SimpleBlePeripheralDisconnect) := GetProcedureAddress(hLib, 'simpleble_peripheral_disconnect');
  if Pointer(SimpleBlePeripheralDisconnect) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_disconnect';
    Exit;
  end;
  Pointer(SimpleBlePeripheralIsConnected) := GetProcedureAddress(hLib, 'simpleble_peripheral_is_connected');
  if Pointer(SimpleBlePeripheralIsConnected) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_is_connected';
    Exit;
  end;
  Pointer(SimpleBlePeripheralIsConnectable) := GetProcedureAddress(hLib, 'simpleble_peripheral_is_connectable');
  if Pointer(SimpleBlePeripheralIsConnectable) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_is_connectable';
    Exit;
  end;
  Pointer(SimpleBlePeripheralIsPaired) := GetProcedureAddress(hLib, 'simpleble_peripheral_is_paired');
  if Pointer(SimpleBlePeripheralIsPaired) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_is_paired';
    Exit;
  end;
  Pointer(SimpleBlePeripheralUnpair) := GetProcedureAddress(hLib, 'simpleble_peripheral_unpair');
  if Pointer(SimpleBlePeripheralUnpair) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_unpair';
    Exit;
  end;
  Pointer(SimpleBlePeripheralServicesCount) := GetProcedureAddress(hLib, 'simpleble_peripheral_services_count');
  if Pointer(SimpleBlePeripheralServicesCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_services_count';
    Exit;
  end;
  Pointer(SimpleBlePeripheralServicesGet) := GetProcedureAddress(hLib, 'simpleble_peripheral_services_get');
  if Pointer(SimpleBlePeripheralServicesGet) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_services_get';
    Exit;
  end;
  Pointer(SimpleBleServiceRelease) := GetProcedureAddress(hLib, 'simpleble_service_release');
  if Pointer(SimpleBleServiceRelease) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_service_release';
    Exit;
  end;
  Pointer(SimpleBlePeripheralManufacturerDataCount) := GetProcedureAddress(hLib, 'simpleble_peripheral_manufacturer_data_count');
  if Pointer(SimpleBlePeripheralManufacturerDataCount) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_manufacturer_data_count';
    Exit;
  end;
  Pointer(SimpleBlePeripheralManufacturerDataGet) := GetProcedureAddress(hLib, 'simpleble_peripheral_manufacturer_data_get');
  if Pointer(SimpleBlePeripheralManufacturerDataGet) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_manufacturer_data_get';
    Exit;
  end;
  Pointer(SimpleBleManufacturerDataRelease) := GetProcedureAddress(hLib, 'simpleble_manufacturer_data_release');
  if Pointer(SimpleBleManufacturerDataRelease) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_manufacturer_data_release';
    Exit;
  end;
  Pointer(SimpleBlePeripheralRead) := GetProcedureAddress(hLib, 'simpleble_peripheral_read');
  if Pointer(SimpleBlePeripheralRead) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_read';
    Exit;
  end;
  Pointer(SimpleBlePeripheralWriteRequest) := GetProcedureAddress(hLib, 'simpleble_peripheral_write_request');
  if Pointer(SimpleBlePeripheralWriteRequest) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_write_request';
    Exit;
  end;
  Pointer(SimpleBlePeripheralWriteCommand) := GetProcedureAddress(hLib, 'simpleble_peripheral_write_command');
  if Pointer(SimpleBlePeripheralWriteCommand) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_write_command';
    Exit;
  end;
  Pointer(SimpleBlePeripheralNotify) := GetProcedureAddress(hLib, 'simpleble_peripheral_notify');
  if Pointer(SimpleBlePeripheralNotify) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_notify';
    Exit;
  end;
  Pointer(SimpleBlePeripheralIndicate) := GetProcedureAddress(hLib, 'simpleble_peripheral_indicate');
  if Pointer(SimpleBlePeripheralIndicate) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_indicate';
    Exit;
  end;
  Pointer(SimpleBlePeripheralUnsubscribe) := GetProcedureAddress(hLib, 'simpleble_peripheral_unsubscribe');
  if Pointer(SimpleBlePeripheralUnsubscribe) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_unsubscribe';
    Exit;
  end;
  Pointer(SimpleBlePeripheralReadDescriptor) := GetProcedureAddress(hLib, 'simpleble_peripheral_read_descriptor');
  if Pointer(SimpleBlePeripheralReadDescriptor) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_read_descriptor';
    Exit;
  end;
  Pointer(SimpleBlePeripheralWriteDescriptor) := GetProcedureAddress(hLib, 'simpleble_peripheral_write_descriptor');
  if Pointer(SimpleBlePeripheralWriteDescriptor) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_write_descriptor';
    Exit;
  end;
  Pointer(SimpleBlePeripheralSetCallbackOnConnected) := GetProcedureAddress(hLib, 'simpleble_peripheral_set_callback_on_connected');
  if Pointer(SimpleBlePeripheralSetCallbackOnConnected) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_set_callback_on_connected';
    Exit;
  end;
  Pointer(SimpleBlePeripheralSetCallbackOnDisconnected) := GetProcedureAddress(hLib, 'simpleble_peripheral_set_callback_on_disconnected');
  if Pointer(SimpleBlePeripheralSetCallbackOnDisconnected) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_peripheral_set_callback_on_disconnected';
    Exit;
  end;
  Pointer(SimpleBleGetOperatingSystem) := GetProcedureAddress(hLib, 'simpleble_get_operating_system');
  if Pointer(SimpleBleGetOperatingSystem) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_get_operating_system';
    Exit;
  end;
  Pointer(SimpleBleFree) := GetProcedureAddress(hLib, 'simpleble_free');
  if Pointer(SimpleBleFree) = nil then
  begin
    LastLoadError := 'SimpleCBLE 1.2.0 is missing required symbol: simpleble_free';
    Exit;
  end;
  Result := True;
end;

function ParseVersionPart(const AValue: string; out ANumber: Integer): Boolean;
var
  Index: Integer;
begin
  Result := False;
  if AValue = '' then
    Exit;
  for Index := 1 to Length(AValue) do
    if not (AValue[Index] in ['0'..'9']) then
      Exit;
  Result := TryStrToInt(AValue, ANumber);
  if Result then
    Result := ANumber >= 0;
end;

function ParseNativeVersion(const AValue: string; out AMajor, AMinor,
  APatch: Integer): Boolean;
var
  FirstDot: Integer;
  SecondDot: Integer;
  Remaining: string;
begin
  Result := False;
  FirstDot := Pos('.', AValue);
  if FirstDot = 0 then
    Exit;
  Remaining := Copy(AValue, FirstDot + 1, MaxInt);
  SecondDot := Pos('.', Remaining);
  if (SecondDot = 0) or (Pos('.', Copy(Remaining, SecondDot + 1,
    MaxInt)) <> 0) then
    Exit;
  Result := ParseVersionPart(Copy(AValue, 1, FirstDot - 1), AMajor) and
    ParseVersionPart(Copy(Remaining, 1, SecondDot - 1), AMinor) and
    ParseVersionPart(Copy(Remaining, SecondDot + 1, MaxInt), APatch);
end;

function SimpleBleLoadLibrary(dllPath: string = ''): Boolean;
var
  CorePath: string;
  ExtPath: string;
  MinimumMajor: Integer;
  MinimumMinor: Integer;
  MinimumPatch: Integer;
  NativeMajor: Integer;
  NativeMinor: Integer;
  NativePatch: Integer;
  VersionText: PChar;
begin
  Result := False;
  SimpleBleUnloadLibrary;
  LastLoadError := '';
  LastLoadWarning := '';

  if dllPath <> '' then
  begin
    if not DirectoryExists(dllPath) then
    begin
      LastLoadError := 'Library directory does not exist: ' + dllPath;
      Exit;
    end;
    CorePath := IncludeTrailingPathDelimiter(dllPath) + SimpleBleCoreLibrary;
    ExtPath := IncludeTrailingPathDelimiter(dllPath) + SimpleBleExtLibrary;
    if not FileExists(CorePath) then
    begin
      LastLoadError := 'Native library not found: ' + CorePath;
      Exit;
    end;
    if not FileExists(ExtPath) then
    begin
      LastLoadError := 'Native library not found: ' + ExtPath;
      Exit;
    end;
  end
  else
  begin
    CorePath := SimpleBleCoreLibrary;
    ExtPath := SimpleBleExtLibrary;
  end;

  hCoreLib := LoadLibrary(PChar(CorePath));
  if hCoreLib = 0 then
  begin
    LastLoadError := 'Failed to load native library: ' + CorePath;
    Exit;
  end;
  hLib := LoadLibrary(PChar(ExtPath));
  if hLib = 0 then
  begin
    LastLoadError := 'Failed to load native library: ' + ExtPath;
    SimpleBleUnloadLibrary;
    Exit;
  end;

  try
    { This is the only C function called before the ABI version gate. }
    Pointer(SimpleBleGetVersion) :=
      GetProcedureAddress(hLib, 'simpleble_get_version');
    if Pointer(SimpleBleGetVersion) = nil then
      LastLoadError :=
        'SimpleCBLE ' + SimpleBleMinimumNativeVersion +
        ' is missing required symbol: simpleble_get_version'
    else
    begin
      VersionText := SimpleBleGetVersion();
      if VersionText = nil then
        LastLoadError := 'SimpleCBLE returned a null version string'
      else
      begin
        if not ParseNativeVersion(SimpleBleMinimumNativeVersion,
          MinimumMajor, MinimumMinor, MinimumPatch) then
          LastLoadError := 'Invalid minimum SimpleCBLE version: ' +
            SimpleBleMinimumNativeVersion
        else if not ParseNativeVersion(string(VersionText), NativeMajor,
          NativeMinor, NativePatch) then
          LastLoadError := 'Invalid SimpleCBLE version: ' +
            string(VersionText)
        else if (NativeMajor < MinimumMajor) or
          ((NativeMajor = MinimumMajor) and
          ((NativeMinor < MinimumMinor) or
          ((NativeMinor = MinimumMinor) and
          (NativePatch < MinimumPatch)))) then
          LastLoadError := 'Unsupported SimpleCBLE version: ' +
            string(VersionText) + ' (minimum ' +
            SimpleBleMinimumNativeVersion + ')'
        else
        begin
          if NativeMajor > MinimumMajor then
            LastLoadWarning := 'SimpleCBLE version ' +
              string(VersionText) + ' is newer than the tested major range ' +
              SimpleBleMinimumNativeVersion + '..<' +
              IntToStr(MinimumMajor + 1) + '.0.0; ABI compatibility is not ' +
              'guaranteed';
          Result := ResolveRequiredSymbols;
        end;
      end;
    end;
  except
    on E: Exception do
      LastLoadError := 'Failed to resolve SimpleCBLE symbols: ' + E.Message;
  end;
  if not Result then
    SimpleBleUnloadLibrary;
end;

function SimpleBleGetLastLoadError(): string;
begin
  Result := LastLoadError;
end;

function SimpleBleGetLastLoadWarning(): string;
begin
  Result := LastLoadWarning;
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
