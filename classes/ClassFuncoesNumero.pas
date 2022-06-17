unit ClassFuncoesNumero;

interface

uses SysUtils, Math;

type
  TFuncoesNumero = class
  private
  public
    // Manipulação
    class function Arredondar(const eValor: Extended; const iDecimal: Integer): Extended;
    class function ArredondarProximoInteiro(const eValor: Extended): Integer;
    class function Truncar(const eValor: Extended; const wDecimal: Word): Extended; overload;
    class function Truncar(const cValor: Currency; const wDecimal: Word): Currency; overload;

    // máximo divisor comum
    class function mdc(const iA, iB: Integer): Integer;

    // mínimo múltiplo comum
    class function mmc(const iA, iB: Integer): Integer;

    class function ProximaDezenaAcima(V: Double): Integer;

    // Validação
    class function EntreValores(const iValor, iInicial, iFinal: Integer): Boolean; overload;
    class function EntreValores(const eValor, eInicial, eFinal: Extended): Boolean; overload;

    // Formação
    class function StrZero(const sValor: string; const iTamanho: Integer): string; overload;
    class function StrZero(const iValor: Int64; const iTamanho: Integer): string; overload;

    class procedure PorExtenso(var VExt: array of string; nValor: Real; cTextoIni, cTextoFim: string;
      nLinhas, nLargura: integer; cResto: string; nMoeda: integer; logica: Boolean; TextoFeminino: Boolean = False);
  end;

implementation

uses ClassFuncoesString;

class function TFuncoesNumero.Arredondar(const eValor: Extended; const iDecimal: Integer): Extended;
var
  Potencia10: Single;
  ValorElevado: Double;
{  ParteInteira: Int64;
  ParteFracionaria: Double;
  ParteFrac10S: String;
  DigitoDecisivo: Char;}
// http://www.devmedia.com.br/rotinas-matematicas-para-manipulacao-numerica/20881
// http://www.devmedia.com.br/dicas-arredondando-numeros-de-modos-diferentes/1005
// http://www.devmedia.com.br/rotinas-de-arredondamento-round-roundto-simpleroundto-setroundmode-e-getroundmode/21114
begin
  Potencia10   := System.Math.IntPower(10, iDecimal);
  ValorElevado := eValor * Potencia10;

//  Modo Fatind (se a próxima casa decimal for 5, arredonda para cima
//  Result := (System.Int(ValorElevado) + System.Int(System.Frac(ValorElevado) * 2)) / Potencia10;

//  Modo Nativo (se o valor passado for Double, segue regra da ABNT, se for Extended oscilará o resultado)
  Result := Round(ValorElevado) / Potencia10;

//  Modo manual seguindo regra ABNT
//  ParteInteira     := Trunc(ValorElevado); // Se ValorElevado for Extended oscilará o resultado
//  ParteFracionaria := ValorElevado - ParteInteira;
//  ParteFrac10S     := FloatToStr(ParteFracionaria * 10);
//  DigitoDecisivo   := ParteFrac10S[1];
//  case DigitoDecisivo of
//    '5':
//      if (Length(ParteFrac10S) > 1) or Odd(ParteInteira) then
//        Inc(ParteInteira);
//    '6'..'9': Inc(ParteInteira);
//  end;
//  Result := ParteInteira / Potencia10;
end;

class function TFuncoesNumero.ArredondarProximoInteiro(const eValor: Extended): Integer;
begin
  Result := Ceil(eValor);
end;

class function TFuncoesNumero.Truncar(const eValor: Extended; const wDecimal: Word): Extended;
begin
  Result := System.Int(eValor * System.Math.Power(10, wDecimal)) / System.Math.Power(10, wDecimal);
end;

class function TFuncoesNumero.Truncar(const cValor: Currency; const wDecimal: Word): Currency;
begin
  Result := System.Int(cValor * System.Math.Power(10, wDecimal)) / System.Math.Power(10, wDecimal);
end;

class function TFuncoesNumero.mdc(const iA, iB: Integer): Integer;
begin
  if (iA = 0) and (iB = 0) then
    Result := 0 // preferi não retornar erro
  else if (iA = 0) then
    Result := iB // preferi não retornar erro e sim o outro número
  else if (iB = 0) then
    Result := iA // preferi não retornar erro e sim o outro número
  else
    Result := mdc(iB, iA mod iB);
end;

class function TFuncoesNumero.mmc(const iA, iB: Integer): Integer;
begin
  if (iA = 0) or (iB = 0) then
    Result := 0 // por definição
  else
    Result := (iA * iB) div (mdc(iA, iB));
end;

class function TFuncoesNumero.EntreValores(const eValor, eInicial, eFinal: Extended): Boolean;
begin
  Result := System.Math.InRange(eValor, eInicial, eFinal);
end;

class function TFuncoesNumero.EntreValores(const iValor, iInicial, iFinal: Integer): Boolean;
begin
  Result := System.Math.InRange(iValor, iInicial, iFinal);
end;

class function TFuncoesNumero.StrZero(const iValor: Int64; const iTamanho: Integer): string;
var
  Base: string;
  Tam: Integer;
begin
  Tam := iTamanho;

  if iValor < 0 then // Valor negativo suportar o sinal antes
    Dec(Tam);

  Base := '%.' + IntToStr(Tam) + 'd';
  Result := Format(Base, [iValor]);
end;

class function TFuncoesNumero.StrZero(const sValor: string; const iTamanho: Integer): string;
var
  Base: string;
begin
  Base := '%.' + IntToStr(iTamanho) + 'd';
  Result := Format(Base, [StrToInt64Def(sValor, 0)]);
end;

class procedure TFuncoesNumero.PorExtenso(var VExt: array of string; nValor: Real; cTextoIni, cTextoFim: string;
  nLinhas, nLargura: integer; cResto: string; nMoeda: integer; logica: Boolean; TextoFeminino: Boolean = False);

type
  {$IFDEF NEXTGEN}
  TMoeda = array[1..3, 1..2] of string;
  TNumeros = array[1..10] of string;
  {$ELSE}
  TMoeda = array[1..3, 1..2] of string[10];
  TNumeros = array[1..10] of string[15];
  {$ENDIF}
const
  aUnidade: TNumeros = ('UM ', 'DOIS ', 'TRES ', 'QUATRO ', 'CINCO ', 'SEIS ', 'SETE ', 'OITO ', 'NOVE ', '');
  aDezena: TNumeros = ('DEZ ', 'VINTE ', 'TRINTA ', 'QUARENTA ', 'CINQUENTA ', 'SESSENTA ', 'SETENTA ', 'OITENTA ', 'NOVENTA ', '');
  aDezena2: TNumeros = ('DEZ ', 'ONZE ', 'DOZE ', 'TREZE ', 'QUATORZE ', 'QUINZE ', 'DEZESSEIS ',
    'DEZESSETE ', 'DEZOITO ', 'DEZENOVE ');
  aCentena: TNumeros = ('CENTO ', 'DUZENTOS ', 'TREZENTOS ', 'QUATROCENTOS ', 'QUINHENTOS ', 'SEISCENTOS ', 'SETECENTOS ', 'OITOCENTOS ', 'NOVECENTOS ', '');
  aCentenaFem: TNumeros = ('CENTO ', 'DUZENTAS ', 'TREZENTAS ', 'QUATROCENTAS ', 'QUINHENTAS ', 'SEISCENTAS ', 'SETECENTAS ', 'OITOCENTAS ', 'NOVECENTAS ', '');
  aMilhar: TNumeros = ('MIL ', 'MILHAO ', 'MILHOES ', '', '', '', '', '', '', '');
  aMoeda: TMoeda = (('CRUZEIRO ', 'CRUZEIROS '), ('DOLAR ', 'DOLARES '), ('REAL ', 'REAIS '));
  aCentavo: TNumeros = ('CENTAVO', 'CENTAVOS', '', '', '', '', '', '', '', '');
var
  cTexto, cValor1, cPosicao1, cPosicao2, cPosicao3, cPosicao4: string;
  cTipoMoeda: Byte;

  procedure ConverteExt(cNumero: string; nCasas: Byte; log1: Boolean; Feminino: Boolean = False);
  var
    cNumero1, cNumero2, cNumero3, cNumero4: string;
  begin
    if cNumero = '000' then
      Exit;
    cNumero1 := Copy(cNumero, 1, 1);
    cNumero2 := Copy(cNumero, 2, 1);
    cNumero3 := Copy(cNumero, Length(cNumero), 1);
    cNumero4 := Copy(cNumero, Length(cNumero) - 1, 2);
    if nCasas = 4 then
    begin
      if StrToInt(cPosicao1 + cPosicao2 + cPosicao3) <> 0 then
        cTexto := cTexto + 'E ';
    end;
    if cNumero1 <> '0' then
    begin
      if (cNumero4 = '00') and (cNumero1 = '1') then
        cTexto := cTexto + 'CEM '
      else if (Feminino) then
        cTexto := cTexto + string(aCentenaFem[StrToInt(cNumero1)])
      else
        cTexto := cTexto + string(aCentena[StrToInt(cNumero1)]);
    end;
    if (cNumero4 >= '10') and (cNumero4 <= '19') then
    begin
      if (cNumero1 <> '0') then
        cTexto := cTexto + 'E ' + string(aDezena2[StrToInt(cNumero4) - 9])
      else
        cTexto := cTexto + string(aDezena2[StrToInt(cNumero4) - 9]);
    end;
    if cNumero2 >= '2' then
    begin
      if cNumero1 <> '0' then
        cTexto := cTexto + 'E ' + string(aDezena[StrToInt(cNumero2)])
      else
        cTexto := cTexto + string(aDezena[StrToInt(cNumero2)]);
    end;
    if (cNumero3 <> '0') and ((cNumero4 < '10') or (cNumero4 > '19')) then
    begin
      if (cNumero1 <> '0') or (cNumero2 <> '0') then
        cTexto := cTexto + 'E ' + string(aUnidade[StrToInt(cNumero3)])
      else
        cTexto := cTexto + string(aUnidade[StrToInt(cNumero3)]);
    end;
    case nCasas of
      1:
        begin
          if StrToInt(cNumero) = 1 then
            cTexto := cTexto + string(aMilhar[2])
          else
            cTexto := cTexto + string(aMilhar[3]);
        end;
      2:
        begin
          if StrToInt(cNumero) > 0 then
            cTexto := cTexto + string(aMilhar[1]);
        end;
      3:
        begin
          if log1 then
            if StrToInt(cPosicao1 + cPosicao2 + cPosicao3) = 1 then
              cTexto := cTexto + string(aMoeda[cTipoMoeda, 1])
            else
              cTexto := cTexto + string(aMoeda[cTipoMoeda, 2]);
        end;
      4:
        begin
          if log1 then
            if StrToInt(cNumero) = 1 then
              cTexto := cTexto + string(aCentavo[1])
            else
              cTexto := cTexto + string(aCentavo[2]);
        end;
    end;
  end;

  function FormataExt(Text: string; nLinhas, nTamanho: integer; cResto: string): string;
  var
    nTotLin, N1, N2, nInicio, nFalta, nAcha: integer;
    cTextoAux, cLinha: string;
  begin
    nTotLin := nLinhas; {length(cTexto) div nTamanho;}
    nInicio := 1;
    if nTotLin > nLinhas then
      nTotLin := nLinhas;
    cTextoAux := '';
    for N1 := 1 to nTotLin do
    begin
      cLinha := Trim(Copy(Text, nInicio, nTamanho));
      while True do
      begin
        nFalta := nTamanho - Length(cLinha);
        if (nFalta > 20) or (Copy(cLinha, Length(cLinha), 1) = '.') then
          Break;
        if Length(cLinha) < nTamanho then
        begin
          nAcha := -1;
          cLinha := TFuncoesString.Trocar(cLinha, ' ', '|');
          for N2 := 1 to nFalta do
          begin
            nAcha := TFuncoesString.PosDireita('|', cLinha);
            if nAcha = 0 then
              Break;
            Delete(cLinha, nAcha, 1);
            Insert('  ', cLinha, nAcha);
          end;
          if nAcha = 0 then
            Break; // Linha inserida pois o programa ficava preso no loop maior se a string não tivesse espaço
          cLinha := TFuncoesString.Trocar(cLinha, '|', ' ');
        end;
        if Length(Trim(cLinha)) = nTamanho then
          Break;
      end;
      cTextoAux := cTextoAux + cLinha;
      nInicio := nInicio + nTamanho;
    end;
    cTextoAux := Copy(Trim(cTextoAux) + TFuncoesString.Completar('', nTamanho * nLinhas, cResto, 0), 1, nTamanho * nLinhas);
    Result := cTextoAux
  end;

var
  N1, nInicio: integer;
begin
  cTexto := '';
  if nMoeda = 0 then
    cTipoMoeda := 3
  else
    cTipoMoeda := nMoeda;

  cValor1 := FormatFloat('0000000000.00', Abs(nValor));
  cPosicao1 := Copy(cValor1, 2, 3);
  cPosicao2 := Copy(cValor1, 5, 3);
  cPosicao3 := Copy(cValor1, 8, 3);
  cPosicao4 := '0' + Copy(cValor1, (Length(cValor1) - 1), 2);
  ConverteExt(cPosicao1, 1, logica, TextoFeminino);
  cTexto := cTextoIni + cTexto;
  ConverteExt(cPosicao2, 2, logica, TextoFeminino);
  if (StrToInt(cPosicao2) <> 0) and (StrToInt(cPosicao3) <> 0) and (StrToInt(cPosicao4) = 0) then
    cTexto := cTexto + 'E ';
  ConverteExt(cPosicao3, 3, logica, TextoFeminino);
  if (StrToInt(cPosicao3) = 0) and (StrToInt(cPosicao1 + cPosicao2) <> 0) and logica then
    cTexto := cTexto + string(aMoeda[cTipoMoeda, 2]);
  ConverteExt(cPosicao4, 4, logica, TextoFeminino);
  cTexto := cTexto + cTextoFim;
  cTexto := FormataExt(cTexto, nLinhas, nLargura, cResto);
  nInicio := 1;

  for N1 := 0 to nLinhas - 1 do
  begin
    VExt[N1] := Copy(cTexto, nInicio, nLargura);
    nInicio := nInicio + nLargura;
  end;
end;

class function TFuncoesNumero.ProximaDezenaAcima(V: Double): Integer;
begin
  Result := Ceil(V / 10) * 10;
end;

end.
