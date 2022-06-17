unit UFBaixarProdutos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UPai, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, Data.DB, Vcl.Buttons, Vcl.Grids, Vcl.DBGrids, frxClass, frxExportPDF, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet,
  UDMConexao, UConstantes, FireDAC.Phys.MongoDBWrapper, Vcl.ExtCtrls;

type
  TFBaixarProdutos = class(TFPai)
    dbgrd1: TDBGrid;
    mQueryConfig: TFDMongoQuery;
    mQueryFornecedor: TFDMongoQuery;
    pnl1: TPanel;
    btnAtualizarProdutos: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnAtualizarProdutosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    procedure AtualizarFornecedores;
  public
    { Public declarations }
  end;

var
  FBaixarProdutos: TFBaixarProdutos;

implementation

uses
  UClassFuncoesBling, UClassFuncoes, System.JSON, ClassFuncoesJSON;

{$R *.dfm}

procedure TFBaixarProdutos.AtualizarFornecedores;
begin
  mQueryFornecedor.Close;
  mQueryFornecedor.Open;
  mQueryFornecedor.IndexFieldNames := 'razaoSocial';

  mQuery.First;
  while not mQuery.Eof do
  begin
    if trim(mQuery.FieldByName('nomeFornecedor').AsString) <> '' then
    begin
      if not mQueryFornecedor.FindKey([mQuery.FieldByName('nomeFornecedor').AsString]) then
        mQueryFornecedor.AppendRecord([mQuery.FieldByName('nomeFornecedor').AsString, '', '']);
    end;

    mQuery.Next;
  end;
end;

procedure TFBaixarProdutos.btnAtualizarProdutosClick(Sender: TObject);
var
  retorno: TJSON;
  doc: TMongoDocument;
  json: String;
  JsonArray: TJSONArray;
begin
  inherited;
  DMConexao.AbrirTelaAguarde;
  doc := TMongoDocument.Create(conexao.Env);
  try
    retorno := GetJsonRecurso(mQueryConfig.FieldByName('webservice').AsString + cPathProduto,
                              mQueryConfig.FieldByName('token').AsString,
                              'produtos');

    if retorno.erros <> '' then
    begin
      MensagemErro(retorno.erros);
      Exit;
    end;

    conexao[cNomeBancoDados][NomeColecao].RemoveAll;

    for json in retorno.json do
    begin
      JsonArray := TJSONArray(TJSONObject.ParseJSONValue(Json));

      while JsonArray.Count > 0 do
      begin
        doc.AsJSON := TFuncoesJSON.GetObjectJson(JsonArray.Remove(0).ToJSON, 'produto');
        conexao[cNomeBancoDados][NomeColecao].Insert(doc);
      end;
    end;

    mQuery.Close;
    mQuery.Open;

    AtualizarFornecedores;

    mQuery.First;
  finally
    FreeAndNil(doc);
    FreeAndNil(JsonArray);
    DMConexao.FecharTelaAguarde;
  end;
end;

procedure TFBaixarProdutos.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  FBaixarProdutos := nil;
end;

procedure TFBaixarProdutos.FormCreate(Sender: TObject);
begin
  NomeColecao := cColecaoProduto;
  inherited;

  mQueryConfig.Close;
  mQueryConfig.DatabaseName := cNomeBancoDados;
  mQueryConfig.CollectionName := cColecaoConfiguracao;
  mQueryConfig.Open;

  with mQueryFornecedor do
  begin
    Close;
    DatabaseName := cNomeBancoDados;
    CollectionName := cColecaoFornecedor;

    FieldDefs.Clear;
    FieldDefs.Add('razaoSocial', ftString, 150);
    FieldDefs.Add('cnpjCpf', ftString, 20);
    FieldDefs.Add('email', ftString, 100);
    CreateDataSet;
  end;
end;

procedure TFBaixarProdutos.FormShow(Sender: TObject);
begin
  inherited;
  mQuery.Open;
end;

end.
