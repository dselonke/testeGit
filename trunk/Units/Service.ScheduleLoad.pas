unit Service.ScheduleLoad;

interface

uses
  Service.GenericObject, Service.TaskTime, System.Generics.Collections, UPri_FactoryDAO, Service.DAO.DBConnection;

type
  TScheduleLoad = class(TGenericObject)
  private
    FFactoryDAO   : TPri_FactoryDAO;
    FDbConnection : TDBConnection;
  public
    procedure GetTaskTimes(AListaTaskTime, AListaPendentesTaskTime : TObjectList<TTaskTime>);

    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, Service.DAO.Pri_PontoEntrada, Service.DTO.Pri_PontoEntrada, UPri_CDSUtils, Datasnap.DBClient,
  Service.DAO.Pri_PontoEntrada_Agenda, Service.DTO.Pri_PontoEntrada_Agenda, Data.DB;

{ TScheduleLoad }

constructor TScheduleLoad.Create;
begin
  inherited;

  FDbConnection := TDBConnection.Create;
  FFactoryDAO   := TPri_FactoryDAO.Create;

  FFactoryDAO.Connection := FDbConnection.Connection;
end;

destructor TScheduleLoad.Destroy;
begin
  System.SysUtils.FreeAndNil(FFactoryDAO);
  System.SysUtils.FreeAndNil(FDbConnection);

  inherited;
end;

procedure TScheduleLoad.GetTaskTimes(AListaTaskTime, AListaPendentesTaskTime: TObjectList<TTaskTime>);
var
  PriPontoEntradaDAO            : TPri_PontoEntradaDAO;
  PriPontoEntradaDTO            : TPri_PontoEntradaDTO;
  PriPontoEntradaAgendaDAO      : TPri_PontoEntrada_AgendaDAO;
  PriPontoEntradaAgendaDTO      : TPri_PontoEntrada_AgendaDTO;
  PriPontoEntradaAgendaDTOBusca : TPri_PontoEntrada_AgendaDTO;
  CDSUtils                      : TPri_CDSUtils;
  CDSPontosEntrada              : TClientDataSet;
  CDSPontosEntradaAgenda        : TClientDataSet;
  TaskTime                      : TTaskTime;
  IdxPontoEntrada               : TIdxPontoEntrada;
  IdxPontoEntradaAgenda         : TIdxPontoEntrada_Agenda;
begin
  PriPontoEntradaDAO            := nil;
  PriPontoEntradaDTO            := nil;
  PriPontoEntradaAgendaDAO      := nil;
  PriPontoEntradaAgendaDTOBusca := nil;
  CDSUtils                      := nil;
  CDSPontosEntrada              := nil;
  CDSPontosEntradaAgenda        := nil;
  TaskTime                      := nil;

  try
    PriPontoEntradaDAO            := TPri_PontoEntradaDAO.Create(FFactoryDAO);
    PriPontoEntradaDTO            := TPri_PontoEntradaDTO.Create;
    PriPontoEntradaAgendaDAO      := TPri_PontoEntrada_AgendaDAO.Create(FFactoryDAO);
    PriPontoEntradaAgendaDTOBusca := TPri_PontoEntrada_AgendaDTO.Create;
    CDSUtils                      := TPri_CDSUtils.Create;
    CDSPontosEntrada              := TClientDataSet.Create(nil);
    CDSPontosEntradaAgenda        := TClientDataSet.Create(nil);

    CDSUtils.UnirQueryCDS(CDSPontosEntrada, PriPontoEntradaDAO.BuscarLista(PriPontoEntradaDTO));

    IdxPontoEntrada.PkPontoEntrada := CDSPontosEntrada.FieldByName('PKPONTOENTRADA').Index;
    IdxPontoEntrada.DsPontoEntrada := CDSPontosEntrada.FieldByName('PONTOENTRADA').Index;
    IdxPontoEntrada.CodigoFonte    := CDSPontosEntrada.FieldByName('CODIGO_FONTE').Index;

    {$REGION 'Verifica as Task que deverão ser removidas'}
    for TaskTime in AListaTaskTime do
    begin
      if not CDSPontosEntrada.Locate('PKPONTOENTRADA', TaskTime.Dto.PkPontoEntrada, []) then
      begin
        AListaTaskTime.Remove(TaskTime);
        AListaPendentesTaskTime.Add(TaskTime);
      end;
    end;
    {$ENDREGION}

    {$REGION 'Verifica as Task que deverão ser adicionadas'}
    CDSPontosEntrada.First;
    while not CDSPontosEntrada.Eof do
    begin
      for TaskTime in AListaTaskTime do
      begin
        if TaskTime.Dto.PkPontoEntrada = CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger then
        begin
          Break;
        end;
      end;

      if Assigned(TaskTime) and (TaskTime.Dto.PkPontoEntrada = CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger) then
      begin
        CDSPontosEntrada.Next;
        Continue;
      end;

      PriPontoEntradaAgendaDTOBusca.FkPontoEntrada := CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger;

      CDSUtils.UnirQueryCDS(CDSPontosEntradaAgenda, PriPontoEntradaAgendaDAO.BuscarLista(PriPontoEntradaAgendaDTOBusca));

      if CDSPontosEntradaAgenda.IsEmpty then
      begin
        CDSPontosEntrada.Next;
        Continue;
      end;

      TaskTime := TTaskTime.Create;
      TaskTime.Dto.PkPontoEntrada := CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger;
      TaskTime.Dto.Codigo_Fonte   := CDSPontosEntrada.Fields[IdxPontoEntrada.CodigoFonte].AsString;
      TaskTime.Dto.DsPontoEntrada := CDSPontosEntrada.Fields[IdxPontoEntrada.DsPontoEntrada].AsString;

      IdxPontoEntradaAgenda.Tipo      := CDSPontosEntradaAgenda.FieldByName('TIPO').Index;
      IdxPontoEntradaAgenda.DiaSemana := CDSPontosEntradaAgenda.FieldByName('DIASEMANA').Index;
      IdxPontoEntradaAgenda.Mes       := CDSPontosEntradaAgenda.FieldByName('MES').Index;
      IdxPontoEntradaAgenda.Dia       := CDSPontosEntradaAgenda.FieldByName('DIA').Index;
      IdxPontoEntradaAgenda.Hora      := CDSPontosEntradaAgenda.FieldByName('HORA').Index;
      IdxPontoEntradaAgenda.Minuto    := CDSPontosEntradaAgenda.FieldByName('MINUTO').Index;

      CDSPontosEntradaAgenda.First;
      while not CDSPontosEntradaAgenda.Eof do
      begin
        PriPontoEntradaAgendaDTO := TPri_PontoEntrada_AgendaDTO.Create;

        PriPontoEntradaAgendaDTO.FkPontoEntrada := TaskTime.Dto.PkPontoEntrada;
        PriPontoEntradaAgendaDTO.Tipo           := TTipoAgenda(CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Tipo].AsInteger);
        PriPontoEntradaAgendaDTO.DiaSemana      := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.DiaSemana].AsString;
        PriPontoEntradaAgendaDTO.Mes            := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Mes].AsString;
        PriPontoEntradaAgendaDTO.Dia            := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Dia].AsString;
        PriPontoEntradaAgendaDTO.Hora           := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Hora].AsString;
        PriPontoEntradaAgendaDTO.Minuto         := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Minuto].AsString;

        TaskTime.DtoAgenda.Add(PriPontoEntradaAgendaDTO);

        CDSPontosEntradaAgenda.Next;
      end;

      AListaTaskTime.Add(TaskTime);

      CDSPontosEntrada.Next;
    end;
    {$ENDREGION}

    {$REGION 'Verifica se as Task removidas possuem thread em andamento pra então destruir'}
    for TaskTime in AListaPendentesTaskTime do
    begin
      if not Assigned(TaskTime.Thread) then
      begin
        AListaPendentesTaskTime.Remove(TaskTime);
        TaskTime.Free;
      end;
    end;
    {$ENDREGION}
  finally
    System.SysUtils.FreeAndNil(PriPontoEntradaDAO);
    System.SysUtils.FreeAndNil(PriPontoEntradaDTO);
    System.SysUtils.FreeAndNil(PriPontoEntradaAgendaDAO);
    System.SysUtils.FreeAndNil(PriPontoEntradaAgendaDTOBusca);
    System.SysUtils.FreeAndNil(CDSUtils);
    System.SysUtils.FreeAndNil(CDSPontosEntrada);
    System.SysUtils.FreeAndNil(CDSPontosEntradaAgenda);
  end;
end;

end.
