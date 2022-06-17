unit UDMConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Phys.MongoDBDef, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client, FireDAC.Phys.MongoDB,
  System.Rtti, System.JSON.Types, System.JSON.Readers, System.JSON.BSON,
  System.JSON.Builders, FireDAC.Phys.MongoDBWrapper, System.IniFiles,
  Vcl.Forms, FireDAC.Comp.UI, frxClass, frxExportPDF, UFAguarde;

type
  TDMConexao = class(TDataModule)
    FDPhysMongoDriverLink1: TFDPhysMongoDriverLink;
    FDConexao: TFDConnection;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure DataModuleDestroy(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);

  private
     fAguarde: TFAguarde;
  public
    procedure TestarConexao(Servidor: String);
    function Conectar: Boolean;
    procedure AbrirTelaAguarde;
    procedure FecharTelaAguarde;
  protected

  end;

var
  DMConexao: TDMConexao;

implementation

uses UClassFuncoes, UConstantes;

{$R *.dfm}

{ TDMConexao }

function TDMConexao.Conectar: Boolean;
var
  INI: TIniFile;
  Servidor: string;
begin
  Result := False;
  INI := nil;
  try
    try
      INI := TIniFile.Create(ExtractFilePath(Application.ExeName) + cNomeArquivoConfigINI);
      Servidor := INI.ReadString('Servidor', 'Servidor', '');

      FDConexao.Close;
      FDConexao.Params.Values['Server'] := Servidor;
      FDConexao.Params.Values['Database'] := cNomeBancoDados;

      FDConexao.Connected := True;
      Result := True;
    except
    on E: Exception do
      MensagemErro('Erro ao ler configuraçăo: ' + E.Message);
    end;
  finally
    INI.Free;
  end;
end;

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
  fAguarde := nil;
end;

procedure TDMConexao.DataModuleDestroy(Sender: TObject);
begin
  FDConexao.Close;
  FDConexao.Connected := False;
end;

procedure TDMConexao.AbrirTelaAguarde;
begin
   if not Assigned(fAguarde) then
      fAguarde := TFAguarde.Create(nil);

   fAguarde.Show;
   Application.ProcessMessages;
end;

procedure TDMConexao.FecharTelaAguarde;
begin
  if Assigned(fAguarde) then
    FreeAndNil(fAguarde);
end;

procedure TDMConexao.TestarConexao(Servidor: String);
begin
  try
    FDConexao.Close;
    FDConexao.Params.Values['Server'] := Servidor;
    Conectar;
    MensagemInformacao('Teste realizado com sucesso');
  except
    on E: Exception do
      MensagemErro('Falha ao testar conexão: ' + E.Message);
  end;
end;

end.
