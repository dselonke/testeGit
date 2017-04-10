unit Service.DAO.Pri_PontoEntrada_Agenda;

interface

uses
  UPri_GenericDAO, UPri_FactoryDAO, UPri_GenericDTO, Data.SqlExpr;

type
  TPri_PontoEntrada_AgendaDAO = class(TPri_GenericDAO)
  private
    FFactoryDAO : TPri_FactoryDAO;
  public
    function BuscarLista(Dto : TPri_GenericDTO) : TSQLQuery;

    constructor Create(AFactoryDAO : TPri_FactoryDAO);
  end;

implementation

{ TPri_PontoEntrada_AgendaDAO }

function TPri_PontoEntrada_AgendaDAO.BuscarLista(Dto: TPri_GenericDTO): TSQLQuery;
begin
  Result := FFactoryDAO.BuscaQuery(Dto, 'BuscarLista');
end;

constructor TPri_PontoEntrada_AgendaDAO.Create(AFactoryDAO: TPri_FactoryDAO);
begin
  inherited Create;

  FFactoryDAO := AFactoryDAO;
end;

end.
