unit Service.Thread.Executor;

interface

uses
  Service.Thread.Generic, Service.TaskTime;

type
  TExecutorThread = class(TGenericThread)
  private
    FTaskTime : TTaskTime;
  protected
    procedure Execute; override;
  public
    constructor Create(ATaskTime : TTaskTime);

    property TaskTime : TTaskTime read FTaskTime;
  end;

implementation

uses
  System.SysUtils, UPri_ProgramaAutonomo_Container, UPri_ProgramaAutonomoCompiladorUtils;

{ TExecutorThread }

constructor TExecutorThread.Create(ATaskTime : TTaskTime);
begin
  inherited Create(True);

  FreeOnTerminate := True;
  FTaskTime       := ATaskTime;
end;

procedure TExecutorThread.Execute;
var
  PriPAContainer       : TPri_ProgramaAutonomo_Container;
  PriPACompiladorUtils : TPri_ProgramaAutonomoCompiladorUtils;
begin
  inherited;

  PriPAContainer       := nil;
  PriPACompiladorUtils := nil;

  try
    PriPAContainer       := TPri_ProgramaAutonomo_Container.Create;
    PriPACompiladorUtils := TPri_ProgramaAutonomoCompiladorUtils.Create;

    PriPAContainer.Codigo_Fonte := FTaskTime.Dto.Codigo_Fonte;
  finally
    System.SysUtils.FreeAndNil(PriPAContainer);
    System.SysUtils.FreeAndNil(PriPACompiladorUtils);
  end;
end;

end.
