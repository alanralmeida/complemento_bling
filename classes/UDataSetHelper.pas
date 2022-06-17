unit UDataSetHelper;

interface

uses
  System.SysUtils, System.Classes, Datasnap.DBClient, Data.DB, Math,
  System.DateUtils, System.Variants, Data.FMTBcd, Vcl.ExtCtrls, Vcl.Graphics,
  System.JSON.Writers, System.StrUtils;


type
  TDataSetHelper = class helper for TClientDataSet
  private
    function IndexOf(const sNome: string): Integer;
  public
    procedure InverterSelecao(const sCampo: string = 'MARQUE');
    procedure Ordenar(const sCampos, sCamposDescendente: string);
    function IndexAtivo: Integer;
  end;

const
  idxDefault = 'DEFAULT_ORDER';
  idxOrdenacao = 'ORDER_TKG';

implementation

{ TDataSetHelper }

procedure TDataSetHelper.InverterSelecao(const sCampo: string);
var
  F: TField;
begin
  F := FindField(sCampo);
  if (IsEmpty) or (F = nil) then
    Exit;

  Edit;
  if F.AsString = 'S' then
    F.AsString := 'N'
  else
    F.AsString := 'S';
  Post;
end;

procedure TDataSetHelper.Ordenar(const sCampos, sCamposDescendente: string);
var
  I             : Integer;
  NomeIndex     : string;
  FlagIncluirIdx: Boolean;
  idOptions     : TIndexOptions;
  BM            : TBookmark;
begin
  if (not Self.Active) or
    (Assigned(Self.MasterSource)) then
    Exit;

  BM        := GetBookmark;
  IndexName := idxDefault;

  if (sCampos = '') then
    Exit;

  DisableControls;
  try
    NomeIndex      := idxOrdenacao;
    FlagIncluirIdx := True;

    if sCamposDescendente = sCampos then
      idOptions := [ixDescending]
    else
      idOptions := [];

    with IndexDefs do
    begin
      Update;
      for I := 0 to Count - 1 do
        if (Items[I].Name = idxOrdenacao) then
        begin
          if (Items[I].Fields <> sCampos) or (Items[I].DescFields <> sCamposDescendente) or (Items[I].Options <> idOptions) then
            DeleteIndex(idxOrdenacao)
          else
            FlagIncluirIdx := False;
          Break;
        end;
    end;

    if FlagIncluirIdx then
    begin
      try
        AddIndex(NomeIndex, sCampos, idOptions, sCamposDescendente);
      except
        NomeIndex := idxDefault;
      end;
    end;

    try
      IndexName := NomeIndex;
    except
      on E: Exception do
      begin
        IndexName := idxDefault;
        raise Exception.Create('Ocorreu o seguinte erro ao tentar ordenar: ' + #13 + E.Message + #13 + 'Será usada a ordenação padrão');
      end;
    end;

    if BookmarkValid(BM) then
      GotoBookmark(BM);
  finally
    FreeBookmark(BM);
    EnableControls;
  end;
end;

function TDataSetHelper.IndexAtivo: Integer;
begin
  Result := -1;

  if IndexName = '' then
    Exit;

  Result := IndexOf(IndexName);
end;

function TDataSetHelper.IndexOf(const sNome: string): Integer;
var
  I: Integer;
begin
  Result := -1;

  IndexDefs.Update;
  for I := 0 to IndexDefs.Count - 1 do
    if (IndexDefs[I].Name = sNome) then
    begin
      Result := I;
      Break;
    end;
end;
end.
