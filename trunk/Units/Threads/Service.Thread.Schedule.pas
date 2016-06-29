unit Service.Thread.Schedule;

interface

uses
  Service.Thread.Generic, System.Generics.Collections, Service.TaskTime, Service.Parametros, Service.Log;

type
  TScheduleThread = class(TGenericThread)
  private
    FLista          : TObjectList<TTaskTime>;
    FListaPendentes : TObjectList<TTaskTime>;
    FParametros     : TParametros;
    FLog            : TLog;

    procedure CarregarTasks;
    procedure ExecutarPA(TaskTime : TTaskTime);
    procedure FinalizarPA(TaskTime : TTaskTime);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;

    procedure OnTerminateThreadTask(Sender : TObject);
  end;

implementation

uses
  System.Classes, Service.ScheduleLoad, System.SysUtils, Service.Exceptions, Service.Thread.Executor,
  Service.DTO.Pri_PontoEntrada_Agenda {$IFDEF MSWINDOWS}, Winapi.Windows{$ENDIF};

{ TScheduleThread }

procedure TScheduleThread.CarregarTasks;
var
  ScheduleLoad : TScheduleLoad;
begin
  ScheduleLoad := nil;

  try
    ScheduleLoad := TScheduleLoad.Create;

    ScheduleLoad.GetTaskTimes(FLista, FListaPendentes);
  finally
    System.SysUtils.FreeAndNil(ScheduleLoad);
  end;
end;

constructor TScheduleThread.Create;
begin
  inherited;

  FLista          := TObjectList<TTaskTime>.Create(False);
  FListaPendentes := TObjectList<TTaskTime>.Create(False);
  FParametros     := TParametros.Create;
  FLog            := TLog.Create(FParametros.LogFile);
end;

destructor TScheduleThread.Destroy;
begin
  System.SysUtils.FreeAndNil(FLista);
  System.SysUtils.FreeAndNil(FListaPendentes);
  System.SysUtils.FreeAndNil(FLog);
  System.SysUtils.FreeAndNil(FParametros);

  inherited;
end;

procedure TScheduleThread.ExecutarPA(TaskTime: TTaskTime);
var
  Thread : TExecutorThread;
begin
  Thread := TExecutorThread.Create(TaskTime);

  Thread.OnTerminate := OnTerminateThreadTask;
  Thread.Start;
  TaskTime.Thread := Thread;
end;

procedure TScheduleThread.Execute;
var
  Passagens      : Integer;
  Msg            : String;
  TaskTime       : TTaskTime;
begin
  try
    inherited;

    FLog.Escrever(Self, TTipoLog.Info, Format('Iniciando a aplicação com os seguintes parâmetros: %s', [FParametros.Parametros]));

    Passagens := FParametros.ReloadTime;

    while not Terminated do
    begin
      try
        if Passagens = FParametros.ReloadTime then
        begin
          Passagens := 0;
          CarregarTasks;

          FLog.Escrever(Self, TTipoLog.Info, Format('Conectado no servidor e carregado %d PA', [FLista.Count]));

          for TaskTime in FLista do
          begin
            if TaskTime.TaskNova then
            begin
              TaskTime.CalcularProximaExecucao;

              Msg := Format('PA %d: %s', [FLista.IndexOf(TaskTime) +1, TaskTime.Dto.DsPontoEntrada]);

              if TaskTime.DtoAgenda[0].Tipo = TTipoAgenda.Periodico then
              begin
                Msg := Msg + Format(' Config exec: %s %s %s %s %s, Próx exec: %s',
                              [TaskTime.DtoAgendaProxima.Mes, TaskTime.DtoAgendaProxima.Dia, TaskTime.DtoAgendaProxima.DiaSemana,
                               TaskTime.DtoAgendaProxima.Hora, TaskTime.DtoAgendaProxima.Minuto,
                               DateTimeToStr(TaskTime.ProximaExecucao, TFormatSettings.Create('pt-BR'))]);
              end;

              FLog.Escrever(Self, TTipoLog.Info, Msg);
            end;
          end;
        end;

        for TaskTime in FLista do
        begin
          if TaskTime.Executar then
          begin
            if Assigned(TaskTime.Thread) then
            begin
              FLog.Escrever(Self, TTipoLog.Info, Format('O seguinte PA não foi inicado pois sua última execução ainda não finalizou: %s', [TaskTime.Dto.DsPontoEntrada]));
              Continue;
            end;

            FLog.Escrever(Self, TTipoLog.Info, Format('Iniciado PA: %s', [TaskTime.Dto.DsPontoEntrada]));
            ExecutarPA(TaskTime);
          end;
        end;
      except
        on E: EServiceGeneric do
        begin
          FLog.Escrever(Self, TTipoLog.Erro, E.Message);
        end;

        on E: Exception do
        begin
          FLog.Escrever(Self, TTipoLog.Erro, Format('Ocorreu uma exceção desconhecida:%s%s: %s', [sLineBreak, E.ClassName, E.Message]));
        end;
      end;

      Inc(Passagens);
      TThread.Sleep(5000);
    end;

    for TaskTime in FLista do
    begin
      FinalizarPA(TaskTime);
    end;

    for TaskTime in FListaPendentes do
    begin
      FinalizarPA(TaskTime);
    end;

    FLog.Escrever(Self, TTipoLog.Info, 'Aplicação finalizada');
  except
    on E: EServiceGeneric do
    begin
      FLog.Escrever(Self, TTipoLog.Erro, E.Message);
    end;

    on E: Exception do
    begin
      FLog.Escrever(Self, TTipoLog.Erro, Format('Ocorreu uma exceção desconhecida:%s%s: %s', [sLineBreak, E.ClassName, E.Message]));
    end;
  end;
end;

procedure TScheduleThread.FinalizarPA(TaskTime: TTaskTime);
begin
  if Assigned(TaskTime.Thread) then
  begin
    FLog.Escrever(Self, TTipoLog.Info, Format('Aguardando o seguinte PA finalizar sua execução: %s', [TaskTime.Dto.DsPontoEntrada]));
    {$IFDEF MSWINDOWS}
    WaitForSingleObject(TaskTime.Thread.Handle, INFINITE);
    {$ELSE}
    TaskTime.Thread.WaitFor; //Existe um bug nas versões antigas do Delphi no WaitFor no Windows quando usado dentro de outra Thread, e a thread a ser chamada é FreeOnTerminate. No Linux não foi testado
    {$ENDIF}
  end;

  TaskTime.Free;
end;

procedure TScheduleThread.OnTerminateThreadTask(Sender: TObject);
var
  Msg : String;
begin
  if (Assigned(Sender)) and (Sender is TExecutorThread) then
  begin
    if (Assigned(TGenericThread(Sender).FatalException)) and (TGenericThread(Sender).FatalException is Exception) then
    begin
      Msg := 'Ocorreu uma exceção na execução de um PA!' + sLineBreak +
             'PA: %s' + sLineBreak +
             'Erro: %s';
      FLog.Escrever(Sender, TTipoLog.Erro, Format(Msg, [TExecutorThread(Sender).TaskTime.Dto.DsPontoEntrada, Exception(TGenericThread(Sender).FatalException).Message]));
    end;

    TExecutorThread(Sender).TaskTime.Thread := nil;
    TExecutorThread(Sender).TaskTime.CalcularProximaExecucao;

    Msg := Format('Finalizado PA: %s', [TExecutorThread(Sender).TaskTime.Dto.DsPontoEntrada]);

    if TExecutorThread(Sender).TaskTime.DtoAgenda[0].Tipo = TTipoAgenda.Periodico then
    begin
      Msg := Msg + Format(', Próx exec: %s', [DateTimeToStr(TExecutorThread(Sender).TaskTime.ProximaExecucao, TFormatSettings.Create('pt-BR'))]);
    end;

    FLog.Escrever(Sender, TTipoLog.Info, Msg);
  end;
end;

end.
