unit Service.DAO.Pri_PontoEntrada;

interface

uses
  UPri_GenericDAO, UPri_FactoryDAO, UPri_GenericDTO, FireDAC.Comp.Client;

type
  TPri_PontoEntradaDAO = class(TPri_GenericDAO)
  private
    FFactoryDAO : TPri_FactoryDAO;
  public
    function BuscarLista(Dto : TPri_GenericDTO) : TFDQuery;

    constructor Create(AFactoryDAO : TPri_FactoryDAO);
  end;

implementation

{ TPri_PontoEntradaDAO }

function TPri_PontoEntradaDAO.BuscarLista(Dto: TPri_GenericDTO): TFDQuery;
begin
  Result := FFactoryDAO.BuscaQuery(Dto, 'BuscarLista');
end;

constructor TPri_PontoEntradaDAO.Create(AFactoryDAO : TPri_FactoryDAO);
begin
  inherited Create;

  FFactoryDAO := AFactoryDAO;
end;

end.
