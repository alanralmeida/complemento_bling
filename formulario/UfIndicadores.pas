unit UFIndicadores;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UPai, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, frxClass, frxExportPDF, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet, Vcl.Menus, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.Mask, JvExMask, JvToolEdit, Vcl.Buttons, Vcl.ExtCtrls,
  frxDBSet, Datasnap.DBClient, System.JSON, Vcl.DBCtrls, JvDBControls, Vcl.ComCtrls,
  FireDAC.Phys.MongoDBWrapper, System.JSON.Writers, System.StrUtils, ComObj,
  JvComponentBase, JvgExportComponents, JvDBGridExport, JvBaseDlg,
  JvProgressDialog;

type
  TFIndicadores = class(TFPai)
    mQueryConfig: TFDMongoQuery;
    DSItens: TDataSource;
    cdsItens: TClientDataSet;
    frxItens: TfrxDBDataset;
    frxReport: TfrxReport;
    mQueryFornecedor: TFDMongoQuery;
    mQueryProdutos: TFDMongoQuery;
    DSDocumentos: TDataSource;
    cdsDocumentos: TClientDataSet;
    cdsDocumentoImportado: TClientDataSet;
    cdsItemImportado: TClientDataSet;
    frxDBDocumentos: TfrxDBDataset;
    mQueryDocumentoImportado: TFDMongoQuery;
    DSDocumentoImportado: TDataSource;
    DSItemImportado: TDataSource;
    pm1: TPopupMenu;
    mniMarcartodos1: TMenuItem;
    mniDesmarcartodos1: TMenuItem;
    JvgExportExcel: TJvgExportXML;
    dlgSave1: TSaveDialog;
    JvDBGridExcelExport1: TJvDBGridExcelExport;
    ProgressDialog: TJvProgressDialog;
    pgPrincipal: TPageControl;
    tbsImportacao: TTabSheet;
    btnImportarDocumentos: TSpeedButton;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    btnGerarPedidoCompra: TSpeedButton;
    cbSituacao: TComboBox;
    edtDataFinal: TJvDateEdit;
    edtDataInicial: TJvDateEdit;
    grp1: TGroupBox;
    dbgrdDocumento: TDBGrid;
    grpItens: TGroupBox;
    dbgrd1: TDBGrid;
    chkApenasPedidoNaoImportados: TCheckBox;
    btnExportar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure btnBuscarDocumentosClick(Sender: TObject);
//    procedure btnConsultaClick(Sender: TObject);
//    procedure cbCampoPesquisaChange(Sender: TObject);
//    procedure btnPesquisarClick(Sender: TObject);
    procedure dbgridConsultaDblClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
//    procedure btnVisualizarClick(Sender: TObject);
//    procedure btnVoltarClick(Sender: TObject);
    procedure dbgrdDocumentoDblClick(Sender: TObject);
    procedure btnGerarPedidoCompraClick(Sender: TObject);
    procedure mQueryAfterOpen(DataSet: TDataSet);
    procedure dbgrdDocumentoDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
//    procedure edtSequencialExit(Sender: TObject);
    procedure mniMarcartodos1Click(Sender: TObject);
    procedure mniDesmarcartodos1Click(Sender: TObject);
    procedure btnExportarClick(Sender: TObject);
    procedure btnImportarDocumentosClick(Sender: TObject);
  private
    FGerandoPedidoCompra, FRetornoConsulta: Boolean;
    procedure ValidateItem(Sender: TField);
    procedure CriarEstruturaCDS;
    procedure BuscarDocumentos;
    function EnviarEmail(Email, Msg: string; Arquivos: TStrings): Boolean;
    procedure GerarPedidoCompraPorFornecedor;
    procedure InserirDocumento;
//    procedure IrParaDados;
    procedure PopularCDSDocumentoImportado;
    procedure CriarRelacionamentoCDS;
    procedure RemoverRelacionamentoCDS;
    procedure AtualizarDocumentoImportado(NumeroPedido: string);
    procedure AtualizarDocumentoEnviado(Codigo: Integer);
    procedure AtualizarDocumento(Codigo: Integer);
    procedure CopiarDadosConsulta;
  public
    { Public declarations }
  end;

var
  FIndicadores: TFIndicadores;

implementation

uses
  UConstantes, UDMConexao, ClassFuncoesJSON, UClassFuncoesBling, UClassFuncoes,
  ClassEnviarEmail, UDataSetHelper, UGridHelper;

{$R *.dfm}

procedure TFIndicadores.FormCreate(Sender: TObject);
begin
  NomeColecao := cColecaoPedidoCompra;

  inherited;

  FGerandoPedidoCompra := False;
  FRetornoConsulta := False;

  mQueryConfig.Close;
  mQueryConfig.DatabaseName := cNomeBancoDados;
  mQueryConfig.CollectionName := cColecaoConfiguracao;
  mQueryConfig.Open;

  mQueryFornecedor.Close;
  mQueryFornecedor.DatabaseName := cNomeBancoDados;
  mQueryFornecedor.CollectionName := cColecaoFornecedor;
  mQueryFornecedor.Open;
  mQueryFornecedor.IndexFieldNames := '_id';

  mQueryProdutos.Close;
  mQueryProdutos.DatabaseName := cNomeBancoDados;
  mQueryProdutos.CollectionName := cColecaoProduto;

  mQueryDocumentoImportado.Close;
  mQueryDocumentoImportado.DatabaseName := cNomeBancoDados;
  mQueryDocumentoImportado.CollectionName := cColecaoPedido;
end;

procedure TFIndicadores.FormShow(Sender: TObject);
begin
  inherited;

  pgPrincipal.ActivePage := tbsImportacao;
  //tbsConsulta.TabVisible := False;
  CriarEstruturaCDS;

  cbSituacao.Items.Clear;
  cbSituacao.Items.Add('0-Todos');
  cbSituacao.Items.AddStrings(GetSituacoesPedido(mQueryConfig.FieldByName('webservice').AsString, mQueryConfig.FieldByName('token').AsString));
  cbSituacao.ItemIndex := 0;

  ConfigurarColunaMarcacao(ProcurarColunaPeloNome(dbgrdDocumento, 'MARQUE'));

  dbgrdDocumento.Configurar;
end;

procedure TFIndicadores.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  FIndicadores := nil;
end;

procedure TFIndicadores.CriarEstruturaCDS;
begin
  with CDSDocumentoImportado.FieldDefs do
  begin
    CDSDocumentoImportado.Close;
    Clear;
    Add('MARQUE', ftString, 1);
    Add('_id', ftString, 50);
    Add('pedidoImportado', ftString, 1);
    Add('numeroNF', ftInteger);
    Add('numero', ftInteger);
    Add('data', ftDateTime);
    Add('dataEmissaoNota', ftDateTime);  //Alteração dia 28, 29, 30/11/2019
    Add('tipoIntegracao', ftString, 30);   //Alteração dia 03/12/2019
    Add('totalvenda', ftCurrency);
    Add('situacao', ftString, 20);
    Add('dataPrevista', ftDateTime);
    Add('nomeCliente', ftString, 70);
    Add('cnpjCliente', ftString, 15);
    Add('cidadeCliente', ftString, 30);
    Add('ufCliente', ftString, 2);
    Add('chaveNF', ftString, 44);
    Add('linkDanfe', ftString, 255);
    CDSDocumentoImportado.CreateDataSet;
    CDSDocumentoImportado.FieldByName('_id').Visible := False;
    CDSDocumentoImportado.FieldByName('pedidoImportado').Visible := False;
   // CDSDocumentoImportado.FieldByName('pedidoImportado').DisplayLabel := 'XXX';
  end;

  with CDSItemImportado.FieldDefs do
  begin
    CDSItemImportado.Close;
    Clear;
    Add('MARQUE', ftString, 1);
    Add('numero', ftInteger);
    Add('codigo', ftString, 20);
  //  Add('codigoFabricante', ftString, 20);
    Add('descricao', ftString, 150);
  //  Add('descricaoFornecedor', ftString, 120);
    Add('quantidade', ftFloat);
    Add('un', ftString, 4);
    Add('pesoBruto', ftFloat);
    Add('largura', ftFloat);
    Add('altura', ftFloat);
    Add('profundidade', ftFloat);
    CDSItemImportado.CreateDataSet;
    CDSItemImportado.FieldByName('MARQUE').Visible := False;
  end;

  with cdsDocumentos.FieldDefs do
  begin
    cdsDocumentos.Close;
    Clear;
    Add('_id', ftString, 50);
    Add('sequencial', ftInteger);
    Add('idFornecedor', ftString, 50);
    Add('nomeFornecedor', ftString, 150);
    Add('condicaoPagamento', ftString, 150);
    Add('dataEmissao', ftDateTime, 0);
    Add('observacao', ftMemo, 0);
    Add('pedidoEnviado', ftString, 1);
    cdsDocumentos.CreateDataSet;
  end;

  with cdsItens.FieldDefs do
  begin
    cdsItens.Close;
    Clear;
    Add('codigo', ftString, 20);
    Add('codigoFabricante', ftString, 20);
    Add('descricao', ftString, 150);
    Add('descricaoFornecedor', ftString, 150);
    Add('un', ftString, 4);
    Add('quantidade', ftFloat);
    Add('precoCusto', ftCurrency);
    Add('pesoBruto', ftFloat);
    Add('largura', ftFloat);
    Add('altura', ftFloat);
    Add('profundidade', ftFloat);
    Add('nomeCliente', ftString, 120);
    Add('cnpjCliente', ftString, 15);
    Add('cidadeCliente', ftString, 30);
    Add('ufCliente', ftString, 2);
    cdsItens.CreateDataSet;

    cdsItens.FieldByName('nomeCliente').Visible := False;
    cdsItens.FieldByName('cnpjCliente').Visible := False;
    cdsItens.FieldByName('cidadeCliente').Visible := False;
    cdsItens.FieldByName('ufCliente').Visible := False;

    cdsItens.FieldByName('codigo').OnValidate := ValidateItem;
  end;
end;

procedure TFIndicadores.dbgrdDocumentoDblClick(Sender: TObject);
begin
  inherited;
  CDSDocumentoImportado.InverterSelecao;
end;

procedure TFIndicadores.dbgrdDocumentoDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn; State: TGridDrawState);
begin
  inherited;
  if CDSDocumentoImportado.FieldByName('pedidoImportado').AsString = 'S' then
    dbgrdDocumento.Canvas.Brush.Color := $00F9D6AA;

  dbgrdDocumento.DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TFIndicadores.dbgridConsultaDblClick(Sender: TObject);
begin
  CopiarDadosConsulta;
end;

{procedure TFIndicadores.edtSequencialExit(Sender: TObject);
begin
  inherited;
  mQuery.Close;
  mQuery.QMatch := '"sequencial":' + edtSequencial.Text;
  mQuery.Open;

  CopiarDadosConsulta;
end;
 }

procedure TFIndicadores.btnBuscarDocumentosClick(Sender: TObject);
begin
  inherited;
  CDSDocumentoImportado.EmptyDataSet;
  CDSItemImportado.EmptyDataSet;

  BuscarDocumentos;
  PopularCDSDocumentoImportado;

  MensagemInformacao('Importação realizada com sucesso.');
end;

{procedure TFIndicadores.btnConsultaClick(Sender: TObject);
begin
  inherited;
  tbsConsulta.TabVisible := True;
  tbsImportacao.TabVisible := False;
  tbsDados.TabVisible := False;
  pgPrincipal.ActivePage := tbsConsulta;
end;
       }
procedure TFIndicadores.btnExcluirClick(Sender: TObject);
var
  objId: TMongoOID;
  DocDelete: TMongoSelector;
begin
  inherited;
  DocDelete := TMongoSelector.Create(conexao.Env);
  objId := TMongoOID.Create(conexao.Env, nil);
  try
    if cdsDocumentos.IsEmpty then
      Exit;

    objId.AsString := cdsDocumentos.FieldByName('_id').AsString;

    DocDelete.Match().Add(fCampoCache, objId);
    conexao[cNomeBancoDados][NomeColecao].Remove(DocDelete);

    cdsDocumentos.EmptyDataSet;
    cdsItens.EmptyDataSet;
  finally
    FreeAndNil(DocDelete);
    FreeAndNil(objId);
  end;
end;

procedure TFIndicadores.btnExportarClick(Sender: TObject);
begin
 dlgSave1.Title := 'Exportar a Microsoft Excel...';
 dlgSave1.Filter := 'Microsoft Excel 97-2003 [*.xls]|*.xls|Microsoft Excel 2007 [*.xlsx]|*.xlsx|Todos los Archivos [*.*]|*.*';
 dlgSave1.FilterIndex := 1;
 dlgSave1.DefaultExt := '*.xls';
 if dlgSave1.Execute Then
 begin
   JvDBGridExcelExport1.FileName := dlgSave1.FileName;
 //DBGridExcelExport.UseFieldGetText := true;
   JvDBGridExcelExport1.Grid := dbgrdDocumento;
   //ProgressDialog.Position := 0;
   //ProgressDialog.Max := DBUltimGrid.DataSource.DataSet.RecordCount-1;
   //ProgressDialog.Show;
   JvDBGridExcelExport1.ExportGrid;
  // ProgressDialog.Hide;
 end;

end;

procedure TFIndicadores.btnGerarPedidoCompraClick(Sender: TObject);
begin
  inherited;
  try
    LockWindowUpdate(Self.Handle);
    DMConexao.AbrirTelaAguarde;

    CDSDocumentoImportado.Filtered := False;
    CDSDocumentoImportado.Filter := 'MARQUE = ' + QuotedStr('S');
    CDSDocumentoImportado.Filtered := True;

    if CDSDocumentoImportado.IsEmpty then
    begin
      MensagemInformacao('Nenhum documento foi selecionado.');
      Exit;
    end;

    GerarPedidoCompraPorFornecedor;

  finally
    DMConexao.FecharTelaAguarde;

    CDSDocumentoImportado.Filtered := False;

    LockWindowUpdate(0);
  end;
end;

procedure TFIndicadores.btnImportarDocumentosClick(Sender: TObject);
begin
  inherited;
  CDSDocumentoImportado.EmptyDataSet;
  CDSItemImportado.EmptyDataSet;

  BuscarDocumentos;
  PopularCDSDocumentoImportado;

  MensagemInformacao('Importação realizada com sucesso.');
end;

{procedure TFIndicadores.btnVisualizarClick(Sender: TObject);
var
  ST: TMemoryStream;
  Arquivo: string;
  LSArquivo: TStrings;
  Mensagem: string;
begin
  inherited;
  LSArquivo := TStringList.Create;
  try

    ST := TMemoryStream.Create;
    try
      LerRecursoDLL(cRecursoRelPedidoCompra, cNomeDLL, ST);

      if ST.Size = 0 then
        raise Exception.Create('Relatório não encontrado no recurso.');

      frxReport.LoadFromStream(ST);
    finally
      FreeAndNil(ST);
    end;

    if mQueryFornecedor.FindKey([cdsDocumentos.FieldByName('idFornecedor').AsString]) then
    begin
      LSArquivo.Clear;

      if ckEnviarEmail.Checked then
      begin
        Arquivo := ExtractFilePath(Application.ExeName) + cdsDocumentos.FieldByName('nomeFornecedor').AsString + '.pdf';

        frxpdExport.FileName := Arquivo;

        frxReport.PrepareReport;
        frxReport.Export(frxpdExport);

        LSArquivo.Add(Arquivo);

        Mensagem := 'Segue em anexo o pedido de compra.';

        try
          EnviarEmail(mQueryFornecedor.FieldByName('emailCompra').AsString, Mensagem, LSArquivo);
          AtualizarDocumentoEnviado(cdsDocumentos.FieldByName('sequencial').AsInteger);
          MensagemInformacao('Pedido de compra enviado com sucesso.');
        except
          on E: Exception do
            MensagemErro('Falha ao enviar o email para o fornecedor ' + cdsDocumentos.FieldByName('nomeFornecedor').AsString + #13 + 'Erro: ' + E.Message + #13);
        end;

        DeleteFile(Arquivo);
      end
      else
        frxReport.ShowReport;
    end
    else
      MensagemErro('Fornecedor ' + cdsDocumentos.FieldByName('nomeFornecedor').AsString + ' não encontrado.');
  finally
    FreeAndNil(LSArquivo);
  end;
end;   }

{procedure TFIndicadores.btnVoltarClick(Sender: TObject);
begin
  inherited;
  IrParaDados;
end;     }

//procedure TFIndicadores.btnPesquisarClick(Sender: TObject);
//begin
//  inherited;
//  mQuery.Close;
//
//  case cbCampoPesquisa.ItemIndex of
//    // Fornecedor
//    0:
//      begin
//        mQuery.QMatch := '{"nomeFornecedor":{"$regex": "' + edtValor.Text + '"}' + IfThen(ckApenasNaoEnviados.Checked, ',"pedidoEnviado":"N"', '') + '}';
//      end;

    // Data de emissão
//      1:
//      begin
//       mQuery.QMatch := '{"dataEmissao":{"$gte":{"$date":"' + FormatDateTime('yyyy-mm-dd', edtDataPesqInicial.Date) + 'T00:00:00.000Z"},' +
//                                        '"$lte":{"$date":"' + FormatDateTime('yyyy-mm-dd', edtDataPesqFinal.Date) + 'T23:59:00.000Z"}}}';
//      end;
//  end;

//  mQuery.Open;
//end;

procedure TFIndicadores.btnSalvarClick(Sender: TObject);
begin
  inherited;
  try
    AtualizarDocumento(cdsDocumentos.FieldByName('sequencial').AsInteger);
    MensagemInformacao('Registro salvo com sucesso.');
  except
    on E: Exception do
      MensagemErro('Falha ao salvar o registro: ' + E.Message);
  end;
end;

procedure TFIndicadores.BuscarDocumentos;
var
  retorno: TJSON;
  Json, JsonNF, JsonTmp, FiltroSituacao: string;
  JsonArrayDocumento, JsonArrayItens: TJSONArray;
  FuncoesJson: TFuncoesJSON;
  doc: TMongoDocument;
begin
  inherited;

  JsonArrayDocumento := nil;
  JsonArrayItens := nil;

  FuncoesJson := TFuncoesJSON.Create;
  doc := TMongoDocument.Create(conexao.Env);
  try
    DMConexao.AbrirTelaAguarde;
    mQueryDocumentoImportado.DisableControls;
    try
      FiltroSituacao := '';

      if (edtDataInicial.Date <= 0) or (edtDataFinal.Date <= 0) then
      begin
        MensagemAviso('Data inicial e final devem ser informadas.');
        Exit;
      end;

      if cbSituacao.ItemIndex > 0 then
        FiltroSituacao := '; idSituacao[' + Copy(cbSituacao.Items[cbSituacao.ItemIndex], 0, cbSituacao.Items[cbSituacao.ItemIndex].LastIndexOf('-')) + ']';

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
          JsonNF := FuncoesJson.GetObjectJson(Json, 'nota');

          if Pos('numero', JsonNF) > 0 then
          begin
           { if FuncoesJson.GetValueJson(JsonNF, 'dataEmissao')  then


            cds.Insert;
            FuncoesJson.JSONObjectToFields(TJSONObject.ParseJSONValue(Json), cds);

            cds.fieldbynam := FuncoesJson.GetValueJson(JsonNF, 'numero');
            cds.fieldbynam := FuncoesJson.GetValueJson(JsonNF, 'chave');
            cds.fieldbynam := FuncoesJson.GetValueJson(JsonNF, 'dataEmissao');
            cds.fieldbynam := FuncoesJson.GetValueJson(JsonNF, '...');

            cds.Post;   }
          end;
        end;
      end;
    except
      on E: Exception do
        MensagemErro('Falha ao buscar pedidos. Erro ' + E.Message);
    end;
  finally
    mQueryDocumentoImportado.EnableControls;
    JsonArrayDocumento.Free;
    JsonArrayItens.Free;
    FreeAndNil(doc);
    FreeAndNil(FuncoesJson);
    DMConexao.FecharTelaAguarde;
  end;
end;


function TFIndicadores.EnviarEmail(Email, Msg: string; Arquivos: TStrings): Boolean;
var
  EnviaEmail: ClassEnviarEmail.TEnviarEmail;
begin
  EnviaEmail := TEnviarEmail.Create(nil);
  try
    with EnviaEmail do
    begin
      ServidorEmail_Host := mQueryConfig.FieldByName('smtpEmail').AsString;
      ServidorEmail_Port := mQueryConfig.FieldByName('portaEmail').AsInteger;
      ServidorEmail_Username := mQueryConfig.FieldByName('contaEmail').AsString;
      ServidorEmail_Password := mQueryConfig.FieldByName('senhaEmail').AsString;

      Destinatario_Email := Email;
      Destinatario_EmailCC := mQueryConfig.FieldByName('emailCopia').AsString;
      Assunto := 'Pedido de Compra';
      Mensagem := Msg;

      ArquivosAnexados.Assign(Arquivos);

      AguardarEnvio := True;
      Enviar;

      Result := Enviado;
    end;
  finally
    FreeAndNil(EnviaEmail);
  end;
end;

procedure TFIndicadores.CriarRelacionamentoCDS;
begin
  CDSDocumentoImportado.IndexFieldNames := 'numero';

  CDSItemImportado.IndexFieldNames := 'numero';
  CDSItemImportado.MasterSource := DSDocumentoImportado;
  CDSItemImportado.MasterFields := 'numero';
end;

procedure TFIndicadores.RemoverRelacionamentoCDS;
begin
  CDSItemImportado.MasterFields := '';
  CDSItemImportado.MasterSource := nil;
  CDSItemImportado.IndexFieldNames := '';
end;

procedure TFIndicadores.ValidateItem(Sender: TField);
begin
  if FGerandoPedidoCompra or FRetornoConsulta then
    Exit;

  try
    mQueryProdutos.Close;
    mQueryProdutos.QMatch := '"codigo": "' + Sender.AsString + '"';
    mQueryProdutos.Open;

    if mQueryProdutos.IsEmpty then
    begin
      MensagemInformacao('Item ' + Sender.AsString + ' não encontrado.');
      Abort;
    end;

    cdsItens.FieldByName('descricao').AsString := mQueryProdutos.FieldByName('descricao').AsString;
    cdsItens.FieldByName('codigoFabricante').AsString := mQueryProdutos.FieldByName('codigoFabricante').AsString;
    cdsItens.FieldByName('descricaoFornecedor').AsString := mQueryProdutos.FieldByName('descricaoFornecedor').AsString;
    cdsItens.FieldByName('un').AsString := mQueryProdutos.FieldByName('unidade').AsString;
    cdsItens.FieldByName('precoCusto').AsCurrency := StrToCurr(mQueryProdutos.FieldByName('precoCusto').AsString.Replace('.', ','));
    cdsItens.FieldByName('pesoBruto').AsFloat := StrToFloatDef(mQueryProdutos.FieldByName('pesoBruto').AsString.Replace('.', ','), 0);
    cdsItens.FieldByName('largura').AsFloat := StrToFloatDef(mQueryProdutos.FieldByName('larguraProduto').AsString.Replace('.', ','), 0);
    cdsItens.FieldByName('altura').AsFloat := StrToFloatDef(mQueryProdutos.FieldByName('alturaProduto').AsString.Replace('.', ','), 0);
    cdsItens.FieldByName('profundidade').AsFloat := StrToFloatDef(mQueryProdutos.FieldByName('profundidadeProduto').AsString.Replace('.', ','), 0);
  finally
    mQueryProdutos.Close;
  end;
end;


function FormatarData(Data: string): TDateTime;
begin
  if trim(Data) <> '' then
    Result := StrToDateTime(copy(Data, 9, 2) + '/' + copy(Data, 6, 2) + '/' + copy(Data, 1, 4))
  else
    Result := 0;
end;

  procedure TFIndicadores.PopularCDSDocumentoImportado;
var
  DSItensTemp: TDataSet;

begin
  try
    RemoverRelacionamentoCDS;
    CDSDocumentoImportado.DisableControls;
    CDSItemImportado.DisableControls;

    mQueryDocumentoImportado.Close;
    //mQueryDocumentoImportado.QMatch := IfThen(ckApenasPedidoNaoImportados.Checked, '"pedidoImportado":"N"', '');
    mQueryDocumentoImportado.Open;
    try
      mQueryDocumentoImportado.First;

      while not mQueryDocumentoImportado.Eof do
      begin
        with CDSDocumentoImportado do
        begin
          Append;
          FieldByName('MARQUE').AsString := 'S';
          FieldByName('pedidoImportado').AsString := mQueryDocumentoImportado.FieldByName('pedidoImportado').AsString;
          FieldByName('numeroNF').AsInteger := StrToIntDef(mQueryDocumentoImportado.FieldByName('nota.numero').AsString, 0);
          FieldByName('numero').AsInteger := mQueryDocumentoImportado.FieldByName('numero').AsInteger;
          FieldByName('data').AsDateTime := FormatarData(mQueryDocumentoImportado.FieldByName('data').AsString);
          FieldByName('dataEmissaoNota').AsDateTime := FormatarData(mQueryDocumentoImportado.FieldByName('nota.dataEmissao').AsString);
          FieldByName('tipoIntegracao').AsString := mQueryDocumentoImportado.FieldByName('tipoIntegracao').AsString;
          FieldByName('totalvenda').AsCurrency := StrToCurr(mQueryDocumentoImportado.FieldByName('totalvenda').AsString.Replace('.', ','));
          FieldByName('situacao').AsString := mQueryDocumentoImportado.FieldByName('situacao').AsString;
          FieldByName('dataPrevista').AsDateTime := FormatarData(mQueryDocumentoImportado.FieldByName('dataPrevista').AsString);
          FieldByName('nomeCliente').AsString := mQueryDocumentoImportado.FieldByName('cliente.nome').AsString;
          FieldByName('cnpjCliente').AsString := mQueryDocumentoImportado.FieldByName('cliente.cnpj').AsString;
          FieldByName('cidadeCliente').AsString := mQueryDocumentoImportado.FieldByName('cliente.cidade').AsString;
          FieldByName('ufCliente').AsString := mQueryDocumentoImportado.FieldByName('cliente.uf').AsString;
          FieldByName('chaveNF').AsString := mQueryDocumentoImportado.FieldByName('nota.chaveAcesso').AsString;
          Post;
        end;

        DSItensTemp := (mQueryDocumentoImportado.FieldByName('itens') as TDataSetField).NestedDataSet;

        DSItensTemp.First;
        while not DSItensTemp.Eof do
        begin
          with CDSItemImportado do
          begin
            Append;
           // FieldByName('MARQUE').AsString        := 'S';
            FieldByName('numero').AsInteger := mQueryDocumentoImportado.FieldByName('numero').AsInteger;
            FieldByName('codigo').AsString := DSItensTemp.FieldByName('Elem.item.codigo').AsString;
//            FieldByName('codigoFabricante').AsString := DSItensTemp.FieldByName('Elem.item.codigoFabricante').AsString;
//            FieldByName('descricaoFornecedor').AsString := DSItensTemp.FieldByName('Elem.item.descricaoFornecedor').AsString;
            FieldByName('descricao').AsString := DSItensTemp.FieldByName('Elem.item.descricao').AsString;
            FieldByName('quantidade').AsFloat := StrToFloat(DSItensTemp.FieldByName('Elem.item.quantidade').AsString.Replace('.', ','));
            FieldByName('un').AsString := DSItensTemp.FieldByName('Elem.item.un').AsString;
            FieldByName('pesoBruto').AsFloat := StrToFloatDef(DSItensTemp.FieldByName('Elem.item.pesoBruto').AsString.Replace('.', ','), 0);
            FieldByName('largura').AsFloat := StrToFloatDef(DSItensTemp.FieldByName('Elem.item.largura').AsString.Replace('.', ','), 0);
            FieldByName('altura').AsFloat := StrToFloatDef(DSItensTemp.FieldByName('Elem.item.altura').AsString.Replace('.', ','), 0);
            FieldByName('profundidade').AsFloat := StrToFloatDef(DSItensTemp.FieldByName('Elem.item.profundidade').AsString.Replace('.', ','), 0);
            Post;
          end;

          DSItensTemp.Next;
        end;

        mQueryDocumentoImportado.Next;
      end;
    except
      on E: Exception do
        MensagemErro('Falha ao popular CDS de pedidos importados: ' + E.Message);
    end;
  finally
    CriarRelacionamentoCDS;
    mQueryDocumentoImportado.Close;   //Alterado dia 01/12/2019
    CDSDocumentoImportado.EnableControls;
    CDSItemImportado.EnableControls;
  end;
end;

procedure TFIndicadores.GerarPedidoCompraPorFornecedor;
var
  LSDocumentosImp: TStringList;
  I: Integer;

  function GetAutoIncremento: Integer;
  var
    Cursor: IMongoCursor;
  begin
    Cursor := conexao[cNomeBancoDados][NomeColecao].Find().Sort('{"sequencial":-1}').&End.Limit(1);

    if Cursor.Next then
      Result := StrToInt(TFuncoesJSON.GetValueJson(Cursor.Doc.AsJSON, 'sequencial')) + 1
    else
      Result := 1;
  end;

begin
  LSDocumentosImp := TStringList.Create;
  try
    FGerandoPedidoCompra := True;
    DMConexao.AbrirTelaAguarde;

    cdsDocumentos.DisableControls;
    cdsItens.DisableControls;
    mQueryFornecedor.DisableControls;

    cdsItens.IndexFieldNames := 'codigo';

    mQueryFornecedor.First;
    while not mQueryFornecedor.Eof do
    begin
      LSDocumentosImp.Clear;
      cdsDocumentos.Append;

      cdsDocumentos.FieldByName('sequencial').AsInteger := GetAutoIncremento;
      cdsDocumentos.FieldByName('idFornecedor').AsString := mQueryFornecedor.FieldByName('_id').AsString;
      cdsDocumentos.FieldByName('nomeFornecedor').AsString := mQueryFornecedor.FieldByName('razaoSocial').AsString;
      cdsDocumentos.FieldByName('dataEmissao').AsDateTime := Now;
      cdsDocumentos.FieldByName('pedidoEnviado').AsString := 'N';

      CDSDocumentoImportado.First;
      while not CDSDocumentoImportado.Eof do
      begin
        CDSItemImportado.First;
        while not CDSItemImportado.Eof do
        begin
          mQueryProdutos.Close;
          mQueryProdutos.QMatch := '"codigo": "' + CDSItemImportado.FieldByName('codigo').AsString + '"';
          mQueryProdutos.Open;

          if (mQueryProdutos.IsEmpty) or (AnsiUpperCase(mQueryProdutos.FieldByName('nomeFornecedor').AsString) <> AnsiUpperCase(cdsDocumentos.FieldByName('nomeFornecedor').AsString)) then
          begin
            CDSItemImportado.Next;
            Continue;
          end;

          if not cdsItens.FindKey([CDSItemImportado.FieldByName('codigo').AsString]) then
          begin
            cdsItens.Append;
            cdsItens.FieldByName('codigo').AsString := CDSItemImportado.FieldByName('codigo').AsString;
            cdsItens.FieldByName('descricao').AsString := CDSItemImportado.FieldByName('descricao').AsString;
            cdsItens.FieldByName('descricaoFornecedor').AsString := mQueryProdutos.FieldByName('descricaoFornecedor').AsString;
            cdsItens.FieldByName('codigoFabricante').AsString := mQueryProdutos.FieldByName('codigoFabricante').AsString;
            cdsItens.FieldByName('quantidade').AsFloat := CDSItemImportado.FieldByName('quantidade').AsFloat;
            cdsItens.FieldByName('un').AsString := CDSItemImportado.FieldByName('un').AsString;
            cdsItens.FieldByName('precoCusto').AsCurrency := StrToCurr(mQueryProdutos.FieldByName('precoCusto').AsString.Replace('.', ','));
            cdsItens.FieldByName('pesoBruto').AsFloat := CDSItemImportado.FieldByName('pesoBruto').AsFloat;
            cdsItens.FieldByName('largura').AsFloat := CDSItemImportado.FieldByName('largura').AsFloat;
            cdsItens.FieldByName('altura').AsFloat := CDSItemImportado.FieldByName('altura').AsFloat;
            cdsItens.FieldByName('profundidade').AsFloat := CDSItemImportado.FieldByName('profundidade').AsFloat;
            cdsItens.FieldByName('nomeCliente').AsString := CDSDocumentoImportado.FieldByName('nomeCliente').AsString;
            cdsItens.FieldByName('cnpjCliente').AsString := CDSDocumentoImportado.FieldByName('cnpjCliente').AsString;
            cdsItens.FieldByName('cidadeCliente').AsString := CDSDocumentoImportado.FieldByName('cidadeCliente').AsString;
            cdsItens.FieldByName('ufCliente').AsString := CDSDocumentoImportado.FieldByName('ufCliente').AsString;
          end
          else
          begin
            cdsItens.Edit;
            cdsItens.FieldByName('quantidade').AsCurrency := cdsItens.FieldByName('quantidade').AsCurrency + CDSItemImportado.FieldByName('quantidade').AsCurrency;
          end;

          cdsItens.Post;

          LSDocumentosImp.Add(CDSDocumentoImportado.FieldByName('numero').AsString);

          CDSItemImportado.Next;
        end;

        CDSDocumentoImportado.Next;
      end;

      if cdsItens.IsEmpty then
        cdsDocumentos.Cancel
      else
      begin
        cdsDocumentos.Post;
        InserirDocumento;

        for I := 0 to LSDocumentosImp.Count - 1 do
          AtualizarDocumentoImportado(LSDocumentosImp.Strings[I]);
      end;

      cdsDocumentos.EmptyDataSet;
      cdsItens.EmptyDataSet;

      mQueryFornecedor.Next;
    end;

  finally
    FGerandoPedidoCompra := False;
    DMConexao.FecharTelaAguarde;
    mQueryProdutos.Close;
    cdsDocumentos.EnableControls;
    cdsItens.EnableControls;
    FreeAndNil(LSDocumentosImp);
  end;
end;

procedure TFIndicadores.AtualizarDocumentoEnviado(Codigo: Integer);
var
  Doc: TMongoUpdate;
begin
  Doc := TMongoUpdate.Create(conexao.Env);
  try
    Doc.Match().Add('sequencial', Codigo);
    Doc.Modify().&Set().Field('pedidoEnviado', 'S');

    conexao[cNomeBancoDados][NomeColecao].Update(Doc);
  finally
    FreeAndNil(Doc);
  end;
end;

procedure TFIndicadores.AtualizarDocumentoImportado(NumeroPedido: string);
var
  Doc: TMongoUpdate;
begin
  Doc := TMongoUpdate.Create(conexao.Env);
  try
    Doc.Match().Add('numero', NumeroPedido);
    Doc.Modify().&Set().Field('pedidoImportado', 'S');

    conexao[cNomeBancoDados][cColecaoPedido].Update(Doc);
  finally
    FreeAndNil(Doc);
  end;
end;

procedure TFIndicadores.InserirDocumento;
var
  I: Integer;
  Doc: TMongoDocument;
begin
  Doc := TMongoDocument.Create(conexao.Env);
  try
    try
      for I := 0 to cdsDocumentos.FieldCount - 1 do
      begin
        if (cdsDocumentos.Fields[I].FieldName = '_id') then
          Continue;

        case cdsDocumentos.Fields[I].DataType of
          ftFloat, ftCurrency, ftBCD:
            Doc.Add(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsCurrency);

          ftDate, ftDateTime, ftTimeStamp:
            Doc.Add(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsDateTime);

          ftInteger, ftSmallint, ftShortint:
            Doc.Add(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsInteger);

        else
          Doc.Add(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsString);
        end;
      end;

      Doc.BeginArray('itens');

      cdsItens.First;
      while not cdsItens.Eof do
      begin
        Doc.BeginObject('');
        for I := 0 to cdsItens.FieldCount - 1 do
        begin
          case cdsItens.Fields[I].DataType of
            ftFloat, ftCurrency, ftBCD:
              Doc.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsCurrency);

            ftDate, ftDateTime, ftTimeStamp:
              Doc.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsDateTime);

            ftInteger, ftSmallint, ftShortint:
              Doc.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsInteger);

          else
            Doc.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsString);
          end;
        end;
        Doc.EndObject;

        cdsItens.Next;
      end;

      Doc.EndArray;

      conexao[cNomeBancoDados][NomeColecao].Insert(Doc);
    except
      on E: Exception do
        MensagemErro('Falha ao gravar pedido de compra: ' + E.Message);
    end;
  finally
    FreeAndNil(Doc);
  end;
end;

procedure TFIndicadores.AtualizarDocumento(Codigo: Integer);
var
  I: Integer;
  Doc: TMongoUpdate;
begin
  Doc := TMongoUpdate.Create(conexao.Env);
  try
    try
      Doc.Match().Add('sequencial', Codigo).&End;

      for I := 0 to cdsDocumentos.FieldCount - 1 do
      begin
        if (cdsDocumentos.Fields[I].FieldName = '_id') then
          Continue;

        case cdsDocumentos.Fields[I].DataType of
          ftFloat, ftCurrency, ftBCD:
            Doc.Modify().&Set().Field(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsCurrency);

          ftDate, ftDateTime, ftTimeStamp:
            Doc.Modify().&Set().Field(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsDateTime);

          ftInteger, ftSmallint, ftShortint:
            Doc.Modify().&Set().Field(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsInteger);

        else
          Doc.Modify().&Set().Field(cdsDocumentos.Fields[I].FieldName, cdsDocumentos.Fields[I].AsString);
        end;
      end;

      Doc.Modify().&Set().Writer.BeginArray('itens');

      cdsItens.First;
      while not cdsItens.Eof do
      begin
        Doc.Modify().&Set().Writer.BeginObject('');
        for I := 0 to cdsItens.FieldCount - 1 do
        begin
          case cdsItens.Fields[I].DataType of
            ftFloat, ftCurrency, ftBCD:
              Doc.Modify().&Set().Writer.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsCurrency);

            ftDate, ftDateTime, ftTimeStamp:
              Doc.Modify().&Set().Writer.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsDateTime);

            ftInteger, ftSmallint, ftShortint:
              Doc.Modify().&Set().Writer.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsInteger);

          else
            Doc.Modify().&Set().Writer.Add(cdsItens.Fields[I].FieldName, cdsItens.Fields[I].AsString);
          end;
        end;
        Doc.Modify().&Set().Writer.EndObject;

        cdsItens.Next;
      end;

      Doc.Modify().&Set().Writer.EndArray;

      conexao[cNomeBancoDados][NomeColecao].Update(Doc);
    except
      on E: Exception do
        MensagemErro('Falha ao atualizar pedido de compra: ' + E.Message);
    end;
  finally
    FreeAndNil(Doc);
  end;
end;

{procedure TFIndicadores.IrParaDados;
begin
  tbsDados.TabVisible := True;
  tbsImportacao.TabVisible := True;
  pgPrincipal.ActivePage := tbsDados;
  tbsConsulta.TabVisible := False;
  mQuery.Close;
end;  }

procedure TFIndicadores.mniDesmarcartodos1Click(Sender: TObject);
begin
  inherited;
  LockWindowUpdate(Self.Handle);
  try
    CDSDocumentoImportado.First;
    while not CDSDocumentoImportado.Eof do
    begin
      CDSDocumentoImportado.Edit;
      CDSDocumentoImportado.FieldByName('MARQUE').AsString := 'N';
      CDSDocumentoImportado.Post;

      CDSDocumentoImportado.Next;
    end;
  finally
    CDSDocumentoImportado.First;
    LockWindowUpdate(0);
  end;
end;

procedure TFIndicadores.mniMarcartodos1Click(Sender: TObject);
begin
  inherited;
  LockWindowUpdate(Self.Handle);
  try
    CDSDocumentoImportado.First;
    while not CDSDocumentoImportado.Eof do
    begin
      CDSDocumentoImportado.Edit;
      CDSDocumentoImportado.FieldByName('MARQUE').AsString := 'S';
      CDSDocumentoImportado.Post;

      CDSDocumentoImportado.Next;
    end;
  finally
    CDSDocumentoImportado.First;
    LockWindowUpdate(0);
  end;
end;

procedure TFIndicadores.mQueryAfterOpen(DataSet: TDataSet);
begin
  inherited;
  if mQuery.FindField('idFornecedor') <> nil then
    mQuery.FieldByName('idFornecedor').Visible := False;
end;

procedure TFIndicadores.CopiarDadosConsulta;
var
  DSItens: TDataSet;
begin
  inherited;
  try
    FRetornoConsulta := True;

    cdsDocumentos.EmptyDataSet;
    cdsItens.EmptyDataSet;

    if mQuery.IsEmpty then
    begin
      MensagemAviso('Nenhum registro selecionado');
      Exit;
    end;

    cdsDocumentos.Append;
    cdsDocumentos.FieldByName('_id').AsString := mQuery.FieldByName('_id').AsString;
    cdsDocumentos.FieldByName('sequencial').AsInteger := mQuery.FieldByName('sequencial').AsInteger;
    cdsDocumentos.FieldByName('idFornecedor').AsString := mQuery.FieldByName('idFornecedor').AsString;
    cdsDocumentos.FieldByName('nomeFornecedor').AsString := mQuery.FieldByName('nomeFornecedor').AsString;
    cdsDocumentos.FieldByName('dataEmissao').AsDateTime := mQuery.FieldByName('dataEmissao').AsDateTime;
    cdsDocumentos.FieldByName('observacao').AsString := mQuery.FieldByName('observacao').AsString;
    cdsDocumentos.FieldByName('pedidoEnviado').AsString := mQuery.FieldByName('pedidoEnviado').AsString;
    cdsDocumentos.Post;

    DSItens := (mQuery.FieldByName('itens') as TDataSetField).NestedDataSet;

    DSItens.First;
    while not DSItens.Eof do
    begin
      cdsItens.Append;
      cdsItens.FieldByName('codigo').AsString := DSItens.FieldByName('Elem.codigo').AsString;
      cdsItens.FieldByName('descricao').AsString := DSItens.FieldByName('Elem.descricao').AsString;
      cdsItens.FieldByName('codigoFabricante').AsString := DSItens.FieldByName('Elem.codigoFabricante').AsString;
      cdsItens.FieldByName('descricaoFornecedor').AsString := DSItens.FieldByName('Elem.descricaoFornecedor').AsString;
      cdsItens.FieldByName('un').AsString := DSItens.FieldByName('Elem.un').AsString;
      cdsItens.FieldByName('quantidade').AsFloat := DSItens.FieldByName('Elem.quantidade').AsFloat;
      cdsItens.FieldByName('precoCusto').AsCurrency := DSItens.FieldByName('Elem.precoCusto').AsCurrency;
      cdsItens.FieldByName('pesoBruto').AsFloat := DSItens.FieldByName('Elem.pesoBruto').AsFloat;
      cdsItens.FieldByName('largura').AsFloat := DSItens.FieldByName('Elem.largura').AsFloat;
      cdsItens.FieldByName('altura').AsFloat := DSItens.FieldByName('Elem.altura').AsFloat;
      cdsItens.FieldByName('profundidade').AsFloat := DSItens.FieldByName('Elem.profundidade').AsFloat;
      cdsItens.FieldByName('nomeCliente').AsString := DSItens.FieldByName('Elem.nomeCliente').AsString;
      cdsItens.FieldByName('cnpjCliente').AsString := DSItens.FieldByName('Elem.cnpjCliente').AsString;
      cdsItens.FieldByName('cidadeCliente').AsString := DSItens.FieldByName('Elem.cidadeCliente').AsString;
      cdsItens.FieldByName('ufCliente').AsString := DSItens.FieldByName('Elem.ufCliente').AsString;
      cdsItens.Post;

      DSItens.Next;
    end;

   // IrParaDados;
  finally
    FRetornoConsulta := False;
  end;
end;

end.

