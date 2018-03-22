unit Service.FirebirdDAO.Pri_PontoEntrada;

interface

uses
  UPri_FirebirdDAO, UPri_GenericDTO, Data.SqlExpr;

type
  TPri_PontoEntradaFirebirdDAO = class(TPri_FirebirdDAO)
  published
    function BuscarLista(Dto : TPri_GenericDTO) : TSQLQuery;
  end;

implementation

uses
  System.Classes;

{ TPri_PontoEntradaFirebirdDAO }

function TPri_PontoEntradaFirebirdDAO.BuscarLista(Dto: TPri_GenericDTO): TSQLQuery;
var
  Query : TSQLQuery;
begin
  Query := PrepararQuery;

  Query.SQL.Add(' SELECT PRI_PONTOENTRADA.PKPONTOENTRADA,                         '+
                InstrucaoCodigoDescricao('PRI_PONTOENTRADA') + ' AS PONTOENTRADA, '+
                '        PRI_PONTOENTRADA.CODIGO_FONTE                            '+
                '   FROM PRI_PONTOENTRADA                                         '+
                '  WHERE PRI_PONTOENTRADA.STATUS         = ''A''                  '+
                '    AND PRI_PONTOENTRADA.TPPONTOENTRADA = 1                      ');

  Result := Query;
end;

initialization
  System.Classes.RegisterClass(TPri_PontoEntradaFirebirdDAO);

end.
