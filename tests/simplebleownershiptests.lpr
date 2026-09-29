program SimpleBleOwnershipTests;

{$mode ObjFPC}{$H+}
{$pointermath on}

uses
  SysUtils, SimpleBle;

var
  ServiceReleaseCount: Integer = 0;
  ManufacturerReleaseCount: Integer = 0;
  BufferReleaseCount: Integer = 0;
  ErrorReleaseCount: Integer = 0;
  ReadReturnsError: Boolean = False;
  ReadReturnsEmpty: Boolean = False;
  ErrorMessageBuffer: array[0..31] of Char = 'native failure';

procedure Check(Condition: Boolean; const MessageText: string);
begin
  if not Condition then
    raise Exception.Create(MessageText);
end;

procedure MockServiceRelease(var Service: TSimpleBleService); cdecl;
var
  Index: NativeUInt;
begin
  Inc(ServiceReleaseCount);
  if Service.Characteristics <> nil then
  begin
    for Index := 0 to Service.CharacteristicCount - 1 do
      if Service.Characteristics[Index].Descriptors <> nil then
        FreeMem(Service.Characteristics[Index].Descriptors);
    FreeMem(Service.Characteristics);
  end;
  if Service.Data <> nil then
    FreeMem(Service.Data);
  Service := Default(TSimpleBleService);
end;

procedure MockManufacturerRelease(var Data: TSimpleBleManufacturerData); cdecl;
begin
  Inc(ManufacturerReleaseCount);
  if Data.Data <> nil then
    FreeMem(Data.Data);
  Data := Default(TSimpleBleManufacturerData);
end;

procedure MockFree(Handle: Pointer); cdecl;
begin
  Inc(BufferReleaseCount);
  FreeMem(Handle);
end;

procedure MockServicesGet(Handle: TSimpleBlePeripheral; Index: NativeUInt;
  var OutService: TSimpleBleService; var OutError: TSimpleBleError); cdecl;
begin
  OutService.DataLength := 1;
  GetMem(OutService.Data, 1);
  OutService.Data[0] := 42;
  OutError := Pointer(1);
end;

function MockRead(Handle: TSimpleBlePeripheral; Service,
  Characteristic: TSimpleBleUuid; var DataLength: NativeUInt;
  var OutError: TSimpleBleError): PByte; cdecl;
begin
  if ReadReturnsEmpty then
  begin
    DataLength := 0;
    OutError := nil;
    Exit(nil);
  end;
  GetMem(Result, 2);
  Result[0] := 7;
  Result[1] := 8;
  DataLength := 2;
  if ReadReturnsError then
    OutError := Pointer(1)
  else
    OutError := nil;
end;

function MockErrorCode(Error: TSimpleBleError): TSimpleBleErr; cdecl;
begin
  Result := SIMPLEBLE_ERROR_OPERATION_FAILED;
end;

function MockErrorMessage(Error: TSimpleBleError): PChar; cdecl;
begin
  Result := @ErrorMessageBuffer[0];
end;

procedure MockErrorRelease(var Error: TSimpleBleError); cdecl;
begin
  Inc(ErrorReleaseCount);
  ErrorMessageBuffer[0] := 'X';
  Error := nil;
end;

procedure TestServiceCopyAndRelease;
var
  Native: TSimpleBleService;
  Owned: TSimpleBleOwnedService;
begin
  Native := Default(TSimpleBleService);
  Native.DataLength := 2;
  GetMem(Native.Data, 2);
  Native.Data[0] := 1;
  Native.Data[1] := 2;
  Native.CharacteristicCount := 1;
  GetMem(Native.Characteristics, SizeOf(TSimpleBleCharacteristic));
  Native.Characteristics[0] := Default(TSimpleBleCharacteristic);
  Native.Characteristics[0].CanNotify := True;
  Native.Characteristics[0].DescriptorCount := 1;
  GetMem(Native.Characteristics[0].Descriptors, SizeOf(TSimpleBleDescriptor));
  Native.Characteristics[0].Descriptors[0] := Default(TSimpleBleDescriptor);
  Native.Characteristics[0].Descriptors[0].Uuid.Value[0] := 'a';

  Owned := SimpleBleTakeService(Native);
  Check(ServiceReleaseCount = 1, 'service was not released exactly once');
  Check((Native.Data = nil) and (Native.Characteristics = nil),
    'service release did not clear the native record');
  Check((Length(Owned.Data) = 2) and (Owned.Data[0] = 1) and
    (Owned.Data[1] = 2), 'service payload was not copied');
  Check((Length(Owned.Characteristics) = 1) and
    Owned.Characteristics[0].CanNotify and
    (Length(Owned.Characteristics[0].Descriptors) = 1) and
    (Owned.Characteristics[0].Descriptors[0].Value[0] = 'a'),
    'characteristics or descriptors were not copied');
end;

procedure TestPartialServiceReleasedOnError;
var
  Error: TSimpleBleError;
  Owned: TSimpleBleOwnedService;
begin
  Error := nil;
  Owned := SimpleBleGetService(nil, 0, Error);
  Check(Error <> nil, 'native error was lost');
  Check(Length(Owned.Data) = 0, 'failed service call returned data');
  Check(ServiceReleaseCount = 2, 'partial service was not released');
end;

procedure TestMalformedServiceStillReleased;
var
  Native: TSimpleBleService;
  Raised: Boolean;
begin
  Native := Default(TSimpleBleService);
  Native.CharacteristicCount := 1;
  Raised := False;
  try
    SimpleBleTakeService(Native);
  except
    on ESimpleBleInvalidNativeData do
      Raised := True;
  end;
  Check(Raised, 'malformed service was accepted');
  Check(ServiceReleaseCount = 3, 'malformed service was not released');
end;

procedure TestManufacturerCopyAndRelease;
var
  Native: TSimpleBleManufacturerData;
  Owned: TSimpleBleOwnedManufacturerData;
begin
  Native := Default(TSimpleBleManufacturerData);
  Native.ManufacturerId := 17;
  Native.DataLength := 1;
  GetMem(Native.Data, 1);
  Native.Data[0] := 99;
  Owned := SimpleBleTakeManufacturerData(Native);
  Check(ManufacturerReleaseCount = 1, 'manufacturer data was not released');
  Check((Owned.ManufacturerId = 17) and (Length(Owned.Data) = 1) and
    (Owned.Data[0] = 99), 'manufacturer payload was not copied');
end;

procedure TestReadBufferLifetime;
var
  Buffer: PByte;
  Bytes: TBytes;
  Error: TSimpleBleError;
  Uuid: TSimpleBleUuid;
begin
  Buffer := nil;
  Bytes := SimpleBleCopyBufferAndFree(Buffer, 0);
  Check((Length(Bytes) = 0) and (Buffer = nil) and
    (BufferReleaseCount = 0), 'empty buffer was not accepted');

  Uuid := Default(TSimpleBleUuid);
  Error := nil;
  Bytes := SimpleBleReadValue(nil, Uuid, Uuid, Error);
  Check((Error = nil) and (Length(Bytes) = 2) and (Bytes[0] = 7) and
    (Bytes[1] = 8) and (BufferReleaseCount = 1),
    'successful read was not copied and freed');

  ReadReturnsEmpty := True;
  Bytes := SimpleBleReadValue(nil, Uuid, Uuid, Error);
  Check((Error = nil) and (Length(Bytes) = 0) and
    (BufferReleaseCount = 1), 'empty successful read was rejected');
  ReadReturnsEmpty := False;

  ReadReturnsError := True;
  Bytes := SimpleBleReadValue(nil, Uuid, Uuid, Error);
  Check((Error <> nil) and (Length(Bytes) = 0) and
    (BufferReleaseCount = 2), 'failed read leaked its buffer');
end;

procedure TestErrorInfoLifetime;
var
  Error: TSimpleBleError;
  Info: TSimpleBleErrorInfo;
begin
  Error := Pointer(1);
  Info := SimpleBleTakeErrorInfo(Error);
  Check((Error = nil) and (ErrorReleaseCount = 1),
    'error was not released');
  Check(Info.HasError and
    (Info.Code = SIMPLEBLE_ERROR_OPERATION_FAILED) and
    (Info.Message = 'native failure'),
    'error details did not survive native release');
end;

begin
  SimpleBleServiceRelease := @MockServiceRelease;
  SimpleBleManufacturerDataRelease := @MockManufacturerRelease;
  SimpleBleFree := @MockFree;
  SimpleBlePeripheralServicesGet := @MockServicesGet;
  SimpleBlePeripheralRead := @MockRead;
  SimpleBleErrorCode := @MockErrorCode;
  SimpleBleErrorMessage := @MockErrorMessage;
  SimpleBleErrorRelease := @MockErrorRelease;

  TestServiceCopyAndRelease;
  TestPartialServiceReleasedOnError;
  TestMalformedServiceStillReleased;
  TestManufacturerCopyAndRelease;
  TestReadBufferLifetime;
  TestErrorInfoLifetime;
  WriteLn('SimpleBLE ownership tests passed');
end.
