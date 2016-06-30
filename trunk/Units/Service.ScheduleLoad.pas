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
  PriPontoEntradaDAO               : TPri_PontoEntradaDAO;
  PriPontoEntradaDTO               : TPri_PontoEntradaDTO;
  PriPontoEntradaAgendaDAO         : TPri_PontoEntrada_AgendaDAO;
  PriPontoEntradaAgendaDTO         : TPri_PontoEntrada_AgendaDTO;
  PriPontoEntradaAgendaDTOBusca    : TPri_PontoEntrada_AgendaDTO;
  PriPontoEntradaAgendaDTOAtulizar : TPri_PontoEntrada_AgendaDTO;
  CDSUtils                         : TPri_CDSUtils;
  CDSPontosEntrada                 : TClientDataSet;
  CDSPontosEntradaAgenda           : TClientDataSet;
  TaskTime                         : TTaskTime;
  TaskTimeAtualizar                : TTaskTime;
  ListaRemover                     : TObjectList<TTaskTime>;
  ListaRemoverAgendas              : TObjectList<TPri_PontoEntrada_AgendaDTO>;
  IdxPontoEntrada                  : TIdxPontoEntrada;
  IdxPontoEntradaAgenda            : TIdxPontoEntrada_Agenda;
  Indice                           : Integer;
  AtualizarTask                    : Boolean;
  AtualizarAgenda                  : Boolean;
begin
  PriPontoEntradaDAO            := nil;
  PriPontoEntradaDTO            := nil;
  PriPontoEntradaAgendaDAO      := nil;
  PriPontoEntradaAgendaDTOBusca := nil;
  CDSUtils                      := nil;
  CDSPontosEntrada              := nil;
  CDSPontosEntradaAgenda        := nil;
  ListaRemover                  := nil;
  ListaRemoverAgendas           := nil;

  try
    PriPontoEntradaDAO            := TPri_PontoEntradaDAO.Create(FFactoryDAO);
    PriPontoEntradaDTO            := TPri_PontoEntradaDTO.Create;
    PriPontoEntradaAgendaDAO      := TPri_PontoEntrada_AgendaDAO.Create(FFactoryDAO);
    PriPontoEntradaAgendaDTOBusca := TPri_PontoEntrada_AgendaDTO.Create;
    CDSUtils                      := TPri_CDSUtils.Create;
    CDSPontosEntrada              := TClientDataSet.Create(nil);
    CDSPontosEntradaAgenda        := TClientDataSet.Create(nil);
    ListaRemover                  := TObjectList<TTaskTime>.Create;
    ListaRemoverAgendas           := TObjectList<TPri_PontoEntrada_AgendaDTO>.Create(False);

    CDSUtils.UnirQueryCDS(CDSPontosEntrada, PriPontoEntradaDAO.BuscarLista(PriPontoEntradaDTO));

    IdxPontoEntrada.PkPontoEntrada := CDSPontosEntrada.FieldByName('PKPONTOENTRADA').Index;
    IdxPontoEntrada.DsPontoEntrada := CDSPontosEntrada.FieldByName('PONTOENTRADA').Index;
    IdxPontoEntrada.CodigoFonte    := CDSPontosEntrada.FieldByName('CODIGO_FONTE').Index;

    {$REGION 'Verifica as Task que deverão ser removidas'}
    for TaskTime in AListaTaskTime do
    begin
      if not CDSPontosEntrada.Locate('PKPONTOENTRADA', TaskTime.Dto.PkPontoEntrada, []) then
      begin
        AListaPendentesTaskTime.Add(TaskTime);
      end
      else
      begin
        PriPontoEntradaAgendaDTOBusca.FkPontoEntrada := CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger;

        CDSUtils.UnirQueryCDS(CDSPontosEntradaAgenda, PriPontoEntradaAgendaDAO.BuscarLista(PriPontoEntradaAgendaDTOBusca));

        if CDSPontosEntradaAgenda.IsEmpty then
        begin
          AListaPendentesTaskTime.Add(TaskTime);
        end;
      end;
    end;
    {$ENDREGION}

    {$REGION 'Verifica se as Task removidas possuem thread em andamento pra então destruir'}
    for TaskTime in AListaPendentesTaskTime do
    begin
      Indice := AListaTaskTime.IndexOf(TaskTime);

      if Indice > -1 then
      begin
        AListaTaskTime.Delete(Indice);
      end;

      if not Assigned(TaskTime.Thread) then
      begin
        ListaRemover.Add(TaskTime);
      end;
    end;

    for TaskTime in ListaRemover do
    begin
      Indice := AListaPendentesTaskTime.IndexOf(TaskTime);

      if Indice > -1 then
      begin
        AListaPendentesTaskTime.Delete(Indice);
      end;
    end;

    ListaRemover.Clear; //Aqui as TaskTime são destruídas
    {$ENDREGION}

    {$REGION 'Verifica as Task que deverão ser adicionadas / atualizadas'}
    CDSPontosEntrada.First;
    while not CDSPontosEntrada.Eof do
    begin
      TaskTimeAtualizar := nil;
      AtualizarTask     := False;

      for TaskTime in AListaTaskTime do
      begin
        if TaskTime.Dto.PkPontoEntrada = CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger then
        begin
          TaskTimeAtualizar := TaskTime;
          AtualizarTask     := True;
          Break;
        end;
      end;

      PriPontoEntradaAgendaDTOBusca.FkPontoEntrada := CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger;

      CDSUtils.UnirQueryCDS(CDSPontosEntradaAgenda, PriPontoEntradaAgendaDAO.BuscarLista(PriPontoEntradaAgendaDTOBusca));

      if CDSPontosEntradaAgenda.IsEmpty then
      begin
        CDSPontosEntrada.Next;
        Continue;
      end;

      if AtualizarTask then
      begin
        TaskTime := TaskTimeAtualizar;

        if Assigned(TaskTime.Thread) then
        begin
          CDSPontosEntrada.Next;
          Continue;
        end;
      end
      else
      begin
        TaskTime := TTaskTime.Create;

        TaskTime.Dto.PkPontoEntrada := CDSPontosEntrada.Fields[IdxPontoEntrada.PkPontoEntrada].AsInteger;
      end;

      TaskTime.Dto.Codigo_Fonte   := CDSPontosEntrada.Fields[IdxPontoEntrada.CodigoFonte].AsString;
      TaskTime.Dto.DsPontoEntrada := CDSPontosEntrada.Fields[IdxPontoEntrada.DsPontoEntrada].AsString;

      IdxPontoEntradaAgenda.PkPontoEntrada_Agenda := CDSPontosEntradaAgenda.FieldByName('PKPONTOENTRADA_AGENDA').Index;
      IdxPontoEntradaAgenda.Tipo                  := CDSPontosEntradaAgenda.FieldByName('TIPO').Index;
      IdxPontoEntradaAgenda.DiaSemana             := CDSPontosEntradaAgenda.FieldByName('DIASEMANA').Index;
      IdxPontoEntradaAgenda.Mes                   := CDSPontosEntradaAgenda.FieldByName('MES').Index;
      IdxPontoEntradaAgenda.Dia                   := CDSPontosEntradaAgenda.FieldByName('DIA').Index;
      IdxPontoEntradaAgenda.Hora                  := CDSPontosEntradaAgenda.FieldByName('HORA').Index;
      IdxPontoEntradaAgenda.Minuto                := CDSPontosEntradaAgenda.FieldByName('MINUTO').Index;

      for PriPontoEntradaAgendaDTO in TaskTime.DtoAgenda do
      begin
        if not CDSPontosEntradaAgenda.Locate('PKPONTOENTRADA_AGENDA', PriPontoEntradaAgendaDTO.PkPontoEntrada_Agenda, []) then
        begin
          ListaRemoverAgendas.Add(PriPontoEntradaAgendaDTO);
        end;
      end;

      for PriPontoEntradaAgendaDTO in ListaRemoverAgendas do
      begin
        Indice := TaskTime.DtoAgenda.IndexOf(PriPontoEntradaAgendaDTO);

        if Indice > -1 then
        begin
          TaskTime.DtoAgenda.Delete(Indice); //Aqui a agenda é destruída
        end;
      end;

      ListaRemoverAgendas.Clear;

      CDSPontosEntradaAgenda.First;
      while not CDSPontosEntradaAgenda.Eof do
      begin
        PriPontoEntradaAgendaDTOAtulizar := nil;
        AtualizarAgenda                  := False;

        for PriPontoEntradaAgendaDTO in TaskTime.DtoAgenda do
        begin
          if PriPontoEntradaAgendaDTO.PkPontoEntrada_Agenda = CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.PkPontoEntrada_Agenda].AsInteger then
          begin
            PriPontoEntradaAgendaDTOAtulizar := PriPontoEntradaAgendaDTO;
            AtualizarAgenda                  := True;
            Break;
          end;
        end;

        if AtualizarAgenda then
        begin
          PriPontoEntradaAgendaDTO := PriPontoEntradaAgendaDTOAtulizar;
        end
        else
        begin
          PriPontoEntradaAgendaDTO := TPri_PontoEntrada_AgendaDTO.Create;

          PriPontoEntradaAgendaDTO.PkPontoEntrada_Agenda := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.PkPontoEntrada_Agenda].AsInteger;
          PriPontoEntradaAgendaDTO.FkPontoEntrada        := TaskTime.Dto.PkPontoEntrada;
        end;

        PriPontoEntradaAgendaDTO.Tipo      := TTipoAgenda(CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Tipo].AsInteger);
        PriPontoEntradaAgendaDTO.DiaSemana := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.DiaSemana].AsString;
        PriPontoEntradaAgendaDTO.Mes       := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Mes].AsString;
        PriPontoEntradaAgendaDTO.Dia       := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Dia].AsString;
        PriPontoEntradaAgendaDTO.Hora      := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Hora].AsString;
        PriPontoEntradaAgendaDTO.Minuto    := CDSPontosEntradaAgenda.Fields[IdxPontoEntradaAgenda.Minuto].AsString;

        if not AtualizarAgenda then
        begin
          TaskTime.DtoAgenda.Add(PriPontoEntradaAgendaDTO);
        end;

        CDSPontosEntradaAgenda.Next;
      end;

      if not AtualizarTask then
      begin
        AListaTaskTime.Add(TaskTime);
      end;

      CDSPontosEntrada.Next;
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
    System.SysUtils.FreeAndNil(ListaRemover);
    System.SysUtils.FreeAndNil(ListaRemoverAgendas);
  end;
end;

end.
