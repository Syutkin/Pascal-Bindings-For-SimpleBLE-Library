program SimpleBleNotify;

{$mode objfpc}{$H+}

{ Copyright (c) 2022 Erik Lins; modifications Copyright (c) 2026 Andrey Syutkin.
  MIT license. Native SimpleBLE has separate BUSL-1.1/commercial terms. }

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils, SimpleBle;

const
  MaxPeripherals = 10;
  MaxCharacteristics = 32;

type
  TServiceCharacteristic = record
    Service: TSimpleBleUuid;
    Characteristic: TSimpleBleUuid;
  end;

var
  Peripherals: array[0..MaxPeripherals - 1] of TSimpleBlePeripheral;
  PeripheralCount: Integer = 0;
  Characteristics: array[0..MaxCharacteristics - 1] of TServiceCharacteristic;
  CharacteristicCount: Integer = 0;

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

procedure OnNotify(Peripheral: TSimpleBlePeripheral;
  Service, Characteristic: TSimpleBleUuid; Data: PByte;
  DataLength: NativeUInt; UserData: Pointer); cdecl;
var
  I: SizeInt;
begin
  try
    if (Data = nil) and (DataLength <> 0) then
      raise Exception.Create('Native notification has a null buffer');
    if DataLength > NativeUInt(High(SizeInt)) then
      raise Exception.Create('Native notification is too large');
    Write('Received[', DataLength, ']:');
    for I := 0 to SizeInt(DataLength) - 1 do
      Write(' ', IntToHex(Data[I], 2));
    WriteLn();
  except
    on E: Exception do
      WriteLn(StdErr, 'Notification callback: ', E.Message);
  end;
end;

procedure Run;
var
  Adapter: TSimpleBleAdapter;
  Peripheral: TSimpleBlePeripheral;
  Error: TSimpleBleError;
  Service: TSimpleBleOwnedService;
  AdapterCount, ServiceCount: NativeUInt;
  I, J, Selection: Integer;
  Connected, Subscribed: Boolean;
begin
  if not LoadNativeLibraries then
    raise Exception.Create('Failed to load SimpleCBLE: ' +
      SimpleBleGetLastLoadError());
  Adapter := nil;
  Peripheral := nil;
  Error := nil;
  Connected := False;
  Subscribed := False;
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
    WriteLn('Connected. Select a characteristic that supports notifications:');
    for I := 0 to Integer(ServiceCount) - 1 do
    begin
      Service := SimpleBleGetService(Peripheral, I, Error);
      CheckError(Error, 'service');
      for J := 0 to High(Service.Characteristics) do
      begin
        if not Service.Characteristics[J].CanNotify then
          Continue;
        if CharacteristicCount = MaxCharacteristics then
          Break;
        Characteristics[CharacteristicCount].Service := Service.Uuid;
        Characteristics[CharacteristicCount].Characteristic :=
          Service.Characteristics[J].Uuid;
        WriteLn('[', CharacteristicCount, '] ', string(Service.Uuid.Value),
          ' ', string(Service.Characteristics[J].Uuid.Value));
        Inc(CharacteristicCount);
      end;
    end;
    if CharacteristicCount = 0 then
    begin
      WriteLn('No notify-capable characteristics were found.');
      Exit;
    end;
    Write('Select a characteristic: ');
    ReadLn(Selection);
    if (Selection < 0) or (Selection >= CharacteristicCount) then
      raise Exception.Create('Invalid selection');
    SimpleBlePeripheralNotify(Peripheral,
      Characteristics[Selection].Service,
      Characteristics[Selection].Characteristic, @OnNotify, nil, Error);
    CheckError(Error, 'subscribe');
    Subscribed := True;
    WriteLn('Waiting for notifications for 5 seconds...');
    Sleep(5000);
  finally
    if Subscribed then
    begin
      SimpleBlePeripheralUnsubscribe(Peripheral,
        Characteristics[Selection].Service,
        Characteristics[Selection].Characteristic, Error);
      if Error <> nil then
        WriteLn(StdErr, 'Unsubscribe: ',
          SimpleBleTakeErrorInfo(Error).Message);
    end;
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
