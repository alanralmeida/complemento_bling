unit ClassEnviarEmail;

{ Classe destinada ao Envio de E-mails }

interface

uses Classes, Variants, Forms,
  IdMessage, IdSSLOpenSSL, IdSMTP, IdExplicitTLSClientServerBase, IdAttachmentFile, IdText,
  IdUserPassProvider, IdSASLLogin, ClassFuncoesString,

{$IFDEF VER185} // Compatibilidade com FATIND e CONFECCAO (uso no ACBr...)
  SysUtils, ShellAPI, Windows, Registry,
{$ELSE}
{$IFDEF VER230}
  System.AnsiStrings, // suposto xe2 ?
{$ELSE}
  System.AnsiStrings,
{$ENDIF}
  System.SysUtils, Winapi.ShellAPI, Winapi.Windows, System.Win.Registry,
{$ENDIF}
  smtpsend, mimemess, mimepart, synautil, // units para enviar email synapse
  Mapi, // units para enviar email mapi

  ComObj; // units para enviar email MSOutLock

type
  TFormaEnvioEmail = (envioEmailSynapse, envioEmailIndy, envioEmailMapi, envioMSOutlook, envioThunderBird);

  TEnviarEmail = class(TComponent)
  private
    FServidorEmail_Host           : string;
    FServidorEmail_Port           : Integer;
    FServidorEmail_Username       : string;
    FServidorEmail_Password       : string;
    FServidorEmail_EmailSeguro    : Boolean;
    FSolicitarConfirmacaoDeLeitura: Boolean;
    FUsaRemetenteEmailNoFrom      : Boolean;

    FRemetente_Nome       : string;
    FRemetente_Email      : string;
    FDestinatario_Email   : string;
    FDestinatario_EmailCC : string;
    FDestinatario_EmailCCO: string;
    FAssunto              : string;
    FMensagem             : string;
    FMensagemHTML         : string;

    FArquivosAnexados : TStrings;
    FServidorEmail_TLS: Boolean;

    FTempoMaximoConexao: Integer;
    FTempoMaximoLeitura: Integer;
    FAguardarEnvio     : Boolean;
    FEnviandoEmail     : Boolean;
    FEnviado           : Boolean;
    FMensagemErro      : string;

    FFormaEnvio: TFormaEnvioEmail;

    procedure Enviar_Indy;
    procedure Enviar_Synapse;
    procedure Enviar_Mapi;
    procedure Enviar_MSOutlook;
    procedure Enviar_ThunderBird;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure PrepararParaEnviarOutro(LimparRemetente: Boolean = True; LimparAssunto: Boolean = True; LimparArquivosAnexos: Boolean = True);

    procedure Enviar;
    function getDefaultMailerExeName: string;
    function getDefaultMailer: TFormaEnvioEmail;

    property ServidorEmail_Host: string read FServidorEmail_Host write FServidorEmail_Host;
    property ServidorEmail_Port: Integer read FServidorEmail_Port write FServidorEmail_Port;
    property ServidorEmail_Username: string read FServidorEmail_Username write FServidorEmail_Username;
    property ServidorEmail_Password: string read FServidorEmail_Password write FServidorEmail_Password;
    property ServidorEmail_EmailSeguro: Boolean read FServidorEmail_EmailSeguro write FServidorEmail_EmailSeguro;

    property UsaRemetenteEmailNoFrom: Boolean read FUsaRemetenteEmailNoFrom write FUsaRemetenteEmailNoFrom;

    property Remetente_Nome: string read FRemetente_Nome write FRemetente_Nome;
    property Remetente_Email: string read FRemetente_Email write FRemetente_Email;
    property Destinatario_Email: string read FDestinatario_Email write FDestinatario_Email;
    property Destinatario_EmailCC: string read FDestinatario_EmailCC write FDestinatario_EmailCC;
    property Destinatario_EmailCCO: string read FDestinatario_EmailCCO write FDestinatario_EmailCCO;
    property Assunto: string read FAssunto write FAssunto;
    property Mensagem: string read FMensagem write FMensagem;
    property MensagemHTML: string read FMensagemHTML write FMensagemHTML;

    property SolicitarConfirmacaoDeLeitura: Boolean read FSolicitarConfirmacaoDeLeitura write FSolicitarConfirmacaoDeLeitura;

    property TempoMaximoConexao: Integer read FTempoMaximoConexao write FTempoMaximoConexao;
    property TempoMaximoLeitura: Integer read FTempoMaximoLeitura write FTempoMaximoLeitura;
    property FormaEnvio: TFormaEnvioEmail read FFormaEnvio write FFormaEnvio;

    property ArquivosAnexados: TStrings read FArquivosAnexados write FArquivosAnexados;
    property EnviandoEmail: Boolean read FEnviandoEmail;
    property Enviado: Boolean read FEnviado write FEnviado;
    property MensagemErro: String read FMensagemErro write FMensagemErro;

    // synapse apenas
    property ServidorEmail_TLS: Boolean read FServidorEmail_TLS write FServidorEmail_TLS;
    property AguardarEnvio: Boolean read FAguardarEnvio write FAguardarEnvio;
  end;

  TSendMailThread = class(TThread)
  private
    fOwner        : TEnviarEmail;
    FAguardarEnvio: Boolean;
    smtp          : TSMTPSend;
    sFrom         : string;
    sTo           : TStrings;
    sCC           : TStrings;
    slmsg_Lines   : TStrings;
  public
    constructor Create(AOwner: TEnviarEmail; AAguardarEnvio: Boolean);
    destructor Destroy; override;
  protected
    procedure Execute; override;
    procedure ShowException(E: Exception);
  end;

implementation

{$REGION 'TEnviarEmail'}


constructor TEnviarEmail.Create(AOwner: TComponent);
begin
  inherited;
  // Criando lista que vai conter os arquivos a serem anexados
  FArquivosAnexados := TStringList.Create;

  // Configurações Padrões
  FServidorEmail_EmailSeguro := False;
  FServidorEmail_TLS         := False;
  FUsaRemetenteEmailNoFrom   := False;
  FAguardarEnvio             := True;
  FTempoMaximoConexao        := 10 * 1000;
  FTempoMaximoLeitura        := 60 * 1000;
  FFormaEnvio                := envioEmailIndy;
end;

destructor TEnviarEmail.Destroy;
begin
  FreeAndNil(FArquivosAnexados);
  inherited;
end;

procedure TEnviarEmail.PrepararParaEnviarOutro(LimparRemetente: Boolean = True; LimparAssunto: Boolean = True; LimparArquivosAnexos: Boolean = True);
begin
  if LimparRemetente then
  begin
    FRemetente_Nome  := '';
    FRemetente_Email := '';
  end;

  FDestinatario_Email    := '';
  FDestinatario_EmailCC  := '';
  FDestinatario_EmailCCO := '';
  FMensagem              := '';
  FMensagemErro          := '';

  if LimparAssunto then
    FAssunto := '';

  if LimparArquivosAnexos then
    FArquivosAnexados.Clear;
end;

procedure TEnviarEmail.Enviar;
begin
  // Utilizar servidor da Tek-System
  if (FServidorEmail_Host = '') then
  begin
    FServidorEmail_Host        := 'mail.teksystem.com.br';
    FServidorEmail_Port        := 587;
    FServidorEmail_Username    := 'teksystemweb@teksystem.com.br';
    FServidorEmail_Password    := '123tek456';
    FServidorEmail_EmailSeguro := False;
    FServidorEmail_TLS         := False;
    FUsaRemetenteEmailNoFrom   := (FFormaEnvio = envioEmailIndy);
  end;

  FEnviado       := False;
  FEnviandoEmail := True;
  try
    case FFormaEnvio of
      envioEmailSynapse:
        Enviar_Synapse;
      envioEmailIndy:
        Enviar_Indy;
      envioEmailMapi:
        Enviar_Mapi;
      envioMSOutlook:
        Enviar_MSOutlook;
      envioThunderBird:
        Enviar_ThunderBird;
    end;
  finally
    FEnviandoEmail := False;
  end;
end;

{$REGION 'Métodos de Envio'}


procedure TEnviarEmail.Enviar_Indy;
var
  x           : Integer;
  htmpart     : TIdText;
  ArquivoAnexo: TIdAttachmentFile;

  IndSMTP            : TIdSMTP;
  IndSSL             : TIdSSLIOHandlerSocketOpenSSL;
  IndUserPassProvider: TIdUserPassProvider;
  IndSASLLogin       : TIdSASLLogin;
  IndMessage         : TIdMessage;
  // IndProxy: TIdSocksInfo;
begin
  // Configuração da Mensagem de E-mail
  IndSMTP             := TIdSMTP.Create(Self);
  IndSSL              := TIdSSLIOHandlerSocketOpenSSL.Create(Self);
  IndSASLLogin        := TIdSASLLogin.Create(Self);
  IndUserPassProvider := TIdUserPassProvider.Create(Self);
  IndMessage          := TIdMessage.Create(Self);
  // IndProxy            := TIdSocksInfo.Create(Self);
  try
    IndSASLLogin.UserPassProvider := IndUserPassProvider;
    with IndMessage do
    begin
      From.Name := Remetente_Nome;

      // Define qual email será utilizado no from (Erros de envio voltam nesse endereço)
      if FUsaRemetenteEmailNoFrom then
        From.Address := Remetente_Email
      else
        From.Address := FServidorEmail_Username;

      ReplyTo.EMailAddresses := Remetente_Email; // Respostas serão para esse endereço

      Recipients.EMailAddresses := Destinatario_Email;
      CCList.EMailAddresses     := Destinatario_EmailCC;
      BccList.EMailAddresses    := Destinatario_EmailCCO;

      ReceiptRecipient.Text := '';
      if FSolicitarConfirmacaoDeLeitura then
        ReceiptRecipient.Text := Remetente_Email; // Desta forma gera "Disposition-Notification-To:" no cabeçalho da mensagem

      Priority := mpNormal;
      Subject  := FAssunto;

      Body.Clear;
      Body.Add(FMensagem);

      MessageParts.Clear;

      // Adicionando em formato HTML
      if (Trim(FMensagemHTML) <> '') then
      begin
        htmpart             := TIdText.Create(MessageParts);
        htmpart.Body.Text   := FMensagemHTML;
        htmpart.ContentType := 'text/html';
        htmpart.CharSet     := 'iso-8859-1';
      end
      else
      begin
        if FArquivosAnexados.Count = 0 then
          IndMessage.ContentType := 'text/plain; charset=ISO-8859-1'
        else
          IndMessage.ContentType := 'multipart/mixed';
        IndMessage.CharSet       := 'ISO-8859-1';
        IndMessage.Encoding      := meMIME;
      end;

      try
        // Anexando Arquivos
        for x := 0 to FArquivosAnexados.Count - 1 do
        begin
          ArquivoAnexo           := TIdAttachmentFile.Create(MessageParts, TFileName(FArquivosAnexados[x]));
          ArquivoAnexo.ContentID := ExtractFileName(FArquivosAnexados[x]);
        end;
      except
        on E: Exception do
        begin
          FMensagemErro := E.Message;
          raise Exception.Create('Erro ao tentar anexar arquivos na mensagem de e-mail' + #13 + E.Message);
        end;
      end;
    end;

    IndUserPassProvider.Username := FServidorEmail_Username;
    IndUserPassProvider.Password := FServidorEmail_Password;

    // IndProxy.Host := '192.168.254.192';
    // IndProxy.Port := 3128;
    // IndProxy.Authentication := saNoAuthentication;
    // IndProxy.Version        := svSocks5;
    // IndProxy.Username := 'Denis Raymundo';
    // IndProxy.Password := ;

    with IndSSL do
    begin
      Host                   := FServidorEmail_Host;
      Port                   := FServidorEmail_Port;
      ssloptions.Method      := sslvTLSv1; // sslvSSLv2;
      ssloptions.Mode        := sslmUnassigned;
      ssloptions.VerifyMode  := [];
      ssloptions.VerifyDepth := 0;
      // TransparentProxy       := IndProxy;
    end;

    with IndSMTP do
    begin
      // Configuração do Servidor de E-mail
      if FServidorEmail_EmailSeguro then
      begin
        // Associação com o componente já configurado
        IOHandler := IndSSL;

        AuthType := {$IFDEF VER185} atSASL {$ELSE} satSASL {$ENDIF};
        UseTLS   := utUseExplicitTLS; // utUseImplicitTLS; // utUseRequireTLS;   // http://www.indyproject.org/kb/index.html?howdoiuseftpwithssl.htm

        // Associação do mecanismo de SASL
        SASLMechanisms.Add.SASL := IndSASLLogin;
      end
      else
        AuthType := {$IFDEF VER185} atDefault {$ELSE} satDefault {$ENDIF};

      Host     := FServidorEmail_Host;
      Port     := FServidorEmail_Port;
      Username := FServidorEmail_Username;
      Password := FServidorEmail_Password;

      ConnectTimeout := FTempoMaximoConexao;
      ReadTimeout    := FTempoMaximoLeitura;

      try
        // Abrindo conexão
        if (not Connected) then
          Connect();

        // Autenticando e Enviando a mensagem
        Send(IndMessage);

        FEnviado := True;

        Disconnect(True);
      except
        on E: Exception do
        begin
          FMensagemErro := E.Message;
          raise Exception.Create('Erro ao tentar enviar e-mail' + #13 + E.Message);
        end;
      end;
    end;
  finally
    FreeAndNil(IndMessage);
    FreeAndNil(IndUserPassProvider);
    FreeAndNil(IndSASLLogin);
    FreeAndNil(IndSSL);
    // FreeAndNil(IndProxy);
    FreeAndNil(IndSMTP);
  end;
end;

procedure TEnviarEmail.Enviar_Synapse;
var
  ThreadSMTP  : TSendMailThread;
  m           : TMimemess;
  MultiPartMix: TMimePart;
  i           : Integer;
  sMensagem   : TStrings;
  StreamString: TStringStream;
  FileStream  : TFileStream;
  ListaMailTo : TStrings;
begin
  // Atenção: se a propriedade AguardarEnvio = False:
  // - Se o local onde TEnviarEmail foi criado é destruido antes do termino do envio do e-mail a thread tambem será destruida e o e-mail não será enviado
  // - Mensagens de erros podem não ser evidenciados
  // - A variável de enviado não é consistente
  // - Não deve ser usado assim no servidor, pois a mensagem de erro é do tipo ShowException e não Raise (não é repassado para o cliente, da no servidor)

  // Trocar ponto e virgula por virgula, apesar da Microsoft adotar o ponto e virgula como delimitador no outlook
  Destinatario_Email    := StringReplace(Destinatario_Email, ';', ',', [rfReplaceAll]);
  Destinatario_EmailCC  := StringReplace(Destinatario_EmailCC, ';', ',', [rfReplaceAll]);
  Destinatario_EmailCCO := StringReplace(Destinatario_EmailCCO, ';', ',', [rfReplaceAll]);

  ListaMailTo := TStringList.Create;
  sMensagem   := TStringList.Create;
  m           := TMimemess.Create;

  ThreadSMTP := TSendMailThread.Create(Self, FAguardarEnvio); // Não Libera, pois usa FreeOnTerminate := True ;
  try
    MultiPartMix := m.AddPartMultipart('mixed', nil);

    // Adicionando em formato HTML
    if (Trim(FMensagemHTML) <> '') then
    begin
      sMensagem.Clear;
      sMensagem.Add(FMensagemHTML);
      m.AddPartHTML(sMensagem, MultiPartMix);
      m.EncodeMessage;
    end
    else if Trim(Mensagem) <> '' then
    begin
      sMensagem.Clear;
      sMensagem.Add(Mensagem);
      m.AddPartText(sMensagem, MultiPartMix);
    end;
    FMensagemErro := '';

    if Assigned(ArquivosAnexados) then
      for i := 0 to ArquivosAnexados.Count - 1 do
        if FileExists(ArquivosAnexados[i]) then
        begin
          FileStream := TFileStream.Create(ArquivosAnexados[i], fmOpenRead or fmShareDenyNone);
          try
            StreamString := TStringStream.Create('');
            try
              StreamString.CopyFrom(FileStream, FileStream.Size);
              m.AddPartBinary(StreamString, ExtractFileName(ArquivosAnexados[i]), MultiPartMix);
            finally
              FreeAndNil(StreamString);
            end;
          finally
            FreeAndNil(FileStream);
          end;
        end;

    ListaMailTo.Clear;
    synautil.ParseParametersEx(Destinatario_Email, ',', ListaMailTo);

    m.header.tolist.Clear;
    for i := 0 to ListaMailTo.Count - 1 do
      m.header.tolist.Add(ListaMailTo[i]);

    m.header.Subject := Assunto;

    if Trim(Remetente_Nome) <> '' then
      m.header.From := Format('%s<%s>', [Remetente_Nome, Remetente_Email])
    else
      m.header.From := Remetente_Email;

    m.header.ReplyTo := Remetente_Email;

    if SolicitarConfirmacaoDeLeitura then
      m.header.CustomHeaders.Add('Disposition-Notification-To: ' + Remetente_Email);
    m.EncodeMessage;

    ThreadSMTP.sFrom := Remetente_Email;

    ThreadSMTP.sTo.Clear;
    for i := 0 to ListaMailTo.Count - 1 do
      ThreadSMTP.sTo.Add(ListaMailTo[i]);

    // copia para...
    if Destinatario_EmailCC <> '' then
    begin
      ListaMailTo.Clear;
      synautil.ParseParametersEx(Destinatario_EmailCC, ',', ListaMailTo);
      for i := 0 to ListaMailTo.Count - 1 do
        ThreadSMTP.sCC.Add(ListaMailTo[i]);
    end;

    if Destinatario_EmailCCO <> '' then
    begin
      ListaMailTo.Clear;
      synautil.ParseParametersEx(Destinatario_EmailCCO, ',', ListaMailTo);
      for i := 0 to ListaMailTo.Count - 1 do
        ThreadSMTP.sCC.Add(ListaMailTo[i]);
    end;

    ThreadSMTP.slmsg_Lines.AddStrings(m.Lines);

    ThreadSMTP.smtp.Username   := ServidorEmail_Username;
    ThreadSMTP.smtp.Password   := ServidorEmail_Password;
    ThreadSMTP.smtp.TargetHost := ServidorEmail_Host;

    if ServidorEmail_Port > 0 then
      ThreadSMTP.smtp.TargetPort := IntToStr(ServidorEmail_Port)
    else
      ThreadSMTP.smtp.TargetPort := '25'; // Usa default

    ThreadSMTP.smtp.FullSSL := ServidorEmail_EmailSeguro;
    ThreadSMTP.smtp.AutoTLS := ServidorEmail_TLS;

    // inicia a thread
{$IF DEFINED (VER185)}
    ThreadSMTP.Resume;
{$ELSE}
    ThreadSMTP.Start;
{$IFEND}
    if AguardarEnvio then
    begin
      repeat
        Sleep(100);
        Application.ProcessMessages;
      until ThreadSMTP.Terminated;

      if (FMensagemErro <> '') then
        raise Exception.Create(FMensagemErro);
    end;
    FEnviado := True;
  finally
    FreeAndNil(m);
    FreeAndNil(sMensagem);
    FreeAndNil(ListaMailTo);
  end;
end;

procedure TEnviarEmail.Enviar_Mapi;
var
  i: Integer;

  MError             : Cardinal;
  MapiMessage        : TMapiMessage;
  Sender             : TMapiRecipDesc;
  PRecip, Recipients : PMapiRecipDesc;
  PFiles, Attachments: PMapiFileDesc;
begin
  PFiles := nil;
  // Application.Handle := Application.Handle;

  MapiMessage.nRecipCount := 1;
  GetMem(Recipients, MapiMessage.nRecipCount * sizeof(TMapiRecipDesc));
  try
    with MapiMessage do
    begin
      ulReserved         := 0;
      lpszSubject        := PAnsiChar(AnsiString(Assunto));
      lpszNoteText       := PAnsiChar(AnsiString(Mensagem));
      lpszMessageType    := nil;
      lpszDateReceived   := nil;
      lpszConversationID := nil;
      flFlags            := 0;

      Sender.ulReserved   := 0;
      Sender.ulRecipClass := MAPI_ORIG;
      Sender.lpszName     := PAnsiChar(AnsiString(''));
      Sender.lpszAddress  := PAnsiChar(AnsiString(''));
      Sender.ulEIDSize    := 0;
      Sender.lpEntryID    := nil;
      lpOriginator        := @Sender;

      PRecip               := Recipients;
      PRecip^.ulReserved   := 0;
      PRecip^.ulRecipClass := MAPI_TO;
      PRecip^.lpszName     := PAnsiChar(AnsiString(Destinatario_Email));
{$IFDEF VER185}
      PRecip^.lpszAddress := SysUtils.StrNew(PAnsiChar(AnsiString('SMTP:' + Destinatario_Email)));
{$ELSE}
      PRecip^.lpszAddress := {$IFDEF VER230} System.SysUtils {$ELSE} System.AnsiStrings {$ENDIF} .StrNew(PAnsiChar(AnsiString('SMTP:' + Destinatario_Email)));
{$ENDIF}
      PRecip^.ulEIDSize := 0;
      PRecip^.lpEntryID := nil;
      // Inc(PRecip);
      lpRecips := Recipients;

      nFileCount := 1;
      GetMem(Attachments, nFileCount * sizeof(TMapiFileDesc));
      PFiles := Attachments;
      if Assigned(ArquivosAnexados) then
        for i := 0 to ArquivosAnexados.Count - 1 do
          if FileExists(ArquivosAnexados[i]) then
          begin
            Attachments^.lpszPathName := PAnsiChar(AnsiString(ArquivosAnexados[i]));
            Attachments^.lpszFileName := PAnsiChar(AnsiString(ExtractFileName(ArquivosAnexados[i])));
            Attachments^.ulReserved   := 0;
            Attachments^.flFlags      := 0;
            Attachments^.nPosition    := Cardinal(-1);
            Attachments^.lpFileType   := nil;
            Inc(Attachments);
          end;
      lpFiles := PFiles;
    end;

    MError := MapiSendMail(0, Application.Handle, MapiMessage, MAPI_DIALOG or MAPI_LOGON_UI or MAPI_NEW_SESSION, 0);

    case MError of
      SUCCESS_SUCCESS:
        FEnviado := True;
      MAPI_E_USER_ABORT:
        begin
          FMensagemErro := 'Operação abortada pelo usuário';
          raise Exception.Create(FMensagemErro);
        end
    else
      begin
        FMensagemErro := 'Ocorreu um erro inesperado!' + #13 + 'Código: ' + IntToStr(MError);
        raise Exception.Create(FMensagemErro);
      end;
    end;
  finally
    PRecip := Recipients;
{$IFDEF VER185} // Compatibilidade com FATIND e CONFECCAO (uso no ACBr...)
    SysUtils.StrDispose(PRecip^.lpszAddress);
{$ELSE}
{$IFDEF VER230} System.SysUtils {$ELSE} System.AnsiStrings {$ENDIF} .StrDispose(PRecip^.lpszAddress);
{$ENDIF}
    // Inc(PRecip);
    FreeMem(Recipients, MapiMessage.nRecipCount * sizeof(TMapiRecipDesc));

    if Assigned(PFiles) then
      FreeMem(PFiles, MapiMessage.nFileCount * sizeof(TMapiFileDesc));

    // Application.Handle := 0;
  end;
end;

procedure TEnviarEmail.Enviar_MSOutlook;
const
  olMailItem = 0;
  olFormatHTML = 2;
var
  i       : Integer;
  Outlook : OLEVariant;
  MailItem: Variant;
begin
  try
    Outlook := GetActiveOleObject('Outlook.Application');
  except
    try
      Outlook := CreateOleObject('Outlook.Application');
    except
      on E: Exception do
      begin
        FMensagemErro := 'Não é possível acessar a Microsoft Outlook.' + #13 + 'Mensagem Original: ' + E.Message;
        raise Exception.Create(FMensagemErro);
      end;
    end;
  end;

  MailItem         := Outlook.CreateItem(olMailItem);
  MailItem.Subject := Assunto;

  MailItem.Recipients.Add(Destinatario_Email);
  MailItem.CC  := Destinatario_EmailCC;
  MailItem.BCC := Destinatario_EmailCCO;

  if FMensagemHTML <> '' then
  begin
    MailItem.BodyFormat := olFormatHTML;
    MailItem.HTMLBody := FMensagemHTML;
  end else
    MailItem.Body := FMensagem;

  if Assigned(ArquivosAnexados) then
    for i := 0 to ArquivosAnexados.Count - 1 do
      if FileExists(ArquivosAnexados[i]) then
        MailItem.Attachments.Add(ArquivosAnexados[i]);

  if FAguardarEnvio then
  begin
    MailItem.GetInspector.Activate;
    MailItem.Display(False);
    VarClear(Outlook);
  end
  else
  begin
    MailItem.Send;
    Outlook := Unassigned;
  end;

  FEnviado := True;
end;

procedure TEnviarEmail.Enviar_ThunderBird;
var
  i                                                        : Integer;
  tpDestinatario, tpAssunto, tpMensagem, tpAnexos, tpParams: string;
begin
  tpDestinatario := TFuncoesString.Deletar(Destinatario_Email, '"''');
  tpAssunto      := TFuncoesString.Deletar(Assunto, '"''');
  tpMensagem     := TFuncoesString.Deletar(FMensagem, '"''');

  tpAnexos := EmpTyStr;
  if Assigned(ArquivosAnexados) then
  begin
    for i := 0 to ArquivosAnexados.Count - 1 do
    begin
      if FileExists(ArquivosAnexados[i]) then
        tpAnexos := tpAnexos + ArquivosAnexados[i];

      if i < ArquivosAnexados.Count - 1 then
        tpAnexos := tpAnexos + ',';
    end;

    tpAnexos := TFuncoesString.Deletar(tpAnexos, '"''');
  end;

  tpParams := EmpTyStr;
  tpParams := tpParams + '-compose "format=2,';
  tpParams := tpParams + 'to=' + QuotedStr(tpDestinatario);
  tpParams := tpParams + ',subject=' + QuotedStr(tpAssunto);
  tpParams := tpParams + ',body=' + QuotedStr(tpMensagem);
  tpParams := tpParams + ',attachment=' + QuotedStr(tpAnexos);
  tpParams := tpParams + '"';

  // exemplo completo da estrutura do comando conforme a Mozilla: http://kb.mozillazine.org/Command_line_arguments_(Thunderbird)
  // thunderbird -compose "format=2,to='john@example.com,kathy@example.com',cc='britney@example.com',subject='dinner',body='How about dinner tonight?',attachment='C:\temp\info.doc,C:\temp\food.doc'"

  ShellExecute(0, nil, PChar(getDefaultMailerExeName), PChar(tpParams), PChar(ExtractFilePath(Application.ExeName)), SW_SHOWNORMAL);
end;

{$ENDREGION}

{$ENDREGION}

{$REGION 'TSendMailThread'}


constructor TSendMailThread.Create(AOwner: TEnviarEmail; AAguardarEnvio: Boolean);
begin
  fOwner         := AOwner;
  FAguardarEnvio := AAguardarEnvio;
  smtp           := TSMTPSend.Create;
  slmsg_Lines    := TStringList.Create;
  sCC            := TStringList.Create;
  sFrom          := '';
  sTo            := TStringList.Create;

  FreeOnTerminate := True;

  inherited Create(True);
end;

destructor TSendMailThread.Destroy;
begin
  FreeAndNil(slmsg_Lines);
  FreeAndNil(sCC);
  FreeAndNil(smtp);
  FreeAndNil(sTo);
  inherited;
end;

procedure TSendMailThread.Execute;
var
  i: Integer;
begin
  inherited;
  try
    try
      if not smtp.Login() then
        raise Exception.Create('SMTP ERROR: Login:' + smtp.EnhCodeString + sLineBreak + smtp.FullResult.Text);

      if not smtp.MailFrom(sFrom, Length(sFrom)) then
        raise Exception.Create('SMTP ERROR: MailFrom:' + smtp.EnhCodeString + sLineBreak + smtp.FullResult.Text);

      for i := 0 to sTo.Count - 1 do
        if not smtp.MailTo(sTo[i]) then
          raise Exception.Create('SMTP ERROR: MailTo:' + smtp.EnhCodeString + sLineBreak + smtp.FullResult.Text);

      if (sCC <> nil) then
      begin
        for i := 0 to sCC.Count - 1 do
          if not smtp.MailTo(sCC.Strings[i]) then
            raise Exception.Create('SMTP ERROR: MailTo:' + smtp.EnhCodeString + sLineBreak + smtp.FullResult.Text);
      end;

      if not smtp.MailData(slmsg_Lines) then
        raise Exception.Create('SMTP ERROR: MailData:' + smtp.EnhCodeString + sLineBreak + smtp.FullResult.Text);

      if not smtp.Logout() then
        raise Exception.Create('SMTP ERROR: Logout:' + smtp.EnhCodeString + sLineBreak + smtp.FullResult.Text);
    finally
      try
        smtp.Sock.CloseSocket;
      except
      end;
      Terminate;
    end;
  except
    on E: Exception do
    begin
      if FAguardarEnvio then
        fOwner.MensagemErro := E.Message
      else
      begin
        ShowException(E);
      end;
    end;
  end;
end;

procedure TSendMailThread.ShowException(E: Exception);
begin
{$IF NOT DEFINED(VER185)}
  Synchronize(
    procedure
    begin
      if E is Exception then
        Application.ShowException(E)
      else
        System.SysUtils.ShowException(E, nil);
    end);
{$IFEND}
end;

{$ENDREGION}


function TEnviarEmail.getDefaultMailerExeName: string;
const
  Mailer = '\mailto\shell\open\command';
var
  tpResult: string;
  tpReg   : TRegistry;
begin
  tpResult := EmpTyStr;
  tpReg    := TRegistry.Create;

  try
    tpReg.RootKey := HKEY_CLASSES_ROOT;
    if tpReg.OpenKeyReadOnly(Mailer) then
    begin
      tpResult := tpReg.ReadString('');
      while (Pos('\', tpResult) > 0) do
        Delete(tpResult, 1, Pos('\', tpResult));

      if (Pos('.exe', tpResult) > 0) then
        Delete(tpResult, Pos('.exe', tpResult) + 4, Length(tpResult));
    end;
    tpReg.CloseKey;
  finally
    tpReg.Free;
  end;

  Result := tpResult;
end;

function TEnviarEmail.getDefaultMailer: TFormaEnvioEmail;
var
  tpStr: string;
begin
  Result := envioEmailIndy;

  tpStr := AnsiUpperCase(getDefaultMailerExeName);
  if Pos('OUTLOOK', tpStr) > 0 then
    Result := envioMSOutlook
  else if Pos('THUNDERBIRD', tpStr) > 0 then
    Result := envioThunderBird;
end;

end.
