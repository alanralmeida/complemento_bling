unit UFFornecedor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UPai, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, frxClass, frxExportPDF, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet, Vcl.StdCtrls, //mongo.VCL.MongoEdit,
  Vcl.Grids, Vcl.DBGrids, Vcl.Buttons, Vcl.Mask, Vcl.DBCtrls, Vcl.ExtCtrls;

type
  TFFornecedores = class(TFPai)
    dbgrd1: TDBGrid;
    pnl1: TPanel;
    btnIncluir: TSpeedButton;
    btnSalvar: TSpeedButton;
    btnExcluir: TSpeedButton;
    dbedtrazaoSocial2: TDBEdit;
    lbl3: TLabel;
    dbedtrazaoSocial1: TDBEdit;
    lbl2: TLabel;
    dbedtrazaoSocial: TDBEdit;
    lbl1: TLabel;
    Label1: TLabel;
    DBEdit1: TDBEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnIncluirClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FFornecedores: TFFornecedores;

implementation

uses
  UConstantes;

{$R *.dfm}

procedure TFFornecedores.btnExcluirClick(Sender: TObject);
begin
  inherited;
  mQuery.Delete;
end;

procedure TFFornecedores.btnIncluirClick(Sender: TObject);
begin
  inherited;
  mQuery.Append;
end;

procedure TFFornecedores.btnSalvarClick(Sender: TObject);
begin
  inherited;
  mQuery.Post;
end;

procedure TFFornecedores.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  inherited;
  FFornecedores := nil;
end;

procedure TFFornecedores.FormCreate(Sender: TObject);
begin
  NomeColecao := cColecaoFornecedor;
  inherited;

  with mQuery do
  begin
    FieldDefs.Clear;
    FieldDefs.Add('razaoSocial', ftString, 150);
    FieldDefs.Add('cnpjCpf', ftString, 20);
    FieldDefs.Add('email', ftString, 100);
    FieldDefs.Add('emailCompra', ftString, 100);
    CreateDataSet;

    Open;
  end;
end;

end.
