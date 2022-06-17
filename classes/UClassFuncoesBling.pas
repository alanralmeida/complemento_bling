unit UClassFuncoesBling;

interface

uses
  System.SysUtils, System.JSON, System.Classes;

const
  cTempoEntreRequisicoes = 340;

  cTextoRequisicaoVazia = '"cod":14';

type
  TJSON = record
    json: Array of String;
    erros: String;
  end;

function GetJsonRecurso(Url, Token, ChaveArray: String; Parametros: String = ''; UnicoRegistro: Boolean = False; Metodo: String = 'GET'): TJSON;
function GetErrosBling(pJson: String): String;
function GetSituacoesPedido(Url, Token: String): TStrings;

implementation

uses
  UClassFuncoesRede, ClassFuncoesJSON, UConstantes, UClassFuncoes;

function GetJsonRecurso(Url, Token, ChaveArray: String; Parametros: String = ''; UnicoRegistro: Boolean = False; Metodo: String = 'GET'): TJSON;
var
  Json, ParametroReq: String;
  Pagina: Integer;
begin
  Pagina := 1;
  try
    while True do
    begin
      if not UnicoRegistro then
        ParametroReq := '/page=' + IntToStr(Pagina) + '/json' + cParamtrokey + Token + Parametros
      else
        ParametroReq := '/json' + cParamtrokey + Token + Parametros;

      Json := TFuncoesRede.EnderecoWebProcessado(Url + ParametroReq, Metodo, '', 0, -1);

      if Pos('"erros"', Json) > 0 then
      begin
        if Pos(cTextoRequisicaoVazia, Json) > 0 then
          Break;
      end;

      //Seta mais indice array
      SetLength(Result.json, Pagina);

      Json := TFuncoesJson.GetObjectJson(Json, 'retorno');
      Json := TFuncoesJson.GetArrayJson(Json, ChaveArray);

      Result.json[Pagina - 1] := Json;

      if UnicoRegistro then
        Break;

      Inc(Pagina);
      Sleep(cTempoEntreRequisicoes);
    end;
  except
    on E: Exception do
      Result.erros := E.Message;
  end;
end;

function GetErrosBling(pJson: String): String;
var
  JsonArrayErros: TJSONArray;
  msgErro, Json: String;
begin
  Json := TFuncoesJson.GetObjectJson(pJson, 'retorno');
  Json := TFuncoesJson.GetArrayJson(Json, 'erros');

  JsonArrayErros := TJSONArray(TJSONObject.ParseJSONValue(Json));

  msgErro := '';
  while JsonArrayErros.Count > 0 do
  begin
    json := JsonArrayErros.Remove(0).ToString;
    Json := TFuncoesJSON.GetObjectJson(Json, 'erro');
    msgErro := msgErro + TFuncoesJSON.GetValueJson(Json, 'msg') + #13;
  end;

  Result := msgErro;
end;

function GetSituacoesPedido(Url, Token: String): TStrings;
var
  retorno: TJSON;
  JsonArray: TJSONArray;
  JsonTmp, JsonSituacao: String;
  LSTemp: TStringList;
begin
  LSTemp := TStringList.Create;
  try
    LSTemp.Clear;
    retorno := GetJsonRecurso(Url + cPathSituacao,
                               Token,
                               'situacoes', '', True);

    if retorno.erros <> '' then
    begin
      MensagemErro(retorno.erros);
      Abort;
    end;

    for JsonTmp in retorno.json do
    begin
      JsonArray := TJSONArray(TJSONObject.ParseJSONValue(JsonTmp));
      while JsonArray.Count > 0 do
      begin
        JsonSituacao := JsonArray.Remove(0).ToString;
        JsonSituacao := TFuncoesJSON.GetObjectJson(JsonSituacao, 'situacao');
        LSTemp.Add(TFuncoesJSON.GetValueJson(JsonSituacao, 'id') + '-' + TFuncoesJSON.GetValueJson(JsonSituacao, 'nome'));
      end;
    end;

    Result := LSTemp;
  finally
    FreeAndNil(JsonArray);
  end;
end;

end.
