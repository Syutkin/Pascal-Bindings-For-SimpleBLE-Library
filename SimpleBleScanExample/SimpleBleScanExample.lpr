program SimpleBleScanExample;

{$mode objfpc}{$H+}

{ Lazarus / Free Pascal BLE scan example for SimpleBLE library.

  The original example is Copyright (c) 2022 Erik Lins.
    https://github.com/eriklins/Pascal-Bindings-For-SimpleBLE-Library

  Modifications are Copyright (c) 2026 Andrey Syutkin.
    https://github.com/Syutkin/Pascal-Bindings-For-SimpleBLE-Library

  The example and modifications are released under the MIT License.

  This example is a port of the C scan example in SimpleBLE to Lazarus/FreePascal.
    https://github.com/simpleble/simpleble/tree/main/examples/simpleble/c/scan

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

  { TSimpleBleScanExample }

  TSimpleBleScanExample = class(TCustomApplication)
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


{ Callback functions for SimpleBLE }

procedure AdapterOnScanStart(Adapter: TSimplebleAdapter; Userdata: Pointer); cdecl;
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

procedure AdapterOnScanStop(Adapter: TSimplebleAdapter; Userdata: Pointer); cdecl;
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

procedure AdapterOnScanFound(Adapter: TSimplebleAdapter; Peripheral: TSimpleBlePeripheral; Userdata: Pointer); cdecl;
var
  AdapterIdentifier: PChar;
  PeripheralIdentifier: PChar;
  PeripheralAddress: PChar;
  ManufDataCount: NativeUInt;
  ManufData: TSimpleBleManufacturerData;
  i, j, rssi: Integer;
begin
  AdapterIdentifier := nil;
  PeripheralIdentifier := nil;
  PeripheralAddress := nil;
  try
    AdapterIdentifier := SimpleBleAdapterIdentifier(Adapter);
    PeripheralIdentifier := SimpleBlePeripheralIdentifier(Peripheral);
    PeripheralAddress := SimpleBlePeripheralAddress(Peripheral);
    if (AdapterIdentifier = nil) or (PeripheralIdentifier = nil) or
      (PeripheralAddress = nil) then
      Exit;
    rssi := SimpleBlePeripheralRssi(Peripheral);
    ManufDataCount := SimpleBlePeripheralManufacturerDataCount(Peripheral);
    Write('device found  : [' + PeripheralAddress + '] ' + IntToStr(rssi) + 'dBm "' + PeripheralIdentifier + '"');
    if ManufDataCount > 0 then
    begin
      for i := 0 to Integer(ManufDataCount) - 1 do
      begin
        ManufData := Default(TSimpleBleManufacturerData);
        if SimpleBlePeripheralManufacturerDataGet(Peripheral, i, ManufData) <>
          SIMPLEBLE_SUCCESS then
          Continue;
        Write(' MD[' + IntToStr(i) + ']=0x');
        for j := 0 to Integer(ManufData.DataLength) - 1 do
          Write(IntToHex(ManufData.Data[j]));
      end;
    end;
    WriteLn();
  finally
    SimpleBleFree(AdapterIdentifier);
    SimpleBleFree(PeripheralIdentifier);
    SimpleBleFree(PeripheralAddress);
    SimpleBlePeripheralReleaseHandle(Peripheral);
  end;
end;

procedure AdapterOnScanUpdated(Adapter: TSimplebleAdapter; Peripheral: TSimpleBlePeripheral; Userdata: Pointer); cdecl;
var
  AdapterIdentifier: PChar;
  PeripheralIdentifier: PChar;
  PeripheralAddress: PChar;
  ManufDataCount: NativeUInt;
  ManufData: TSimpleBleManufacturerData;
  i, j, rssi: Integer;
begin
  AdapterIdentifier := nil;
  PeripheralIdentifier := nil;
  PeripheralAddress := nil;
  try
    AdapterIdentifier := SimpleBleAdapterIdentifier(Adapter);
    PeripheralIdentifier := SimpleBlePeripheralIdentifier(Peripheral);
    PeripheralAddress := SimpleBlePeripheralAddress(Peripheral);
    if (AdapterIdentifier = nil) or (PeripheralIdentifier = nil) or
      (PeripheralAddress = nil) then
      Exit;
    rssi := SimpleBlePeripheralRssi(Peripheral);
    ManufDataCount := SimpleBlePeripheralManufacturerDataCount(Peripheral);
    Write('device updated: [' + PeripheralAddress + '] ' + IntToStr(rssi) + 'dBm "' + PeripheralIdentifier + '"');
    if ManufDataCount > 0 then
    begin
      for i := 0 to Integer(ManufDataCount) - 1 do
      begin
        ManufData := Default(TSimpleBleManufacturerData);
        if SimpleBlePeripheralManufacturerDataGet(Peripheral, i, ManufData) <>
          SIMPLEBLE_SUCCESS then
          Continue;
        Write(' MD[' + IntToStr(i) + ']=0x');
        for j := 0 to Integer(ManufData.DataLength) - 1 do
          Write(IntToHex(ManufData.Data[j]));
      end;
    end;
    WriteLn();
  finally
    SimpleBleFree(AdapterIdentifier);
    SimpleBleFree(PeripheralIdentifier);
    SimpleBleFree(PeripheralAddress);
    SimpleBlePeripheralReleaseHandle(Peripheral);
  end;
end;

{ -------------------------------- }


procedure TSimpleBleScanExample.DoRun;
var
  ErrorMsg: String;
  Adapter: TSimplebleAdapter;

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
    SimpleBleUnloadLibrary();
    Terminate;
    Exit;
  end;

  // parse parameters
  if HasOption('h', 'help') then begin
    WriteHelp;
    SimpleBleUnloadLibrary();
    Terminate;
    Exit;
  end;

  // look for BLE adapters
  if SimpleBleAdapterGetCount() = 0 then
  begin
    WriteLn('No BLE adapter was found.');
    SimpleBleUnloadLibrary();
    Terminate;
    Exit;
  end;

  // get a handle for the BLE Adapter
  Adapter := SimpleBleAdapterGetHandle(0);
  if Adapter = nil then
  begin
    WriteLn('Could not get handle for BLE adapter.');
    SimpleBleUnloadLibrary();
    Terminate;
    Exit
  end;
  WriteLn('Found BLE adapter and got handle.');

  // register SimpleBLE scan callback functions
  SimpleBleAdapterSetCallbackOnScanStart(Adapter, @AdapterOnScanStart, Nil);
  SimpleBleAdapterSetCallbackOnScanStop(Adapter, @AdapterOnScanStop, Nil);
  SimpleBleAdapterSetCallbackOnScanFound(Adapter, @AdapterOnScanFound, Nil);
  SimpleBleAdapterSetCallbackOnScanUpdated(Adapter, @AdapterOnScanUpdated, Nil);

  // start BLE scanning for 5 seconds
  SimpleBleAdapterScanFor(Adapter, 5000);

  // wait for enter key
  ReadLn();

  // release the BLE handle
  SimpleBleAdapterReleaseHandle(Adapter);

  SimpleBleUnloadLibrary();

  // stop program loop
  Terminate;
end;

constructor TSimpleBleScanExample.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  StopOnException:=True;
end;

destructor TSimpleBleScanExample.Destroy;
begin
  inherited Destroy;
end;

procedure TSimpleBleScanExample.WriteHelp;
begin
  { add your help code here }
  WriteLn('Usage: ', ExeName, ' -h');
end;


var
  Application: TSimpleBleScanExample;
begin
  Application:=TSimpleBleScanExample.Create(nil);
  Application.Title:='SimpleBleScanTest';
  Application.Run;
  Application.Free;
end.
