program SimpleBleConnectExample;

{$mode objfpc}{$H+}

{ Lazarus / Free Pascal BLE connect example for SimpleBLE library.

  The original example is Copyright (c) 2022 Erik Lins.
    https://github.com/eriklins/Pascal-Bindings-For-SimpleBLE-Library

  Modifications are Copyright (c) 2026 Andrey Syutkin.
    https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library

  The example and modifications are released under the MIT License.

  This example is a port of the C connect example in SimpleBLE to Lazarus/FreePascal.
    https://github.com/OpenBluetoothToolbox/SimpleBLE/tree/main/examples/simpleble/c/connect

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

  { TSimpleBleConnectExample }

  TSimpleBleConnectExample = class(TCustomApplication)
  protected
    procedure DoRun; override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure WriteHelp; virtual;
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

var
  PeripheralList: array [0..PERIPHERAL_LIST_SIZE-1] of TSimpleBlePeripheral;
  PeripheralListLen: Integer = 0;
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

{ -------------------------------- }


procedure TSimpleBleConnectExample.DoRun;
var
  ErrorMsg: String;
  ErrCode: TSimpleBleErr = SIMPLEBLE_SUCCESS;
  i, j, k, Selection, ServicesCount: Integer;
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

  // show list of found devices
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

  // select a device to connect to
  Selection := -1;
  write('Please select a device to connect to: ');
  ReadLn(Selection);
  if (Selection < 0) or (Selection >= PeripheralListLen) then
  begin
    WriteLn('Invalid selection.');
    Terminate;
    Exit;
  end;

  // connect to device
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
  ServicesCount := SimpleBlePeripheralServicesCount(Peripheral);
  WriteLn('Successfully connected, listing ' + IntToStr(ServicesCount) + ' services.');

  // show gatt table with services and characteristics
  for i := 0 to (ServicesCount - 1) do
  begin
    Service := Default(TSimpleBleService);
    ErrCode := SimpleBlePeripheralServicesGet(Peripheral, i, Service);
    if ErrCode <> SIMPLEBLE_SUCCESS then
    begin
      WriteLn('Failed to get service.');
      Terminate;
      Exit;
    end;
    WriteLn('Service: ' + Service.Uuid.Value + ' - (' + IntToStr(Service.CharacteristicCount) + ')');
    for j := 0 to Integer(Service.CharacteristicCount) - 1 do
    begin
      WriteLn('  Characteristic: ' + Service.Characteristics[j].Uuid.Value + ' - (' + IntToStr(Service.Characteristics[j].DescriptorCount) + ')');
      for k := 0 to Integer(Service.Characteristics[j].DescriptorCount) - 1 do
        WriteLn('    Descriptor: ' + Service.Characteristics[j].Descriptors[k].Uuid.Value);
    end;
  end;

  // wait for enter
  ReadLn();

  // and disconnect again from device
  SimpleBlePeripheralDisconnect(Peripheral);

  // stop program loop
  Terminate;
end;

constructor TSimpleBleConnectExample.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TSimpleBleConnectExample.Destroy;
var
  i: Integer;
begin
  WriteLn('Releasing allocated resources.');
  // Release all saved peripherals
  for i := 0 to (PeripheralListLen - 1) do
    SimpleBlePeripheralReleaseHandle(PeripheralList[i]);
  // Let's not forget to release the associated handle.
  if Adapter <> nil then
    SimpleBleAdapterReleaseHandle(Adapter);
  SimpleBleUnloadLibrary();
  inherited Destroy;
end;

procedure TSimpleBleConnectExample.WriteHelp;
begin
  { add your help code here }
  WriteLn('Usage: ', ExeName, ' -h');
end;


var
  Application: TSimpleBleConnectExample;
begin
  Application:=TSimpleBleConnectExample.Create(nil);
  Application.Title:='SimpleBleScanTest';
  Application.Run;
  Application.Free;
end.
