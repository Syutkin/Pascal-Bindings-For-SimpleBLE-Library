program SimpleBleConnectExample;

{$mode objfpc}{$H+}

{ Copyright (c) 2022 Erik Lins; modifications Copyright (c) 2026 Andrey Syutkin.
  MIT license. Native SimpleBLE has separate BUSL-1.1/commercial terms. }

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils, SimpleBle;

const
  MaxPeripherals = 10;

var
  Peripherals: array[0..MaxPeripherals - 1] of TSimpleBlePeripheral;
  PeripheralCount: Integer = 0;

function LoadNativeLibraries: Boolean;
var
  Directory: string;
begin
  Directory := GetEnvironmentVariable('SIMPLECBLE_LIBRARY_DIR');
  if (Directory <> '') and SimpleBleLoadLibrary(Directory) then
    Exit(True);
  if SimpleBleLoadLibrary(ExtractFilePath(ParamStr(0))) then
    Exit(True);
  Result := SimpleBleLoadLibrary();
end;

procedure CheckError(var Error: TSimpleBleError; const Operation: string);
var
  Info: TSimpleBleErrorInfo;
begin
  if Error = nil then
    Exit;
  Info := SimpleBleTakeErrorInfo(Error);
  raise Exception.CreateFmt('%s: %d %s',
    [Operation, Ord(Info.Code), Info.Message]);
end;

procedure OnScanFound(Adapter: TSimpleBleAdapter;
  Peripheral: TSimpleBlePeripheral; UserData: Pointer); cdecl;
begin
  { Each callback transfers an owned peripheral handle. }
  if PeripheralCount < MaxPeripherals then
  begin
    Peripherals[PeripheralCount] := Peripheral;
    Inc(PeripheralCount);
  end
  else
    SimpleBlePeripheralReleaseHandle(Peripheral);
end;

procedure PrintPeripheral(Peripheral: TSimpleBlePeripheral;
  const Prefix: string);
var
  Identifier, Address: PChar;
  Error: TSimpleBleError;
begin
  Identifier := nil;
  Address := nil;
  Error := nil;
  try
    Identifier := SimpleBlePeripheralIdentifier(Peripheral, Error);
    CheckError(Error, 'peripheral identifier');
    Address := SimpleBlePeripheralAddress(Peripheral, Error);
    CheckError(Error, 'peripheral address');
    WriteLn(Prefix + string(Identifier) + ' [' + string(Address) + ']');
  finally
    if Error <> nil then
      SimpleBleErrorRelease(Error);
    SimpleBleFree(Identifier);
    SimpleBleFree(Address);
  end;
end;

procedure Run;
var
  Adapter: TSimpleBleAdapter;
  Peripheral: TSimpleBlePeripheral;
  Error: TSimpleBleError;
  Service: TSimpleBleOwnedService;
  AdapterCount, ServiceCount: NativeUInt;
  I, J, K, Selection: Integer;
  Connected: Boolean;
begin
  if not LoadNativeLibraries then
    raise Exception.Create('Failed to load SimpleCBLE: ' +
      SimpleBleGetLastLoadError());
  Adapter := nil;
  Peripheral := nil;
  Error := nil;
  Connected := False;
  try
    SimpleBlePinLibrary();
    AdapterCount := SimpleBleAdapterGetCount(Error);
    CheckError(Error, 'adapter count');
    if AdapterCount = 0 then
    begin
      WriteLn('No BLE adapter was found.');
      Exit;
    end;
    Adapter := SimpleBleAdapterGetHandle(0, Error);
    CheckError(Error, 'adapter handle');
    if Adapter = nil then
      raise Exception.Create('Could not get a BLE adapter handle');
    SimpleBleAdapterSetCallbackOnScanFound(Adapter, @OnScanFound, nil);
    WriteLn('Scanning for 5 seconds...');
    SimpleBleAdapterScanFor(Adapter, 5000, Error);
    CheckError(Error, 'scan');
    SimpleBleAdapterSetCallbackOnScanFound(Adapter, nil, nil);

    if PeripheralCount = 0 then
    begin
      WriteLn('No peripherals were found.');
      Exit;
    end;
    for I := 0 to PeripheralCount - 1 do
      PrintPeripheral(Peripherals[I], '[' + IntToStr(I) + '] ');
    Write('Select a peripheral: ');
    ReadLn(Selection);
    if (Selection < 0) or (Selection >= PeripheralCount) then
      raise Exception.Create('Invalid selection');

    Peripheral := Peripherals[Selection];
    PrintPeripheral(Peripheral, 'Connecting to ');
    SimpleBlePeripheralConnect(Peripheral, Error);
    CheckError(Error, 'connect');
    Connected := True;

    ServiceCount := SimpleBlePeripheralServicesCount(Peripheral, Error);
    CheckError(Error, 'service count');
    if ServiceCount > NativeUInt(High(Integer)) then
      raise Exception.Create('Too many services');
    WriteLn('Connected. Services: ', ServiceCount);
    for I := 0 to Integer(ServiceCount) - 1 do
    begin
      Service := SimpleBleGetService(Peripheral, I, Error);
      CheckError(Error, 'service');
      WriteLn('Service: ', string(Service.Uuid.Value),
        ' (', Length(Service.Characteristics), ' characteristics)');
      for J := 0 to High(Service.Characteristics) do
      begin
        WriteLn('  Characteristic: ',
          string(Service.Characteristics[J].Uuid.Value));
        for K := 0 to High(Service.Characteristics[J].Descriptors) do
          WriteLn('    Descriptor: ',
            string(Service.Characteristics[J].Descriptors[K].Value));
      end;
    end;
    WriteLn('Press Enter to disconnect.');
    ReadLn();
  finally
    if Connected then
    begin
      SimpleBlePeripheralDisconnect(Peripheral, Error);
      if Error <> nil then
      begin
        WriteLn(StdErr, 'Disconnect: ',
          SimpleBleTakeErrorInfo(Error).Message);
      end;
    end;
    if Error <> nil then
      SimpleBleErrorRelease(Error);
    if Adapter <> nil then
      SimpleBleAdapterSetCallbackOnScanFound(Adapter, nil, nil);
    for I := 0 to PeripheralCount - 1 do
      SimpleBlePeripheralReleaseHandle(Peripherals[I]);
    if Adapter <> nil then
      SimpleBleAdapterReleaseHandle(Adapter);
    SimpleBleUnloadLibrary();
  end;
end;

begin
  if (ParamCount > 0) and ((ParamStr(1) = '-h') or (ParamStr(1) = '--help')) then
  begin
    WriteLn('Usage: ', ExtractFileName(ParamStr(0)));
    Halt(0);
  end;
  try
    Run;
  except
    on E: Exception do
    begin
      WriteLn(StdErr, E.Message);
      ExitCode := 1;
    end;
  end;
end.
