unit UPai;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.DBCtrls,
  Vcl.ExtCtrls, FireDAC.Phys.MongoDBWrapper, //mongo.Types,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet, frxClass, frxExportPDF, UConstantes, UDMConexao, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB;

type
  TFPai = class(TForm)
    BalloonHint1: TBalloonHint;
    mQuery: TFDMongoQuery;
    DS: TDataSource;
    frxpdExport: TfrxPDFExport;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure mQueryAfterOpen(DataSet: TDataSet);
  private
    FNomeColecao: String;

    { Private declarations }
  public
    conexao: TMongoConnection;
  protected
    property NomeColecao: String read FNomeColecao write FNomeColecao;

  end;

var
  FPai: TFPai;

const
  fCampoCache = '_id';

implementation

{$R *.dfm}

procedure TFPai.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
begin
  for I := 0 to Self.ComponentCount -1 do
  begin
    if Self.Components[I] is TFDMongoQuery then
      TFDMongoQuery(Self.Components[I]).Close;
  end;

  Action := caFree;
end;

procedure TFPai.FormCreate(Sender: TObject);
begin
  mQuery.Close;
  mQuery.DatabaseName := cNomeBancoDados;
  mQuery.CollectionName := NomeColecao;

  conexao := TMongoConnection(DMConexao.FDConexao.CliObj);
end;

procedure TFPai.FormShow(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to Self.ComponentCount -1 do
  begin
    if Self.Components[I] is TDBEdit then
      TDBEdit(Self.Components[I]).CustomHint := BalloonHint1;
  end;
end;

procedure TFPai.mQueryAfterOpen(DataSet: TDataSet);
begin
  if mQuery.FindField('_id') <> nil then
    mQuery.FieldByName('_id').Visible := False;
end;

end.
