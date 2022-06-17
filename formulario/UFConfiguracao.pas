unit UFConfiguracao;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.DBCtrls, System.IniFiles,
  Vcl.Buttons, Data.DB, Vcl.Grids, Vcl.DBGrids, mongo.VCL.MongoEdit, JvExMask, JvToolEdit, JvBaseEdits, JvDBControls, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet,
  frxClass, frxExportPDF, UPai;

type
  TFConfiguracoesGerais = class(TFPai)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    edtServidor: TEdit;
    Label7: TLabel;
    Label8: TLabel;
    btnSalvar: TSpeedButton;
    SpeedButton1: TSpeedButton;
    lbl1: TLabel;
    dbedt1: TDBEdit;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    JvDBCalcEdit1: TJvDBCalcEdit;
    DBEdit4: TDBEdit;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnTestarConexaoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure CriarINI;
    procedure LerINI;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FConfiguracoesGerais: TFConfiguracoesGerais;

implementation

{$R *.dfm}

uses UConstantes, UDMConexao, FireDAC.Phys.MongoDBWrapper, UClassFuncoes;

procedure TFConfiguracoesGerais.FormCreate(Sender: TObject);
begin
  NomeColecao := cColecaoConfiguracao;

  inherited;

  with mQuery.FieldDefs do
  begin
    Clear;
    Add('smtpEmail', ftString, 200);
    Add('descricaoConta', ftString, 50);
    Add('contaEmail', ftString, 200);
    Add('senhaEmail', ftString, 30);
    Add('portaEmail', ftInteger);
    Add('emailCopia', ftString, 300);
    Add('token', ftString, 200);
    Add('webservice', ftString, 200);
    mQuery.CreateDataSet;
  end;

  mQuery.Open;
end;

procedure TFConfiguracoesGerais.FormDestroy(Sender: TObject);
begin
  inherited;
  FConfiguracoesGerais := nil;
end;

procedure TFConfiguracoesGerais.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  CriarINI;
  inherited;
end;

procedure TFConfiguracoesGerais.FormShow(Sender: TObject);
begin
  inherited;
  LerINI;
end;

// Cria arquivo de configuração
procedure TFConfiguracoesGerais.btnSalvarClick(Sender: TObject);
begin
  inherited;
  if mQuery.State in [dsInsert, dsEdit] then
    mQuery.Post;

  MensagemInformacao('Configurações salvas com sucesso');
end;

procedure TFConfiguracoesGerais.btnTestarConexaoClick(Sender: TObject);
begin
  DMConexao.TestarConexao(edtServidor.Text);
end;

procedure TFConfiguracoesGerais.CriarINI;
var
    INI: TIniFile;
begin
    INI := TIniFile.Create(ExtractFilePath(Application.ExeName) + cNomeArquivoConfigINI);
    try
        try
            INI.WriteString('Servidor', 'Servidor', edtServidor.Text);
        except
        on E: Exception do
            MensagemErro('Erro ao gravar arquivo: ' + E.Message);
        end;
    finally
        INI.Free;
    end;
end;

// Lê arquivo de configuração
procedure TFConfiguracoesGerais.LerINI;
var
    INI: TIniFile;
begin
    INI := TIniFile.Create(ExtractFilePath(Application.ExeName) + cNomeArquivoConfigINI);
    try
        try
            edtServidor.Text := INI.ReadString('Servidor', 'Servidor', '');
        except
        on E: Exception do
            MensagemErro('Erro ao ler configuração: ' + E.Message);
        end;
    finally
        INI.Free;
    end;
end;

end.
