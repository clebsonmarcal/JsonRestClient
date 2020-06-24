unit DataSetConverter4D.Helper;

interface

uses
  REST.Response.Adapter,
  System.JSON,
  Data.DB,
  DataSetConverter4D,
  DataSetConverter4D.Impl, System.SysUtils;

type

  TDataSetConverterHelper = class helper for TDataSet
  public
    function AsJSONObject: TJSONObject;
    function AsJSONArray: TJSONArray;

    function AsJSONObjectString: string;
    function AsJSONArrayString: string;

    procedure FromJSONObject(json: TJSONObject);
    procedure FromJSONArray(json: TJSONArray);

    procedure RecordFromJSONObject(json: TJSONObject);
  end;

  procedure InputJsonToDataSet(aDataset : TDataSet; aJSON : string);

implementation

procedure InputJsonToDataSet(aDataset : TDataSet; aJSON : string);
var
  JObj: TJSONArray;
  vConv : TCustomJSONDataSetAdapter;
begin
  if Trim(aJSON).isEmpty then
    Exit;

  JObj := TJSONObject.ParseJSONValue(aJSON) as TJSONArray;
  vConv := TCustomJSONDataSetAdapter.Create(Nil);

  try
    vConv.Dataset := aDataset;
    vConv.UpdateDataSet(JObj);
  finally
    vConv.Free;
    JObj.Free;
  end;
end;

{ TDataSetConverterHelper }

function TDataSetConverterHelper.AsJSONArray: TJSONArray;
begin
  Result := TConverter.New.DataSet(Self).AsJSONArray;
end;

function TDataSetConverterHelper.AsJSONArrayString: string;
var
  ja: TJSONArray;
begin
  ja := Self.AsJSONArray;
  try
    Result := ja.ToString;
  finally
    ja.Free;
  end;
end;

function TDataSetConverterHelper.AsJSONObject: TJSONObject;
begin
  Result := TConverter.New.DataSet(Self).AsJSONObject;
end;

function TDataSetConverterHelper.AsJSONObjectString: string;
var
  jo: TJSONObject;
begin
  jo := Self.AsJSONObject;
  try
    Result := jo.ToString;
  finally
    jo.Free;
  end;
end;

procedure TDataSetConverterHelper.FromJSONArray(json: TJSONArray);
begin
  TConverter.New.JSON(json).ToDataSet(Self);
end;

procedure TDataSetConverterHelper.FromJSONObject(json: TJSONObject);
begin
  TConverter.New.JSON(json).ToDataSet(Self);
end;

procedure TDataSetConverterHelper.RecordFromJSONObject(json: TJSONObject);
begin
  TConverter.New.JSON(json).ToRecord(Self);
end;

end.
