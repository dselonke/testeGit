unit Service.FirebirdDAO.Pri_PontoEntrada_Agenda;

interface

uses
  UPri_FirebirdDAO, UPri_GenericDTO, Data.SqlExpr;

type
  TPri_PontoEntrada_AgendaFirebirdDAO = class(TPri_FirebirdDAO)
  published
    function BuscarLista(Dto : TPri_GenericDTO) : TSQLQuery;
  end;

implementation

uses
  System.Classes, Service.DTO.Pri_PontoEntrada_Agenda;

{ TPri_PontoEntrada_AgendaFirebirdDAO }

function TPri_PontoEntrada_AgendaFirebirdDAO.BuscarLista(Dto: TPri_GenericDTO): TSQLQuery;
var
  Query : TSQLQuery;
begin
  Query := PrepararQuery;

  Query.SQL.Add('SELECT PRI_PONTOENTRADA_AGENDA.PKPONTOENTRADA_AGENDA,           '+
                '       PRI_PONTOENTRADA_AGENDA.TIPO,                            '+
                '       PRI_PONTOENTRADA_AGENDA.MES,                             '+
                '       PRI_PONTOENTRADA_AGENDA.DIA,                             '+
                '       PRI_PONTOENTRADA_AGENDA.DIASEMANA,                       '+
                '       PRI_PONTOENTRADA_AGENDA.HORA,                            '+
                '       PRI_PONTOENTRADA_AGENDA.MINUTO                           '+
                '  FROM PRI_PONTOENTRADA_AGENDA                                  '+
                ' WHERE PRI_PONTOENTRADA_AGENDA.FKPONTOENTRADA = :FKPONTOENTRADA '+
                '   AND PRI_PONTOENTRADA_AGENDA.STATUS         = ''A''           ');

  Query.ParamByName('FKPONTOENTRADA').AsInteger := TPri_PontoEntrada_AgendaDTO(Dto).FkPontoEntrada;

  Result := Query;
end;

initialization
  System.Classes.RegisterClass(TPri_PontoEntrada_AgendaFirebirdDAO);
end.
