{
  Classe..: RestConsumeAPi
  Autor...: I3 Sistemas
  Objetivo: Classe de consumo usando o TRESTRequest
  Obs.....: Caso precisar adcionar algun recurso siga o padrão e não coloque nada
            que não seja nativo.
}
unit RestConsumeAPI;

interface

uses
  System.SysUtils,
  REST.Client,
  REST.Types, System.JSON;
type
 TTypeMetodo  = (tpGet,tpPut,tpPost,tpDelete,tpPatch);
 TTypeAuth    = (tpBasic,tpBearer);

 iRestConsumeAPI = interface
 ['{6375EDC9-911A-4D6D-A62F-728D7223A312}']

 {Metodos Publicos da interface - Functios e Procedures da interface e declaradas na classe}
  function ExecutaMetodo(metodoRest : TTypeMetodo) : TRESTResponse;
  function bodyclear(): TRESTRequest;
  function AddBodyJson(Value: TJSONObject): TRESTRequest; overload;
  function AddBodyJson(Value: string): TRESTRequest; overload;
  function AddParameter(Resource, Value: string; {const} AKind: TRESTRequestParameterKind = pkGETorPOST;
  const AOptions: TRESTRequestParameterOptions = []) : TRESTRequest;
  function SendFile(AFile: Array of TFileName; AParamName: string = 'file'; AMethod: TRESTRequestMethod = rmPOST;
  AContentType: TRESTContentType = ctMULTIPART_FORM_DATA): string;
  procedure Authorization( AuthTipo : TTypeAuth; Value: string);
  function ResultJSONObject(AValue: string): TJSONObject;

end;

type

  TRestConsumeAPI = class(TInterfacedObject,iRestConsumeAPI)

  private
  FBaseURL       : String;
  FMetodo        : String;
  FAuth          : String;

  RESTClient   : TRESTClient;
  RESTRequest  : TRESTRequest;
  RESTResponse : TRESTResponse;


  {Metodo TipoAuth: Recebe o tipos da autenticação e retorna uma string do nome escolhido }
  Function TipoAuth(AuthTipo : TTypeAuth) : string;

  public

  {Metodo ExecutaMetodo: Executa o RESTRequest.Method  passando os paramentros Get,Put,Post,Delete,Patch  e retorna a resposta }
  function ExecutaMetodo(metodoRest : TTypeMetodo) : TRESTResponse;
  {Metodo AddParameter: adcionar Heardes no RESTRequest.AddParameter e passa os valores e paramentros de execução e retorna um RESTRequest }
  function AddParameter(Resource, Value: string; {const} AKind: TRESTRequestParameterKind = pkGETorPOST;
  const AOptions: TRESTRequestParameterOptions = []): TRESTRequest;
  {Metodo SendFile: Usada para o envio de arquivos}
  function SendFile(AFile: Array of TFileName; AParamName: string = 'file'; AMethod: TRESTRequestMethod = rmPOST;
  AContentType: TRESTContentType = ctMULTIPART_FORM_DATA): string;
  {Metodo AddBodyJson: Limpa o Body}
  function bodyclear(): TRESTRequest;
  {Metodo AddBodyJson: Adcionar um Body e recebe um TJSONObject no paramento}
  function AddBodyJson(Value: TJSONObject): TRESTRequest; overload;
  {Metodo AddBodyJson: Adcionar um Body e recebe uma string no paramento}
  function AddBodyJson(Value: string): TRESTRequest; overload;
  {Metodo Authorization: Autorização de acesso ao Json pode ser Basic, Bearer e outros}
  procedure Authorization( AuthTipo : TTypeAuth; Value: string);
  {Metodo NewConsumeReset: Configura o RESTRequest.Client para o consumo do Json}
  function  NewConsumeReset : TRestConsumeAPI;
  {Metodo Create: Criar e Instancia o metodos do TRestClient}
  Constructor Create( BaseUrl : string); overload;
  {Metodo Destroy: libera da memoria as Instancia o metodos do TRestClient}
  Destructor  Destroy; override;
  {Metodo New: executa o metodo Create  da classe}
  class function New( BaseUrl : string) : iRestConsumeAPI;
  {Metodo ResultJSONObject: Receber um json string e retorna um TJSONObject }
  function ResultJSONObject(AValue: string): TJSONObject;

end;

implementation

{ TRestConsumeAPI }

{TODO  -oClebson Marçal -cRestConsumeAPi : Create - Criar e Instancia o metodos do TRestClient }
constructor TRestConsumeAPI.Create( BaseUrl : string);
begin
  FBaseURL                      := BaseUrl;
  RESTClient                    := TRESTClient.Create(BaseUrl);
  RESTRequest                   := TRESTRequest.Create(nil);
  RESTResponse                  := TRESTResponse.Create(nil);
  RESTClient.AutoCreateParams   := True;
  RESTRequest.AutoCreateParams  := True;
  RESTRequest.HandleRedirects   := true;
  RESTRequest.Client            := RESTClient;
  RESTRequest.Response          := RESTResponse;

  NewConsumeReset;
end;

{TODO -oClebson Marçal -cRestConsumeAPi : Destroy - libera da memoria as Instancia o metodos do TRestClient }
destructor TRestConsumeAPI.Destroy;
begin
   RESTClient.Free;
   RESTRequest.Free;
   RESTResponse.Free;
  inherited;
end;
{TODO -oClebson Marçal -cRestConsumeAPi : ResultJSONObject - Receber um json string e retorna um TJSONObject }
function TRestConsumeAPI.ResultJSONObject(AValue: string): TJSONObject;
begin
  if not Trim(AValue).isEmpty and (AValue <> 'null') then
    Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(AValue), 0) as TJSONObject;
end;


{TODO -oClebson Marçal -cRestConsumeAPi : function ExecutaMetodo - Executa o RESTRequest.Method  passando os paramentros Get,Put,Post,Delete,Patch  e retorna a resposta }
function TRestConsumeAPI.ExecutaMetodo(metodoRest : TTypeMetodo) : TRESTResponse;
begin

   case metodoRest of
     tpGet     : RESTRequest.Method := TRESTRequestMethod.rmGET;
     tpPut     : RESTRequest.Method := TRESTRequestMethod.rmPUT;
     tpPost    : RESTRequest.Method := TRESTRequestMethod.rmPOST;
     tpDelete  : RESTRequest.Method := TRESTRequestMethod.rmDELETE;
     tpPatch   : RESTRequest.Method := TRESTRequestMethod.rmPATCH;
   end;

  RESTRequest.Execute;
  Result := RESTResponse;
end;

{TODO -oClebson Marçal -cRestConsumeAPi : function AddParameter: adcionar Heardes no RESTRequest.AddParameter e passa os valores e paramentros de execução e retorna um RESTRequest}
function TRestConsumeAPI.AddParameter(Resource, Value: string; {const} AKind: TRESTRequestParameterKind = pkGETorPOST;
  const AOptions: TRESTRequestParameterOptions = []): TRESTRequest;
begin

  RESTRequest.AddParameter(Resource, Value, AKind, AOptions);
  Result := RESTRequest;

end;

{TODO -oClebson Marçal -cRestConsumeAPi : function Authorization - Autorização de acesso ao Json pode ser Basic, Bearer e outros}
procedure TRestConsumeAPI.Authorization( AuthTipo : TTypeAuth; Value: string);
begin
  RESTRequest.AddParameter(FAuth,TipoAuth(AuthTipo)+value,pkHTTPHEADER, [poDoNotEncode]);
end;

{TODO -oMarivaldo Santos -cRestConsumeAPi : function AddBodyJson - Limpa o Body}
function TRestConsumeAPI.bodyclear: TRESTRequest;
begin
  Result := RESTRequest;
  Result.ClearBody;
end;

{TODO -oMarivaldo Santos -cRestConsumeAPi : function AddBodyJson - Adcionar um Body e recebe um TJSONObject no paramento}
function TRestConsumeAPI.AddBodyJson(Value: TJSONObject): TRESTRequest;
begin
   result := RESTRequest;
   AddBodyJson(value.ToJSON);
end;

{TODO -oMarivaldo Santos -cRestConsumeAPi : function AddBodyJson - Adcionar um Body e recebe uma string no paramento}
function TRestConsumeAPI.AddBodyJson(Value: string): TRESTRequest;
begin
  result := RESTRequest;
  Result.AddBody(Value, TRESTContentType.ctAPPLICATION_JSON);
end;

{TODO -oClebson Marçal -cRestConsumeAPi : function NewConsumeReset - Configura o RESTRequest.Client para o consumo do Json}
function TRestConsumeAPI.NewConsumeReset : TRestConsumeAPI;
begin
  Result := Self;
  RESTRequest.Client.ResetToDefaults;
  RESTResponse.ResetToDefaults;
  RESTRequest.Client.RaiseExceptionOn500 := False;

  {BaseURL Seta novamente por causa do reset}
  RESTRequest.Client.BaseURL       := FBaseURL;
  RESTRequest.Client.Accept        := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  RESTRequest.Client.AcceptCharset := 'utf-8, *;q=0.8';
  RESTRequest.Client.ContentType   := 'application/json; charset=utf-8';

end;

{TODO -oMarivaldo Santos -cRestConsumeAPi : function SendFile - Usada para o envio de arquivos}
function TRestConsumeAPI.SendFile(AFile: array of TFileName; AParamName: string;
  AMethod: TRESTRequestMethod; AContentType: TRESTContentType): string;
var
  J: Integer;
begin
  if Length(AFile) = 0 then
  begin
    Result := '{"Erro": "Nenhum arquivo informado. Verifique!"}';
    exit;
  end;

  RESTRequest.Client.Accept         := '*/*';
  RESTRequest.Client.AcceptCharset  := 'utf-8, *;q=0.8';
  RESTRequest.Client.AcceptEncoding := 'gzip, deflate, br';
  RESTRequest.Client.ContentType    := ContentTypeToString(AContentType);

  RESTRequest.Accept         := RESTRequest.Client.Accept;
  RESTRequest.AcceptEncoding := RESTRequest.Client.AcceptEncoding;
  RESTRequest.Method         := AMethod;

  for J := 0 to Length(AFile) do
  if NOT Trim(AFile[J]).IsEmpty then
    with RESTRequest.Client.Params.AddItem do
    begin
      {$IF COMPILERVERSION > 31}
      Kind := pkFILE;
      {$ELSE}
      Kind := pkREQUESTBODY;
      {$ENDIF}
      Name        := AParamName;
      Value       := AFile[J];
      Options     := [poDoNotEncode];
      ContentType := AContentType;
    end;

  try
    Result := ExecutaMetodo(tpPost).Content;
  except
    Result := RESTResponse.ErrorMessage;
  end;
end;

{TODO -oClebson Marçal -cRestConsumeAPi : Function TipoAuth - Recebe o tipos da autenticação e retorna uma string do nome escolhido}
Function TRestConsumeAPI.TipoAuth(AuthTipo : TTypeAuth) : string;
begin
  FAuth        :=  'Authorization';

  case AuthTipo of
    tpBasic     : Result :=  'Basic ';
    tpBearer    : Result :=  'Bearer ';
  end;
end;

{TODO -oClebson Marçal -cRestConsumeAPi : class function New - executa o metodo Create  da classe}
class function TRestConsumeAPI.New( BaseUrl : string) : iRestConsumeAPI;
begin
 Result := TRestConsumeAPI.Create(BaseUrl);
end;

end.
