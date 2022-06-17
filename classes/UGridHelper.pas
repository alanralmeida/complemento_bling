unit UGridHelper;

interface

uses
  System.SysUtils, System.Classes, System.StrUtils, Winapi.Windows,
  Vcl.Controls, Vcl.Forms, Vcl.Grids, Vcl.DBGrids, Vcl.Graphics, JvDBGrid, JvExDBGrids,
  Data.DB, Datasnap.DBClient, Clipbrd, System.Math;

type
  TGridHelper = class helper for TCustomDBGrid
    private
    public
      procedure TitleClick_Padrao(Column: TColumn);
      procedure Ordenar(Coluna: TColumn; Acumulativo: Boolean = False);

      procedure Configurar;
  end;

implementation

{ TGridHelper }

uses UDataSetHelper, ClassFuncoesString;

procedure TGridHelper.TitleClick_Padrao(Column: TColumn);
begin
  if not (Screen.ActiveControl is TDBGrid) then
    Exit;

  if not (DataSource.DataSet is TClientDataSet) then
    Exit;

  Ordenar(Column, GetKeyState(VK_CONTROL) < 0);
end;

procedure TGridHelper.Ordenar(Coluna: TColumn; Acumulativo: Boolean = False);
var
  i: Integer;
  Campos, CamposDescendente: string;
  Operacao: Integer;
begin
  if not (DataSource.DataSet is TClientDataSet) then
    Exit;

  if (not Self.DataSource.DataSet.Active) or (Coluna.FieldName = '') or Assigned(TClientDataSet(Self.DataSource.DataSet).MasterSource) then
    Exit;

  if (Coluna.Field.FieldKind in [fkCalculated, fkLookup, fkAggregate]) or (Coluna.Field.DataType in [ftBlob, ftMemo, ftGraphic]) then
    Exit;

  Columns.BeginUpdate;
  try
    for I := 0 to Columns.Count - 1 do
      begin
        Columns[I].Title.Font.Style := [];
        Columns[I].Title.Font.Color := clBlack;
      end;
  finally
    Columns.EndUpdate;
  end;

  Campos := Coluna.FieldName;
  CamposDescendente := '';

  with TClientDataSet(DataSource.DataSet) do
  begin
    I := IndexAtivo;
    if (I >= 0) then
    begin
      if (Pos(Campos, IndexDefs[I].DescFields) > 0) or
         ((Pos(Campos, IndexDefs[I].Fields) > 0) and (ixDescending in IndexDefs[I].Options)) then
      begin
        if Acumulativo then
          Operacao := 0
        else
          Operacao := 1
      end
      else if (Pos(Campos, IndexDefs[I].Fields) > 0) and (Pos(Campos, IndexDefs[I].DescFields) = 0) then
        Operacao := 2
      else
        Operacao := 1;

      if Acumulativo then
      begin
        if (ixDescending in IndexDefs[I].Options) then
          CamposDescendente := IndexDefs[I].Fields
        else
          CamposDescendente := IndexDefs[I].DescFields;

        if (Pos(Campos, IndexDefs[I].Fields) = 0) then
          Campos := IndexDefs[I].Fields + ';' + Campos
        else
          Campos := IndexDefs[I].Fields;
      end;

      case Operacao of
        0: // retira
          begin
            TFuncoesString.Trocar(Campos, Coluna.FieldName + ';', '');
            TFuncoesString.Trocar(Campos, Coluna.FieldName, '');
            TFuncoesString.Trocar(Campos, ';;', ';');

            TFuncoesString.Trocar(CamposDescendente, Coluna.FieldName + ';', '');
            TFuncoesString.Trocar(CamposDescendente, Coluna.FieldName, '');
            TFuncoesString.Trocar(CamposDescendente, ';;', ';');
          end;
        1: // ordena ascedente
          begin
            TFuncoesString.Trocar(CamposDescendente, Coluna.FieldName + ';', '');
            TFuncoesString.Trocar(CamposDescendente, Coluna.FieldName, '');
            TFuncoesString.Trocar(CamposDescendente, ';;', ';');
          end;
        2: // Operacao descendente
          begin
            if CamposDescendente <> '' then
              CamposDescendente := CamposDescendente + ';';
            CamposDescendente := CamposDescendente + Coluna.FieldName;
          end;
      end;
    end;
  end;

  TClientDataSet(DataSource.DataSet).Ordenar(Campos, CamposDescendente);
end;

procedure TGridHelper.Configurar;
begin
  if not Assigned(OnTitleClick) then
    OnTitleClick := TitleClick_Padrao;

  if (Self is TJvDBGrid) then
    with (Self as TJvDBGrid) do
    begin
      ShowHint := True;
      ShowTitleHint := True;
      TitleArrow := True;
      TitleButtons := True;
      TitleButtonAllowMove := True;
      with SelectColumnsDialogStrings do
      begin
        SelectColumn := scGrid;
        Caption := 'Selecione as colunas';
        NoSelectionWarning := 'Pelo menos uma coluna deve estar visível';
        RealNamesOption := 'Exibir nomes reais dos campos';
      end;
    end;
end;

end.
