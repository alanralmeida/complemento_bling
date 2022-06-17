unit UClassFuncoesRede;

interface

uses
  Classes, Forms, System.SysUtils, System.Types, Winapi.WinSock, Winapi.WinInet, Vcl.ExtActns, {$IFDEF VER230} {$ELSE} System.AnsiStrings, {$ENDIF}
  IdIcmpClient, IdStack, IdHTTP, IdCompressorZLib, IdSSLOpenSSL, IdAuthentication,
  SHDocVw, ActiveX, Registry, Windows, IdURI, REST.Client, REST.Types;

type
  TSunB = packed record
    s_b1, s_b2, s_b3, s_b4: Byte;
  end;

  TSunW = packed record
    s_w1, s_w2: Word;
  end;

  TIPAddr = record
    case Integer of
      0:
        (S_un_b: TSunB);
      1:
        (S_un_w: TSunW);
      2:
        (S_addr: longword);
  end;

  PIPAddr = ^TIPAddr;
  IPAddr  = TIPAddr;

  TFuncoesRede = class
  private
    class procedure TranslateStringToTInAddr(AIP: string; var AInAddr);
  public
    class function GetIP: string;
    class function GetHost: string;

    class procedure ConfiguracoesProxy(var sServer, sPort, sUser, sPassword: String);

    class function PingEndereco(const sInetAddress: string): Boolean; overload;
    class function PingEndereco(const sInetAddress: string; const iTentativasDePing: Integer; var sIP: string): Boolean; overload;

    class function ExisteConexaoComInternet(const sSite: string = ''): Boolean;

    class function DownloadFile(const sURL: string; const fFileName: TFileName; const vProgressProc: TDownloadProgressEvent = nil): Boolean;
    class procedure DownloadFileToStream(const sURL: String; Stream: TMemoryStream; const cConnectTimeout: Integer = 0; const cReadTimeOut: Integer = -1;
                                 const cProxyServer: String = ''; const cProxyPort: Integer = 0; const cProxyUser: String = '';
                                 const cProxyPassword: String = '');

    class procedure WebBrowser_LoadHTML(WebBrowser: TWebBrowser; const HTMLCode: string; AguardarCarregar: Boolean = false);
    class function ProtocoloIndicaPaginaHTML(const Texto: String): Boolean;

    class function EnderecoWebProcessado(
      const cURL: string;
      Metodo: string = 'GET';
      const cMensagem: string = '';
      const cConnectTimeout: Integer = 0;
      const cReadTimeOut: Integer = -1;
      const cCabecalhosExtras: String = '';
      const TipoConteudo: String = '';
      const cAccept: String = '';
      const cProxyServer: String = '';
      const cProxyPort: Integer = 0;
      const cProxyUser: String = '';
      const cProxyPassword: String = ''): string; overload;

    // Alexsander Wilen - Metodo Criado para requisições REST,
    // mesmo utilizando o protocolo https.
    // Aceita conteúdos dos tipos
    // 'application/json, text/plain; q=0.9, text/html;q=0.8,'
    // Charset 'UTF-8, *;q=0.8'
    // Com o método EnderecoWebProcessado2 não consegui fazer
    // requisição de um REST https.
    // Ex. de url que não funcionou no EnderecoWebProcessado2:
    // https://api.bitcointrade.com.br/v1/public/BTC/ticker/
    class function HttpRestRequest(
      const cURL: string;
      Metodo: string = 'GET';
      const cMensagem: string = '';
      const cConnectTimeout: Integer = 0;
      const cReadTimeOut: Integer = -1;
      const cCabecalhosExtras: String = '';
      const TipoConteudo: String = '';
      const cAccept: String = '';
      const cProxyServer: String = '';
      const cProxyPort: Integer = 0;
      const cProxyUser: String = '';
      const cProxyPassword: String = ''): String;
  end;

function IcmpCreateFile: THandle; stdcall; external 'icmp.dll';
function IcmpCloseHandle(icmpHandle: THandle): Boolean; stdcall; external 'icmp.dll';
function IcmpSendEcho(icmpHandle: THandle; DestinationAddress: IPAddr; RequestData: Pointer; RequestSize: Smallint; RequestOptions: Pointer; ReplyBuffer: Pointer; ReplySize: DWORD; Timeout: DWORD): DWORD; stdcall; external 'icmp.dll';

implementation

class procedure TFuncoesRede.TranslateStringToTInAddr(AIP: string; var AInAddr);
var
  phe      : PHostEnt;
  pac      : PAnsiChar;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  try
    phe := GetHostByName(PAnsiChar(AnsiString(AIP)));
    if Assigned(phe) then
    begin
      pac := phe^.h_addr_list^;
      if Assigned(pac) then
      begin
        with TIPAddr(AInAddr).S_un_b do
        begin
          s_b1 := Byte(pac[0]);
          s_b2 := Byte(pac[1]);
          s_b3 := Byte(pac[2]);
          s_b4 := Byte(pac[3]);
        end;
      end
      else
      begin
        raise Exception.Create('Error getting IP from HostName');
      end;
    end
    else
    begin
      raise Exception.Create('Error getting HostName');
    end;
  except
    FillChar(AInAddr, SizeOf(AInAddr), #0);
  end;
  WSACleanup;
end;

class function TFuncoesRede.GetHost: string;
var
  WSAData: TWSAData;
  Buffer : array [0 .. 63] of AnsiChar;
  HostEnt: PHostEnt;
begin
  Result := '';
  if WSAStartup($0101, WSAData) <> 0 then
    Exit;
  if GetHostName(Buffer, SizeOf(Buffer)) = 0 then
  begin
    HostEnt := GetHostByName(Buffer);
    if HostEnt <> nil then
      Result := string(HostEnt.H_name);
  end;
  WSACleanup;
end;

class function TFuncoesRede.GetIP: string;
type
  TaPInAddr = array [0 .. 10] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  phe      : PHostEnt;
  Pptr     : PaPInAddr;
  Buffer   : array [0 .. 63] of AnsiChar;
  I        : Integer;
  GInitData: TWSAData;
begin
  WSAStartup($101, GInitData);
  Result := '';
  GetHostName(Buffer, SizeOf(Buffer));
  phe := GetHostByName(Buffer);
  if phe = nil then
    Exit;
  Pptr := PaPInAddr(phe^.h_addr_list);
  I    := 0;
  while Pptr^[I] <> nil do
  begin
    Result := string({$IFDEF VER230} System.SysUtils {$ELSE} System.AnsiStrings {$ENDIF} .StrPas(Inet_ntoa(Pptr^[I]^)));
    Inc(I);
  end;
  WSACleanup;
end;

class function TFuncoesRede.HttpRestRequest(
  const cURL: string;
  Metodo: string = 'GET';
  const cMensagem: string = '';
  const cConnectTimeout: Integer = 0;
  const cReadTimeOut: Integer = -1;
  const cCabecalhosExtras: String = '';
  const TipoConteudo: String = '';
  const cAccept: String = '';
  const cProxyServer: String = '';
  const cProxyPort: Integer = 0;
  const cProxyUser: String = '';
  const cProxyPassword: String = ''): string;
var
  RESTClient: TRESTClient;
  RESTRequest: TRESTRequest;
  RESTResponse: TRESTResponse;
  CabecalhosExtras: TStringList;
  I: Integer;
  posicaoAuxiliar: Integer;
begin
  Metodo := AnsiUpperCase(Metodo);
  if ((Metodo <> 'POST')   and
     (Metodo  <> 'GET')    and
     (Metodo  <> 'PUT')    and
     (Metodo  <> 'DELETE') and
     (Metodo  <> 'PATCH')) then
    raise Exception.Create('Apenas os métodos POST, GET, PUT, DELETE e PATCH são aceitos pela função HttpRestRequest');

  RESTClient       := TRESTClient.Create(cURL);
  RESTRequest      := TRESTRequest.Create(RESTClient);
  RESTResponse     := TRESTResponse.Create(RESTRequest);
  CabecalhosExtras := TStringList.Create;
  try
    if Trim(cProxyServer) <> '' then
    begin
      with RESTClient do
      begin
        Accept := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
        AcceptCharset := 'UTF-8, *;q=0.8';
        BaseURL := cURL;

        if (Trim(TipoConteudo) <> '') then
          ContentType := TipoConteudo;

        ProxyServer   := cProxyServer;
        ProxyPort     := cProxyPort;
        ProxyUsername := cProxyUser;
        ProxyPassword := cProxyPassword;
      end;
    end;

    with RESTRequest do
    begin
      RESTRequest.Client   := RESTClient;

      if Metodo = 'POST' then
        RESTRequest.Method := TRESTRequestMethod.rmPOST
      else if Metodo = 'PUT' then
        RESTRequest.Method := TRESTRequestMethod.rmPUT
      else if Metodo = 'GET' then
        RESTRequest.Method := TRESTRequestMethod.rmGET
      else if Metodo = 'DELETE' then
        RESTRequest.Method := TRESTRequestMethod.rmDELETE
      else if Metodo = 'PATCH' then
        RESTRequest.Method := TRESTRequestMethod.rmPATCH;

      CabecalhosExtras.Text := cCabecalhosExtras;
      for I := 0 to CabecalhosExtras.Count-1 do
      begin
        posicaoAuxiliar := pos(':', CabecalhosExtras[i]);
        with RESTRequest.Params.AddItem do
        begin
          Kind        := pkHTTPHEADER;
          name        := copy(CabecalhosExtras[i], 1, posicaoAuxiliar-1);
          Value       := copy(CabecalhosExtras[i], posicaoAuxiliar+1, length(CabecalhosExtras[i])- posicaoAuxiliar);
          Options     := [poDoNotEncode];
          ContentType := ctAPPLICATION_JSON;
        end;
      end;

      if Trim(cMensagem) <> '' then
      begin
        // O Body é passado como parâmetro
        with RESTRequest.Params.AddItem do
        begin
          Kind        := pkREQUESTBODY;
          name        := 'body';
          Value       := cMensagem;
          Options     := [poDoNotEncode];
          ContentType := ctAPPLICATION_JSON;
        end;
      end;

      RestRequest.Response := RESTResponse;
    end;

    with RESTResponse do
    begin
      RestResponse.ContentType := 'application/json';
    end;

    RESTRequest.Execute;
    Result := RESTResponse.Content;
  finally
    FreeAndNil(RESTResponse);
    FreeAndNil(RESTRequest);
    FreeAndNil(RESTClient);
  end;
end;

class function TFuncoesRede.PingEndereco(const sInetAddress: string): Boolean;
var
  Handle: THandle;
  InAddr: IPAddr;
  DW    : DWORD;
  rep   : array [1 .. 128] of Byte;
begin
  Result := false;
  Handle := IcmpCreateFile;
  if Handle = INVALID_HANDLE_VALUE then
    Exit;
  try
    TranslateStringToTInAddr(sInetAddress, InAddr);
    DW     := IcmpSendEcho(Handle, InAddr, nil, 0, nil, @rep, 128, 0);
    Result := (DW <> 0);
  finally
    IcmpCloseHandle(Handle);
  end;
end;

class function TFuncoesRede.PingEndereco(const sInetAddress: string; const iTentativasDePing: Integer; var sIP: string): Boolean;
var
  I   : Integer;
  ICMP: TIdIcmpClient;
begin
  ICMP := TIdIcmpClient.Create(nil);
  TIdStack.IncUsage;
  sIP    := '';
  Result := false;
  I      := 1;
  try
    try
      while True do
      begin
        sIP                 := GStack.ResolveHost(Trim(sInetAddress));
        ICMP.Host           := sIP;
        ICMP.ReceiveTimeout := 500;
        ICMP.Ping;

        if ICMP.ReplyStatus.BytesReceived > 0 then
        begin
          Break;
          Result := True;
        end
        else
        begin
          Inc(I);
          Sleep(1000);
          if I > iTentativasDePing then
            Break;
          Result := false;
        end;
      end;
    except
      Result := false;
    end;
  finally
    ICMP.Destroy;
    TIdStack.DecUsage;
  end;
end;

class function TFuncoesRede.ExisteConexaoComInternet(const sSite: string = ''): Boolean;
var
  Flags: DWORD;
  // Site: string;
begin
  if not InternetGetConnectedState(@Flags, 0) then
    // Você não está conectado à Internet.
    Result := false
  else if Flags and INTERNET_CONNECTION_LAN <> 0 then
    // Você está conectado à Internet através de um roteador
    Result := True
  else if Flags and INTERNET_CONNECTION_PROXY <> 0 then
    // Você está conectado à Internet através de um proxy
    Result := True
  else
    // Você está conectado à Internet por uma conexão direta
    Result := True;

  // if (sSite = '') then
  // Site := 'http://www.google.com.br/';
  // else
  // Site := sSite;
  //
  // Result := InternetCheckConnection({$IFDEF VER185}PAnsiChar{$ELSE}PWideChar{$ENDIF}(Site), 1, 0);
end;

class function TFuncoesRede.DownloadFile(const sURL: string; const fFileName: TFileName; const vProgressProc: TDownloadProgressEvent = nil): Boolean;
begin
  // limpar o cache
  Winapi.WinInet.DeleteUrlCacheEntry(PWideChar(sURL));

  with Vcl.ExtActns.TDownLoadURL.Create(nil) do
    try
      URL                := sURL;
      FileName           := fFileName;
      OnDownloadProgress := vProgressProc;
      ExecuteTarget(nil);
      Result := True;
    finally
      Free;
    end;

  // UrlMon.UrlDownloadToFile(nil, PWideChar(AURL), PWideChar(AFileName), 0, nil);
end;

class procedure TFuncoesRede.DownloadFileToStream(const sURL: String; Stream: TMemoryStream; const cConnectTimeout: Integer = 0; const cReadTimeOut: Integer = -1;
                                         const cProxyServer: String = ''; const cProxyPort: Integer = 0; const cProxyUser: String = '';
                                         const cProxyPassword: String = '');
var
  IdHTTP   : TIdHTTP;
  LHandler : TIdSSLIOHandlerSocketOpenSSL;
begin
  IdHTTP           := TIdHTTP.Create(nil);
  LHandler         := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    IdHTTP.HandleRedirects := True;
    IdHTTP.IOHandler       := LHandler;
    LHandler.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    LHandler.Open;

{$IFNDEF VER230} // Acima de xe2
    // https://robertocschneiders.wordpress.com/2013/05/17/soap-and-rest-using-gzip-with-delphi-client/
    // NOTE: This does not work in Delphi XE2. Access violation occurs. Works in XE3.
    IdHTTP.Compressor := TIdCompressorZLib.Create(IdHTTP);
{$ENDIF}
    IdHTTP.ConnectTimeout := cConnectTimeout;
    IdHTTP.ReadTimeout    := cReadTimeOut;

    if Trim(cProxyServer) <> '' then
    begin
      IdHTTP.ProxyParams.ProxyServer   := cProxyServer;
      IdHTTP.ProxyParams.ProxyPort     := cProxyPort;
      IdHTTP.ProxyParams.ProxyUsername := cProxyUser;
      IdHTTP.ProxyParams.ProxyPassword := cProxyPassword;
    end;

    IdHTTP.Request.CacheControl := 'no-cache';
    IdHTTP.Request.UserAgent    := 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36';

    try
      IdHTTP.Get(sURL, Stream);
    except
      on E:EIdHTTPProtocolException do
      begin
        raise Exception.Create('/*' + e.Message + '*/' + #13 + e.ErrorMessage);
      end
      else raise;
    end;
  finally
{$IF DEFINED(DEBUG)} OutputDebugString(PWideChar(IdHTTP.Response.RawHeaders.Text)); {$IFEND}
    FreeAndNil(LHandler);
    FreeAndNil(IdHTTP);
  end;
end;

class procedure TFuncoesRede.WebBrowser_LoadHTML(WebBrowser: TWebBrowser; const HTMLCode: string; AguardarCarregar: Boolean = false);
var
  sl: TStringList;
  ms: TMemoryStream;
begin
  if (not Assigned(WebBrowser.Document)) then
    WebBrowser.Navigate('about:blank');

  while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do
    Application.ProcessMessages;

  if Assigned(WebBrowser.Document) then
  begin
    sl := TStringList.Create;
    try
      ms := TMemoryStream.Create;
      try
        sl.Text := HTMLCode;
        sl.SaveToStream(ms);
        ms.Seek(0, 0);
        (WebBrowser.Document as IPersistStreamInit).Load(TStreamAdapter.Create(ms));
      finally
        ms.Free;
      end;
      if AguardarCarregar then
        while WebBrowser.ReadyState < READYSTATE_INTERACTIVE do
          Application.ProcessMessages;
    finally
      sl.Free;
    end;
  end;
end;

class function TFuncoesRede.ProtocoloIndicaPaginaHTML(const Texto: String): Boolean;
var S: String;
begin
  S := AnsiUpperCase(Copy(Texto, 1, 8));

  Result :=
    (Pos('HTTP://', S) = 1) or
    (Pos('HTTPS://', S) = 1) or
    (Pos('WWW.', S) = 1) or
    (Pos('FILE://', S) = 1);
end;

class function TFuncoesRede.EnderecoWebProcessado(
  const cURL: string;
  Metodo: string = 'GET';
  const cMensagem: string = '';
  const cConnectTimeout: Integer = 0;
  const cReadTimeOut: Integer = -1;
  const cCabecalhosExtras: String = '';
  const TipoConteudo: String = '';
  const cAccept: String = '';
  const cProxyServer: String = '';
  const cProxyPort: Integer = 0;
  const cProxyUser: String = '';
  const cProxyPassword: String = ''): string;
var
  IdHTTP                 : TIdHTTP;
  RBody, CabecalhosExtras: TStringStream;
  LHandler               : TIdSSLIOHandlerSocketOpenSSL;
begin
  Metodo := AnsiUpperCase(Metodo);
  if ((Metodo <> 'POST') and
    (Metodo <> 'GET') and
    (Metodo <> 'PUT') and
    (Metodo <> 'DELETE')) then
    raise Exception.Create('Apenas os métodos POST, GET, PUT e DELETE são aceitos pela função EnderecoWebProcessado');

  IdHTTP           := TIdHTTP.Create(nil);
  RBody            := TStringStream.Create(cMensagem);
  CabecalhosExtras := TStringStream.Create(cCabecalhosExtras);
  LHandler         := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  try
    IdHTTP.HandleRedirects := True;

    IdHTTP.IOHandler := LHandler;
    LHandler.SSLOptions.SSLVersions := [sslvTLSv1, sslvTLSv1_1, sslvTLSv1_2];
    LHandler.Open;

{$IFNDEF VER230} // Acima de xe2
    // https://robertocschneiders.wordpress.com/2013/05/17/soap-and-rest-using-gzip-with-delphi-client/
    // NOTE: This does not work in Delphi XE2. Access violation occurs. Works in XE3.
    IdHTTP.Compressor := TIdCompressorZLib.Create(IdHTTP);
{$ENDIF}
{$REGION 'Se você acha que o ConnectTimeOut não está funcionando leia isto:'}
    { If you are connecting to a hostname instead of an IP address,
      the hostname has to be resolved to an IP via a DNS lookup,
      which can take time, especially if the hostname has not been cached by the OS yet.
      The ConnectTimeout property does not account for that time.

      Also, when ConnectTimeout is not zero, or if TIdAntiFreeze is being used,
      Indy has to use an internal worker thread to perform
      the actual socket API connect() call to the server.
      Starting a new thread can take some time,
      depending on available system resources at that moment.
      ConnectTimeout does not account for that time, either.

      The current implementation of ConnectTimeout applies only to
      the actual socket API connect() call itself,
      not to any of the extra work needed to reach that point.
      As such, if you have a 5 second ConnectTimeout value set,
      it is possible to hanve more than 5 seconds elapse before TIdTCPClient.Connect() exits.

      http://stackoverflow.com/questions/4271381/tidhttp-connecttimeout-not-working

      OUTRO DETALHE: o tempo é de conexão, não de tráfego do HTML!
    }
{$ENDREGION}
    IdHTTP.ConnectTimeout := cConnectTimeout;
    IdHTTP.ReadTimeout    := cReadTimeOut;

    if Trim(cProxyServer) <> '' then
    begin
      IdHTTP.ProxyParams.ProxyServer   := cProxyServer;
      IdHTTP.ProxyParams.ProxyPort     := cProxyPort;
      IdHTTP.ProxyParams.ProxyUsername := cProxyUser;
      IdHTTP.ProxyParams.ProxyPassword := cProxyPassword;
    end;

    { Outras Propriedades a serem estudadas futuramente:
      IdHTTP.ProxyParams.BasicAuthentication := True;
      IdHTTP.Request.BasicAuthentication := True;
      IdHTTP.Request.Authentication      := TIdBasicAuthentication.Create;
      IdHTTP.HTTPOptions    := IdHTTP.HTTPOptions + [hoKeepOrigProtocol];
      IdHTTP.Request.Authentication.Username := 'admin';
      IdHTTP.Request.Authentication.Password := 'admin';
      IdHTTP.Request.ProxyConnection := 'Keep-Alive';
      IdHTTP.Response.ProxyAuthenticate.Text }

    IdHTTP.Request.CacheControl := 'no-cache';
    IdHTTP.Request.UserAgent    := { 'Tek-System (ERP 4g)'; // } 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36';
    IdHTTP.Request.CustomHeaders.LoadFromStream(CabecalhosExtras);

    if (Trim(TipoConteudo) <> '') then
      IdHTTP.Request.ContentType := TipoConteudo;

    if (Trim(cAccept) <> '') then
      IdHTTP.Request.Accept := cAccept;

    try
       if (Metodo = 'GET') then
        Result := IdHTTP.Get(TIdURI.URLEncode(cURL))
      else if (Metodo = 'POST') then
        Result := IdHTTP.Post(TIdURI.URLEncode(cURL), RBody)
      else if (Metodo = 'PUT') then
        Result := IdHTTP.Put(TIdURI.URLEncode(cURL), RBody)
      else if (Metodo = 'DELETE') then
       {$IFNDEF VER230}Result := {$ENDIF} IdHTTP.Delete(TIdURI.URLEncode(cURL)); // XE2 nao tem result nessa funcao
    except
      on E:EIdHTTPProtocolException do
      begin
        raise Exception.Create('/*' + e.Message + '*/' + #13 + e.ErrorMessage);
      end
      else raise;
    end;
  finally
{$IF DEFINED(DEBUG)} OutputDebugString(PWideChar(IdHTTP.Response.RawHeaders.Text)); {$IFEND}
    FreeAndNil(LHandler);
    FreeAndNil(RBody);
    FreeAndNil(IdHTTP);
  end;
end;

class procedure TFuncoesRede.ConfiguracoesProxy(var sServer, sPort, sUser, sPassword: String);
var
  Len : DWORD;
  I, j: Integer;

  function GetProxyServer: String;
  var
    ProxyInfo: PInternetProxyInfo;
  begin
    Result := '';
    Len    := 0;
    if not InternetQueryOption(nil, INTERNET_OPTION_PROXY, nil, Len) then
    begin
      if GetLastError = ERROR_INSUFFICIENT_BUFFER then
      begin
        GetMem(ProxyInfo, Len);
        try
          if InternetQueryOption(nil, INTERNET_OPTION_PROXY, ProxyInfo, Len) then
          begin
            if ProxyInfo^.dwAccessType = INTERNET_OPEN_TYPE_PROXY then
              Result := String(ProxyInfo^.lpszProxy);
          end;
        finally
          FreeMem(ProxyInfo);
        end;
      end;
    end;
  end;

  function GetOptionString(Option: DWORD): String;
  begin
    Len := 0;
    if not InternetQueryOption(nil, Option, nil, Len) then
    begin
      if GetLastError = ERROR_INSUFFICIENT_BUFFER then
      begin
        SetLength(Result, Len);
        if InternetQueryOption(nil, Option, Pointer(Result), Len) then
          Exit;
      end;
    end;

    Result := '';
  end;

begin
  sPort     := '';
  sServer   := GetProxyServer;
  sUser     := GetOptionString(INTERNET_OPTION_PROXY_USERNAME);
  sPassword := GetOptionString(INTERNET_OPTION_PROXY_PASSWORD);

  if sServer <> '' then
  begin
    I := Pos('http=', sServer);
    if I > 0 then
    begin
      Delete(sServer, 1, I + 5);
      j := Pos(';', sServer);
      if j > 0 then
        sServer := Copy(sServer, 1, j - 1);
    end;

    I := Pos(':', sServer);
    if I > 0 then
    begin
      sPort   := Copy(sServer, I + 1, MaxInt);
      sServer := Copy(sServer, 1, I - 1);
    end;
  end;
end;

end.
