unit ClassFuncoesString;

interface

uses
{$IFDEF VER185}
  SysUtils, Classes, StrUtils
{$ELSE}
  System.SysUtils, System.Classes, System.StrUtils
{$ENDIF};

type
  TFuncDI   = (fdiNenhuma, fdiStrZero);
  TStrArray = Array of string;

  TFuncoesString = class
  public
    // Manipula
    class function Trocar(var sTexto: string; const sAtual, sNovo: string; const Flags: TReplaceFlags = [RfReplaceAll]): string;
    class function TrocarChar(var sTexto: string; const sChr_Inv, sChr_Val: string; const Flags: TReplaceFlags = [RfReplaceAll]): string;
    class function TrocarVetor(var sTexto: string; const sVet_Inv, Vet_Val: array of string; const Flags: TReplaceFlags = [RfReplaceAll]): string;
    class function DeletarChar(var sTexto: string; const sChr: string): string;
    class function Inverter(const sTexto: string; const sA, sB: Char): string;
    class function SoNumero(const sTexto: string): string;
    class function SoLetra(const sTexto: string): string;
    class function SoLetraNumero(const sTexto: string): string;
    class function SoLetraNumeroEspaco(const sTexto: string): string;
    class function RetirarAcentos(sTexto: string): string;

    class procedure Concatenar(var sTexto: string; const S: string; const sQuebra: Char = #13); overload;
    class procedure Concatenar(var sTexto: string; const S, sDelimitador: string); overload;

    class function CorteAte(const sTexto, sSubString: string; const bSensitive: Boolean = False; TrasPraFrente: Boolean = False): string;
    class function CorteApos(const sTexto, sSubString: string; const bSensitive: Boolean = False; TrasPraFrente: Boolean = False): string;
    class function CorteEntre(const sTexto, sSubString_1, sSubString_2: string; const bSensitive: Boolean = False): string;
    class function CorteFora(const sTexto, sSubString_1, sSubString_2: string; const bSensitive: Boolean = False): string;
    class function CopyDelete(var sTexto: string; const iPos, iTamanho: Integer): string;
    class function CopyFimString(const sTexto: string; const iTamanho: Integer): string;

    class function Deletar(const sTexto: string; const sEliminiar: string): string;
    class function DeletarInsere(var sTexto: string; sValor: string; const iInicio, iTamanho: Integer; Funcao: TFuncDI = fdiNenhuma): string;
    class function RemoverEspacoDuplo(const sTexto: string): string;

    class function Completar(const sTexto: string; const iTamanho: Integer; sCaracter: string = ' '; const iAlinhamento: Integer = 0): string;
    class function Espacos(const iTamanho: Integer): string;
    class function PadR(const sTexto: string; const iTamanho: Integer; const sDelimitador: Char = ' '): string;
    class function PadL(const sTexto: string; const iTamanho: Integer; const sDelimitador: Char = ' '): string;
    class function PadC(const sTexto: string; const iTamanho: Integer; const sDelimitador: Char = ' '): string;
    class procedure JustificarTexto(var sTexto: TStrings; const iTamanho: Integer);
    class function PrimeiraLetraMaiscula(const sTexto: string; const bSeparadores: Boolean = False): string;
    class function AcertarFilter(Filtro: string): string;

{$IFNDEF VER230}
{$IF NOT DEFINED(MOBILE)}
    class function ChrValidos(const sTexto: WideString): WideString; deprecated 'Usar a função um pouco mais especifica, válido para que? xml, html, nome arquivo etc.. talvez usar a função AnsiParaAscii';
    class function TrocaCaracterXML(const sTexto: WideString): WideString; deprecated 'Usar a função AnsiParaAscii';
    class function TextoHtmlParaSimples(const sTexto: string): string; deprecated 'Usar a função HtmlParaAscII';

    class function AnsiParaAscii(const sTexto: string): string;
    class function AscIIParaHtml(const sTexto: string): string;
    class function HtmlParaAscII(const sTexto: string; const IsUTF8: Boolean = True): string;

    class function ConteudoTagXML(const sXML, sTag: string; const bIgnoreCase: Boolean = True): string;
    class function LerProximaTagXML(const pTexto: string): string;
    class function RetirarBlocoXML(var pTexto: string; const pTag: string): string;
{$IFEND} // FAVOR DEIXAR ESSA PORRA COMO IFEND, POR CONTA DA PESTE DA PRE VERSAO DO COMERCIO - EM XE2
{$ENDIF}
    // Verifica
    class function Contido(const sSubString, sTexto: string): Boolean;
    class function ContidoIn(Lista: TStrings; CampoSql: string; AQuote: Boolean): string; overload;
    class function ContidoIn(Lista: string; CampoSql: string; AQuote: Boolean): string; overload;

    class function PosDireita(const sBusca, sTexto: string): Integer;

    class function ApenasNumero(const sTexto: string): Boolean;
    class function ApenasCaracter(const S, SS: string): Boolean;

    // Diversas
    class function ContarCaracter(const sTexto: string; const sCaracter: Char): Integer;
    class function ContarSubstring(const sTexto, sSubString: string): Integer;

    class function RetornarSimNao(const sTexto: string): string; overload;
    class function RetornarSimNao(const iTexto: Integer): string; overload;

    class function ContemComadosRepeticao(const sTexto: string): Boolean;

    class function ConcatenarEndereco(const prRua, prNumero, prComplemento: string): string;

    class procedure DividirParaStringList(var SL: TStringList; const sTexto: string; const sSeparator: Char); overload;
    class procedure DividirParaStringList(var SL: TStringList; const sTexto: string; const sSeparator: string); overload;
    class procedure DividirParaArray(var SA: TStrArray; const sTexto: string; const sSeparator: Char);
  end;

  TFuncoesString_DigVerificador = class
  public
    class function Modulo10(const sValor: string): string;
    class function Modulo11(const sValor: string; const iBase: Integer = 9; const bResto: Boolean = False; const sLetra10: string = '0'): string;
    class function DigitoEan(const sValor: string): string;
    class function DigitoMod11ECT(const sValor: string): string;

    class procedure DecompoemEan(const sValor: string; var sBarra, sDigito, sCompleto: string);
  end;

  TFuncoesString_GS1 = class
  public
    type
    TRegTipo = (rtTexto, rtNumero, rtData, rtEAN13);
    TRegUnidades = (ruNenhuma, ruKg, ruMetros, ruMetros2, ruMetros3, ruLitros,
      ruLibras, ruPolegadas, ruPolegadas2, ruPolegadas3, ruPes, ruPes2, ruPes3,
      ruJardas, ruJardas2, ruJardas3, ruOncas, ruQuartos, ruGaloes);
    TRegistro = record
      AI: String;
      Tipo: TRegTipo;
      Valor: String;
      Decimais: Integer;
      Unidades: TRegUnidades;
      Auxiliar: string;
      Tag: string;
      Descricao: String;
      function UnidToStr: String;
    end;

    class function LerRegistro(var sValor: string): TRegistro;
    class function Decompor(const sValor: string; const bCompleto: Boolean = False): string;
  end;

  TCharsType = packed record
    TxtChar: Char;
    AsciiChar: PChar;
    HtmlChar: PChar;
  end;

{$REGION 'Const'}
const
  VetorTxtHtml: array [0 .. 102] of TCharsType = (
    (TxtChar: '&'; AsciiChar: ' '; HtmlChar: '&amp;'), (TxtChar: '"'; AsciiChar: ' '; HtmlChar: '&quot;'), (TxtChar: ''''; AsciiChar: ''''; HtmlChar: '&apos;'),
    (TxtChar: '&'; AsciiChar: ' '; HtmlChar: '&amp;'), (TxtChar: '<'; AsciiChar: ' '; HtmlChar: '&lt;'), (TxtChar: '>'; AsciiChar: ' '; HtmlChar: '&gt;'),
    (TxtChar: ' '; AsciiChar: ' '; HtmlChar: '&nbsp;'), (TxtChar: '¡'; AsciiChar: ' '; HtmlChar: '&iexcl;'), (TxtChar: '¢'; AsciiChar: ' '; HtmlChar: '&cent;'),
    (TxtChar: '£'; AsciiChar: ' '; HtmlChar: '&pound;'), (TxtChar: '¤'; AsciiChar: ' '; HtmlChar: '&curren;'), (TxtChar: '¥'; AsciiChar: ' '; HtmlChar: '&yen;'),
    (TxtChar: '¦'; AsciiChar: ' '; HtmlChar: '&brvbar;'), (TxtChar: '§'; AsciiChar: ' '; HtmlChar: '&sect;'), (TxtChar: '¨'; AsciiChar: ' '; HtmlChar: '&uml;'),
    (TxtChar: '©'; AsciiChar: ' '; HtmlChar: '&copy;'), (TxtChar: 'ª'; AsciiChar: ' '; HtmlChar: '&ordf;'), (TxtChar: '«'; AsciiChar: ' '; HtmlChar: '&laquo;'),
    (TxtChar: '¬'; AsciiChar: ' '; HtmlChar: '&not;'), (TxtChar: ' '; AsciiChar: ' '; HtmlChar: '&shy;'), (TxtChar: '®'; AsciiChar: ' '; HtmlChar: '&reg;'),
    (TxtChar: '¯'; AsciiChar: ' '; HtmlChar: '&macr;'), (TxtChar: '°'; AsciiChar: ' '; HtmlChar: '&deg;'), (TxtChar: '±'; AsciiChar: ' '; HtmlChar: '&plusmn;'),
    (TxtChar: '²'; AsciiChar: ' '; HtmlChar: '&sup2;'), (TxtChar: '³'; AsciiChar: ' '; HtmlChar: '&sup3;'), (TxtChar: '´'; AsciiChar: ' '; HtmlChar: '&acute;'),
    (TxtChar: 'µ'; AsciiChar: ' '; HtmlChar: '&micro;'), (TxtChar: '¶'; AsciiChar: ' '; HtmlChar: '&para;'), (TxtChar: '•'; AsciiChar: ' '; HtmlChar: '&middot;'),
    (TxtChar: '¸'; AsciiChar: ' '; HtmlChar: '&cedil;'), (TxtChar: '¹'; AsciiChar: ' '; HtmlChar: '&sup1;'), (TxtChar: 'º'; AsciiChar: ' '; HtmlChar: '&ordm;'),
    (TxtChar: '»'; AsciiChar: ' '; HtmlChar: '&raquo;'), (TxtChar: '¼'; AsciiChar: ' '; HtmlChar: '&frac14;'), (TxtChar: '½'; AsciiChar: ' '; HtmlChar: '&frac12;'),
    (TxtChar: '¾'; AsciiChar: ' '; HtmlChar: '&frac34;'), (TxtChar: '¿'; AsciiChar: ' '; HtmlChar: '&iquest;'), (TxtChar: '×'; AsciiChar: ' '; HtmlChar: '&times;'),
    (TxtChar: '÷'; AsciiChar: ' '; HtmlChar: '&divide;'), (TxtChar: 'À'; AsciiChar: 'A'; HtmlChar: '&Agrave;'), (TxtChar: 'Á'; AsciiChar: 'A'; HtmlChar: '&Aacute;'),
    (TxtChar: 'Â'; AsciiChar: 'A'; HtmlChar: '&Acirc;'), (TxtChar: 'Ã'; AsciiChar: 'A'; HtmlChar: '&Atilde;'), (TxtChar: 'Ä'; AsciiChar: 'A'; HtmlChar: '&Auml;'),
    (TxtChar: 'Å'; AsciiChar: 'A'; HtmlChar: '&Aring;'), (TxtChar: 'Æ'; AsciiChar: 'E'; HtmlChar: '&AElig;'), (TxtChar: 'Ç'; AsciiChar: 'C'; HtmlChar: '&Ccedil;'),
    (TxtChar: 'È'; AsciiChar: 'E'; HtmlChar: '&Egrave;'), (TxtChar: 'É'; AsciiChar: 'E'; HtmlChar: '&Eacute;'), (TxtChar: 'Ê'; AsciiChar: 'E'; HtmlChar: '&Ecirc;'),
    (TxtChar: 'Ë'; AsciiChar: 'E'; HtmlChar: '&Euml;'), (TxtChar: 'Ì'; AsciiChar: 'I'; HtmlChar: '&Igrave;'), (TxtChar: 'Í'; AsciiChar: 'I'; HtmlChar: '&Iacute;'),
    (TxtChar: 'Î'; AsciiChar: 'I'; HtmlChar: '&Icirc;'), (TxtChar: 'Ï'; AsciiChar: 'I'; HtmlChar: '&Iuml;'), (TxtChar: 'Ð'; AsciiChar: 'D'; HtmlChar: '&ETH;'),
    (TxtChar: 'Ñ'; AsciiChar: 'N'; HtmlChar: '&Ntilde;'), (TxtChar: 'Ò'; AsciiChar: 'O'; HtmlChar: '&Ograve;'), (TxtChar: 'Ó'; AsciiChar: 'O'; HtmlChar: '&Oacute;'),
    (TxtChar: 'Ô'; AsciiChar: 'O'; HtmlChar: '&Ocirc;'), (TxtChar: 'Õ'; AsciiChar: 'O'; HtmlChar: '&Otilde;'), (TxtChar: 'Ö'; AsciiChar: 'O'; HtmlChar: '&Ouml;'),
    (TxtChar: 'Ø'; AsciiChar: ' '; HtmlChar: '&Oslash;'), (TxtChar: 'Ù'; AsciiChar: 'U'; HtmlChar: '&Ugrave;'), (TxtChar: 'Ú'; AsciiChar: 'U'; HtmlChar: '&Uacute;'),
    (TxtChar: 'Û'; AsciiChar: 'U'; HtmlChar: '&Ucirc;'), (TxtChar: 'Ü'; AsciiChar: 'U'; HtmlChar: '&Uuml;'), (TxtChar: 'Ý'; AsciiChar: 'Y'; HtmlChar: '&Yacute;'),
    (TxtChar: 'Þ'; AsciiChar: 'P'; HtmlChar: '&THORN;'), (TxtChar: 'ß'; AsciiChar: ' '; HtmlChar: '&szlig;'), (TxtChar: 'à'; AsciiChar: 'a'; HtmlChar: '&agrave;'),
    (TxtChar: 'á'; AsciiChar: 'a'; HtmlChar: '&aacute;'), (TxtChar: 'â'; AsciiChar: 'a'; HtmlChar: '&acirc;'), (TxtChar: 'ã'; AsciiChar: 'a'; HtmlChar: '&atilde;'),
    (TxtChar: 'ä'; AsciiChar: 'a'; HtmlChar: '&auml;'), (TxtChar: 'å'; AsciiChar: 'a'; HtmlChar: '&aring;'), (TxtChar: 'æ'; AsciiChar: 'e'; HtmlChar: '&aelig;'),
    (TxtChar: 'ç'; AsciiChar: 'c'; HtmlChar: '&ccedil;'), (TxtChar: 'è'; AsciiChar: 'e'; HtmlChar: '&egrave;'), (TxtChar: 'é'; AsciiChar: 'e'; HtmlChar: '&eacute;'),
    (TxtChar: 'ê'; AsciiChar: 'e'; HtmlChar: '&ecirc;'), (TxtChar: 'ë'; AsciiChar: 'e'; HtmlChar: '&euml;'), (TxtChar: 'ì'; AsciiChar: 'i'; HtmlChar: '&igrave;'),
    (TxtChar: 'í'; AsciiChar: 'i'; HtmlChar: '&iacute;'), (TxtChar: 'î'; AsciiChar: 'i'; HtmlChar: '&icirc;'), (TxtChar: 'ï'; AsciiChar: 'i'; HtmlChar: '&iuml;'),
    (TxtChar: 'ð'; AsciiChar: ' '; HtmlChar: '&eth;'), (TxtChar: 'ñ'; AsciiChar: 'n'; HtmlChar: '&ntilde;'), (TxtChar: 'ò'; AsciiChar: 'o'; HtmlChar: '&ograve;'),
    (TxtChar: 'ó'; AsciiChar: 'o'; HtmlChar: '&oacute;'), (TxtChar: 'ô'; AsciiChar: 'i'; HtmlChar: '&ocirc;'), (TxtChar: 'õ'; AsciiChar: 'o'; HtmlChar: '&otilde;'),
    (TxtChar: 'ö'; AsciiChar: 'o'; HtmlChar: '&ouml;'), (TxtChar: 'ø'; AsciiChar: ' '; HtmlChar: '&oslash;'), (TxtChar: 'ù'; AsciiChar: 'u'; HtmlChar: '&ugrave;'),
    (TxtChar: 'ú'; AsciiChar: 'u'; HtmlChar: '&uacute;'), (TxtChar: 'û'; AsciiChar: 'u'; HtmlChar: '&ucirc;'), (TxtChar: 'ü'; AsciiChar: 'u'; HtmlChar: '&uuml;'),
    (TxtChar: 'ý'; AsciiChar: 'y'; HtmlChar: '&yacute;'), (TxtChar: 'þ'; AsciiChar: ' '; HtmlChar: '&thorn;'), (TxtChar: 'ÿ'; AsciiChar: 'y'; HtmlChar: '&yuml;'),
    (TxtChar: #39; AsciiChar: ' '; HtmlChar: '&#39;'));
{$ENDREGION}

implementation

uses
  ClassFuncoesNumero {$IFNDEF VER230}, System.Character{$ENDIF};

{$REGION 'Retro-compatibilidade Delphi'}
{$IFDEF VER185}
function CharInSet(C: AnsiChar;
  const
  CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;
{$ENDIF}
{$ENDREGION}

{$REGION 'TFuncoesString'}

class function TFuncoesString.Trocar(var sTexto: string; const sAtual, sNovo: string; const Flags: TReplaceFlags): string;
begin
  Result := StringReplace(sTexto, sAtual, sNovo, Flags);
  sTexto := Result;
end;

class function TFuncoesString.TrocarChar(var sTexto: string; const sChr_Inv, sChr_Val: string; const Flags: TReplaceFlags): string;
var
  i: Integer;
begin
  for i := 1 to Length(sChr_Inv) do
    if Pos(sChr_Inv[i], sTexto) > 0 then
      sTexto := Trocar(sTexto, sChr_Inv[i], sChr_Val[i], Flags);

  Result := sTexto;
end;

class function TFuncoesString.TrocarVetor(var sTexto: string; const sVet_Inv, Vet_Val: array of string; const Flags: TReplaceFlags): string;
var
  I: Integer;
begin
  for i := Low(sVet_Inv) to High(sVet_Inv) do
    if Pos(sVet_Inv[i], sTexto) > 0 then
      sTexto := Trocar(sTexto, sVet_Inv[i], Vet_Val[i], Flags);

  Result := sTexto;
end;

class function TFuncoesString.DeletarChar(var sTexto: string; const sChr: string): string;
var
  i: Integer;
begin
  for i    := 1 to Length(sChr) do
    sTexto := Deletar(sTexto, sChr[i]);
  Result   := sTexto;
end;

class function TFuncoesString.Inverter(const sTexto: string; const sA, sB: Char): string;
var
  i: Integer;
begin
  Result := sTexto;
  for i  := 1 to Length(Result) do
    if Result[i] = sA then
      Result[i] := sB
    else if Result[i] = sB then
      Result[i] := sA;
end;

class function TFuncoesString.SoNumero(const sTexto: string): string;
var
  i: Byte;
begin
  Result := '';
{$IFDEF VER230}
  for i := 1 to Length(sTexto) do
    if CharInSet(sTexto[i], ['0' .. '9']) then
{$ELSE}
  for i := Low(sTexto) to High(sTexto) do
    if sTexto[i].IsNumber then
{$ENDIF}
      Result := Result + sTexto[i];
end;

class function TFuncoesString.SoLetra(const sTexto: string): string;
var
  i: Byte;
begin
  Result := '';
{$IFDEF VER230}
  for i := 1 to Length(sTexto) do
    if CharInSet(sTexto[i], ['A' .. 'Z']) then
{$ELSE}
  for i := Low(sTexto) to High(sTexto) do
    if sTexto[i].IsLetter then
{$ENDIF}
      Result := Result + sTexto[i];
end;

class function TFuncoesString.SoLetraNumero(const sTexto: string): string;
var
  i: Byte;
begin
  Result := '';
{$IFDEF VER230}
  for i := 1 to Length(sTexto) do
    if CharInSet(sTexto[i], ['A' .. 'Z', 'a' .. 'z', '0' .. '9']) then
{$ELSE}
  for i := Low(sTexto) to High(sTexto) do
    if (sTexto[i].IsNumber) or (sTexto[i].IsLetter) then
{$ENDIF}
      Result := Result + sTexto[i];
end;

class function TFuncoesString.SoLetraNumeroEspaco(const sTexto: string): string;
var
  i: Byte;
begin
  Result := '';
{$IFDEF VER230}
  for i := 1 to Length(sTexto) do
    if CharInSet(sTexto[i], ['A' .. 'Z', 'a' .. 'z', '0' .. '9', ' ', '_']) then
{$ELSE}
  for i := Low(sTexto) to High(sTexto) do
    if (sTexto[i].IsNumber) or (sTexto[i].IsLetter) or (sTexto[i].IsInArray([' ', '_'])) then
{$ENDIF}
      Result := Result + sTexto[i];
end;

class procedure TFuncoesString.Concatenar(var sTexto: string; const S: string; const sQuebra: Char = #13);
begin
  if sTexto <> '' then
    sTexto := sTexto + sQuebra;
  sTexto   := sTexto + S;
end;

class procedure TFuncoesString.Concatenar(var sTexto: string; const S, sDelimitador: string);
begin
  if (sTexto <> '') and (S <> '') then
    sTexto := sTexto + sDelimitador;
  sTexto   := sTexto + S;
end;

class function TFuncoesString.CorteAte(const sTexto, sSubString: string; const bSensitive: Boolean = False; TrasPraFrente: Boolean = False): string;
var
  X   : Integer;
  T, S: string;
begin
  if bSensitive then
  begin
    S := sSubString;
    T := sTexto;
  end
  else
  begin
    S := UpperCase(sSubString);
    T := UpperCase(sTexto);
  end;

  if TrasPraFrente then
  begin
    S := ReverseString(S);
    T := ReverseString(T);
    X := Pos(S, T);
    X := Length(T) - X +1;
  end else
    X := Pos(S, T);

  if (X > 0) then
    Result := Copy(sTexto, 1, X - 1)
  else
    Result := sTexto;
end;

class function TFuncoesString.CorteApos(const sTexto, sSubString: string; const bSensitive: Boolean = False; TrasPraFrente: Boolean = False): string;
var
  X   : Integer;
  T, S: string;
begin
  if bSensitive then
  begin
    S := sSubString;
    T := sTexto;
  end
  else
  begin
    S := UpperCase(sSubString);
    T := UpperCase(sTexto);
  end;

  if TrasPraFrente then
  begin
    S := ReverseString(S);
    T := ReverseString(T);
    X := Pos(S, T);
    X := Length(T) - X +1;
  end else
    X := Pos(S, T);

  if (X > 0) then
    Result := Copy(sTexto, X + Length(sSubString), Length(sTexto))
  else
    Result := sTexto;
end;

class function TFuncoesString.CorteEntre(const sTexto, sSubString_1, sSubString_2: string; const bSensitive: Boolean): string;
begin
  Result := sTexto;
  Result := CorteAte(Result, sSubString_2, bSensitive);
  Result := CorteApos(Result, sSubString_1, bSensitive);
end;

class function TFuncoesString.CorteFora(const sTexto, sSubString_1, sSubString_2: string; const bSensitive: Boolean): string;
begin
  Result := CorteAte(sTexto, sSubString_1, bSensitive);
  Result := Result + CorteApos(sTexto, sSubString_2, bSensitive);
end;

class function TFuncoesString.CopyDelete(var sTexto: string; const iPos, iTamanho: Integer): string;
begin
  Result := Copy(sTexto, iPos, iTamanho);
  Delete(sTexto, iPos, iTamanho);
end;

class function TFuncoesString.CopyFimString(const sTexto: string; const iTamanho: Integer): string;
var
  i: Integer;
begin
  i := Length(sTexto);
  if i > iTamanho then
    Result := Copy(sTexto, i - iTamanho + 1, iTamanho)
  else
    Result := sTexto;
end;

class function TFuncoesString.Deletar(const sTexto, sEliminiar: string): string;
var
  X: Integer;
  S: string;
begin
  S     := sTexto;
  for X := Length(S) downto 1 do
    if Pos(S[X], sEliminiar) > 0 then
      Delete(S, X, 1);
  Result := S;
end;

class function TFuncoesString.DeletarInsere(var sTexto: string; sValor: string; const iInicio, iTamanho: Integer; Funcao: TFuncDI = fdiNenhuma): string;
begin
  if (iInicio <= 0) or (iTamanho <= 0) then
    Exit;

  Delete(sTexto, iInicio, iTamanho);
  if Funcao = fdiStrZero then
    sValor := TFuncoesNumero.StrZero(sValor, iTamanho);

  Insert(Copy(sValor, 1, iTamanho), sTexto, iInicio);
  Result := sTexto;
end;

class function TFuncoesString.RemoverEspacoDuplo(const sTexto: string): string;
begin
  Result := sTexto;
  while Pos('  ', Result) > 0 do
    Result := StringReplace(Result, '  ', ' ', [RfReplaceAll]);
end;

class function TFuncoesString.Completar(const sTexto: string; const iTamanho: Integer; sCaracter: string = ' '; const iAlinhamento: Integer = 0): string;
var
  X, Y: Integer;
  S   : string;
begin
  if sCaracter = '' then
    sCaracter := ' ';

  S := sTexto;
  X := Length(S);

  if X < iTamanho then
    if X + Length(sCaracter) <= iTamanho then
    begin
      Y := 0;
      while X < iTamanho do
      begin
        Inc(Y);
        Inc(X, Length(sCaracter));
        case iAlinhamento of
          0: // Alinha o texto a Esquerda
            S := S + sCaracter;
          1: // Alinha o texto ao Centro
            if odd(Y) then
              S := sCaracter + S
            else
              S := S + sCaracter;
          2: // Alinha o texto a Direita
            S := sCaracter + S;
        end;
      end;
    end
    else
      S  := S + Copy(sCaracter, 1, iTamanho);
  S      := Copy(S, 1, iTamanho);
  Result := S;
end;

class function TFuncoesString.Espacos(const iTamanho: Integer): string;
var
  i: Integer;
begin
  Result   := '';
  for i    := 1 to iTamanho do
    Result := Result + ' ';
end;

class function TFuncoesString.PadR(const sTexto: string; const iTamanho: Integer; const sDelimitador: Char = ' '): string;
begin
  Result := Copy(sTexto, 1, iTamanho) + Completar(sDelimitador, (iTamanho - Length(sTexto)));
end;

class function TFuncoesString.PadL(const sTexto: string; const iTamanho: Integer; const sDelimitador: Char = ' '): string;
begin
  if iTamanho > Length(sTexto) then
    Result := Completar(sDelimitador, (iTamanho - Length(sTexto)))
  else
    Result := '';

  Result := Result + Copy(sTexto, 1, iTamanho);
end;

class function TFuncoesString.PadC(const sTexto: string; const iTamanho: Integer; const sDelimitador: Char = ' '): string;
begin
  Result := TFuncoesString.Completar(sTexto, iTamanho, sDelimitador, 1);
end;

class procedure TFuncoesString.JustificarTexto(var sTexto: TStrings; const iTamanho: Integer);
var
  X, J: Integer;
  S   : string;
begin
  for X := 0 to sTexto.Count - 1 do
  begin
    S := Trim(sTexto[X]);
    if (Length(S) < iTamanho) then
    begin
      J := 2;
      while (Length(S) < iTamanho) do
      begin
        if J > Length(S) then
          Break;
        if (S[J] = ' ') and (Copy(S, J, 3) <> Espacos(3)) then
        begin
          Insert(' ', S, J);
          J := J + 3;
        end
        else
          J := J + 1;

        S := Trim(S);
      end;
    end;
    sTexto[X] := S;
  end;
end;

class function TFuncoesString.PrimeiraLetraMaiscula(const sTexto: string; const bSeparadores: Boolean = False): string;
var
  i  : Integer;
  sep: Boolean;
  str: string;
begin
  str   := AnsiLowerCase(Trim(sTexto));
  for i := 1 to Length(str) do
  begin
    if i = 1 then
      str[i] := UpCase(str[i])
    else
    begin
      if i <> Length(str) then
      begin
        sep := (str[i] = ' ') or (bSeparadores and (str[i].IsInArray(['-', '_', '=', '/', '|', '\'])));
        if sep then
          str[i + 1] := UpCase(str[i + 1]);
      end;
    end;
  end;
  Result := str;
end;

class function TFuncoesString.AcertarFilter(Filtro: string): string;
// Tem comandos ("FRSelecao.ContidoIn()") que não são reconhecidos no "filter" do ClientDataSet.
// Essa classe faz uma adequação. Vide serviço 70555
var iPos, iTamanho: Integer;
begin
  iPos := Pos(' in (', LowerCase(Filtro));
  if iPos > 0 then
  begin
    iTamanho := Length(Filtro);
    repeat
      begin
        if (Filtro[iPos] = ',') then
        begin
        {$IFDEF VER230}
          if (CharInSet(Filtro[iPos + 1], ['0'..'9'])) or
             (CharInSet(Filtro[iPos + 1], [char(39)])) then
            insert(' ', Filtro, iPos + 1);
        {$ELSE}
          if (Filtro[iPos + 1].IsInArray(['0','1','2','3','4','5','6','7','8','9'])) or
             (Filtro[iPos + 1] = char(39))then
            insert(' ', Filtro, iPos + 1);
        {$ENDIF}
        end;
        inc(iPos);
      end;
    until (iPos >= iTamanho);
  end;

  Result := Filtro;
end;

{$IFNDEF VER230}
{$IF NOT DEFINED(MOBILE)}

class function TFuncoesString.ChrValidos(const sTexto: WideString): WideString;
const
  Chr_Inv: string = '&ÇçâãáàéèêìíîôõóòûùúÂÃÁÀÉÈÊÌÍÎÔÕÓÒÛÙÚ¨º°ª§¢£³²¹¬^~´`‘’–';
  Chr_Val: string = 'ECcaaaaeeeiiioooouuuAAAAEEEIIIOOOOUUU ooa              ';
var
  S: string;
begin
  S := sTexto;
  TrocarChar(S, Chr_Inv, Chr_Val);

  Result := S;
  Result := StringReplace(Result, #9, '', [RfReplaceAll]);
  Result := StringReplace(Result, #39, '', [RfReplaceAll]);
end;

class function TFuncoesString.TrocaCaracterXML(const sTexto: WideString): WideString;
const // <         >          &        "       '
  NaoPermitido: array [0 .. 4] of PAnsiChar = (CHR(60), CHR(62), CHR(38), CHR(34), CHR(39));
  TrocarPor: array [0 .. 4] of string = ('&lt;', '&gt;', '&amp;', '&quot;', '&#39;');
var
  Col, i, L: Integer;
  S        : string;
begin
  // Essa funcao só poderá ser aplicada em strings que o usuário final digita nos campos.
  // Não usei stringreplace por causa do caracter: & pois ele faz parte do carater de troca e deve ser conferido se está na posicao encontrada
  // Trocado em 23/09/2008 para trocar de tras para frente. Aumentando a string...
  Result := sTexto;
  Col    := Length(Result);
  while Col > 0 do
  begin
    for i := Low(NaoPermitido) to High(NaoPermitido) do
    begin
      if (PAnsiChar(Result[Col]) = PAnsiChar(NaoPermitido[i])) then
      begin
        L := Length(TrocarPor[i]);
        S := Copy(Result, Col, L);
        if (S <> string(NaoPermitido[i])) or
          ((S = string(NaoPermitido[i])) and (Length(S) = Length(NaoPermitido[i]))) then // Caso em que o caracter a ser trocado está no final da string...
        begin
          Delete(Result, Col, 1);
          Insert(TrocarPor[i], Result, Col);
          Break;
        end;
      end;
    end;
    Dec(Col);
  end;
end;

class function TFuncoesString.TextoHtmlParaSimples(const sTexto: string): string;
begin
  Result := HtmlParaAscII(sTexto);
end;

class function TFuncoesString.AnsiParaAscii(const sTexto: string): string;
var
  i: Integer;
begin
  Result := sTexto;

  for i    := Low(VetorTxtHtml) to High(VetorTxtHtml) do
    Result := StringReplace(Result, VetorTxtHtml[i].TxtChar, VetorTxtHtml[i].AsciiChar, [RfReplaceAll]);
end;

class function TFuncoesString.AscIIParaHtml(const sTexto: string): string;
var
  i: Integer;
begin
  Result := sTexto;

  for i    := Low(VetorTxtHtml) to High(VetorTxtHtml) do
    Result := StringReplace(Result, VetorTxtHtml[i].TxtChar, VetorTxtHtml[i].HtmlChar, [RfReplaceAll]);
end;

class function TFuncoesString.HtmlParaAscII(const sTexto: string; const IsUTF8: Boolean = True): string;
var
  i: Integer;
begin
  if IsUTF8 then
    Result := UTF8ToString(AnsiString(sTexto))
  else
    Result := sTexto;

  for i    := Low(VetorTxtHtml) to High(VetorTxtHtml) do
    Result := StringReplace(Result, VetorTxtHtml[i].HtmlChar, VetorTxtHtml[i].TxtChar, [RfReplaceAll]);
end;

class function TFuncoesString.ConteudoTagXML(const sXML, sTag: string; const bIgnoreCase: Boolean = True): string;
var
  PI, PF    : Integer;
  UXML, UTAG: String;
begin
  Result := '';
  if bIgnoreCase then
  begin
    UXML := UpperCase(sXML);
    UTAG := UpperCase(sTag);
  end
  else
  begin
    UXML := sXML;
    UTAG := sTag;
  end;

  PI := Pos('<' + UTAG + '>', UXML);
  if PI = 0 then
    Exit;

  PI := PI + Length(UTAG) + 2;
  PF := PosEx('</' + UTAG + '>', UXML, PI);
  if PF = 0 then
    PF := Length(sXML);

  Result := Copy(sXML, PI, PF - PI)
end;

class function TFuncoesString.LerProximaTagXML(const pTexto: string): string;
var
  i: Integer;
begin
  Result := TFuncoesString.CorteApos(pTexto, '<');
  Result := TFuncoesString.CorteAte(Result, '>');

  i := Length(Result);
  if ((I > 0) and (Result[i] = '/')) then
    Result := Copy(Result, 1, i -2);
end;

class function TFuncoesString.RetirarBlocoXML(var pTexto: string; const pTag: string): string;
var
  tpUnicaTag: Boolean;
begin
  tpUnicaTag := Pos('<' + pTag + ' />', pTexto) > 0;

  if tpUnicaTag then
  begin
    Result := '';
    pTexto := TFuncoesString.CorteApos(pTexto, '<' + pTag + ' />');
  end else begin
    pTexto := TFuncoesString.CorteApos(pTexto, '<' + pTag + '>');
    Result := TFuncoesString.CorteAte(pTexto, '</' + pTag + '>');
    pTexto := TFuncoesString.CorteApos(pTexto, '</' + pTag + '>');
  end;
end;

{$IFEND}
{$ENDIF}

class function TFuncoesString.Contido(const sSubString, sTexto: string): Boolean;
begin
  Result := (Pos(sSubString, sTexto) > 0);
end;

class function TFuncoesString.ContidoIn(Lista: TStrings; CampoSql: string; AQuote: Boolean): string;
var
  X: Integer;
  r: string;
begin
  r     := '(' + CampoSql + ' in (';
  for X := 0 to Lista.Count - 1 do
  begin
    if AQuote then
      r := r + QuotedStr(Lista[X])
    else
      r := r + Lista[X];

    if ((X mod 1498) = 0) and (X <> 0) then
      r := r + ') ' + #10 + ' or ' + CampoSql + ' in ('
    else
      r := r + ',';
  end;

  if AQuote then
    r := r + QuotedStr('-1') + '))'
  else
    r := r + '-1))';

  Result := r;
end;

class function TFuncoesString.ContidoIn(Lista: string; CampoSql: string; AQuote: Boolean): string;
var
  ListaString: TStrings;
begin
  ListaString := TStringList.Create;
  try
    ExtractStrings([',', ';', '|'], [' '], {$IFDEF VER185}PAnsiChar{$ELSE}PWideChar{$ENDIF}(Lista), ListaString);
    Result := ContidoIn(ListaString, CampoSql, AQuote);
  finally
    FreeAndNil(ListaString);
  end;
end;

class function TFuncoesString.PosDireita(const sBusca, sTexto: string): Integer;
var
  X: Integer;
begin
  Result := 0;
  for X  := Length(sTexto) downto 1 do
    if Copy(sTexto, X, 1) = sBusca then
    begin
      Result := X;
      Break;
    end;
end;

class function TFuncoesString.ApenasNumero(const sTexto: string): Boolean;
var
  i: Byte;
begin
  Result := True;
{$IFDEF VER230}
  for i := 1 to Length(sTexto) do
    if not CharInSet(sTexto[i], ['0' .. '9']) then
{$ELSE}
  for i := Low(sTexto) to High(sTexto) do
    if not sTexto[i].IsNumber then
{$ENDIF}
    begin
      Result := False;
      Break;
    end;
end;

class function TFuncoesString.ApenasCaracter(const S, SS: string): Boolean;
var
  TS, TSS, i: Integer;
  Parte     : string;
begin
  // Verifica se a string S é formada apenas pela substring SS

  TS  := Length(S);
  TSS := Length(SS);

  // A String e SubString não pode ser vazia
  Result := (S <> '') and (SS <> '');

  // O tamanho da String tem que ser múltiplo do tamanho da SubString, senão quer dizer que tem algo a mais
  if Result then
    Result := ((TS mod TSS) = 0);

  if Result then
  begin
    i := 1;
    while (i - 1 + TSS <= TS) do
    begin
      Parte := Copy(S, i, TSS);
      if (Parte <> SS) then
      begin
        Result := False;
        Break;
      end;

      i := i + TSS;
    end;
  end;
end;

class function TFuncoesString.ContarCaracter(const sTexto: string; const sCaracter: Char): Integer;
var
  X: Integer;
begin
  Result := 0;
  for X  := 1 to Length(sTexto) do
  begin
    if sTexto[X] = sCaracter then
      Inc(Result);
  end;
end;

class function TFuncoesString.ContarSubstring(const sTexto, sSubString: string): Integer;
var
  X, iString, iSubString: Integer;
begin
  Result := 0;

  iString    := Length(sTexto);
  iSubString := Length(sTexto);

  if (iString < iSubString) then
    Abort;

  for X := 1 to (iString - iSubString + 1) do
  begin
    if (Copy(sTexto, X, iSubString) = sSubString) then
      Inc(Result);
  end;
end;

class function TFuncoesString.RetornarSimNao(const sTexto: string): string;
begin
  if (sTexto = 'S') then
    Result := 'Sim'
  else if (sTexto = 'N') then
    Result := 'Não'
  else
    Result := EmptyStr;
end;

class function TFuncoesString.RetirarAcentos(sTexto: string): string;
var
  I: Integer;
const
  COM_ACENTO = 'àâêôûãõáéíóúçüîäëïöèìòùÀÂÊÔÛÃÕÁÉÍÓÚÇÜÎÄËÏÖÈÌÒÙ';
  SEM_ACENTO = 'aaeouaoaeioucuiaeioeiouAAEOUAOAEIOUCUIAEIOEIOU';
begin
  for I := 1 to Length(sTexto) do
  begin
    if Pos(sTexto[I], COM_ACENTO) <> 0 then
      sTexto[I] := Char(SEM_ACENTO[Pos(sTexto[I], COM_ACENTO)]);

    if (ord(sTexto[I]) < 32) or (ord(sTexto[I]) > 126) then
      sTexto[I] := ' ';
  end;
  Result := sTexto;
end;

class function TFuncoesString.RetornarSimNao(const iTexto: Integer): string;
begin
  if (iTexto = 1) then
    Result := 'Sim'
  else if (iTexto = 0) then
    Result := 'Não'
  else
    Result := EmptyStr;
end;

class function TFuncoesString.ContemComadosRepeticao(const sTexto: string): Boolean;
var
  ListaCodigo: TStringList;
  i          : Integer;
begin
  Result      := False;
  ListaCodigo := TStringList.Create;
  try
    ListaCodigo.Clear;
    ListaCodigo.Text := AnsiUpperCase(sTexto);

    for i := 0 to ListaCodigo.Count - 1 do
    begin
      if (LeftStr(Trim(ListaCodigo[i]), 6) = 'WHILE ') or (LeftStr(Trim(ListaCodigo[i]), 4) = 'FOR ') or
        (LeftStr(Trim(ListaCodigo[i]), 6) = 'REPEAT') then
      begin
        Result := True;
        Break;
      end;
    end;
  finally
    FreeAndNil(ListaCodigo);
  end;
end;

class function TFuncoesString.ConcatenarEndereco(const prRua, prNumero, prComplemento: string): string;
begin
  Result := prRua + IfThen(prNumero <> '', ', ' + prNumero, '');
  Result := Result + IfThen(prComplemento <> '', ' - ' + prComplemento, '');
end;

class procedure TFuncoesString.DividirParaStringList(var SL: TStringList; const sTexto: string; const sSeparator: Char);
var
  tpTarget: string;
  tpPosition: Integer;
begin
  SL.Clear;

  tpTarget := sTexto;
  while True do
  begin
    tpPosition := Pos(sSeparator, tpTarget);
    if tpPosition <> 0 then
      begin
        SL.Add(Copy(tpTarget, 1, tpPosition - 1));
        Delete(tpTarget, 1, tpPosition);
      end
    else
      begin
        SL.Add(tpTarget);
        Break;
      end;
  end;
end;

class procedure TFuncoesString.DividirParaStringList(var SL: TStringList; const sTexto: string; const sSeparator: string);
var
  tpTarget: string;
  tpPosition: Integer;
begin
  SL.Clear;

  tpTarget := sTexto;
  while True do
    begin
      tpPosition := Pos(sSeparator, tpTarget);
      if tpPosition <> 0 then
        begin
          SL.Add(Copy(tpTarget, 1, tpPosition - 1));
          Delete(tpTarget, 1, tpPosition + Length(sSeparator) -1);
        end
      else
        begin
          SL.Add(tpTarget);
          Break;
        end;
    end;
end;

class procedure TFuncoesString.DividirParaArray(var SA: TStrArray; const sTexto: string; const sSeparator: Char);
var
  tpStrList: TStringList;
  i        : Integer;
begin
  tpStrList := TStringList.Create;
  try
    DividirParaStringList(tpStrList, sTexto, sSeparator);
    SetLength(SA, tpStrList.Count);

    for i := 0 to tpStrList.Count - 1 do
      SA[i] := tpStrList.Strings[i];
  finally
    tpStrList.Free;
  end;
end;

{$ENDREGION}

{$REGION 'TFuncoesString_DigVerificador'}

class function TFuncoesString_DigVerificador.Modulo10(const sValor: string): string;
{
  Rotina usada para cálculo de alguns dígitos verificadores
  Pega-se cada um dos dígitos contidos no parâmetro VALOR, da direita para a
  esquerda e multiplica-se por 2121212...
  Soma-se cada um dos subprodutos. Caso algum dos subprodutos tenha mais de um
  dígito, deve-se somar cada um dos dígitos. (Exemplo: 7*2 = 14 >> 1+4 = 5)
  Divide-se a soma por 10.
  Faz-se a operação 10-Resto da divisão e devolve-se o resultado dessa operação
  como resultado da função Modulo10.
  Obs.: Caso o resultado seja maior que 9, deverá ser substituído por 0 (ZERO).
}
var
  Auxiliar      : string;
  Contador, Peso: Integer;
  Digito        : Integer;
begin
  Auxiliar     := '';
  Peso         := 2;
  for Contador := Length(sValor) downto 1 do
  begin
    Auxiliar := IntToStr(StrToInt(sValor[Contador]) * Peso) + Auxiliar;
    if Peso = 1 then
      Peso := 2
    else
      Peso := 1;
  end;

  Digito       := 0;
  for Contador := 1 to Length(Auxiliar) do
    Digito     := Digito + StrToInt(Auxiliar[Contador]);
  Digito       := 10 - (Digito mod 10);
  if (Digito > 9) then
    Digito := 0;
  Result   := IntToStr(Digito);
end;

class function TFuncoesString_DigVerificador.Modulo11(const sValor: string; const iBase: Integer = 9; const bResto: Boolean = False; const sLetra10: string = '0'): string;
{ Rotina muito usada para calcular dígitos verificadores
  Pega-se cada um dos dígitos contidos no parâmetro VALOR, da direita para a
  esquerda e multiplica-se pela seqüência de pesos 2, 3, 4 ... até BASE.
  Por exemplo: se a base for 9, os pesos serão 2,3,4,5,6,7,8,9,2,3,4,5...
  Se a base for 7, os pesos serão 2,3,4,5,6,7,2,3,4...
  Soma-se cada um dos subprodutos.
  Divide-se a soma por 11.
  Faz-se a operação 11-Resto da divisão e devolve-se o resultado dessa operação
  como resultado da função Modulo11.
  Obs.: Caso o resultado seja maior que 9, deverá ser substituído por 0 (ZERO).
}
var
  Soma                  : Integer;
  Contador, Peso, Digito: Integer;
begin
  Soma         := 0;
  Peso         := 2;
  for Contador := Length(sValor) downto 1 do
  begin
    Soma := Soma + (StrToInt(sValor[Contador]) * Peso);
    if Peso < iBase then
      Inc(Peso)
    else
      Peso := 2;
  end;

  if bResto then
    Result := IntToStr(Soma mod 11)
  else
  begin
    Digito := 11 - (Soma mod 11);
    if Digito = 10 then
      Result := sLetra10
    else
    begin
      if Digito = 11 then
        Digito := 0;
      Result   := IntToStr(Digito);
    end;
  end;
end;

class function TFuncoesString_DigVerificador.DigitoEan(const sValor: string): string;
var
  fator, Fator10, ResFinal: Integer;
begin
  ResFinal    := 0;
  fator       := 3;
  for Fator10 := Length(sValor) downto 1 do
  begin
    ResFinal := ResFinal + (StrToInt(sValor[Fator10]) * fator);
    if fator = 3 then
      fator := 1
    else
      fator := 3;
  end;
  if (ResFinal mod 10) = 0 then
    Result := '0'
  else
  begin
    Fator10 := ((Round(Int(ResFinal / 10))) + 1) * 10;
    fator   := (Fator10 - ResFinal);
    Result  := string(IntToStr(fator));
  end;
end;

class function TFuncoesString_DigVerificador.DigitoMod11ECT(const sValor: string): string;
const
  STR_CALC = '86423597';
var
  numero: string;
  i     : Integer;
  Soma  : Integer;
  resto : Integer;
begin
  if (Length(sValor) < 12) then
    raise Exception.Create('Etiqueta inválida');

  numero := Trim(Copy(sValor, 3, 9));
  if (Length(numero) < 8) and (Length(sValor) = 12) then
    numero := TFuncoesString.Completar(numero, 8, '0', 2)
  else
    numero := Copy(numero, 0, 8);

  Soma   := 0;
  for i  := 1 to 8 do
    Soma := Soma + StrToInt(numero[i]) * StrToInt(STR_CALC[i]);

  resto := Soma mod 11;
  if (resto = 0) then
    Result := '5'
  else if (resto = 1) then
    Result := '0'
  else
    Result := IntToStr(11 - resto);
end;

class procedure TFuncoesString_DigVerificador.DecompoemEan(const sValor: string; var sBarra, sDigito, sCompleto: string);
var
  X: Integer;
  S: string;
  SL: TStrings;
begin
  // Achar o codigo de barras, pode ser que esteja digitado com ou sem DV
  sBarra    := '';
  sDigito   := '';
  sCompleto := '';

  X := Length(sValor);

  if X in [7,12] then
  begin
    // Sem o DV, calcula o DV
    sBarra  := sValor;
    sDigito := TFuncoesString_DigVerificador.DigitoEan(sValor);
  end
  else if X in [8,13] then
  begin
    // Com o DV, extrai o DV e reduz o código em 1
    sBarra  := Copy(sValor, 1, X - 1);
    sDigito := Copy(sValor, X, 1);
  end
  else if X in [9,14] then
  begin
    // Sequencial de Identificação da Unidade Logística (embalagem de embarque, caixa, números de 1 a 8) + Código EAN + DV14
    sBarra  := Copy(sValor, 2, X - 2);
    sDigito := TFuncoesString_DigVerificador.DigitoEan(sBarra);
  end
  else if (Length(sValor) >= 15) then
  begin
    S := TFuncoesString_GS1.Decompor(sValor, False);
    if S <> '' then
    begin
      SL := TStringList.Create;
      try
        SL.Text := S;
        sBarra := SL.Values['Valor'];
      finally
        SL.Free;
      end;
    end;
    if sBarra = '' then
      sBarra := sValor
    else
     DecompoemEan(Copy(sBarra,1,14), sBarra, sDigito, sCompleto);
  end
  else
    sBarra := sValor;

  // Descricao, retorna com codigo + DV
  sCompleto := sBarra + sDigito;
end;

{$ENDREGION}

{$REGION 'TFuncoesString_GS1'}

function TFuncoesString_GS1.TRegistro.UnidToStr: String;
begin
  case Unidades of
    ruNenhuma: Result:= EmptyStr;
    ruKg: Result:= 'Quilogramas';
    ruMetros: Result:= 'Metros';
    ruMetros2: Result:= 'Metros quadrados';
    ruMetros3: Result:= 'Metros cúbicos';
    ruLitros: Result:= 'Litros';
    ruLibras: Result:= 'Libras';
    ruPolegadas: Result:= 'Polegadas';
    ruPolegadas2: Result:= 'Polegadas quadradas';
    ruPolegadas3: Result:= 'Polegadas cúbicas';
    ruPes: Result:= 'Pés';
    ruPes2: Result:= 'Pés quadrados';
    ruPes3: Result:= 'Pés cúbicos';
    ruJardas: Result:= 'Jardas';
    ruJardas2: Result:= 'Jardas quadradas';
    ruJardas3: Result:= 'Jardas cúbicas';
    ruOncas: Result:= 'Onças';
    ruQuartos: Result:= 'Quartos';
    ruGaloes: Result:= 'Galões';
  end;
end;

class function TFuncoesString_GS1.LerRegistro(var sValor: string): TRegistro;

  function ValorAteBreak: string;
  var
    C: Char;
  begin
    Result := '';
    while Length(sValor) > 0 do
    begin
      C := sValor[1];
      Delete(sValor,1,1);
      if C = #$1D then
        break
      else
        Result := Result + C;
    end;
  end;

begin
  with Result do
  begin
    AI:= '';
    Tipo:= rtTexto;
    Decimais:= 0;
    Unidades:= ruNenhuma;
    Descricao:= '';
    Auxiliar:= '';
    Tag := '';
    Valor:= '';
  end;

  if Copy(sValor,1,2) = '00' then
    with Result do
    begin
      AI:= '00';
      Tipo:= rtNumero;
      Descricao:= 'Código de Série de Unidade Logística';
      Tag := 'SSCC';
      Valor:= Copy(sValor,3,18);
      Delete(sValor,1,20);
    end else
  if Copy(sValor,1,2) = '01' then
    with Result do
    begin
      AI:= '01';
      Tipo:= rtNumero;
      Descricao:= 'Número Global de Item Comercial';
      Tag := 'GTIN';
      Valor:= Copy(sValor,3,14);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,2) = '02' then
    with Result do
    begin
      AI:= '02';
      Tipo:= rtNumero;
      Descricao:= 'GTIN de itens comerciais contidos em uma unidade logística';
      Tag := 'CONTENT';
      Valor:= Copy(sValor,3,14);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,2) = '10' then
    with Result do
    begin
      AI:= '10';
      Tipo:= rtTexto;
      Descricao:= 'Número de Batch ou Lote';
      Tag := 'BATCH/LOT';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,2) = '11' then
    with Result do
    begin
      AI:= '11';
      Tipo:= rtData;
      Descricao:= 'Data de produção';
      Tag := 'PROD DATE';
      Valor := Copy(sValor,3,6);
      Delete(sValor,1,8);
    end else
  if Copy(sValor,1,2) = '12' then
    with Result do
    begin
      AI:= '12';
      Tipo:= rtData;
      Descricao:= 'Data de vencimento';
      Tag := 'DUE DATE';
      Valor:= Copy(sValor,3,6);
      Delete(sValor,1,8);
    end else
  if Copy(sValor,1,2) = '13' then
    with Result do
    begin
      AI:= '13';
      Tipo:= rtData;
      Descricao:= 'Data de embalagem';
      Tag := 'PACK DATE';
      Valor:= Copy(sValor,3,6);
      Delete(sValor,1,8);
    end else
  if Copy(sValor,1,2) = '15' then
    with Result do
    begin
      AI:= '15';
      Tipo:= rtData;
      Descricao:= 'Data de durabilidade mínima';
      Tag := 'BEST BEFORE';
      Valor:= Copy(sValor,3,6);
      Delete(sValor,1,8);
    end else
  if Copy(sValor,1,2) = '17' then
    with Result do
    begin
      AI:= '17';
      Tipo:= rtData;
      Descricao:= 'Data de durabilidade máxima';
      Tag := 'USE BY';
      Valor:= Copy(sValor,3,6);
      Delete(sValor,1,8);
    end else
  if Copy(sValor,1,2) = '20' then
    with Result do
    begin
      AI:= '20';
      Tipo:= rtNumero;
      Descricao:= 'Variante do produto';
      Tag := 'VARIANT';
      Valor:= Copy(sValor,3,2);
      Delete(sValor,1,4);
    end else
  if Copy(sValor,1,2) = '21' then
    with Result do
    begin
      AI:= '21';
      Tipo:= rtTexto;
      Descricao:= 'Número de série';
      Tag := 'SERIAL';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,2) = '22' then
    with Result do
    begin
      AI:= '22';
      Tipo:= rtTexto;
      Descricao:= 'Dados secundários para produtos específicos do setor de saúde (HIBCC)';
      Tag := 'QTY/DATE/BATCH';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '240' then
    with Result do
    begin
      AI:= '240';
      Tipo:= rtTexto;
      Descricao:= 'Identificação adicional do produto atribuída pelo fabricante';
      Tag := 'ADDITIONAL ID';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '241' then
    with Result do
    begin
      AI:= '241';
      Tipo:= rtTexto;
      Descricao:= 'Número de Referência do cliente';
      Tag := 'CUSTOMER PART Nº';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '242' then
    with Result do
    begin
      AI:= '242';
      Tipo:= rtTexto;
      Descricao:= 'Número Variável do Pedido sob Encomenda';
      Tag := 'VARIATION NUMBER';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '243' then
    with Result do
    begin
      AI:= '243';
      Tipo:= rtTexto;
      Descricao:= 'Número do componente da embalagem';
      Tag := 'COMPONENT NUMBER EMB';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '250' then
    with Result do
    begin
      AI:= '250';
      Tipo:= rtTexto;
      Descricao:= 'Número de série secundário';
      Tag := 'SECONDARY SERIAL';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '251' then
    with Result do
    begin
      AI:= '251';
      Tipo:= rtTexto;
      Descricao:= 'Referência da entidade de origem';
      Tag := 'REF. TO SOURCE';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '253' then
    with Result do
    begin
      AI:= '253';
      Tipo:= rtTexto;
      Descricao:= 'Identificador Global do Tipo de Documento';
      Tag := 'DOC. ID';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '254' then
    with Result do
    begin
      AI:= '254';
      Tipo:= rtTexto;
      Descricao:= 'Componente de Extensão do GLN';
      Tag := 'GLN EXTENSION';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '255' then
    with Result do
    begin
      AI:= '255';
      Tipo:= rtTexto;
      Descricao:= 'Número global de Cupom';
      Tag := 'CUPOM';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,2) = '30' then
    with Result do
    begin
      AI:= '30';
      Tipo:= rtNumero;
      Descricao:= 'Contagem (Quantidade) variável';
      Tag := 'VAR. COUNT';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '310' then
    with Result do
    begin
      AI:= '310';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruKg;
      Descricao:= 'Peso líquido do produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '311' then
    with Result do
    begin
      AI:= '311';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros;
      Descricao:= 'Comprimento do Produto / 1ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '312' then
    with Result do
    begin
      AI:= '312';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros;
      Descricao:= 'Largura do Produto / Diâmetro / 2ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '313' then
    with Result do
    begin
      AI:= '313';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros;
      Descricao:= 'Profundidade do Produto / Espessura / 3ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '314' then
    with Result do
    begin
      AI:= '314';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros2;
      Descricao:= 'Área do produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '315' then
    with Result do
    begin
      AI:= '315';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruLitros;
      Descricao:= 'Volume do Produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '316' then
    with Result do
    begin
      AI:= '316';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros3;
      Descricao:= 'Volume do Produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '320' then
    with Result do
    begin
      AI:= '320';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruLibras;
      Descricao:= 'Peso líquido do produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '321' then
    with Result do
    begin
      AI:= '321';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas;
      Descricao:= 'Comprimento do Produto / 1ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '322' then
    with Result do
    begin
      AI:= '322';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes;
      Descricao:= 'Comprimento do Produto / 1ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '323' then
    with Result do
    begin
      AI:= '323';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas;
      Descricao:= 'Comprimento do Produto / 1ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '324' then
    with Result do
    begin
      AI:= '324';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas;
      Descricao:= 'Largura do Produto / Diâmetro / 2ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '325' then
    with Result do
    begin
      AI:= '325';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes;
      Descricao:= 'Largura do Produto / Diâmetro / 2ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '326' then
    with Result do
    begin
      AI:= '326';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas;
      Descricao:= 'Largura do Produto / Diâmetro / 2ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '327' then
    with Result do
    begin
      AI:= '327';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas;
      Descricao:= 'Profundidade do Produto / Espessura / 3ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '328' then
    with Result do
    begin
      AI:= '328';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes;
      Descricao:= 'Profundidade do Produto / Espessura / 3ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '329' then
    with Result do
    begin
      AI:= '329';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas;
      Descricao:= 'Profundidade do Produto / Espessura / 3ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '330' then
    with Result do
    begin
      AI:= '330';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruKg;
      Descricao:= 'Peso bruto do recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '331' then
    with Result do
    begin
      AI:= '331';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros;
      Descricao:= 'Comprimento do recipiente / 1ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '332' then
    with Result do
    begin
      AI:= '332';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros;
      Descricao:= 'Largura do contêiner / diâmetro / 2ª dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '333' then
    with Result do
    begin
      AI:= '333';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros;
      Descricao:= 'Profundidade / Espessura do Recipiente / 3ª Dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '334' then
    with Result do
    begin
      AI:= '334';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros2;
      Descricao:= 'Área de recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '335' then
    with Result do
    begin
      AI:= '335';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruLitros;
      Descricao:= 'Volume Bruto do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '336' then
    with Result do
    begin
      AI:= '336';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros3;
      Descricao:= 'Volume Bruto do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '337' then
    with Result do
    begin
      AI:= '337';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruMetros2;
      Descricao:= 'Quilos por metro quadrado';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '340' then
    with Result do
    begin
      AI:= '340';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruLibras;
      Descricao:= 'Peso bruto do recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '341' then
    with Result do
    begin
      AI:= '341';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas;
      Descricao:= 'Comprimento do recipiente/1ª Dimensão em';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '342' then
    with Result do
    begin
      AI:= '342';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes;
      Descricao:= 'Comprimento do recipiente/1ª Dimensão em';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '343' then
    with Result do
    begin
      AI:= '343';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas;
      Descricao:= 'Comprimento do recipiente/1ª Dimensão em';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '343' then
    with Result do
    begin
      AI:= '343';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas;
      Descricao:= 'Comprimento do recipiente/1ª Dimensão em';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '344' then
    with Result do
    begin
      AI:= '344';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas;
      Descricao:= 'Largura do contêiner / diâmetro / 2ª dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '345' then
    with Result do
    begin
      AI:= '345';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes;
      Descricao:= 'Largura do contêiner / diâmetro / 2ª dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '346' then
    with Result do
    begin
      AI:= '346';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas;
      Descricao:= 'Largura do contêiner / diâmetro / 2ª dimensão';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '347' then
    with Result do
    begin
      AI:= '347';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas;
      Descricao:= 'Profundidade / Espessura / Altura / 3ª Dimensão do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '348' then
    with Result do
    begin
      AI:= '348';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes;
      Descricao:= 'Profundidade / Espessura / Altura / 3ª Dimensão do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '349' then
    with Result do
    begin
      AI:= '349';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas;
      Descricao:= 'Profundidade / Espessura / Altura / 3ª Dimensão do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '350' then
    with Result do
    begin
      AI:= '350';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas2;
      Descricao:= 'Área do produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '351' then
    with Result do
    begin
      AI:= '351';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes2;
      Descricao:= 'Área do produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '352' then
    with Result do
    begin
      AI:= '352';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas2;
      Descricao:= 'Área do produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '353' then
    with Result do
    begin
      AI:= '353';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas2;
      Descricao:= 'Área de recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '354' then
    with Result do
    begin
      AI:= '354';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes2;
      Descricao:= 'Área de recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '355' then
    with Result do
    begin
      AI:= '355';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas2;
      Descricao:= 'Área de recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '356' then
    with Result do
    begin
      AI:= '356';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruOncas;
      Descricao:= 'Peso líquido';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '360' then
    with Result do
    begin
      AI:= '360';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruQuartos;
      Descricao:= 'Volume do Produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '361' then
    with Result do
    begin
      AI:= '361';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruGaloes;
      Descricao:= 'Volume do Produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '362' then
    with Result do
    begin
      AI:= '362';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruQuartos;
      Descricao:= 'Volume Bruto do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '363' then
    with Result do
    begin
      AI:= '363';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruGaloes;
      Descricao:= 'Volume Bruto do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '364' then
    with Result do
    begin
      AI:= '364';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas3;
      Descricao:= 'Volume do Produto';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '365' then
    with Result do
    begin
      AI:= '365';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes3;
      Descricao:= 'Product Volume';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '366' then
    with Result do
    begin
      AI:= '366';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas3;
      Descricao:= 'Product Volume';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '367' then
    with Result do
    begin
      AI:= '364';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPolegadas3;
      Descricao:= 'Volume Bruto do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '368' then
    with Result do
    begin
      AI:= '365';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruPes3;
      Descricao:= 'Volume Bruto do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,3) = '369' then
    with Result do
    begin
      AI:= '366';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas3;
      Descricao:= 'Volume Bruto do Recipiente';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,2) = '37' then
    with Result do
    begin
      AI:= '37';
      Tipo:= rtNumero;
      Descricao:= 'Contagem (Quantidade) de itens comerciais contidos em uma unidade logística';
      Tag := 'COUNT';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '390' then
    with Result do
    begin
      AI:= '390';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas3;
      Descricao:= 'Quantia a pagar - Área Monetária Única';
      Tag := 'AMOUNT';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '391' then
    with Result do
    begin
      AI:= '391';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas3;
      Descricao:= 'Quantia a pagar - Com código ISO da moeda corrente';
      Tag := 'AMOUNT';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '392' then
    with Result do
    begin
      AI:= '392';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas3;
      Descricao:= 'Quantia a pagar por item comercial de medida variável - Unidade Monetária Única';
      Tag := 'PRICE';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '393' then
    with Result do
    begin
      AI:= '393';
      Tipo:= rtNumero;
      Decimais:= StrToInt(Copy(sValor,4,1));
      Unidades:= ruJardas3;
      Descricao:= 'Quantia a pagar por item comercial de medida variável - Unidade Monetária Única';
      Tag := 'PRICE';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '400' then
    with Result do
    begin
      AI:= '400';
      Tipo:= rtTexto;
      Descricao:= 'Número da ordem de compra do cliente';
      Tag := 'ORDER NUMBER';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '401' then
    with Result do
    begin
      AI:= '401';
      Tipo:= rtTexto;
      Descricao:= 'Número de consignação';
      Tag := 'CONSIGNMENT';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '402' then
    with Result do
    begin
      AI:= '402';
      Tipo:= rtTexto;
      Descricao:= 'Número de identificação do despacho';
      Tag := 'SHIPMENT N°';
      Valor:= Copy(sValor,4,17);
      Delete(sValor,1,20);
    end else
  if Copy(sValor,1,3) = '403' then
    with Result do
    begin
      AI:= '403';
      Tipo:= rtTexto;
      Descricao:= 'Código de Rota';
      Tag := 'ROUTE';
      Delete(sValor,1,2);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '410' then
    with Result do
    begin
      AI:= '410';
      Tipo:= rtEAN13;
      Descricao:= 'Número Global de Localização - "Despachar/Entregar para" Destino imediato';
      Tag := 'SHIP TO LOC';
      Valor:= Copy(sValor,4,13);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,3) = '411' then
    with Result do
    begin
      AI:= '411';
      Descricao:= 'Número Global de Localização - "Faturar para - Cobrar de"';
      Tag := 'BILL TO';
      Valor:= Copy(sValor,4,13);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,3) = '412' then
    with Result do
    begin
      AI:= '412';
      Tipo:= rtEAN13;
      Descricao:= 'Número Global de Localização - "Comprado de"';
      Tag := 'PURCHASE FROM';
      Valor:= Copy(sValor,4,13);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,3) = '413' then
    with Result do
    begin
      AI:= '413';
      Tipo:= rtEAN13;
      Descricao:= 'Número Global de Localização - "Despachar/Entregar para" Destino final';
      Tag := 'SHIP FOR LOC';
      Valor:= Copy(sValor,4,13);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,3) = '414' then
    with Result do
    begin
      AI:= '414';
      Tipo:= rtEAN13;
      Descricao:= 'Número Global de Localização -  Identificação de local físico';
      Tag := 'LOC Nº';
      Valor:= Copy(sValor,4,13);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,3) = '415' then
    with Result do
    begin
      AI:= '415';
      Tipo:= rtEAN13;
      Descricao:= 'Número Global de Localização da parte que fatura';
      Tag := 'PAY TO';
      Valor:= Copy(sValor,4,13);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,3) = '420' then
    with Result do
    begin
      AI:= '420';
      Tipo:= rtTexto;
      Descricao:= 'Entregar para - Código postal dentro de uma única autoridade postal - "Despachar/ Entregar para"';
      Tag := 'SHIP TO POST';
      Delete(sValor,1,3);
      Valor := ValorAteBreak;
    end else
  // 421 422 423 424 425 426
  if Copy(sValor,1,4) = '7001' then
    with Result do
    begin
      AI:= '7001';
      Tipo:= rtNumero;
      Descricao:= 'Número OTAN de armazenagem';
      Tag := 'NSN';
      Valor:= Copy(sValor,5,13);
      Delete(sValor,1,17);
    end else
  if Copy(sValor,1,4) = '7002' then
    with Result do
    begin
      AI:= '7002';
      Tipo:= rtTexto;
      Descricao:= 'Classificação da carcaça e do corte da carne pelas Nações Unidas (UN/ECE)';
      Tag := 'MEAT CUT';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,3) = '703' then
    with Result do
    begin
      AI:= '703';
      Tipo:= rtTexto;
      Descricao:= 'Número de aprovação do processador, com código ISO de país ';
      Tag := 'PROCESSOR # S 4';
      Valor:= Copy(sValor,5,10);
      Delete(sValor,1,14);
    end else
  if Copy(sValor,1,4) = '7003' then
    with Result do
    begin
      AI:= '7003';
      Tipo:= rtNumero;
      Descricao:= 'Data e Hota de Validade';
      Tag := 'EXPIRY DATE/TIME';
      Valor:= Copy(sValor,5,10);
      Delete(sValor,1,14);
    end else
  if Copy(sValor,1,4) = '7004' then
    with Result do
    begin
      AI:= '7004';
      Tipo:= rtTexto;
      Descricao:= 'Potência Ativa';
      Tag := 'POTENCIA';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '7005' then
    with Result do
    begin
      AI:= '7005';
      Tipo:= rtTexto;
      Descricao:= 'Zona de Captura';
      Tag := 'ZONA';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '7006' then
    with Result do
    begin
      AI:= '7006';
      Tipo:= rtData;
      Descricao:= 'Data do primeiro congelamento';
      Tag := 'DATE CONGELAMENTO';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,4) = '7007' then
    with Result do
    begin
      AI:= '7007';
      Tipo:= rtData;
      Descricao:= 'Data da colheita';
      Tag := 'DATE COLHEITA';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,4) = '7008' then
    with Result do
    begin
      AI:= '7008';
      Tipo:= rtTexto;
      Descricao:= 'Espécies para fins de pesca';
      Tag := 'ESPECIE';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '7009' then
    with Result do
    begin
      AI:= '7009';
      Tipo:= rtTexto;
      Descricao:= 'Tipo de arte de pesca';
      Tag := 'ART FIST';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '7010' then
    with Result do
    begin
      AI:= '7010';
      Tipo:= rtTexto;
      Descricao:= 'Método de Produção';
      Tag := 'METODE FIST';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8001' then
    with Result do
    begin
      AI:= '8001';
      Tipo:= rtNumero;
      Descricao:= 'Produtos em rolo - largura, comprimento, diâmetro central, direção e emendas';
      Tag := 'DIMENSIONS';
      Valor:= Copy(sValor,5,14);
      Delete(sValor,1,18);
    end else
  if Copy(sValor,1,4) = '8002' then
    with Result do
    begin
      AI:= '8002';
      Tipo:= rtTexto;
      Descricao:= 'Identificador de série para telefones celulares';
      Tag := 'CMT Nº';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8003' then
    with Result do
    begin
      AI:= '8003';
      Tipo:= rtTexto;
      Descricao:= 'Identificador Global de Ativo Retornável';
      Tag := 'GRAI';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8004' then
    with Result do
    begin
      AI:= '8004';
      Tipo:= rtTexto;
      Descricao:= 'UPC/EAN Identificação série';
      Tag := 'GIAI';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8005' then
    with Result do
    begin
      AI:= '8005';
      Tipo:= rtNumero;
      Descricao:= 'Preço por unidade de medida';
      Tag := 'PRICE PER UNIT';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,4) = '8006' then
    with Result do
    begin
      AI:= '8006';
      Tipo:= rtNumero;
      Descricao:= 'Identificação do componente de um item comercial';
      Tag := 'GCTIN';
      Valor := Copy(sValor,5,18);
      Auxiliar := Copy(sValor,19,4);
      Delete(sValor,1,22);
    end else
  if Copy(sValor,1,4) = '8007' then
    with Result do
    begin
      AI:= '8007';
      Tipo:= rtTexto;
      Descricao:= 'Número de conta bancária internacional';
      Tag := 'IBAN';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8008' then
    with Result do
    begin
      AI:= '8008';
      Tipo:= rtNumero;
      Descricao:= 'Data e hora de produção';
      Tag := 'PROD. TIME';
      Valor:= Copy(sValor,5,12);
      Delete(sValor,1,16);
    end else
  if Copy(sValor,1,4) = '8010' then
    with Result do
    begin
      AI:= '8010';
      Tipo:= rtNumero;
      Descricao:= 'Identificador do componente';
      Tag := 'ID COMPONENT';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8011' then
    with Result do
    begin
      AI:= '8011';
      Tipo:= rtNumero;
      Descricao:= 'Número de série do identificador do componente';
      Tag := 'SERIE ID COMPONENT';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8012' then
    with Result do
    begin
      AI:= '8012';
      Tipo:= rtNumero;
      Descricao:= 'Versão do software';
      Tag := 'VERSION';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8017' then
    with Result do
    begin
      AI:= '8017';
      Tipo:= rtNumero;
      Descricao:= 'Número de Relação de Serviço Global para identificar o relacionamento entre uma empresa prestadora de serviços com o provedor de serviços';
      // Tag := 'GSRN';
      Valor:= Copy(sValor,5,18);
      Delete(sValor,1,22);
    end else
  if Copy(sValor,1,4) = '8018' then
    with Result do
    begin
      AI:= '8018';
      Tipo:= rtNumero;
      Descricao:= 'Número de Relação de Serviço Global';
      Tag := 'GSRN';
      Valor:= Copy(sValor,5,18);
      Delete(sValor,1,22);
    end else
  if Copy(sValor,1,4) = '8019' then
    with Result do
    begin
      AI:= '8019';
      Tipo:= rtNumero;
      Descricao:= 'Número de Relação de Serviço em Instância';
      //Tag := 'GSRN';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8020' then
    with Result do
    begin
      AI:= '8020';
      Tipo:= rtTexto;
      Descricao:= 'Número de referência de nota de pagamento';
      Tag := 'REF Nº';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,4) = '8100' then
    with Result do
    begin
      AI:= '8100';
      Tipo:= rtNumero;
      Descricao:= 'Código estendido de cupom - NSC + código de oferta';
      Valor:= Copy(sValor,5,6);
      Delete(sValor,1,10);
    end else
  if Copy(sValor,1,4) = '8101' then
    with Result do
    begin
      AI:= '8101';
      Tipo:= rtNumero;
      Descricao:= 'Código estendido de cupom - NSC + código de oferta + código de final de oferta';
      Valor:= Copy(sValor,5,10);
      Delete(sValor,1,14);
    end else
  if Copy(sValor,1,4) = '8102' then
    with Result do
    begin
      AI:= '8102';
      Tipo:= rtNumero;
      Descricao:= 'Código estendido de cupom - NSC';
      Valor:= Copy(sValor,5,2);
      Delete(sValor,1,6);
    end else
  if Copy(sValor,1,4) = '8200' then
    with Result do
    begin
      AI:= '8200';
      Tipo:= rtTexto;
      Descricao:= 'URL da embalagem estendida';
      Tag := 'URL';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,2) = '90' then
    with Result do
    begin
      AI:= '90';
      Tipo:= rtTexto;
      Descricao:= 'Informação combinada mutuamente entre parceiros comerciais (incluindo FACT DIs)';
      Tag := 'INTERNAL';
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end else
  if Copy(sValor,1,1) = '9' then
    with Result do
    begin
      AI:= Copy(sValor,1,2);
      Tipo:= rtTexto;
      Descricao:= 'Informação interna de empresa';
      Tag := 'INTERNAL' + AI;
      Delete(sValor,1,4);
      Valor := ValorAteBreak;
    end;
end;

class function TFuncoesString_GS1.Decompor(const sValor: string; const bCompleto: Boolean = False): string;
var
  i, Cnt: Integer;
  d: Double;
  Str: String;
  Registro: TRegistro;
begin
  Result := '';

  Cnt := 1;
  Str := sValor;
  while (Str <> EmptyStr) and (Cnt < 25) do
  begin
    Registro := LerRegistro(Str);

    if Registro.Tag <> '' then
      Result := Result + '[' + Registro.Tag + ']' + #13
    else
      Result := Result + '[' + Registro.AI + ']' + #13;

    if bCompleto then
    begin
      Result := Result +
        'AI=' + Registro.AI + #13 +
        'Descrição=' + Registro.Descricao + #13;

      if Registro.Auxiliar <> '' then
       Result := Result +
         'Auxiliar=' + Registro.Auxiliar + #13;
    end;

    case Registro.Tipo of
      rtTexto:
        begin
          if bCompleto then
            Result := Result +
              'Tipo=Texto' + #13 +
              'Valor=';

          Result := Result + Registro.Valor + #13;
        end;
      rtNumero:
        begin
          if bCompleto then
            Result := Result +
              'Tipo=Numero' + #13 +
              'Decimais=' + IntToStr(Registro.Decimais) + #13 +
              'Unidade=' + Registro.UnidToStr + #13 +
              'Valor=';

          i := Registro.Decimais;
          if i > 0 then
          begin
            d := StrToFloat(Registro.Valor);
            while i > 0 do
            begin
              d := d / 10;
              dec(i);
            end;
            Result := Result + FloatToStr(d) + #13;
          end else
            Result := Result + Registro.Valor + #13;
        end;
      rtData:
        begin
          if bCompleto then
            Result := Result +
              'Tipo=Data' + #13 +
              'Valor=';

          Result := Result + Copy(Registro.Valor,5,2) + '/' + Copy(Registro.Valor,3,2) + '/' + Copy(Registro.Valor,1,2) + #13;
        end;
      rtEAN13:
        begin
          if bCompleto then
            Result := Result +
              'Tipo=EAN13' + #13 +
              'Valor=';

          Result := Result + Registro.Valor + #13;
        end;
    end;

    if not bCompleto then
      Break;

    // Contador para escape, devido a etiquetas incorreta pode ficar no loop
    Inc(Cnt);
  end;
end;

{$ENDREGION}

end.
