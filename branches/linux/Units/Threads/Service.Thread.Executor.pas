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
  System.SysUtils, UPri_ProgramaAutonomo_Container, UPri_ProgramaAutonomoCompiladorUtils, Service.DAO.DBConnection,
  Service.Exceptions;

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
  DBConnection         : TDBConnection;
begin
  inherited;

  PriPAContainer       := nil;
  PriPACompiladorUtils := nil;
  DBConnection         := nil;

  try
    PriPAContainer       := TPri_ProgramaAutonomo_Container.Create;
    PriPACompiladorUtils := TPri_ProgramaAutonomoCompiladorUtils.Create;
    DBConnection         := TDBConnection.Create;

    PriPAContainer.Codigo_Fonte := FTaskTime.Dto.Codigo_Fonte;
    PriPAContainer.ConexaoBanco := DBConnection.Connection;
    PriPACompiladorUtils.Executar(PriPAContainer);

    if not PriPAContainer.CompiladorOutput.ExecucaoSucesso then
    begin
      raise ECompilador.Create(PriPAContainer.CompiladorOutput.MensagemExcecao);
    end;
  finally
    System.SysUtils.FreeAndNil(PriPAContainer);
    System.SysUtils.FreeAndNil(PriPACompiladorUtils);
    System.SysUtils.FreeAndNil(DBConnection);
  end;
end;

end.
