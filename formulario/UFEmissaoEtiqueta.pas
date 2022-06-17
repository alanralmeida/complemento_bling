unit UFEmissaoEtiqueta;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UPai, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet, Vcl.StdCtrls, Vcl.Buttons,
  Datasnap.DBClient, REST.Response.Adapter, Vcl.Grids, Vcl.DBGrids, Vcl.ExtCtrls, frxClass, frxDBSet, frxExportPDF, Vcl.Mask, JvExMask, JvToolEdit, Vcl.Menus;

type
  TFEmissaoEtiquetas = class(TFPai)
    btnBuscarDocumentos: TSpeedButton;
    mQueryConfig: TFDMongoQuery;
    CDSDocumentos: TClientDataSet;
    dbgrdDocumento: TDBGrid;
    DSDocumentos: TDataSource;
    pnl1: TPanel;
    grpFornecedor: TGroupBox;
    grp1: TGroupBox;
    grpItens: TGroupBox;
    dbgrd1: TDBGrid;
    DSFornecedores: TDataSource;
    DSItens: TDataSource;
    dbgrd2: TDBGrid;
    cdsItens: TClientDataSet;
    btnImprimiEtiqueta: TSpeedButton;
    frxItens: TfrxDBDataset;
    Label1: TLabel;
    frxReport: TfrxReport;
    mQueryFornecedor: TFDMongoQuery;
    mQueryProdutos: TFDMongoQuery;
    chkExibiRelatorio: TCheckBox;
    cbbSituacao: TComboBox;
    edtDataInicial: TJvDateEdit;
    edtDataFinal: TJvDateEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    pm1: TPopupMenu;
    mniMarcartodos1: TMenuItem;
    mniDesmarcartodos1: TMenuItem;
    procedure btnBuscarDocumentosClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnImprimiEtiquetaClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mQueryFornecedorAfterOpen(DataSet: TDataSet);
    procedure dbgrdDocumentoDblClick(Sender: TObject);
    procedure mniMarcartodos1Click(Sender: TObject);
    procedure mniDesmarcartodos1Click(Sender: TObject);
  private
    procedure CriarEstruturaCDS;
    procedure CriarRelacionamento;
    procedure RemoverRelacionamento;
    procedure BuscarDocumentos;
    procedure PrepararItensParaEmissaoEtiqueta;
    procedure MarcarRegistro;
    function EnviarEmail(Email, Msg: String; Arquivos: TStrings): Boolean;
    procedure DesmarcarRegistro;
  public
    { Public declarations }
  end;

var
  FEmissaoEtiquetas: TFEmissaoEtiquetas;

implementation

{$R *.dfm}

uses UClassFuncoesRede, UDMConexao, UConstantes, ClassFuncoesJSON, System.JSON, UClassFuncoes, UClassFuncoesBling, ClassEnviarEmail,
  System.StrUtils, UGridHelper;

procedure TFEmissaoEtiquetas.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  FEmissaoEtiquetas := nil;
end;

procedure TFEmissaoEtiquetas.FormCreate(Sender: TObject);
begin
  inherited;
  mQueryConfig.Close;
  mQueryConfig.DatabaseName := cNomeBancoDados;
  mQueryConfig.CollectionName := cColecaoConfiguracao;
  mQueryConfig.Open;

  mQueryFornecedor.Close;
  mQueryFornecedor.DatabaseName := cNomeBancoDados;
  mQueryFornecedor.CollectionName := cColecaoFornecedor;
  mQueryFornecedor.Open;
  mQueryFornecedor.IndexFieldNames := 'razaoSocial';

  mQueryProdutos.Close;
  mQueryProdutos.DatabaseName := cNomeBancoDados;
  mQueryProdutos.CollectionName := cColecaoProduto;
end;

procedure TFEmissaoEtiquetas.FormShow(Sender: TObject);
begin
  inherited;
  CriarEstruturaCDS;
  CriarRelacionamento;

  cbbSituacao.Items.Clear;
  cbbSituacao.Items.Add('0-Todos');
  cbbSituacao.Items.AddStrings(
          GetSituacoesPedido(mQueryConfig.FieldByName('webservice').AsString, mQueryConfig.FieldByName('token').AsString)
   );
  cbbSituacao.ItemIndex := 0;

  ConfigurarColunaMarcacao(ProcurarColunaPeloNome(dbgrdDocumento, 'MARQUE'));

  dbgrdDocumento.Configurar;
end;

procedure TFEmissaoEtiquetas.MarcarRegistro;
var
  Marcado: String;
begin
  cdsItens.DisableControls;
  try
  //  Marcado := CDSDocumentos.FieldByName('MARQUE').AsString;
 //   if Marcado = 'S' then
  //    Exit;

    CDSDocumentos.Edit;
    CDSDocumentos.FieldByName('MARQUE').AsString := 'S';
    CDSDocumentos.Post;

    cdsItens.First;
    while not cdsItens.Eof do
    begin
      CDSItens.Edit;
      CDSItens.FieldByName('MARQUE').AsString := 'S';
      CDSItens.Post;
      CDSItens.Next;
    end;
  finally
    cdsItens.EnableControls;
  end;
end;

procedure TFEmissaoEtiquetas.DesmarcarRegistro;
var
  Marcado: String;
begin
  Marcado := CDSDocumentos.FieldByName('MARQUE').AsString;
  if Marcado = 'N' then
    Exit;

  CDSDocumentos.Edit;
  CDSDocumentos.FieldByName('MARQUE').AsString := 'N';
  CDSDocumentos.Post;

  cdsItens.First;
  while not cdsItens.Eof do
  begin
    CDSItens.Edit;
    CDSItens.FieldByName('MARQUE').AsString := 'N';
    CDSItens.Post;
    CDSItens.Next;
  end;
end;

procedure TFEmissaoEtiquetas.mniDesmarcartodos1Click(Sender: TObject);
begin
  inherited;
  LockWindowUpdate(Self.Handle);
  try
    CDSDocumentos.First;
    while not CDSDocumentos.Eof do
    begin
      DesmarcarRegistro;
      CDSDocumentos.Next;
    end;
  finally
    CDSDocumentos.First;
    LockWindowUpdate(0);
  end;
end;

procedure TFEmissaoEtiquetas.mniMarcartodos1Click(Sender: TObject);
begin
  inherited;

  LockWindowUpdate(Self.Handle);
  try
    CDSDocumentos.First;
    while not CDSDocumentos.Eof do
    begin
      MarcarRegistro;
      CDSDocumentos.Next;
    end;
  finally
    CDSDocumentos.First;
    LockWindowUpdate(0);
  end;
end;

procedure TFEmissaoEtiquetas.mQueryFornecedorAfterOpen(DataSet: TDataSet);
begin
  inherited;
  if DataSet.FindField('_id') <> nil then
    DataSet.FieldByName('_id').Visible := False;
end;

procedure TFEmissaoEtiquetas.btnImprimiEtiquetaClick(Sender: TObject);
var
  ST: TMemoryStream;
  Arquivo: String;
  LSArquivo, LSErros, LSDanfe: TStrings;
  CodigoTemp: Integer;
  Mensagem: String;
begin
  inherited;
  LSArquivo := TStringList.Create;
  LSErros := TStringList.Create;
  LSDanfe := TStringList.Create;
  DMConexao.AbrirTelaAguarde;
  try
    LSErros.Clear;
    mQueryFornecedor.DisableControls;
    CDSDocumentos.DisableControls;
    cdsItens.DisableControls;
    RemoverRelacionamento;

    CDSDocumentos.IndexFieldNames := 'numero';

    ST := TMemoryStream.Create;
    try
      LerRecursoDLL(cRecursoEtiquetas, cNomeDLL, ST);

      if ST.Size = 0 then
          raise Exception.Create('Relatório não encontrado no recurso.');

      frxReport.LoadFromStream(ST);
    finally
        FreeAndNil(ST);
    end;

    mQueryFornecedor.First;
    while not mQueryFornecedor.Eof do
    begin
      LSArquivo.Clear;

      cdsItens.Filtered := False;
      cdsItens.Filter := 'fornecedor = ' + QuotedStr(mQueryFornecedor.FieldByName('_id').AsString) + ' and MARQUE = ' + QuotedStr('S');
      cdsItens.Filtered := True;

      CodigoTemp := 0;
      LSDanfe.Clear;
      while not cdsItens.Eof do
      begin
        if (CodigoTemp <> cdsItens.FieldByName('numero').AsInteger) and
           CDSDocumentos.FindKey([cdsItens.FieldByName('numero').AsInteger]) then
        begin
          CodigoTemp := cdsItens.FieldByName('numero').AsInteger;
          LSDanfe.Add('Nota fiscal ' + CDSDocumentos.FieldByName('numeroNF').AsString + ': ' + CDSDocumentos.FieldByName('linkDanfe').AsString + '   ' + CDSDocumentos.FieldByName('transportadora').AsString);
        end;

        cdsItens.Next;
      end;

      if cdsItens.IsEmpty then
      begin
        mQueryFornecedor.Next;
        Continue;
      end;

      if chkExibiRelatorio.Checked then
      begin
        Arquivo := ExtractFilePath(Application.ExeName) + mQueryFornecedor.FieldByName('razaoSocial').AsString + '.pdf';

        frxpdExport.FileName := Arquivo;

        frxReport.PrepareReport;
        frxReport.Export(frxpdExport);

        LSArquivo.Add(Arquivo);

        Mensagem := 'Em anexo as etiquetas.' + #13#13 +
                    'Link para danfe das nota(s) fiscal(is): ' + #13 +
                     LSDanfe.Text;

        try
          EnviarEmail(mQueryFornecedor.FieldByName('email').AsString, Mensagem, LSArquivo);
        except
          on E:Exception do
            LSErros.Add('Falha ao enviar o email para o fornecedor ' + mQueryFornecedor.FieldByName('razaoSocial').AsString + #13 +
                        'Erro: ' + E.Message + #13);
        end;

        DeleteFile(Arquivo);
      end
      else
        frxReport.ShowReport;

      mQueryFornecedor.Next;
    end;

    if LSErros.Count > 0 then
      MensagemErro(LSErros.Text)
    else
      MensagemInformacao('Impressão realizada com sucesso');
  finally
    DMConexao.FecharTelaAguarde;
    FreeAndNil(LSArquivo);
    FreeAndNil(LSErros);
    FreeAndNil(LSDanfe);

    cdsItens.Filtered := False;
    CriarRelacionamento;
    mQueryFornecedor.EnableControls;
    CDSDocumentos.EnableControls;
    cdsItens.EnableControls;
    mQueryFornecedor.First;
    CDSDocumentos.First;
  end;
end;

procedure TFEmissaoEtiquetas.CriarEstruturaCDS;
begin
  with CDSDocumentos.FieldDefs do
  begin
    CDSDocumentos.Close;
    Clear;
    Add('MARQUE', ftString, 1);
    Add('numeroNF', ftInteger);
    Add('numero', ftInteger);
    Add('data', ftDateTime);
    Add('totalvenda', ftCurrency);
    Add('situacao', ftString, 20);
    Add('dataPrevista', ftDateTime);
    Add('nomeCliente', ftString, 70);
    Add('cnpjCliente', ftString, 15);
    Add('cidadeCliente', ftString, 30);
    Add('ufCliente', ftString, 2);
    Add('chaveNF', ftString, 44);
    Add('linkDanfe', ftString, 255);
    Add('observacaointerna', ftString, 255);
    Add('transportadora', ftString, 255); /////////////// TRANSPORTADORA
    CDSDocumentos.CreateDataSet;
  end;

  with cdsItens.FieldDefs do
  begin
    cdsItens.Close;
    Clear;
    Add('MARQUE', ftString, 1);
    Add('numero', ftInteger);
    Add('codigo', ftString, 20);
    Add('descricao', ftString, 120);
    Add('quantidade', ftFloat);
    Add('volumes', ftInteger);
    Add('fracao', ftString, 10);
    Add('un', ftString, 4);
    Add('pesoBruto', ftFloat);
    Add('largura', ftFloat);
    Add('altura', ftFloat);
    Add('profundidade', ftFloat);
    Add('fornecedor', ftString, 50);
    Add('nomeCliente', ftString, 70);
    Add('cnpjCliente', ftString, 15);
    Add('cidadeCliente', ftString, 30);
    Add('ufCliente', ftString, 2);
    Add('numeroNF', ftInteger);
    Add('linkDanfe', ftString, 255);
    Add('obs_internas', ftString, 255);
    Add('transportadora', ftString, 255); /////////////// TRANSPORTADORA
    cdsItens.CreateDataSet;
    cdsItens.FieldByName('MARQUE').Visible := False;
    cdsItens.FieldByName('fornecedor').Visible := False;
    cdsItens.FieldByName('cnpjCliente').Visible := False;
    cdsItens.FieldByName('cidadeCliente').Visible := False;
    cdsItens.FieldByName('ufCliente').Visible := False;
    cdsItens.FieldByName('ufCliente').Visible := False;
    cdsItens.FieldByName('linkDanfe').Visible := False;
  end;
end;

procedure TFEmissaoEtiquetas.CriarRelacionamento;
begin
  CDSDocumentos.IndexFieldNames := 'numero';

  cdsItens.IndexFieldNames := 'numero';
  cdsItens.MasterSource := DSDocumentos;
  cdsItens.MasterFields := 'numero';
end;

procedure TFEmissaoEtiquetas.dbgrdDocumentoDblClick(Sender: TObject);
begin
  inherited;
  if CDSDocumentos.FieldByName('MARQUE').AsString = 'S' then
    DesmarcarRegistro
  else
    MarcarRegistro;
end;

function TFEmissaoEtiquetas.EnviarEmail(Email, Msg: String; Arquivos: TStrings): Boolean;
var
  EnviaEmail: ClassEnviarEmail.TEnviarEmail;
begin
  EnviaEmail := TEnviarEmail.Create(nil);
  try
    with EnviaEmail do
    begin
      ServidorEmail_Host     := mQueryConfig.FieldByName('smtpEmail').AsString;
      ServidorEmail_Port     := mQueryConfig.FieldByName('portaEmail').AsInteger;
      ServidorEmail_Username := mQueryConfig.FieldByName('contaEmail').AsString;
      ServidorEmail_Password := mQueryConfig.FieldByName('senhaEmail').AsString;

      Destinatario_Email   := Email;
      Destinatario_EmailCC := mQueryConfig.FieldByName('emailCopia').AsString;
      Assunto              := 'Etiquetas';
      Mensagem             := Msg;

      ArquivosAnexados.Assign(Arquivos);

      AguardarEnvio := True;
      Enviar;

      Result := Enviado;
    end;
  finally
    FreeAndNil(EnviaEmail);
  end;
end;

procedure TFEmissaoEtiquetas.RemoverRelacionamento;
begin
  cdsItens.MasterFields := '';
  cdsItens.MasterSource := nil;
  cdsItens.IndexFieldNames := '';
end;

procedure TFEmissaoEtiquetas.btnBuscarDocumentosClick(Sender: TObject);
begin
  inherited;
  BuscarDocumentos;
  PrepararItensParaEmissaoEtiqueta;
end;

procedure TFEmissaoEtiquetas.BuscarDocumentos;
var
  retorno, retornoNF: TJSON;
  Json, JsonTmp, JsonCliente, JsonTransportadora, JsonNF, FiltroSituacao: String;
  JsonArrayDocumento, JsonArrayItens, JsonArrayNF: TJSONArray;
  FuncoesJson: TFuncoesJSON;
begin
  inherited;
  JsonArrayDocumento := nil;
  JsonArrayItens := nil;
  JsonArrayNF := nil;

  FuncoesJson := TFuncoesJSON.Create;
  try
    DMConexao.AbrirTelaAguarde;
    try
      FiltroSituacao := '';
      CDSDocumentos.EmptyDataSet;
      cdsItens.EmptyDataSet;

      if (edtDataInicial.Date <= 0) or (edtDataFinal.Date <= 0) then
      begin
        MensagemAviso('Data inicial e final devem ser informadas.');
        Exit;
      end;

      if cbbSituacao.ItemIndex > 0 then
        FiltroSituacao := '; idSituacao[' + Copy(cbbSituacao.Items[cbbSituacao.ItemIndex], 0, cbbSituacao.Items[cbbSituacao.ItemIndex].LastIndexOf('-')) + ']';

      retorno := GetJsonRecurso(mQueryConfig.FieldByName('webservice').AsString + cPathPedido,
                             mQueryConfig.FieldByName('token').AsString,
                             'pedidos',
                             '&filters=dataEmissao[' + FormatDateTime('dd/mm/yyyy', edtDataInicial.Date) + ' TO ' + FormatDateTime('dd/mm/yyyy', edtDataFinal.Date) + ']' +
                             FiltroSituacao);

      if retorno.erros <> '' then
      begin
        MensagemErro(retorno.erros);
        Exit;
      end;

      for JsonTmp in retorno.json do
      begin
        JsonArrayDocumento := TJSONArray(TJSONObject.ParseJSONValue(JsonTmp));
        while JsonArrayDocumento.Count > 0 do
        begin
          Json := FuncoesJson.GetObjectJson(JsonArrayDocumento.Remove(0).ToString, 'pedido');

          if Pos('"codigosRastreamento"', Json) > 0 then
          begin
            CDSDocumentos.Append;
            CDSDocumentos.FieldByName('MARQUE').AsString := 'S';
            FuncoesJson.JSONObjectToFields(TJSONObject(TJSONObject.ParseJSONValue(Json)), CDSDocumentos);

            //Cliente
            JsonCliente := FuncoesJson.GetObjectJson(Json, 'cliente');
            CDSDocumentos.FieldByName('nomeCliente').AsString   := FuncoesJson.GetValueJson(JsonCliente, 'nome');
            CDSDocumentos.FieldByName('cnpjCliente').AsString   := FuncoesJson.GetValueJson(JsonCliente, 'cnpj');
            CDSDocumentos.FieldByName('cidadeCliente').AsString := FuncoesJson.GetValueJson(JsonCliente, 'cidade');
            CDSDocumentos.FieldByName('ufCliente').AsString     := FuncoesJson.GetValueJson(JsonCliente, 'uf');

            //Transportadora
            JsonTransportadora := FuncoesJson.GetObjectJson(Json, 'transporte');
            CDSDocumentos.FieldByName('transportadora').AsString   := FuncoesJson.GetValueJson(JsonTransportadora, 'transportadora');

            //Nota Fiscal
            if Pos('"nota"', Json) > 0 then
            begin
              JsonNF := FuncoesJson.GetObjectJson(Json, 'nota');
              CDSDocumentos.FieldByName('numeroNF').AsString := FuncoesJson.GetValueJson(JsonNF, 'numero');
              CDSDocumentos.FieldByName('chaveNF').AsString  := FuncoesJson.GetValueJson(JsonNF, 'chaveAcesso');

              // Busca link do danfe
              retornoNF := GetJsonRecurso(mQueryConfig.FieldByName('webservice').AsString + cPathNotaFiscal +
                                          '/' + CDSDocumentos.FieldByName('numeroNF').AsString +
                                          '/' + FuncoesJson.GetValueJson(JsonNF, 'serie'),
                                          mQueryConfig.FieldByName('token').AsString,
                                          'notasfiscais', '', True);

              if retornoNF.erros <> '' then
              begin
                MensagemErro(retornoNF.erros);
                Exit;
              end;

              JsonArrayNF := TJSONArray(TJSONObject.ParseJSONValue(retornoNF.json[0]));
              JsonNF := FuncoesJson.GetObjectJson(JsonArrayNF.Remove(0).ToString, 'notafiscal');
              CDSDocumentos.FieldByName('linkDanfe').AsString := FuncoesJson.GetValueJson(jsonNF, 'linkDanfe');

            end;

            CDSDocumentos.Post;


            //Itens
            JsonArrayItens := TJSONArray(TJSONObject.ParseJSONValue(FuncoesJson.GetArrayJson(Json, 'itens')));
            FuncoesJson.JSONArrayToRecords(JsonArrayItens, cdsItens);

            // Atribui dados para facilitar impressão da etiqueta por fornecedor
            cdsItens.First;
            while not cdsItens.Eof do
            begin
              cdsItens.Edit;
              CDSItens.FieldByName('MARQUE').AsString := CDSDocumentos.FieldByName('MARQUE').AsString;
              cdsItens.FieldByName('nomeCliente').AsString := CDSDocumentos.FieldByName('nomeCliente').AsString;
              cdsItens.FieldByName('cnpjCliente').AsString := CDSDocumentos.FieldByName('cnpjCliente').AsString;
              cdsItens.FieldByName('cidadeCliente').AsString := CDSDocumentos.FieldByName('cidadeCliente').AsString;
              cdsItens.FieldByName('ufCliente').AsString := CDSDocumentos.FieldByName('ufCliente').AsString;
              cdsItens.FieldByName('numeroNF').AsString := CDSDocumentos.FieldByName('numeroNF').AsString;
              cdsItens.FieldByName('obs_internas').AsString := CDSDocumentos.FieldByName('observacaointerna').AsString;
              cdsItens.FieldByName('transportadora').AsString := CDSDocumentos.FieldByName('transportadora').AsString;  /////////////// TRANSPORTADORA
              cdsItens.Next;
            end;
          end;
        end;
      end;

      CDSDocumentos.First;
      cdsItens.First;
    except
      on E: Exception do
        MensagemErro('Falha ao buscar pedidos. Erro ' + E.Message);
    end;
  finally
    JsonArrayDocumento.Free;
    JsonArrayItens.Free;
    JsonArrayNF.Free;
    FreeAndNil(FuncoesJson);
    DMConexao.FecharTelaAguarde;
  end;
end;

procedure TFEmissaoEtiquetas.PrepararItensParaEmissaoEtiqueta;
var
  CDSTmp: TClientDataSet;
  I, J, K: Integer;
begin
  RemoverRelacionamento;

  CDSTmp := TClientDataSet.Create(nil);
  try
    cdsItens.DisableControls;
    mQueryFornecedor.DisableControls;

    cdsItens.IndexFieldNames := 'numero;codigo';

    CDSTmp.Data := cdsItens.Data;

    CDSTmp.First;
    while not CDSTmp.Eof do
    begin
      if not cdsItens.FindKey([CDSTmp.FieldByName('numero').AsString, CDSTmp.FieldByName('codigo').AsString]) then
      begin
        CDSTmp.Next;
        Continue;
      end;

      mQueryProdutos.Close;
      mQueryProdutos.QMatch := '"codigo": "' + CDSTmp.FieldByName('codigo').AsString + '"';
      mQueryProdutos.Open;

      if not mQueryProdutos.IsEmpty then
      begin
        for J := 1 to CDSTmp.FieldByName('quantidade').AsInteger do
        begin
          for I := 1 to mQueryProdutos.FieldByName('volumes').AsInteger do
          begin
            if (I = 1) and (J = 1) then
              cdsItens.Edit
            else
            begin
              cdsItens.Append;
              for K := 0 to CDSTmp.FieldCount - 1 do
                cdsItens.Fields[K].Value := CDSTmp.Fields[K].Value;
            end;

            cdsItens.FieldByName('volumes').AsInteger := mQueryProdutos.FieldByName('volumes').AsInteger;
            cdsItens.FieldByName('fracao').AsString := I.ToString + '/' + mQueryProdutos.FieldByName('volumes').AsString;

            if mQueryFornecedor.FindKey([mQueryProdutos.FieldByName('nomeFornecedor').AsString]) then
              cdsItens.FieldByName('fornecedor').AsString := mQueryFornecedor.FieldByName('_id').AsString;

            cdsItens.Post;
          end;
        end;
      end;

      CDSTmp.Next;
    end;
  finally
    CriarRelacionamento;
    mQueryProdutos.Close;
    cdsItens.EnableControls;
    mQueryFornecedor.EnableControls;
    cdsItens.First;

    FreeAndNil(CDSTmp);
  end;
end;

end.
