program Sdiapp;

uses
  Forms,
  UDMConexao in 'DM\UDMConexao.pas' {DMConexao: TDataModule},
  UFEmissaoEtiqueta in 'formulario\UFEmissaoEtiqueta.pas',
  UFPrincipal in 'formulario\UFPrincipal.pas' {FPrincipal},
  UPai in 'formulario\UPai.pas' {FPai},
  ClassFuncoesJSON in 'classes\ClassFuncoesJSON.pas',
  ClassFuncoesNumero in 'classes\ClassFuncoesNumero.pas',
  ClassFuncoesString in 'classes\ClassFuncoesString.pas',
  UClassFuncoes in 'classes\UClassFuncoes.pas',
  UClassFuncoesRede in 'classes\UClassFuncoesRede.pas',
  UConstantes in 'classes\UConstantes.pas',
  UClassFuncoesBling in 'classes\UClassFuncoesBling.pas',
  UFBaixarProdutos in 'formulario\UFBaixarProdutos.pas' {FBaixarProdutos},
  UFAguarde in 'formulario\UFAguarde.pas' {FAguarde},
  UFFornecedor in 'formulario\UFFornecedor.pas' {FFornecedores},
  ClassEnviarEmail in 'classes\ClassEnviarEmail.pas',
  UFConfigSistema in 'formulario\UFConfigSistema.pas' {FConfigSistema},
  UFPedidoCompra in 'formulario\UFPedidoCompra.pas' {FPedidoCompra},
  UDataSetHelper in 'classes\UDataSetHelper.pas',
  UGridHelper in 'classes\UGridHelper.pas';

{$R *.RES}
var
 I: integer = 0;

begin
  Application.Initialize;
  repeat
    Application.Title := 'Movelan';
  Application.CreateForm(TDMConexao, DMConexao);
  if (Assigned(DMConexao)) then
      if DMConexao.Conectar then
      begin
        Application.CreateForm(TFPrincipal, FPrincipal);
        Application.Run;
        Break;
      end
      else
      begin
        Application.CreateForm(TFConfigSistema, FConfigSistema);
        FConfigSistema.ShowModal;
        FConfigSistema.Free;
        Inc(I);
      end;
  until(I = 2);
    Application.Terminate;
end.
 
