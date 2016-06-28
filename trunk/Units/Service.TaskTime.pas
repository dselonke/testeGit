unit Service.TaskTime;

interface

uses
  Service.GenericObject, Service.Thread.Generic, Service.DTO.Pri_PontoEntrada, Service.DTO.Pri_PontoEntrada_Agenda,
  System.Generics.Collections;

type
  TTaskTime = class(TGenericObject)
  private
    FThread           : TGenericThread;
    FTaskNova         : Boolean;
    FDto              : TPri_PontoEntradaDTO;
    FDtoAgenda        : TObjectList<TPri_PontoEntrada_AgendaDTO>;
    FDtoAgendaProxima : TPri_PontoEntrada_AgendaDTO;
    FProximaExecucao  : TDateTime;

    function GetExecutar : Boolean;
    function GetExecutarPeriodico : Boolean;
    function GetExecutarAgendado : Boolean;
    function RemoverSegundos(const AValor : TDateTime) : TDateTime;
  public
    property Thread           : TGenericThread                           read FThread   write FThread;
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
  System.DateUtils, System.SysUtils, System.Types;

{ TTaskTime }

procedure TTaskTime.CalcularProximaExecucao;
begin
  FTaskNova := False;

  if DtoAgenda[0].Tipo = TTipoAgenda.Periodico then
  begin
    FDtoAgendaProxima := DtoAgenda[0];
    FProximaExecucao  := IncHour(IncMinute(Now, StrToIntDef(DtoAgendaProxima.Minuto, 0)), StrToIntDef(DtoAgendaProxima.Hora, 0));
    FProximaExecucao  := RemoverSegundos(FProximaExecucao);
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
end;

destructor TTaskTime.Destroy;
begin
  System.SysUtils.FreeAndNil(FThread);
  System.SysUtils.FreeAndNil(FDto);
  System.SysUtils.FreeAndNil(FDtoAgenda);

  inherited;
end;

function TTaskTime.GetExecutar: Boolean;
begin
  Result := False;

  case DtoAgenda[0].Tipo of
    TTipoAgenda.Agendado  : Result := GetExecutarAgendado;
    TTipoAgenda.Periodico : Result := GetExecutarPeriodico;
  end;
end;

function TTaskTime.GetExecutarAgendado: Boolean;
var
  Ano                   : Word;
  Mes                   : Word;
  Dia                   : Word;
  Hora                  : Word;
  Minuto                : Word;
  Segundo               : Word;
  MSegundo              : Word;
  PriPontoEntradaAgenda : TPri_PontoEntrada_AgendaDTO;
begin
  Result := False;

  DecodeDateTime(Now, Ano, Mes, Dia, Hora, Minuto, Segundo, MSegundo);

  for PriPontoEntradaAgenda in DtoAgenda do
  begin
    if (PriPontoEntradaAgenda.Mes = '*') or (Mes = StrToInt(PriPontoEntradaAgenda.Mes)) then
    begin
      if (PriPontoEntradaAgenda.Dia = '*') or (Dia = StrToInt(PriPontoEntradaAgenda.Dia)) then
      begin
        if (PriPontoEntradaAgenda.DiaSemana = '*') or (DayOfTheWeek(Date) = StrToInt(PriPontoEntradaAgenda.DiaSemana)) then
        begin
          if (PriPontoEntradaAgenda.Hora = '*') or (Hora = StrToInt(PriPontoEntradaAgenda.Hora)) then
          begin
            if (PriPontoEntradaAgenda.Minuto = '*') or (Minuto = StrToInt(PriPontoEntradaAgenda.Minuto)) then
            begin
              FDtoAgendaProxima := PriPontoEntradaAgenda;
              Result := True;
            end;
          end;
        end;
      end;
    end;
  end;
end;

function TTaskTime.GetExecutarPeriodico: Boolean;
var
  Hora     : Word;
  Minuto   : Word;
  Segundo  : Word;
  MSegundo : Word;
begin
  Result := False;

  if CompareDate(Date, FProximaExecucao) = EqualsValue then
  begin
    DecodeTime(FProximaExecucao, Hora, Minuto, Segundo, MSegundo);

    if (Hora = HourOf(Time)) and (Minuto = MinuteOf(Time)) then
    begin
      Result := True;
    end;
  end;
end;

function TTaskTime.RemoverSegundos(const AValor: TDateTime): TDateTime;
var
  Ano      : Word;
  Mes      : Word;
  Dia      : Word;
  Hora     : Word;
  Minuto   : Word;
  Segundo  : Word;
  MSegundo : Word;
begin
  DecodeDateTime(AValor, Ano, Mes, Dia, Hora, Minuto, Segundo, MSegundo);
  Result := EncodeDateTime(Ano, Mes, Dia, Hora, Minuto, 0, 0);
end;

end.
