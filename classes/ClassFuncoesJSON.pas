unit ClassFuncoesJSON;

interface

uses
  System.SysUtils,
  System.StrUtils,
  System.Variants,
  System.JSON,
  System.JSON.Writers,
  System.Generics.Collections,
  Rest.json,
  Data.DB,
  Data.DBXJSONReflect,
  DBClient,
  System.Classes,
  System.Rtti;

type
  TFuncoesJSON = class
  private
    VetorCDS: array of TClientDataSet;
    ListaObjJSONtoCDS: TStringList;

    function CDSPeloNome(NomeObjJSON: String): TClientDataSet;
    procedure TentarGravarArraySimples(Campo, Valor: String; CDS: TClientDataSet; ForcarInclusao: Boolean = False);

    procedure _JSONObjectToFields(JSONObject: TJSONObject; CDS: TClientDataSet);
    function _JSONArrayToRecords(JSONArray: TJsonArray; CDS: TClientDataSet): string;
  public
    constructor Create;
    destructor Destroy; override;

    class function JSONToString(const sJSON: string): string;
    class function StringToJSON(const sString: string): string;
    class function JSONFormatado(const sJSON: string): string;

    class function GetObjectJson(JSON, PropertyName: string): string;
    class function GetArrayJson(JSON, PropertyName: string): string;
    class function GetValueJson(JSON, PropertyName: string): string; overload;
    class function GetValueJson(JSON, PropertyName: string; const DefaultValue: string): string; overload;

    class procedure JSONPairToField(JSONPar: TJSONPair; CDS: TClientDataSet);
    class procedure JSONObjectToFields(JSONObject: TJSONObject; CDS: TClientDataSet);
    class procedure JSONArrayToRecords(JSONArray: TJsonArray; CDS: TClientDataSet);

    procedure JSONToCDS(sJSONObject: String; CDSs: array of TClientDataSet; NomesObjJSON: String);
    class function ObjectToJson(Obj: TObject): TJSONValue;
    class function RecordToJson<T>(pRecord: T): TJSONValue;
  end;

implementation

uses ClassFuncoesString;

constructor TFuncoesJSON.Create;
begin
  inherited Create;

  ListaObjJSONtoCDS := TStringList.Create;
  SetLength(VetorCDS, 0);
end;

destructor TFuncoesJSON.Destroy;
var x: Integer;
begin
  ListaObjJSONtoCDS.Free;

  for x := High(VetorCDS) downto Low(VetorCDS) do
    VetorCDS[x] := nil;

  SetLength(VetorCDS, 0);

  inherited;
end;

class function TFuncoesJSON.JSONToString(const sJSON: string): string;
begin
  with TJSONObject.ParseJSONValue(sJSON) do
    try
      Result := ToString;
    finally
      Free;
    end;
end;

class function TFuncoesJSON.StringToJSON(const sString: string): string;
begin
  with TJSONObject.ParseJsonValue(sString) do
    try
      Result := ToJson;
    finally
      Free;
    end;
end;

class function TFuncoesJSON.JSONFormatado(const sJSON: string): string;
var JSONValue: TJSONValue;
begin
  JSONValue := TJSONObject.ParseJSONValue(sJSON);
  if(Assigned(JSONValue))then
  begin
    Result := Trim(REST.Json.TJson.Format(JSONValue));
    Result := StringReplace(Result, #13#10','#13#10, ',', [rfReplaceAll]);
  end
  else raise Exception.Create('JSON inválido!');
end;

class function TFuncoesJSON.GetObjectJson(JSON, PropertyName: string): string;
begin
  with TJSONObject.ParseJSONValue(Json) do
    try
      Result := GetValue<TJSONObject>(PropertyName).ToJSON;
    finally
      Free;
    end;
end;

class function TFuncoesJSON.GetArrayJson(JSON, PropertyName: string): string;
begin
  with TJSONObject.ParseJSONValue(Json) do
    try
      Result := GetValue<TJSONArray>(PropertyName).ToJSON;
    finally
      Free;
    end;
end;

class function TFuncoesJSON.GetValueJson(JSON, PropertyName: string): string;
begin
  with TJSONObject.ParseJSONValue(Json) do
    try
      Result := GetValue<string>(PropertyName)
    finally
      Free;
    end;
end;

class function TFuncoesJSON.GetValueJson(JSON, PropertyName: string; const DefaultValue: string): string;
begin
  with TJSONObject.ParseJSONValue(Json) do
    try
      Result := GetValue<string>(PropertyName, DefaultValue);
    finally
      Free;
    end;
end;

class procedure TFuncoesJSON.JSONPairToField(JSONPar: TJSONPair; CDS: TClientDataSet);
var
  sCampo, sValor: String;
  fCampo: TField;
  DataHoraTemp: TDateTime;
  Valor: Double;
begin
  if (JSONPar.JsonValue is TJSONArray) then
    Exit;

  if not Assigned(CDS) then
    Exit;

  // Identificando em qual campo gravar
  sCampo := Trim(JSONPar.JsonString.Value);

  fCampo := CDS.FindField(sCampo);

  if Assigned(fCampo) then
    begin
      sValor := Trim(JSONPar.JsonValue.Value);

      if (fCampo.DataType in [ftFloat, ftCurrency, ftExtended, ftBCD, ftFMTBcd]) then
        begin
          JSONPar.JsonValue.TryGetValue<double>(Valor);
          sValor := FloatToStr(Valor);
        end;
      if (fCampo.DataType in [ftDate, ftDateTime, ftTimeStamp]) then
        begin
          if not JSONPar.JsonValue.TryGetValue<TDateTime>(DataHoraTemp) then
            try
              DataHoraTemp := StrToDateTime(sValor);
            except
            end;
          if (DataHoraTemp = 0) then
            sValor := ''
          else
            begin
              if (fCampo.DataType = ftDate) then
                sValor := DateToStr(DataHoraTemp)
              else
                sValor := DateTimeToStr(DataHoraTemp);
            end;
        end;

      fCampo.AsString := sValor;
    end;
end;

class procedure TFuncoesJSON.JSONObjectToFields(JSONObject: TJSONObject; CDS: TClientDataSet);
var
  iCampo: Integer;
  JSONPar: TJSONPair;
begin
  for iCampo := 0 to JSONObject.Count - 1 do
    begin
      JSONPar := JSONObject.Pairs[iCampo];

      if (JSONPar.JsonValue is TJSONArray) or
         (JSONPar.JSONValue is TJSONObject) then
        Continue;

      JSONPairToField(JSONPar, CDS);
    end;
end;

class procedure TFuncoesJSON.JSONArrayToRecords(JSONArray: TJSONArray; CDS: TClientDataSet);
var
  iRegistro: Integer;
  oRegistro: TJSONObject;
  JSONValue: TJSONValue;
begin
  for iRegistro := 0 to JSONArray.Count - 1 do
    begin
      JSONValue := JSONArray.Items[iRegistro];
      if (JSONValue is TJSONObject) then
        begin
          oRegistro := TJSONObject(JSONValue);

          // Se for um elemento nominado no Array, deve pegar apenas a parte mais interna, sem o nome
          if (oRegistro.Count = 1) then
            oRegistro := TJSONObject(oRegistro.Pairs[0].JsonValue);

          CDS.Append;
          JSONObjectToFields(oRegistro, CDS);
          CDS.Post;
        end;
    end;
end;

procedure TFuncoesJSON.JSONToCDS(sJSONObject: String; CDSs: Array of TClientDataSet; NomesObjJSON: String);
var
  ValueGeral: TJSONValue;
  ObjetoGeral: TJSONObject;
  Enumerador: TJSONPairEnumerator;
  ParAtual: TJSONPair;
  CDSGravar: TClientDataSet;
  I: Integer;
  S: String;
begin
  {$region 'Validações/Carregamentos iniciais}
  if Trim(sJSONObject) = '' then
    raise Exception.Create('String JSON está vazia.');

  ListaObjJSONtoCDS.Text := AnsiUpperCase(Trim(TFuncoesString.Trocar(NomesObjJSON, ';', #13)));

  if ListaObjJSONtoCDS.Count = 0 then
    raise Exception.Create('Pelo menos um elemento deve ser capturado para gravação.');

  if ListaObjJSONtoCDS.Count <> Length(CDSs) then
    raise Exception.Create('O array de TClientDataSets deve conter o mesmo número de elementos JSON a serem pesquisados');

  ValueGeral := TJSONObject.ParseJSONValue(sJSONObject);
  if not Assigned(ValueGeral) then
    raise Exception.Create('String contém um arquivo JSON inválido');

  if not (ValueGeral is TJSONObject) then
    raise Exception.Create('O JSON passado não é um TJSONObject válido, é apenas um TJSONValue. Experimente delimitá-lo dando um nome para o elemento principal.');

  SetLength(VetorCDS, Length(CDSs));
  for I := Low(CDSs) to High(CDSs) do
    VetorCDS[I] := CDSs[I];

  ObjetoGeral := TJSONObject(ValueGeral);
  {$endregion}

  Enumerador := ObjetoGeral.GetEnumerator;
  try
    while Enumerador.MoveNext do
      begin
        ParAtual  := Enumerador.Current;

        CDSGravar := CDSPeloNome(ParAtual.JSONString.Value);

        if (ParAtual.JSONValue is TJSONArray) then
          begin
            S := _JSONArrayToRecords(TJSONArray(ParAtual.JSONValue), CDSGravar);
            TentarGravarArraySimples(ParAtual.JSONString.Value, S, CDSGravar, True);
          end

        else if (ParAtual.JSONValue is TJSONObject) then
          _JSONObjectToFields(TJSONObject(ParAtual.JSONValue), CDSGravar)

        else // é apenas um JSONPair simples
          begin
  //          JSONPairToField(ParAtual, CDSGravar);
            {ShowMessage(ParAtual.ToString + #13 +
                        ParAtual.JsonString.ToString + #13 +
                        ParAtual.JsonValue.ToString);}
          end;
      end;
  finally
    Enumerador.Free;
  end;
end;

procedure TFuncoesJSON._JSONObjectToFields(JSONObject: TJSONObject; CDS: TClientDataSet);
var
  iCampo: Integer;
  JSONPar: TJSONPair;
  S: String;
begin
  if Assigned(CDS) then
    CDS.Append;

  for iCampo := 0 to JSONObject.Count - 1 do
    begin
      JSONPar  := JSONObject.Pairs[iCampo];

      if (JSONPar.JSONValue is TJSONArray) then
        begin
          S := _JSONArrayToRecords(TJSONArray(JSONPar.JsonValue), CDSPeloNome(JSONPar.JSONString.Value));
          if (S <> '') then
            begin
              if (Assigned(CDS)) then
                TentarGravarArraySimples(JSONPar.JSONString.Value, S, CDS, False)
              else
                TentarGravarArraySimples(JSONPar.JSONString.Value, S, CDSPeloNome(JSONPar.JSONString.Value), True);
            end;
        end

      else if (JSONPar.JSONValue is TJSONObject) then
        _JSONObjectToFields(TJSONObject(JSONPar.JSONValue), CDSPeloNome(JSONPar.JSONString.Value))

      else // Par simples pode gravar direto no CDS em questão
        JSONPairToField(JSONPar, CDS);
    end;

  if Assigned(CDS) then
    CDS.Post;
end;

function TFuncoesJSON._JSONArrayToRecords(JSONArray: TJSONArray; CDS: TClientDataSet): String;
var
  iRegistro: Integer;
  JSONValue: TJSONValue;
  oRegistro: TJSONObject;
  ArraySimples: String;
begin
  ArraySimples := '';
  for iRegistro := 0 to JSONArray.Count - 1 do
    begin
      JSONValue := JSONArray.Items[iRegistro];

      if (JSONValue is TJSONObject) then
        begin
          oRegistro := TJSONObject(JSONValue);

          // Se for um elemento nominado no Array, deve pegar apenas a parte mais interna, sem o nome
          if (oRegistro.Count = 1) then
            oRegistro := TJSONObject(oRegistro.Pairs[0].JsonValue);

          _JSONObjectToFields(oRegistro, CDS);
        end

      else if (JSONValue is TJSONArray) then
        _JSONArrayToRecords(TJSONArray(JSONValue), CDSPeloNome(JSONValue.ToJSON))

      else {if (JSONValue is TJSONString) or
              (JSONValue is TJSONNumber) then}
        begin
          if Trim(ArraySimples) <> '' then
            ArraySimples := ArraySimples + ', ';
          ArraySimples := ArraySimples + JSONValue.ToString;
        end;
    end;
  Result := ArraySimples;
end;

function TFuncoesJSON.CDSPeloNome(NomeObjJSON: String): TClientDataSet;
var IndiceCDS: Integer;
begin
  Result := nil;

  NomeObjJSON := AnsiUpperCase(Trim(NomeObjJSON));
  NomeObjJSON := AnsiDequotedStr(NomeObjJSON, '"');
  NomeObjJSON := AnsiDequotedStr(NomeObjJSON, '''');

  if (NomeObjJSON <> '') then
    begin
      IndiceCDS := ListaObjJSONtoCDS.IndexOf(NomeObjJSON);
      if (IndiceCDS > -1) then
        Result := VetorCDS[IndiceCDS];
    end;
end;

procedure TFuncoesJSON.TentarGravarArraySimples(Campo, Valor: String; CDS: TClientDataSet; ForcarInclusao: Boolean = False);
var F: TField;
begin
  if (Trim(Valor) = '') then
    Exit;

  if not Assigned(CDS) then
    Exit;

  F := CDS.FindField(Trim(Campo));

  if Assigned(F) then
    begin
      if ForcarInclusao then
        CDS.Append;

      F.AsString := Valor;

      if ForcarInclusao then
        CDS.Post;
    end;
end;

class function TFuncoesJSON.ObjectToJson(Obj: TObject): TJSONValue;
var
  xMarshal: TJSONMarshal;
begin
  if Assigned(Obj) then
  begin
    xMarshal := TJSONMarshal.Create(TJSONConverter.Create);
    try
      Result := xMarshal.Marshal(Obj);
    finally
      xMarshal.Free;
    end;
  end
  else Result := TJSONNull.Create;
end;

class function TFuncoesJSON.RecordToJson<T>(pRecord: T): TJSONValue;
var
  AContext: TRttiContext;
  ARecord: TRttiRecordType;
  AField: TRttiField;
  Json: TJsonObjectWriter;
  NomeField: String;
  ValorField: TValue;
begin
  AContext := TRttiContext.Create;
  try
    ARecord := AContext.GetType(TypeInfo(T)).AsRecord;
    Json := TJsonObjectWriter.Create(False);

    Json.WriteStartObject;
    for AField in ARecord.GetFields do
    begin
      NomeField := AField.Name;
      ValorField := AField.GetValue(@pRecord);

      case ValorField.TypeInfo.Kind of
        tkInteger, tkInt64:
          begin
            Json.WritePropertyName(NomeField);
            Json.WriteValue(ValorField.AsInt64);
          end;
        tkString, tkChar, tkWideString, tkUnicodeString, tkAnsiString:
          begin
            Json.WritePropertyName(NomeField);
            Json.WriteValue(ValorField.AsString);
          end;
        tkFloat:
          begin
            Json.WritePropertyName(NomeField);

            if AField.FieldType.ToString.Equals('TDateTime') then
              Json.WriteValue(FormatDateTime('dd/mm/yyyy hh:nn:ss', ValorField.AsExtended))
            else if AField.FieldType.ToString.Equals('TDate') then
              Json.WriteValue(FormatDateTime('dd/mm/yyyy', ValorField.AsExtended))
            else if AField.FieldType.ToString.Equals('TTime') then
              Json.WriteValue(FormatDateTime('HH:nn:ss', ValorField.AsExtended))
            else
              Json.WriteValue(ValorField.AsCurrency);
          end;
        tkEnumeration:
          begin
            Json.WritePropertyName(NomeField);
            Json.WriteValue(ValorField.AsBoolean);
          end;
      end

    end;
    Json.WriteEndObject;

    Result := TJSONValue(Json.JSON);
  finally
    AContext.Free;
    Json.Free;
  end;
end;

end.

