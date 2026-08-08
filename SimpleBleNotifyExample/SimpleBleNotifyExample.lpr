program SimpleBleNotifyExample;

{$mode objfpc}{$H+}

{ Lazarus / Free Pascal BLE notify example for SimpleBLE library.

  The original example is Copyright (c) 2022 Erik Lins.
    https://github.com/eriklins/Pascal-Bindings-For-SimpleBLE-Library

  Modifications are Copyright (c) 2026 Andrey Syutkin.
    https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library

  The example and modifications are released under the MIT License.

  This example is a port of the C notify example in SimpleBLE to Lazarus/FreePascal.
    https://github.com/OpenBluetoothToolbox/SimpleBLE/tree/main/examples/simpleble/c/notify

  The native SimpleBLE library has its own BUSL-1.1/commercial licensing terms.
    https://github.com/simpleble/simpleble
}

{$UNDEF DYNAMIC_LOADING}
{$IFDEF WINDOWS}
  //{$DEFINE DYNAMIC_LOADING}    { UNCOMMENT IF YOU WANT DYNAMIC LOADING }
{$ENDIF}


uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, SysUtils, CustApp, SimpleBle;

type

  { TSimpleBleNotifyExample }

  TSimpleBleNotifyExample = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
  end;

  TServiceCharacteristic = record
    Service: TSimpleBleUuid;
    Characteristic: TSimpleBleUuid;
  end;

function LoadNativeLibraries: Boolean;
var
  LibraryDirectory: string;
begin
  LibraryDirectory := GetEnvironmentVariable('SIMPLECBLE_LIBRARY_DIR');
  if LibraryDirectory <> '' then
  begin
    Result := SimpleBleLoadLibrary(LibraryDirectory);
    if Result then
      Exit;
  end;

  Result := SimpleBleLoadLibrary(ExtractFilePath(ParamStr(0)));
  if Result then
    Exit;

  Result := SimpleBleLoadLibrary();
end;


const
  PERIPHERAL_LIST_SIZE = 10;
  SERVICES_LIST_SIZE = 32;

var
  CharacteristicList: array [0..SERVICES_LIST_SIZE-1] of TServiceCharacteristic;
  PeripheralList: array [0..PERIPHERAL_LIST_SIZE-1] of TSimpleBlePeripheral;
  PeripheralListLen: NativeUInt = 0;
  Adapter: TSimpleBleAdapter = nil;


{ Callback functions for SimpleBLE }

procedure AdapterOnScanStart(Adapter: TSimpleBleAdapter; Userdata: Pointer); cdecl;
var
  Identifier: PChar;
begin
  Identifier := SimpleBleAdapterIdentifier(Adapter);
  try
    if Identifier = nil then
      Exit;
    WriteLn('Adapter ' + Identifier + ' started scanning.');
  finally
    SimpleBleFree(Identifier);
  end;
end;

procedure AdapterOnScanStop(Adapter: TSimpleBleAdapter; Userdata: Pointer); cdecl;
var
  Identifier: PChar;
begin
  Identifier := SimpleBleAdapterIdentifier(Adapter);
  try
    if Identifier = nil then
      Exit;
    WriteLn('Adapter ' + Identifier + ' stopped scanning.');
  finally
    SimpleBleFree(Identifier);
  end;
end;

procedure AdapterOnScanFound(Adapter: TSimpleBleAdapter; Peripheral: TSimpleBlePeripheral; Userdata: Pointer); cdecl;
var
  AdapterIdentifier: PChar;
  PeripheralIdentifier: PChar;
  PeripheralAddress: PChar;
  Stored: Boolean;
begin
  AdapterIdentifier := nil;
  PeripheralIdentifier := nil;
  PeripheralAddress := nil;
  Stored := False;
  try
    AdapterIdentifier := SimpleBleAdapterIdentifier(Adapter);
    PeripheralIdentifier := SimpleBlePeripheralIdentifier(Peripheral);
    PeripheralAddress := SimpleBlePeripheralAddress(Peripheral);
    if (AdapterIdentifier = nil) or (PeripheralIdentifier = nil) or
      (PeripheralAddress = nil) then
      Exit;
    WriteLn('Adapter ' + AdapterIdentifier + ' found device: ' +
      PeripheralIdentifier + ' [' + PeripheralAddress + ']');
    if PeripheralListLen < PERIPHERAL_LIST_SIZE then
    begin
      PeripheralList[PeripheralListLen] := Peripheral;
      Inc(PeripheralListLen);
      Stored := True;
    end;
  finally
    if not Stored then
      SimpleBlePeripheralReleaseHandle(Peripheral);
    SimpleBleFree(AdapterIdentifier);
    SimpleBleFree(PeripheralIdentifier);
    SimpleBleFree(PeripheralAddress);
  end;
end;

procedure PeripheralOnNotify(Peripheral: TSimpleBlePeripheral;
  Service: TSimpleBleUuid; Characteristic: TSimpleBleUuid; Data: PByte;
  DataLength: NativeUInt; Userdata: Pointer); cdecl;
var
  i: Integer;
begin
  write('Received[' + IntToStr(DataLength) + ']: ');
  if (Data = nil) and (DataLength > 0) then
  begin
    WriteLn('<invalid null buffer>');
    Exit;
  end;
  for i := 0 to Integer(DataLength) - 1 do
    write(IntToStr(data[i]) + ' ');
  WriteLn();
end;

{ -------------------------------- }


procedure TSimpleBleNotifyExample.DoRun;
var
  ErrorMsg: String;
  ErrCode: TSimpleBleErr = SIMPLEBLE_SUCCESS;
  i, j, Selection, CharacteristicCount: Integer;
  Peripheral: TSimpleBlePeripheral;
  PeripheralIdentifier: PChar;
  PeripheralAddress: PChar;
  Service: TSimpleBleService;
begin

  if not LoadNativeLibraries() then begin
    WriteLn('Failed to load library: ' + SimpleBleGetLastLoadError());
    Terminate;
    Exit;
  end;

  // quick check parameters
  ErrorMsg:=CheckOptions('h', 'help');
  if ErrorMsg<>'' then begin
    ShowException(Exception.Create(ErrorMsg));
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    Terminate;
    Exit;
  end;

  // look for BLE adapters
  if SimpleBleAdapterGetCount() = 0 then
  begin
    WriteLn('No BLE adapter was found.');
    Terminate;
    Exit;
  end;

  // get a handle for the BLE Adapter
  Adapter := SimpleBleAdapterGetHandle(0);
  if Adapter = nil then
  begin
    WriteLn('Could not get handle for BLE adapter.');
    Terminate;
    Exit
  end;
  WriteLn('Found BLE adapter and got handle.');

  // register SimpleBLE scan callback functions
  SimpleBleAdapterSetCallbackOnScanStart(Adapter, @AdapterOnScanStart, Nil);
  SimpleBleAdapterSetCallbackOnScanStop(Adapter, @AdapterOnScanStop, Nil);
  SimpleBleAdapterSetCallbackOnScanFound(Adapter, @AdapterOnScanFound, Nil);

  // start BLE scanning for 5 seconds
  SimpleBleAdapterScanFor(Adapter, 5000);

  // list found Peripheral devices
  WriteLn('The following devices were found:');
  for i := 0 to (PeripheralListLen - 1) do
  begin
    Peripheral := PeripheralList[i];
    PeripheralIdentifier := SimpleBlePeripheralIdentifier(Peripheral);
    PeripheralAddress := SimpleBlePeripheralAddress(Peripheral);
    WriteLn('[' + IntToStr(i) + '] ' + PeripheralIdentifier + ' [' + PeripheralAddress + ']');
    SimpleBleFree(PeripheralIdentifier);
    SimpleBleFree(PeripheralAddress);
  end;

  // select device to connect
  Selection := -1;
  write('Please select a device to connect to: ');
  ReadLn(Selection);
  if (Selection < 0) or (Selection >= PeripheralListLen) then
  begin
    WriteLn('Invalid selection.');
    Terminate;
    Exit;
  end;

  // connect to selected device
  Peripheral := PeripheralList[Selection];
  PeripheralIdentifier := SimpleBlePeripheralIdentifier(Peripheral);
  PeripheralAddress := SimpleBlePeripheralAddress(Peripheral);
  WriteLn('Connecting to ' + PeripheralIdentifier + ' [' + PeripheralAddress + ']');
  SimpleBleFree(PeripheralIdentifier);
  SimpleBleFree(PeripheralAddress);
  ErrCode := SimpleBlePeripheralConnect(Peripheral);
  if ErrCode <> SIMPLEBLE_SUCCESS then
  begin
    WriteLn('Failed to connect.');
    Terminate;
    Exit;
  end;
  WriteLn('Successfully connected, listing services and characteristics.');

  // show list of characteristics to select one to subscribe to notifications
  CharacteristicCount := 0;
  for i := 0 to Integer(SimpleBlePeripheralServicesCount(Peripheral)) - 1 do
  begin
    Service := Default(TSimpleBleService);
    ErrCode := SimpleBlePeripheralServicesGet(Peripheral, i, Service);
    if ErrCode <> SIMPLEBLE_SUCCESS then
    begin
      WriteLn('Failed to get service.');
      Terminate;
      Exit;
    end;
    for j := 0 to Integer(Service.CharacteristicCount) - 1 do
    begin
      if CharacteristicCount >= SERVICES_LIST_SIZE then
        break;
      WriteLn('[' + IntToStr(CharacteristicCount) + '] ' + Service.Uuid.Value + ' ' + Service.Characteristics[j].Uuid.Value);
      CharacteristicList[CharacteristicCount].Service := Service.Uuid;
      CharacteristicList[CharacteristicCount].Characteristic := Service.Characteristics[j].Uuid;
      Inc(CharacteristicCount);
    end;
  end;

  // select characteristic to subsribe notifications
  Selection := -1;
  write('Please select characteristic to read from: ');
  ReadLn(Selection);
  if (Selection < 0) or (Selection >= CharacteristicCount) then
  begin
    WriteLn('Invalid selection.');
    Terminate;
    Exit;
  end;

  // subscribe to notification and register callback function
  ErrCode := SimpleBlePeripheralNotify(Peripheral,
    CharacteristicList[Selection].Service,
    CharacteristicList[Selection].Characteristic, @PeripheralOnNotify, nil);
  if ErrCode <> SIMPLEBLE_SUCCESS then
  begin
    WriteLn('Failed to subscribe to notifications.');
    Terminate;
    Exit;
  end;

  // sleep 5 sec, during these 5 secs the Peripheral needs to update the characteristic value
  Sleep(5000);

  // unsubscribe notifications
  SimpleBlePeripheralUnsubscribe(Peripheral, CharacteristicList[Selection].Service, CharacteristicList[Selection].Characteristic);

  // disconnect from Peripheral
  SimpleBlePeripheralDisconnect(Peripheral);

  // wait for enter
  ReadLn();

  // stop program loop
  Terminate;
end;

constructor TSimpleBleNotifyExample.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TSimpleBleNotifyExample.Destroy;
var
  i: Integer;
begin
  WriteLn('Releasing allocated resources.');
  // Release all saved peripherals
  for i := 0 to Integer(PeripheralListLen) - 1 do
    SimpleBlePeripheralReleaseHandle(PeripheralList[i]);
  // Let's not forget to release the associated handle.
  if Adapter <> nil then
    SimpleBleAdapterReleaseHandle(Adapter);
  SimpleBleUnloadLibrary();
  inherited Destroy;
end;

procedure TSimpleBleNotifyExample.WriteHelp;
begin
  { add your help code here }
  WriteLn('Usage: ', ExeName, ' -h');
end;


var
  Application: TSimpleBleNotifyExample;
begin
  Application:=TSimpleBleNotifyExample.Create(nil);
  Application.Title:='SimpleBleScanTest';
  Application.Run;
  Application.Free;
end.
