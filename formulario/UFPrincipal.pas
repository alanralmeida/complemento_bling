unit UFPrincipal;

interface

uses Winapi.Windows, System.Classes, Vcl.Graphics, Vcl.Forms, Vcl.Controls,
  Vcl.Menus, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  Vcl.ImgList, Vcl.StdActns, Vcl.ActnList, Vcl.ToolWin, System.ImageList,
  System.Actions, System.SysUtils, JvExControls, JvButton, JvNavigationPane;

type
  TFPrincipal = class(TForm)
    BalloonHint1: TBalloonHint;
    pnlMenu: TPanel;
    btnProdutos: TSpeedButton;
    btnFornecedor: TSpeedButton;
    btnPedidoCompra: TSpeedButton;
    Panel1: TPanel;
    pnlTitulo: TPanel;
    pnl1: TPanel;
    btnConfiguracao: TSpeedButton;
    btnEmissaoEtiqueta: TSpeedButton;
    btnIndicadoresRelatorios: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConfiguracaoClick(Sender: TObject);
    procedure btnIndicadoresRelatoriosClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnFornecedorClick(Sender: TObject);
    procedure Centralizar;
    procedure CriarTela(Form: TFormClass);
    procedure btnPedidoCompraClick(Sender: TObject);
    procedure btnEmissaoEtiquetaClick(Sender: TObject);
  private
     fFormularioAtivo: TForm;
  public
    { Public declarations }
  end;

var
  FPrincipal: TFPrincipal;

implementation

uses UDMConexao, UFEmissaoEtiqueta, UFBaixarProdutos, UFFornecedor, UPai, UFConfigSistema, UFPedidoCompra;


{$R *.dfm}

procedure TFPrincipal.Centralizar;
begin
  fFormularioAtivo.Left := Round((Panel1.Width - fFormularioAtivo.Width)/2);
  fFormularioAtivo.Top := Round((Panel1.Height - fFormularioAtivo.Height)/2);
end;

procedure TFPrincipal.CriarTela(Form: TFormClass);
begin
  FreeAndNil(fFormularioAtivo);
  fFormularioAtivo := Form.Create(Self);
  pnlTitulo.Caption := fFormularioAtivo.Caption;
  fFormularioAtivo.Parent := Panel1;
  fFormularioAtivo.BorderStyle := bsNone;
  fFormularioAtivo.Show;
  fFormularioAtivo.Width := Panel1.Width - 20;
  fFormularioAtivo.Height := Panel1.Height - 150;
  Centralizar;
end;

procedure TFPrincipal.btnConfiguracaoClick(Sender: TObject);
begin
  CriarTela(TFConfigSistema);
end;

procedure TFPrincipal.btnEmissaoEtiquetaClick(Sender: TObject);
begin
  CriarTela(TFEmissaoEtiquetas);
end;

procedure TFPrincipal.btnFornecedorClick(Sender: TObject);
begin
  CriarTela(TFFornecedores);
end;

procedure TFPrincipal.btnPedidoCompraClick(Sender: TObject);
begin
  CriarTela(TFPedidoCompra);
end;

procedure TFPrincipal.btnProdutosClick(Sender: TObject);
begin
  CriarTela(TFBaixarProdutos);
end;

procedure TFPrincipal.FormCreate(Sender: TObject);
begin
  DMConexao := TDMConexao.Create(Self);
end;

procedure TFPrincipal.FormDestroy(Sender: TObject);
begin
  DMConexao.FDConexao.Close;
  FreeAndNil(DMConexao);
end;

procedure TFPrincipal.btnIndicadoresRelatoriosClick(Sender: TObject);
begin
  //CriarTela(TFEmissaoEtiquetas);
end;

end.
