unit Service.TaskTime;

interface

uses
  Service.GenericObject, Service.Thread.Generic, Service.DTO.Pri_PontoEntrada, Service.DTO.Pri_PontoEntrada_Agenda,
  System.Generics.Collections, System.Classes;

type
  TDecodedDateTime = record
    Ano      : Word;
    Mes      : Word;
    Dia      : Word;
    Hora     : Word;
    Minuto   : Word;
    Segundo  : Word;
    MSegundo : Word;
    Semana   : Word;
  end;

  TTaskTime = class(TGenericObject)
  private
    FThread           : TGenericThread;
    FTaskNova         : Boolean;
    FDto              : TPri_PontoEntradaDTO;
    FDtoAgenda        : TObjectList<TPri_PontoEntrada_AgendaDTO>;
    FDtoAgendaProxima : TPri_PontoEntrada_AgendaDTO;
    FProximaExecucao  : TDateTime;
    FArqMem           : TStringList;
    FArqMemPath       : String;

    const ARQ_MEM = 'priorizeservice.mem';

    function GetExecutar : Boolean;
    function GetExecutarPeriodico : Boolean;
    function GetExecutarAgendado : Boolean;
    function VerificarUltimaExecAgendado(ADtoAgenda : TPri_PontoEntrada_AgendaDTO; ADataHoraAtual : TDecodedDateTime) : Boolean;
    function VerificarExecAgendado(ADtoAgenda : TPri_PontoEntrada_AgendaDTO; ADataHoraAtual : TDecodedDateTime) : Boolean;
    function RemoverSegundos(const AValor : TDateTime) : TDateTime;
    procedure CarregarMem;
    procedure SalvarMem(ADtoAgenda : TPri_PontoEntrada_AgendaDTO);
    function VerificarMem(ADtoAgenda : TPri_PontoEntrada_AgendaDTO; out ADataMen : TDateTime) : Boolean;
  public
    property Thread           : TGenericThread                           read FThread           write FThread;
    property TaskNova         : Boolean                                  read FTaskNova;
    property Dto              : TPri_PontoEntradaDTO                     read FDto;
    property DtoAgenda        : TObjectList<TPri_PontoEntrada_AgendaDTO> read FDtoAgenda;
    property DtoAgendaProxima : TPri_PontoEntrada_AgendaDTO              read FDtoAgendaProxima;
    property ProximaExecucao  : TDateTime                                read FProximaExecucao;
    property Executar         : Boolean                                  read GetExecutar;

    procedure CalcularProximaExecucao;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.DateUtils, System.Types, System.SysUtils;

{ TTaskTime }

procedure TTaskTime.CalcularProximaExecucao;
begin
  FTaskNova := False;

  if DtoAgenda.First.Tipo = TTipoAgenda.Periodico then
  begin
    FDtoAgendaProxima := DtoAgenda.First;
    FProximaExecucao  := IncHour(IncMinute(Now, StrToIntDef(DtoAgendaProxima.Minuto, 0)), StrToIntDef(DtoAgendaProxima.Hora, 0));
    FProximaExecucao  := RemoverSegundos(FProximaExecucao);
  end;
end;

procedure TTaskTime.CarregarMem;
begin
  if (FArqMem.Text.IsEmpty) and (FileExists(FArqMemPath)) then
  begin
    FArqMem.LoadFromFile(FArqMemPath);
  end;
end;

constructor TTaskTime.Create;
begin
  inherited;

  FThread           := nil;
  FTaskNova         := True;
  FDto              := TPri_PontoEntradaDTO.Create;
  FDtoAgenda        := TObjectList<TPri_PontoEntrada_AgendaDTO>.Create;
  FDtoAgendaProxima := nil;
  FArqMem           := TStringList.Create;
  FArqMemPath       := ExtractFileDir(ParamStr(0)) + PathDelim + ARQ_MEM;
end;

destructor TTaskTime.Destroy;
begin
  System.SysUtils.FreeAndNil(FDto);
  System.SysUtils.FreeAndNil(FDtoAgenda);
  System.SysUtils.FreeAndNil(FArqMem);

  inherited;
end;

function TTaskTime.GetExecutar: Boolean;
begin
  Result := False;

  case DtoAgenda.First.Tipo of
    TTipoAgenda.Agendado  : Result := GetExecutarAgendado;
    TTipoAgenda.Periodico : Result := GetExecutarPeriodico;
  end;
end;

function TTaskTime.GetExecutarAgendado: Boolean;
var
  PriPontoEntradaAgenda : TPri_PontoEntrada_AgendaDTO;
  DhAtual               : TDecodedDateTime;
begin
  Result            := False;
  FDtoAgendaProxima := nil;

  DecodeDateTime(Now, DhAtual.Ano, DhAtual.Mes, DhAtual.Dia, DhAtual.Hora, DhAtual.Minuto, DhAtual.Segundo, DhAtual.MSegundo);
  DhAtual.Semana := DayOfTheWeek(Date);

  for PriPontoEntradaAgenda in DtoAgenda do
  begin
    if not VerificarExecAgendado(PriPontoEntradaAgenda, DhAtual) then
    begin
      Continue;
    end;

    if not VerificarUltimaExecAgendado(PriPontoEntradaAgenda, DhAtual) then
    begin
      Continue;
    end;

    SalvarMem(PriPontoEntradaAgenda);
    FDtoAgendaProxima := PriPontoEntradaAgenda;
    Result := True;
  end;
end;

function TTaskTime.GetExecutarPeriodico: Boolean;
var
  DataHoraMem : TDateTime;
begin
  Result := False;

  if CompareDate(Date, FProximaExecucao) = EqualsValue then
  begin
    if (HourOf(FProximaExecucao) = HourOf(Time)) and (MinuteOf(FProximaExecucao) = MinuteOf(Time)) then
    begin
      if VerificarMem(FDtoAgendaProxima, DataHoraMem) then
      begin
        if (HourOf(DataHoraMem) = HourOf(Time)) and (MinuteOf(DataHoraMem) = MinuteOf(Time)) then
        begin
          Exit;
        end;
      end;

      SalvarMem(FDtoAgendaProxima);
      Result := True;
    end;
  end;
end;

function TTaskTime.RemoverSegundos(const AValor: TDateTime): TDateTime;
var
  Valor : TDecodedDateTime;
begin
  DecodeDateTime(AValor, Valor.Ano, Valor.Mes, Valor.Dia, Valor.Hora, Valor.Minuto, Valor.Segundo, Valor.MSegundo);
  Result := EncodeDateTime(Valor.Ano, Valor.Mes, Valor.Dia, Valor.Hora, Valor.Minuto, 0, 0);
end;

procedure TTaskTime.SalvarMem(ADtoAgenda: TPri_PontoEntrada_AgendaDTO);
var
  I     : Integer;
  Texto : String;
begin
  CarregarMem;

  Texto := IntToStr(ADtoAgenda.PkPontoEntrada_Agenda) + '=' + DateTimeToStr(RemoverSegundos(Now));

  for I := 0 to FArqMem.Count -1 do
  begin
    if FArqMem.Strings[I] = Texto then
    begin
      Exit;
    end;

    if FArqMem.Strings[I].Split(['='])[0] = IntToStr(ADtoAgenda.PkPontoEntrada_Agenda) then
    begin
      FArqMem.Delete(I);
      Break;
    end;
  end;

  FArqMem.Add(Texto);
  FArqMem.SaveToFile(FArqMemPath);
end;

function TTaskTime.VerificarExecAgendado(ADtoAgenda: TPri_PontoEntrada_AgendaDTO; ADataHoraAtual: TDecodedDateTime): Boolean;
begin
  Result := True;

  if (ADtoAgenda.Mes <> '*') and (ADataHoraAtual.Mes <> StrToInt(ADtoAgenda.Mes)) then
  begin
    Exit(False);
  end;

  if (ADtoAgenda.Dia <> '*') and (ADataHoraAtual.Dia <> StrToInt(ADtoAgenda.Dia)) then
  begin
    Exit(False);
  end;

  if (ADtoAgenda.DiaSemana <> '*') and (ADataHoraAtual.Semana <> StrToInt(ADtoAgenda.DiaSemana)) then
  begin
    Exit(False);
  end;

  if (ADtoAgenda.Hora <> '*') and (ADataHoraAtual.Hora <> StrToInt(ADtoAgenda.Hora)) then
  begin
    Exit(False);
  end;

  if (ADtoAgenda.Minuto <> '*') and (ADataHoraAtual.Minuto <> StrToInt(ADtoAgenda.Minuto)) then
  begin
    Exit(False);
  end;
end;

function TTaskTime.VerificarMem(ADtoAgenda: TPri_PontoEntrada_AgendaDTO; out ADataMen: TDateTime): Boolean;
var
  I     : Integer;
  Linha : TArray<String>;
begin
  Result   := False;
  ADataMen := 0;

  CarregarMem;

  for I := 0 to FArqMem.Count -1 do
  begin
    Linha := FArqMem.Strings[I].Split(['=']);

    if Linha[0] = IntToStr(ADtoAgenda.PkPontoEntrada_Agenda) then
    begin
      ADataMen := StrToDateTimeDef(Linha[1], 0);
      Exit(True);
    end;
  end;
end;

function TTaskTime.VerificarUltimaExecAgendado(ADtoAgenda: TPri_PontoEntrada_AgendaDTO; ADataHoraAtual: TDecodedDateTime): Boolean;
var
  DataHora : TDateTime;
  DhMem    : TDecodedDateTime;
begin
  Result := False;

  if VerificarMem(ADtoAgenda, DataHora) then
  begin
    DecodeDateTime(DataHora, DhMem.Ano, DhMem.Mes, DhMem.Dia, DhMem.Hora, DhMem.Minuto, DhMem.Segundo, DhMem.MSegundo);

    if ADataHoraAtual.Ano <> DhMem.Ano then
    begin
      Exit(True);
    end;

    if ADataHoraAtual.Mes <> DhMem.Mes then
    begin
      Exit(True);
    end;

    if ADataHoraAtual.Dia <> DhMem.Dia then
    begin
      Exit(True);
    end;

    if ADataHoraAtual.Hora <> DhMem.Hora then
    begin
      Exit(True);
    end;
  end
  else
  begin
    Exit(True);
  end;
end;

end.
