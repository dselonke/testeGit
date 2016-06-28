unit Service.Log;

interface

uses
  Service.GenericObject;

type
  TTipoLog = (Info, Erro);

  TLog = class(TGenericObject)
  private
    FArquivoLog : String;

    procedure GerenciarArquivoLog;
  public
    procedure Escrever(AObject : TObject; Tipo : TTipoLog; const Msg : String; Log : Boolean = True);

    constructor Create(AArquivoLog : String);
  end;

implementation

uses
  {$IFDEF MSWINDOWS}Winapi.Windows,{$ENDIF} System.SysUtils, UPri_CaracterUtils, System.TypInfo;

{ TLog }

constructor TLog.Create(AArquivoLog: String);
begin
  inherited Create;

  FArquivoLog := AArquivoLog;

  GerenciarArquivoLog;
end;

procedure TLog.Escrever(AObject: TObject; Tipo: TTipoLog; const Msg: String; Log: Boolean);
const
  SEPARADOR = ' | ';
var
  Texto            : String;
  PriCaracterUtils : TPri_CaracterUtils;
  FormatSettings   : TFormatSettings;
  Arq              : TextFile;
begin
  PriCaracterUtils := nil;
  FormatSettings   := TFormatSettings.Create('pt-BR');

  try
    PriCaracterUtils := TPri_CaracterUtils.Create;

    Texto := PriCaracterUtils.PreencherString(AObject.ClassName, 16, TTipoPreencher.tpEspaco, TTipoAlinhar.taEsquerda) + ': '
             + PriCaracterUtils.PreencherString(IntToStr(GetCurrentThreadId), 4, TTipoPreencher.tpEspaco, TTipoAlinhar.taEsquerda)
             + SEPARADOR + DateToStr(Now, FormatSettings) + SEPARADOR + TimeToStr(Time, FormatSettings) + SEPARADOR
             + GetEnumName(TypeInfo(TTipoLog), Integer(Tipo)) + SEPARADOR + Msg;

    Writeln(Texto);

    if (Log) and (not FArquivoLog.IsEmpty) then
    begin
      AssignFile(Arq, FArquivoLog);

      if FileExists(FArquivoLog) then
      begin
        Append(Arq);
      end
      else
      begin
        Rewrite(Arq);
      end;

      try
        Writeln(Arq, Texto);
        Flush(Arq);
      finally
        CloseFile(Arq);
      end;
    end;
  finally
    System.SysUtils.FreeAndNil(PriCaracterUtils);
  end;
end;

procedure TLog.GerenciarArquivoLog;
var
  Arq        : File of byte;
  TamanhoArq : Double;
  ArquivoBak : String;
begin
  if FArquivoLog.IsEmpty then
  begin
    Exit;
  end;

  FArquivoLog := ExtractFileDir(ParamStr(0)) + PathDelim + FArquivoLog;
  AssignFile(Arq, FArquivoLog);

  try
    if FileExists(FArquivoLog) then
    begin
      Reset(Arq);
    end
    else
    begin
      Rewrite(Arq);
    end;

    CloseFile(Arq);
  except
    Escrever(Self, TTipoLog.Info, Format('O arquivo de log configurado não tem permissão de escrita ou possui um caminho inválido%sArquivo: %s', [sLineBreak, FArquivoLog]), False);
    FArquivoLog := EmptyStr;
    Exit;
  end;

  if FileExists(FArquivoLog) then
  begin
    Reset(Arq);

    try
      TamanhoArq := (FileSize(Arq) / 1024 / 1024);
    finally
      CloseFile(Arq);
    end;

    if (TamanhoArq) > 50 then
    begin
      Escrever(Self, TTipoLog.Info, Format('O arquivo de log atingiu o tamanho de %dmb e será limpado', [Round(TamanhoArq)]));

      ArquivoBak := FArquivoLog + '.bak';

      if FileExists(ArquivoBak) then
      begin
        DeleteFile(ArquivoBak);
      end;

      RenameFile(FArquivoLog, ArquivoBak);
    end;
  end;
end;

end.
