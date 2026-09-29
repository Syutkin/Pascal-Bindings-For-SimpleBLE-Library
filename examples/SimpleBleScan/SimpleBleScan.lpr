program SimpleBleScan;

{$mode objfpc}{$H+}

{ Copyright (c) 2022 Erik Lins; modifications Copyright (c) 2026 Andrey Syutkin.
  MIT license. Native SimpleBLE has separate BUSL-1.1/commercial terms. }

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  SysUtils, SimpleBle;

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

procedure OnScan(Adapter: TSimpleBleAdapter; Peripheral: TSimpleBlePeripheral;
  UserData: Pointer); cdecl;
var
  Error: TSimpleBleError;
  Identifier, Address: PChar;
  Count: NativeUInt;
  I, J: SizeInt;
  Manufacturer: TSimpleBleOwnedManufacturerData;
  Rssi: Int16;
begin
  Error := nil;
  Identifier := nil;
  Address := nil;
  try
    try
      Identifier := SimpleBlePeripheralIdentifier(Peripheral, Error);
      CheckError(Error, 'peripheral identifier');
      Address := SimpleBlePeripheralAddress(Peripheral, Error);
      CheckError(Error, 'peripheral address');
      Rssi := SimpleBlePeripheralRssi(Peripheral, Error);
      CheckError(Error, 'peripheral RSSI');
      Count := SimpleBlePeripheralManufacturerDataCount(Peripheral, Error);
      CheckError(Error, 'manufacturer data count');
      if Count > NativeUInt(High(SizeInt)) then
        raise Exception.Create('Too many manufacturer records');
      Write('[' + string(Address) + '] ' + IntToStr(Rssi) +
        ' dBm "' + string(Identifier) + '"');
      for I := 0 to SizeInt(Count) - 1 do
      begin
        Manufacturer := SimpleBleGetManufacturerData(Peripheral, I, Error);
        CheckError(Error, 'manufacturer data');
        Write(' MD[' + IntToStr(I) + ']=0x');
        for J := 0 to High(Manufacturer.Data) do
          Write(IntToHex(Manufacturer.Data[J], 2));
      end;
      WriteLn();
    except
      on E: Exception do
        WriteLn('Scan callback: ' + E.Message);
    end;
  finally
    if Error <> nil then
      SimpleBleErrorRelease(Error);
    SimpleBleFree(Identifier);
    SimpleBleFree(Address);
    SimpleBlePeripheralReleaseHandle(Peripheral);
  end;
end;

procedure Run;
var
  Adapter: TSimpleBleAdapter;
  Error: TSimpleBleError;
  Count: NativeUInt;
begin
  if not LoadNativeLibraries then
    raise Exception.Create('Failed to load SimpleCBLE: ' +
      SimpleBleGetLastLoadError());
  Adapter := nil;
  Error := nil;
  try
    SimpleBlePinLibrary();
    Count := SimpleBleAdapterGetCount(Error);
    CheckError(Error, 'adapter count');
    if Count = 0 then
    begin
      WriteLn('No BLE adapter was found.');
      Exit;
    end;
    Adapter := SimpleBleAdapterGetHandle(0, Error);
    CheckError(Error, 'adapter handle');
    if Adapter = nil then
      raise Exception.Create('Could not get a BLE adapter handle');
    SimpleBleAdapterSetCallbackOnScanFound(Adapter, @OnScan, nil);
    SimpleBleAdapterSetCallbackOnScanUpdated(Adapter, @OnScan, nil);
    WriteLn('Scanning for 5 seconds...');
    SimpleBleAdapterScanFor(Adapter, 5000, Error);
    CheckError(Error, 'scan');
  finally
    if Error <> nil then
      SimpleBleErrorRelease(Error);
    if Adapter <> nil then
    begin
      SimpleBleAdapterSetCallbackOnScanFound(Adapter, nil, nil);
      SimpleBleAdapterSetCallbackOnScanUpdated(Adapter, nil, nil);
      SimpleBleAdapterReleaseHandle(Adapter);
    end;
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
