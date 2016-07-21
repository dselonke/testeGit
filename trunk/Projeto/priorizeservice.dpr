program priorizeservice;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ENDIF}
  Service.Parametros in '..\Units\Service.Parametros.pas',
  Service.Exceptions in '..\Units\Service.Exceptions.pas',
  Service.Thread.Schedule in '..\Units\Threads\Service.Thread.Schedule.pas',
  Service.DAO.DBConnection in '..\Units\DAO\Service.DAO.DBConnection.pas',
  Service.GenericObject in '..\Units\Service.GenericObject.pas',
  Service.Thread.Generic in '..\Units\Threads\Service.Thread.Generic.pas',
  Service.ScheduleLoad in '..\Units\Service.ScheduleLoad.pas',
  Service.FirebirdDAO.Pri_PontoEntrada in '..\Units\FirebirdDAO\Service.FirebirdDAO.Pri_PontoEntrada.pas',
  Service.DAO.Pri_PontoEntrada in '..\Units\DAO\Service.DAO.Pri_PontoEntrada.pas',
  Service.DTO.Pri_PontoEntrada in '..\Units\DTO\Service.DTO.Pri_PontoEntrada.pas',
  Service.TaskTime in '..\Units\Service.TaskTime.pas',
  Service.Thread.Executor in '..\Units\Threads\Service.Thread.Executor.pas',
  Service.Help in '..\Units\Service.Help.pas',
  Service.Log in '..\Units\Service.Log.pas',
  Service.FirebirdDAO.Pri_PontoEntrada_Agenda in '..\Units\FirebirdDAO\Service.FirebirdDAO.Pri_PontoEntrada_Agenda.pas',
  Service.DAO.Pri_PontoEntrada_Agenda in '..\Units\DAO\Service.DAO.Pri_PontoEntrada_Agenda.pas',
  Service.DTO.Pri_PontoEntrada_Agenda in '..\Units\DTO\Service.DTO.Pri_PontoEntrada_Agenda.pas',
  Service.InicializarPackages in '..\Units\Service.InicializarPackages.pas',
  fs_iclassesrtti in '..\Units\FastScript\fs_iclassesrtti.pas',
  fs_idbrtti in '..\Units\FastScript\fs_idbrtti.pas';

var
  Schedule : TScheduleThread;

procedure FinalizarThread;
begin
  if Assigned(Schedule) then
  begin
    Schedule.Terminate;
    Schedule.WaitFor;
  end;
end;

{$IFDEF MSWINDOWS}
function ConsoleCtrlHandler(CtrlType: DWORD): BOOL; stdcall;
begin
  if CtrlType in [CTRL_CLOSE_EVENT, CTRL_C_EVENT] then
  begin
    FinalizarThread;
  end;

  Result := True;
end;
{$ENDIF}

begin
  Schedule := nil;

  try
    try
      {$IFDEF MSWINDOWS}
      SetConsoleCtrlHandler(@ConsoleCtrlHandler, True);
      ReportMemoryLeaksOnShutdown := DebugHook <> 0;
      {$ENDIF}

      Schedule := TScheduleThread.Create;
      Schedule.WaitFor;
    except
      on E: Exception do
      begin
        Writeln(E.Message);
      end;
    end;
  finally
    System.SysUtils.FreeAndNil(Schedule);
  end;
end.
