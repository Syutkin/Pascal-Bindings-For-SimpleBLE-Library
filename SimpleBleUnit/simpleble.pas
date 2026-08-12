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

  {$IFDEF FPC}
  {$PACKRECORDS C}
  {$PACKENUM 4}
  {$ENDIF}

  //#define SIMPLEBLE_UUID_STR_LEN 37  // 36 characters + null terminator
  //#define SIMPLEBLE_CHARACTERISTIC_MAX_COUNT 16
  //#define SIMPLEBLE_DESCRIPTOR_MAX_COUNT 16
  //Note: in C array declaration the above is the number of elements,
  //hence in Pascal we need to subtract 1 in the array declaration
  //like array[0..SIMPLEBLE_UUID_STR_LEN-1]
  SIMPLEBLE_UUID_STR_LEN = 37;
  SIMPLEBLE_CHARACTERISTIC_MAX_COUNT = 16;
  SIMPLEBLE_DESCRIPTOR_MAX_COUNT = 16;


{ types from SimpleBLE types.h }

type
  //typedef enum {
  //    SIMPLEBLE_SUCCESS = 0,
  //    SIMPLEBLE_FAILURE = 1,
  //} simpleble_err_t;
  TSimpleBleErr = (SIMPLEBLE_SUCCESS = 0, SIMPLEBLE_FAILURE = 1);

  //typedef struct {
  //  char value[SIMPLEBLE_UUID_STR_LEN];
  //} simpleble_uuid_t;
  TSimpleBleUuid = record
    Value: array[0..SIMPLEBLE_UUID_STR_LEN-1] of Char;
  end;

  //typedef struct {
  //    simpleble_uuid_t uuid;
  //} simpleble_descriptor_t;
  TSimpleBleDescriptor = record
    Uuid: TSimpleBleUuid;
  end;

  //typedef struct {
  //    simpleble_uuid_t uuid;
  //    bool can_read;
  //    bool can_write_request;
  //    bool can_write_command;
  //    bool can_notify;
  //    bool can_indicate;
  //    size_t descriptor_count;
  //    simpleble_descriptor_t descriptors[SIMPLEBLE_DESCRIPTOR_MAX_COUNT];
  //} simpleble_characteristic_t;
  TSimpleBleCharacteristic = record
    Uuid: TSimpleBleUuid;
    CanRead: Boolean;
    CanWriteRequest: Boolean;
    CanWriteCommand: Boolean;
    CanNotify: Boolean;
    CanIndicate: Boolean;
    DescriptorCount: NativeUInt;
    Descriptors: array[0..SIMPLEBLE_DESCRIPTOR_MAX_COUNT-1] of TSimpleBleDescriptor;
  end;

  //typedef struct {
  //    simpleble_uuid_t uuid;
  //    size_t data_length;
  //    uint8_t data[27];
  //    // Note: The maximum length of a BLE advertisement is 31 bytes.
  //    // The first byte will be the length of the field,
  //    // the second byte will be the type of the field,
  //    // the next two bytes will be the service UUID,
  //    // and the remaining 27 bytes are the manufacturer data.
  //    size_t characteristic_count;
  //    simpleble_characteristic_t characteristics[SIMPLEBLE_CHARACTERISTIC_MAX_COUNT];
  //} simpleble_service_t;
  TSimpleBleService = record
    Uuid: TSimpleBleUuid;
    DataLength: NativeUInt;
    Data: array[0..27-1] of Byte;
    CharacteristicCount: NativeUInt;
    Characteristics: array[0..SIMPLEBLE_CHARACTERISTIC_MAX_COUNT-1] of TSimpleBleCharacteristic;
  end;

  //typedef struct {
  //    uint16_t manufacturer_id;
  //    size_t data_length;
  //    uint8_t data[27];
  //    // Note: The maximum length of a BLE advertisement is 31 bytes.
  //    // The first byte will be the length of the field,
  //    // the second byte will be the type of the field (0xFF for manufacturer data),
  //    // the next two bytes will be the manufacturer ID,
  //    // and the remaining 27 bytes are the manufacturer data.
  //} simpleble_manufacturer_data_t;
  TSimpleBleManufacturerData = record
    ManufacturerId: UInt16;
    DataLength: NativeUInt;
    Data: array[0..27-1] of Byte
  end;

  //typedef void* simpleble_adapter_t;
  //typedef void* simpleble_peripheral_t;
  TSimpleBleAdapter = Pointer;
  TSimpleBlePeripheral = Pointer;

  //typedef enum {
  //  SIMPLEBLE_OS_WINDOWS = 0,
  //  SIMPLEBLE_OS_MACOS = 1,
  //  SIMPLEBLE_OS_LINUX = 2,
  //} simpleble_os_t;
  TSimpleBleOs = (SIMPLEBLE_OS_WINDOWS = 0, SIMPLEBLE_OS_MACOS = 1,
    SIMPLEBLE_OS_LINUX = 2, SIMPLEBLE_OS_IOS = 3,
    SIMPLEBLE_OS_ANDROID = 4, SIMPLEBLE_OS_UNKNOWN = 5);

  //typedef enum {
  //    SIMPLEBLE_ADDRESS_TYPE_PUBLIC = 0,
  //    SIMPLEBLE_ADDRESS_TYPE_RANDOM = 1,
  //    SIMPLEBLE_ADDRESS_TYPE_UNSPECIFIED = 2,
  //} simpleble_address_type_t;
  TSimpleBleAddressType = (SIMPLEBLE_ADDRESS_TYPE_PUBLIC = 0, SIMPLEBLE_ADDRESS_TYPE_RANDOM = 1, SIMPLEBLE_ADDRESS_TYPE_UNSPECIFIED = 2);

  TSimpleBleConfigAndroidConnectionPriority = type LongInt;

const
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DISABLED = -1;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_BALANCED = 0;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_HIGH = 1;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_LOW_POWER = 2;
  SIMPLEBLE_CONFIG_ANDROID_CONNECTION_PRIORITY_DCK = 3;

procedure SimpleBlePinLibrary();

{$IFNDEF DYNAMIC_LOADING}

{ functions from SimpleBLE adapter.h }

// new types for callback functions
type
  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_start(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, void* userdata), void* userdata);
  TSimpleBleCallbackScanStart = procedure(Adapter: TSimpleBleAdapter; UserData: Pointer); cdecl;

  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_stop(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, void* userdata), void* userdata);
  TSimpleBleCallbackScanStop = procedure(Adapter: TSimpleBleAdapter; UserData: Pointer); cdecl;

  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_updated(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, simpleble_peripheral_t peripheral, void* userdata), void* userdata);
  TSimpleBleCallbackScanUpdated = procedure(Adapter: TSimpleBleAdapter; Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;

  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_found(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, simpleble_peripheral_t peripheral, void* userdata), void* userdata);
  TSimpleBleCallbackScanFound = procedure(Adapter: TSimpleBleAdapter; Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;

//SIMPLEBLE_EXPORT bool simpleble_adapter_is_bluetooth_enabled(void);
function SimpleBleAdapterIsBluetoothEnabled(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_is_bluetooth_enabled';

//SIMPLEBLE_EXPORT size_t simpleble_adapter_get_count(void);
function SimpleBleAdapterGetCount(): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_count';

//SIMPLEBLE_EXPORT simpleble_adapter_t simpleble_adapter_get_handle(size_t index);
function SimpleBleAdapterGetHandle(Index: NativeUInt): TSimpleBleAdapter; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_handle';

//SIMPLEBLE_EXPORT void simpleble_adapter_release_handle(simpleble_adapter_t handle);
procedure SimpleBleAdapterReleaseHandle(Handle: TSimpleBleAdapter); cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_release_handle';

function SimpleBleAdapterUnderlying(Handle: TSimpleBleAdapter): Pointer; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_underlying';

//SIMPLEBLE_EXPORT char* simpleble_adapter_identifier(simpleble_adapter_t handle);
function SimpleBleAdapterIdentifier(Handle: TSimpleBleAdapter): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_identifier';

//SIMPLEBLE_EXPORT char* simpleble_adapter_address(simpleble_adapter_t handle);
function SimpleBleAdapterAddress(Handle: TSimpleBleAdapter): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_address';

function SimpleBleAdapterPowerOn(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_power_on';
function SimpleBleAdapterPowerOff(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_power_off';
function SimpleBleAdapterIsPowered(Handle: TSimpleBleAdapter; var Powered: Boolean): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_is_powered';
function SimpleBleAdapterSetCallbackOnPowerOn(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_power_on';
function SimpleBleAdapterSetCallbackOnPowerOff(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStop; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_power_off';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_scan_start(simpleble_adapter_t handle);
function SimpleBleAdapterScanStart(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_start';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_scan_stop(simpleble_adapter_t handle);
function SimpleBleAdapterScanStop(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_stop';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_scan_is_active(simpleble_adapter_t handle, bool* active);
function SimpleBleAdapterScanIsActive(Handle: TSimpleBleAdapter; var Active: Boolean): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_is_active';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_scan_for(simpleble_adapter_t handle, int timeout_ms);
function SimpleBleAdapterScanFor(Handle: TSimpleBleAdapter; TimeoutMs: Integer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_for';

//SIMPLEBLE_EXPORT size_t simpleble_adapter_scan_get_results_count(simpleble_adapter_t handle);
function SimpleBleAdapterScanGetResultsCount(Handle: TSimpleBleAdapter): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_get_results_count';

//SIMPLEBLE_EXPORT simpleble_peripheral_t simpleble_adapter_scan_get_results_handle(simpleble_adapter_t handle, size_t index);
function SimpleBleAdapterScanGetResultsHandle(Handle: TSimpleBleAdapter; Index: NativeUInt): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_scan_get_results_handle';

//SIMPLEBLE_EXPORT size_t simpleble_adapter_get_paired_peripherals_count(simpleble_adapter_t handle);
function SimpleBleAdapterGetPairedPeripheralsCount(Handle: TSimpleBleAdapter): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_paired_peripherals_count';

//SIMPLEBLE_EXPORT simpleble_peripheral_t simpleble_adapter_get_paired_peripherals_handle(simpleble_adapter_t handle, size_t index);
function SimpleBleAdapterGetPairedPeripheralsHandle(Handle: TSimpleBleAdapter; Index: NativeUInt): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_paired_peripherals_handle';

function SimpleBleAdapterGetConnectedPeripheralsCount(Handle: TSimpleBleAdapter): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_connected_peripherals_count';
function SimpleBleAdapterGetConnectedPeripheralsHandle(Handle: TSimpleBleAdapter; Index: NativeUInt): TSimpleBlePeripheral; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_get_connected_peripherals_handle';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_start(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, void* UserData), void* userdata);
function SimpleBleAdapterSetCallbackOnScanStart(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; UserData: Pointer): TSimpleBleErr;  cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_start';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_stop(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, void* userdata), void* userdata);
function SimpleBleAdapterSetCallbackOnScanStop(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStop; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_stop';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_updated(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, simpleble_peripheral_t peripheral, void* userdata), void* userdata);
function SimpleBleAdapterSetCallbackOnScanUpdated(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanUpdated; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_updated';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_adapter_set_callback_on_scan_found(simpleble_adapter_t handle, void (*callback)(simpleble_adapter_t adapter, simpleble_peripheral_t peripheral, void* userdata), void* userdata);
function SimpleBleAdapterSetCallbackOnScanFound(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanFound; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_adapter_set_callback_on_scan_found';


{ functions from SimpleBLE peripheral.h }

// new types for callback functions
type
  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_set_callback_on_connected(simpleble_peripheral_t handle, void (*callback)(simpleble_peripheral_t peripheral, void* userdata), void* userdata);
  TSimpleBleCallbackOnConnected = procedure(Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;

  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_set_callback_on_disconnected(simpleble_peripheral_t handle, void (*callback)(simpleble_peripheral_t peripheral, void* userdata), void* userdata);
  TSimpleBleCallbackOnDisconnected = procedure(Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;

  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_notify(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, void (*callback)(simpleble_uuid_t service, simpleble_uuid_t characteristic, const uint8_t* data, size_t data_length, void* userdata), void* userdata);
  TSimpleBleCallbackNotify = procedure(Peripheral: TSimpleBlePeripheral;
    Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte;
    DataLength: NativeUInt; UserData: Pointer); cdecl;

  //SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_indicate(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, void (*callback)(simpleble_uuid_t service, simpleble_uuid_t characteristic, const uint8_t* data, size_t data_length, void* userdata), void* userdata);
  TSimpleBleCallbackIndicate = procedure(Peripheral: TSimpleBlePeripheral;
    Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte;
    DataLength: NativeUInt; UserData: Pointer); cdecl;

//SIMPLEBLE_EXPORT void simpleble_peripheral_release_handle(simpleble_peripheral_t handle);
procedure SimpleBlePeripheralReleaseHandle(Handle: TSimpleBlePeripheral); cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_release_handle';

function SimpleBlePeripheralUnderlying(Handle: TSimpleBlePeripheral): Pointer; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_underlying';

//SIMPLEBLE_EXPORT char* simpleble_peripheral_identifier(simpleble_peripheral_t handle);
function SimpleBlePeripheralIdentifier(Handle: TSimpleBlePeripheral): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_identifier';

//SIMPLEBLE_EXPORT char* simpleble_peripheral_address(simpleble_peripheral_t handle);
function SimpleBlePeripheralAddress(Handle: TSimpleBlePeripheral): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_address';

//SIMPLEBLE_EXPORT simpleble_address_type_t simpleble_peripheral_address_type(simpleble_peripheral_t handle);
function SimpleBlePeripheralAddressType(Handle: TSimpleBlePeripheral): TSimpleBleAddressType; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_address_type';

//SIMPLEBLE_EXPORT int16_t simpleble_peripheral_rssi(simpleble_peripheral_t handle);
function SimpleBlePeripheralRssi(Handle: TSimpleBlePeripheral): Int16; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_rssi';

//SIMPLEBLE_EXPORT int16_t simpleble_peripheral_tx_power(simpleble_peripheral_t handle);
function SimpleBlePeripheralTxPower(Handle: TSimpleBlePeripheral): Int16; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_tx_power';

//SIMPLEBLE_EXPORT uint16_t simpleble_peripheral_mtu(simpleble_peripheral_t handle);
function SimpleBlePeripheralMtu(Handle: TSimpleBlePeripheral): UInt16; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_mtu';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_connect(simpleble_peripheral_t handle);
function SimpleBlePeripheralConnect(Handle: TSimpleBlePeripheral): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_connect';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_disconnect(simpleble_peripheral_t handle);
function SimpleBlePeripheralDisconnect(Handle: TSimpleBlePeripheral): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_disconnect';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_is_connected(simpleble_peripheral_t handle, bool* connected);
function SimpleBlePeripheralIsConnected(Handle: TSimpleBlePeripheral; var Connected: Boolean): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_is_connected';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_is_connectable(simpleble_peripheral_t handle, bool* connectable);
function SimpleBlePeripheralIsConnectable(Handle: TSimpleBlePeripheral; var Connectable: Boolean): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_is_connectable';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_is_paired(simpleble_peripheral_t handle, bool* paired);
function SimpleBlePeripheralIsPaired(Handle: TSimpleBlePeripheral; var Paired: Boolean): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_is_paired';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_unpair(simpleble_peripheral_t handle);
function SimpleBlePeripheralUnpair(Handle: TSimpleBlePeripheral): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_unpair';

//SIMPLEBLE_EXPORT size_t simpleble_peripheral_services_count(simpleble_peripheral_t handle);
function SimpleBlePeripheralServicesCount(Handle: TSimpleBlePeripheral): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_services_count';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_services_get(simpleble_peripheral_t handle, size_t index, simpleble_service_t* services);
function SimpleBlePeripheralServicesGet(Handle: TSimpleBlePeripheral; Index: NativeUInt; var Services: TSimpleBleService): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_services_get';

//SIMPLEBLE_EXPORT size_t simpleble_peripheral_manufacturer_data_count(simpleble_peripheral_t handle);
function SimpleBlePeripheralManufacturerDataCount(Handle: TSimpleBlePeripheral): NativeUInt; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_manufacturer_data_count';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_manufacturer_data_get(simpleble_peripheral_t handle, size_t index, simpleble_manufacturer_data_t* manufacturer_data);
function SimpleBlePeripheralManufacturerDataGet(Handle: TSimpleBlePeripheral; Index: NativeUInt; var ManufacturerData: TSimpleBleManufacturerData): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_manufacturer_data_get';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_read(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, uint8_t** data, size_t* data_length);
function SimpleBlePeripheralRead(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; var Data: PByte; var DataLength: NativeUInt): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_read';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_write_request(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, const uint8_t* data, size_t data_length);
function SimpleBlePeripheralWriteRequest(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_write_request';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_write_command(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, const uint8_t* data, size_t data_length);
function SimpleBlePeripheralWriteCommand(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_write_command';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_notify(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, void (*callback)(simpleble_uuid_t service, simpleble_uuid_t characteristic, const uint8_t* data, size_t data_length, void* userdata), void* userdata);
function SimpleBlePeripheralNotify(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackNotify; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_notify';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_indicate(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, void (*callback)(simpleble_uuid_t service, simpleble_uuid_t characteristic, const uint8_t* data, size_t data_length, void* userdata), void* userdata);
function SimpleBlePeripheralIndicate(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackIndicate; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_indicate';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_unsubscribe(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic);
function SimpleBlePeripheralUnsubscribe(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid):TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_unsubscribe';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_read_descriptor(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, simpleble_uuid_t descriptor, uint8_t** data, size_t* data_length);
function SimpleBlePeripheralReadDescriptor(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; var Data: PByte; var DataLength: NativeUInt): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_read_descriptor';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_write_descriptor(simpleble_peripheral_t handle, simpleble_uuid_t service, simpleble_uuid_t characteristic, simpleble_uuid_t descriptor, const uint8_t* data, size_t data_length);
function SimpleBlePeripheralWriteDescriptor(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_write_descriptor';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_set_callback_on_connected(simpleble_peripheral_t handle, void (*callback)(simpleble_peripheral_t peripheral, void* userdata), void* userdata);
function SimpleBlePeripheralSetCallbackOnConnected(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnConnected; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_set_callback_on_connected';

//SIMPLEBLE_EXPORT simpleble_err_t simpleble_peripheral_set_callback_on_disconnected(simpleble_peripheral_t handle, void (*callback)(simpleble_peripheral_t peripheral, void* userdata), void* userdata);
function SimpleBlePeripheralSetCallbackOnDisconnected(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnDisconnected; UserData: Pointer): TSimpleBleErr; cdecl; external SimpleBleExtLibrary name 'simpleble_peripheral_set_callback_on_disconnected';


{ functions from SimpleBLE simpleble.h }

//SIMPLEBLE_EXPORT void simpleble_free(void* handle);
procedure SimpleBleFree(Handle: Pointer); cdecl; external SimpleBleExtLibrary name 'simpleble_free';


{ functions from SimpleBLE logging.h }

type
  //typedef enum {
  //  SIMPLEBLE_LOG_LEVEL_NONE = 0,
  //  SIMPLEBLE_LOG_LEVEL_FATAL,
  //  SIMPLEBLE_LOG_LEVEL_ERROR,
  //  SIMPLEBLE_LOG_LEVEL_WARN,
  //  SIMPLEBLE_LOG_LEVEL_INFO,
  //  SIMPLEBLE_LOG_LEVEL_DEBUG,
  //  SIMPLEBLE_LOG_LEVEL_VERBOSE
  //} simpleble_log_level_t;
  TSimpleBleLogLevel = (SIMPLEBLE_LOG_LEVEL_NONE    = 0,
                        SIMPLEBLE_LOG_LEVEL_FATAL   = 1,
                        SIMPLEBLE_LOG_LEVEL_ERROR   = 2,
                        SIMPLEBLE_LOG_LEVEL_WARN    = 3,
                        SIMPLEBLE_LOG_LEVEL_INFO    = 4,
                        SIMPLEBLE_LOG_LEVEL_DEBUG   = 5,
                        SIMPLEBLE_LOG_LEVEL_VERBOSE = 6);

  //typedef void (*simpleble_log_callback_t)(
  //    simpleble_log_level_t level,
  //    const char* module,
  //    const char* file,
  //    uint32_t line,
  //    const char* function,
  //    const char* message
  //);
  TCallbackLog = procedure(Level: TSimpleBleLogLevel; Module: PChar;
    LFile: PChar; Line: DWord; LFunction: PChar; LMessage: PChar); cdecl;

//SIMPLEBLE_EXPORT void simpleble_logging_set_level(simpleble_log_level_t level);
procedure SimpleBleLoggingSetLevel(Level: TSimpleBleLogLevel); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_set_level';

//SIMPLEBLE_EXPORT void simpleble_logging_set_callback(simpleble_log_callback_t callback);
procedure SimpleBleLoggingSetCallback(Callback: TCallbackLog); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_set_callback';
function SimpleBleLoggingGetLevel(): TSimpleBleLogLevel; cdecl; external SimpleBleExtLibrary name 'simpleble_logging_get_level';
function SimpleBleLoggingHasCallback(): Boolean; cdecl; external SimpleBleExtLibrary name 'simpleble_logging_has_callback';
procedure SimpleBleLoggingLogDefaultStdout(); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_log_default_stdout';
procedure SimpleBleLoggingLogDefaultFile(); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_log_default_file';
procedure SimpleBleLoggingLogDefaultFilePath(Path: PChar); cdecl; external SimpleBleExtLibrary name 'simpleble_logging_log_default_file_path';

{ functions from SimpleBLE config.h }

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


{ functions from SimpleBLE utils.h }

//SIMPLEBLE_EXPORT simpleble_os_t simpleble_get_operating_system(void);
function SimpleBleGetOperatingSystem(): TSimpleBleOs; cdecl; external SimpleBleExtLibrary name 'simpleble_get_operating_system';

//SIMPLEBLE_EXPORT const char* simpleble_get_version(void);
function SimpleBleGetVersion(): PChar; cdecl; external SimpleBleExtLibrary name 'simpleble_get_version';

{$ELSE}

// Dynamic loading is the default on all supported platforms.


// define function for dynamically loading/unloading the DLL
function SimpleBleLoadLibrary(dllPath:string=''): Boolean;
procedure SimpleBleUnloadLibrary();
function SimpleBleGetLastLoadError(): string;


{ functions from SimpleBLE adapter.h }

type
  TSimpleBleCallbackScanStart = procedure(Adapter: TSimpleBleAdapter; UserData: Pointer); cdecl;
  TSimpleBleCallbackScanStop = procedure(Adapter: TSimpleBleAdapter; UserData: Pointer); cdecl;
  TSimpleBleCallbackScanUpdated = procedure(Adapter: TSimpleBleAdapter;
    Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;
  TSimpleBleCallbackScanFound = procedure(Adapter: TSimpleBleAdapter;
    Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;

var
  SimpleBleAdapterIsBluetoothEnabled : function() : Boolean; cdecl;
  SimpleBleAdapterGetCount : function() : NativeUInt; cdecl;
  SimpleBleAdapterGetHandle : function(Index: NativeUInt): TSimpleBleAdapter; cdecl;
  SimpleBleAdapterReleaseHandle : procedure(Handle: TSimpleBleAdapter); cdecl;
  SimpleBleAdapterUnderlying : function(Handle: TSimpleBleAdapter): Pointer; cdecl;
  SimpleBleAdapterIdentifier : function(Handle: TSimpleBleAdapter): PChar; cdecl;
  SimpleBleAdapterAddress : function(Handle: TSimpleBleAdapter): PChar; cdecl;
  SimpleBleAdapterPowerOn : function(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl;
  SimpleBleAdapterPowerOff : function(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl;
  SimpleBleAdapterIsPowered : function(Handle: TSimpleBleAdapter; var Powered: Boolean): TSimpleBleErr; cdecl;
  SimpleBleAdapterSetCallbackOnPowerOn : function(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; UserData: Pointer): TSimpleBleErr; cdecl;
  SimpleBleAdapterSetCallbackOnPowerOff : function(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStop; UserData: Pointer): TSimpleBleErr; cdecl;
  SimpleBleAdapterScanStart : function(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl;
  SimpleBleAdapterScanStop : function(Handle: TSimpleBleAdapter): TSimpleBleErr; cdecl;
  SimpleBleAdapterScanIsActive : function(Handle: TSimpleBleAdapter; var Active: Boolean): TSimpleBleErr; cdecl;
  SimpleBleAdapterScanFor : function(Handle: TSimpleBleAdapter; TimeoutMs: Integer): TSimpleBleErr; cdecl;
  SimpleBleAdapterScanGetResultsCount : function(Handle: TSimpleBleAdapter): NativeUInt; cdecl;
  SimpleBleAdapterScanGetResultsHandle : function(Handle: TSimpleBleAdapter; Index: NativeUInt): TSimpleBlePeripheral; cdecl;
  SimpleBleAdapterGetPairedPeripheralsCount : function(Handle: TSimpleBleAdapter): NativeUInt; cdecl;
  SimpleBleAdapterGetPairedPeripheralsHandle : function(Handle: TSimpleBleAdapter; Index: NativeUInt): TSimpleBlePeripheral; cdecl;
  SimpleBleAdapterGetConnectedPeripheralsCount : function(Handle: TSimpleBleAdapter): NativeUInt; cdecl;
  SimpleBleAdapterGetConnectedPeripheralsHandle : function(Handle: TSimpleBleAdapter; Index: NativeUInt): TSimpleBlePeripheral; cdecl;
  SimpleBleAdapterSetCallbackOnScanStart : function(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStart; UserData: Pointer): TSimpleBleErr;  cdecl;
  SimpleBleAdapterSetCallbackOnScanStop : function(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanStop; UserData: Pointer): TSimpleBleErr; cdecl;
  SimpleBleAdapterSetCallbackOnScanUpdated : function(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanUpdated; UserData: Pointer): TSimpleBleErr; cdecl;
  SimpleBleAdapterSetCallbackOnScanFound : function(Handle: TSimpleBleAdapter; Callback: TSimpleBleCallbackScanFound; UserData: Pointer): TSimpleBleErr; cdecl;


{ functions from SimpleBLE peripheral.h }

type
  TSimpleBleCallbackOnConnected = procedure(Peripheral: TSimpleBlePeripheral;
    UserData: Pointer); cdecl;
  TSimpleBleCallbackOnDisconnected = procedure(Peripheral: TSimpleBlePeripheral;
    UserData: Pointer); cdecl;
  TSimpleBleCallbackNotify = procedure(Peripheral: TSimpleBlePeripheral;
    Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte;
    DataLength: NativeUInt; UserData: Pointer); cdecl;
  TSimpleBleCallbackIndicate = procedure(Peripheral: TSimpleBlePeripheral;
    Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte;
    DataLength: NativeUInt; UserData: Pointer); cdecl;

var
  SimpleBlePeripheralReleaseHandle : procedure(Handle: TSimpleBlePeripheral); cdecl;
  SimpleBlePeripheralUnderlying : function(Handle: TSimpleBlePeripheral): Pointer; cdecl;
  SimpleBlePeripheralIdentifier : function(Handle: TSimpleBlePeripheral): PChar; cdecl;
  SimpleBlePeripheralAddress : function(Handle: TSimpleBlePeripheral): PChar; cdecl;
  SimpleBlePeripheralAddressType : function(Handle: TSimpleBlePeripheral): TSimpleBleAddressType; cdecl;
  SimpleBlePeripheralRssi : function(Handle: TSimpleBlePeripheral): Int16; cdecl;
  SimpleBlePeripheralTxPower : function(Handle: TSimpleBlePeripheral): Int16; cdecl;
  SimpleBlePeripheralMtu : function(Handle: TSimpleBlePeripheral): UInt16; cdecl;
  SimpleBlePeripheralConnect : function(Handle: TSimpleBlePeripheral): TSimpleBleErr; cdecl;
  SimpleBlePeripheralDisconnect : function(Handle: TSimpleBlePeripheral): TSimpleBleErr; cdecl;
  SimpleBlePeripheralIsConnected : function(Handle: TSimpleBlePeripheral; var connected: Boolean): TSimpleBleErr; cdecl;
  SimpleBlePeripheralIsConnectable : function(Handle: TSimpleBlePeripheral; var connectable: Boolean): TSimpleBleErr; cdecl;
  SimpleBlePeripheralIsPaired : function(Handle: TSimpleBlePeripheral; var paired: Boolean): TSimpleBleErr; cdecl;
  SimpleBlePeripheralUnpair : function(Handle: TSimpleBlePeripheral): TSimpleBleErr; cdecl;
  SimpleBlePeripheralServicesCount : function(Handle: TSimpleBlePeripheral): NativeUInt; cdecl;
  SimpleBlePeripheralServicesGet : function(Handle: TSimpleBlePeripheral; Index: NativeUInt; var Services: TSimpleBleService): TSimpleBleErr; cdecl;
  SimpleBlePeripheralManufacturerDataCount : function(Handle: TSimpleBlePeripheral): NativeUInt; cdecl;
  SimpleBlePeripheralManufacturerDataGet : function(Handle: TSimpleBlePeripheral; Index: NativeUInt; var ManufacturerData: TSimpleBleManufacturerData): TSimpleBleErr; cdecl;
  SimpleBlePeripheralRead : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; var Data: PByte; var DataLength: NativeUInt): TSimpleBleErr; cdecl;
  SimpleBlePeripheralWriteRequest : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt): TSimpleBleErr; cdecl;
  SimpleBlePeripheralWriteCommand : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt): TSimpleBleErr; cdecl;
  SimpleBlePeripheralNotify : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackNotify; UserData: Pointer): TSimpleBleErr; cdecl;
  SimpleBlePeripheralIndicate : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Callback: TSimpleBleCallbackIndicate; UserData: Pointer): TSimpleBleErr; cdecl;
  SimpleBlePeripheralUnsubscribe : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid):TSimpleBleErr; cdecl;
  SimpleBlePeripheralReadDescriptor : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; var Data: PByte; var DataLength: NativeUInt): TSimpleBleErr; cdecl;
  SimpleBlePeripheralWriteDescriptor : function(Handle: TSimpleBlePeripheral; service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Descriptor: TSimpleBleUuid; Data: PByte; DataLength: NativeUInt): TSimpleBleErr; cdecl;
  SimpleBlePeripheralSetCallbackOnConnected : function(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnConnected; UserData: Pointer): TSimpleBleErr; cdecl;
  SimpleBlePeripheralSetCallbackOnDisconnected : function(Handle: TSimpleBlePeripheral; Callback: TSimpleBleCallbackOnDisconnected; UserData: Pointer): TSimpleBleErr; cdecl;


{ functions from SimpleBLE simpleble.h }

var
  SimpleBleFree : procedure(Handle: Pointer); cdecl;


{ functions from SimpleBLE logging.h }

type
  TSimpleBleLogLevel = (SIMPLEBLE_LOG_LEVEL_NONE    = 0,
                        SIMPLEBLE_LOG_LEVEL_FATAL   = 1,
                        SIMPLEBLE_LOG_LEVEL_ERROR   = 2,
                        SIMPLEBLE_LOG_LEVEL_WARN    = 3,
                        SIMPLEBLE_LOG_LEVEL_INFO    = 4,
                        SIMPLEBLE_LOG_LEVEL_DEBUG   = 5,
                        SIMPLEBLE_LOG_LEVEL_VERBOSE = 6);

  TCallbackLog = procedure(Level: TSimpleBleLogLevel; Module: PChar;
    LFile: PChar; Line: DWord; LFunction: PChar; LMessage: PChar); cdecl;

var
  SimpleBleLoggingSetLevel : procedure(Level: TSimpleBleLogLevel); cdecl;
  SimpleBleLoggingSetCallback : procedure(Callback: TCallbackLog); cdecl;
  SimpleBleLoggingGetLevel : function(): TSimpleBleLogLevel; cdecl;
  SimpleBleLoggingHasCallback : function(): Boolean; cdecl;
  SimpleBleLoggingLogDefaultStdout : procedure(); cdecl;
  SimpleBleLoggingLogDefaultFile : procedure(); cdecl;
  SimpleBleLoggingLogDefaultFilePath : procedure(Path: PChar); cdecl;


{ functions from SimpleBLE config.h }

var
  SimpleBleConfigResetAll : procedure(); cdecl;
  SimpleBleConfigSimpleBluezReset : procedure(); cdecl;
  SimpleBleConfigSimpleBluezGetUseSystemBus : function(): Boolean; cdecl;
  SimpleBleConfigSimpleBluezSetUseSystemBus : procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigSimpleBluezGetConnectionTimeoutMs : function(): Int64; cdecl;
  SimpleBleConfigSimpleBluezSetConnectionTimeoutMs : procedure(TimeoutMs: Int64); cdecl;
  SimpleBleConfigSimpleBluezGetDisconnectionTimeoutMs : function(): Int64; cdecl;
  SimpleBleConfigSimpleBluezSetDisconnectionTimeoutMs : procedure(TimeoutMs: Int64); cdecl;
  SimpleBleConfigWinRtReset : procedure(); cdecl;
  SimpleBleConfigWinRtGetExperimentalUseOwnMtaApartment : function(): Boolean; cdecl;
  SimpleBleConfigWinRtSetExperimentalUseOwnMtaApartment : procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigWinRtGetExperimentalReinitializeWinRtApartmentOnMainThread : function(): Boolean; cdecl;
  SimpleBleConfigWinRtSetExperimentalReinitializeWinRtApartmentOnMainThread : procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigWinRtGetUseDeferredDisconnect : function(): Boolean; cdecl;
  SimpleBleConfigWinRtSetUseDeferredDisconnect : procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigCoreBluetoothReset : procedure(); cdecl;
  SimpleBleConfigAndroidReset : procedure(); cdecl;
  SimpleBleConfigAndroidGetConnectionPriority : function(): TSimpleBleConfigAndroidConnectionPriority; cdecl;
  SimpleBleConfigAndroidSetConnectionPriority : procedure(Priority: TSimpleBleConfigAndroidConnectionPriority); cdecl;
  SimpleBleConfigSetAndroidConnectionPriority : procedure(Priority: LongInt); cdecl;
  SimpleBleConfigDonglReset : procedure(); cdecl;
  SimpleBleConfigDonglGetUseDonglBackend : function(): Boolean; cdecl;
  SimpleBleConfigDonglSetUseDonglBackend : procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigDonglGetAutoUpdate : function(): Boolean; cdecl;
  SimpleBleConfigDonglSetAutoUpdate : procedure(Enabled: Boolean); cdecl;
  SimpleBleConfigDonglGetForceUpdate : function(): Boolean; cdecl;
  SimpleBleConfigDonglSetForceUpdate : procedure(Enabled: Boolean); cdecl;


{ functions from SimpleBLE utils.h }

//var
  SimpleBleGetOperatingSystem : function(): TSimpleBleOs; cdecl;
  SimpleBleGetVersion : function(): PChar; cdecl;

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
