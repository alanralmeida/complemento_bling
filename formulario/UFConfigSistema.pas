unit UFConfigSistema;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, UPai, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, frxClass, frxExportPDF, Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MongoDBDataSet, JvExMask, JvToolEdit, JvBaseEdits,
  JvDBControls, Vcl.Mask, Vcl.DBCtrls, Vcl.StdCtrls, Vcl.Buttons,
  System.IniFiles;

type
  TFConfigSistema = class(TFPai)
    GroupBox1: TGroupBox;
    Label6: TLabel;
    SpeedButton1: TSpeedButton;
    edtServidor: TEdit;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    lbl1: TLabel;
    dbedt1: TDBEdit;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    DBEdit3: TDBEdit;
    JvDBCalcEdit1: TJvDBCalcEdit;
    dbedtemailCopia: TDBEdit;
    GroupBox3: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    DBEdit5: TDBEdit;
    DBEdit6: TDBEdit;
    btnSalvar: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSalvarClick(Sender: TObject);
    procedure DSDataChange(Sender: TObject; Field: TField);
  private
    procedure CriarINI;
    procedure LerINI;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FConfigSistema: TFConfigSistema;

implementation

{$R *.dfm}

uses UConstantes, UClassFuncoes, UDMConexao;

procedure TFConfigSistema.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  CriarINI;
  inherited;
end;

procedure TFConfigSistema.FormCreate(Sender: TObject);
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

procedure TFConfigSistema.FormDestroy(Sender: TObject);
begin
  inherited;
  FConfigSistema := nil;
end;

procedure TFConfigSistema.FormShow(Sender: TObject);
begin
  inherited;
  LerINI;
end;

procedure TFConfigSistema.btnSalvarClick(Sender: TObject);
begin
  inherited;
  if mQuery.State in [dsInsert, dsEdit] then
    mQuery.Post;

  MensagemInformacao('Configuração salva com sucesso');
end;

procedure TFConfigSistema.CriarINI;
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

procedure TFConfigSistema.DSDataChange(Sender: TObject; Field: TField);
begin
  inherited;

end;

// Lê arquivo de configuração
procedure TFConfigSistema.LerINI;
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
procedure TFConfigSistema.SpeedButton1Click(Sender: TObject);
begin
  inherited;
  DMConexao.TestarConexao(edtServidor.Text);
end;

end.
