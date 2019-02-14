unit Service.DTO.Pri_PontoEntrada;

interface

uses
  UPri_GenericDTO;

type
  TPri_PontoEntradaDTO = class(TPri_GenericDTO)
  private
    FPkPontoEntrada : Integer;
    FDsPontoEntrada : String;
    FCodigo_Fonte   : String;
  public
    constructor Create;

    property PkPontoEntrada  : Integer read FPkPontoEntrada write FPkPontoEntrada;
    property Codigo_Fonte    : String  read FCodigo_Fonte   write FCodigo_Fonte;
    property DsPontoEntrada  : String  read FDsPontoEntrada write FDsPontoEntrada;
  end;

  TIdxPontoEntrada = record
    PkPontoEntrada : Integer;
    CodigoFonte    : Integer;
    DsPontoEntrada : Integer;
  end;

implementation

{ TPri_PontoEntradaDTO }

constructor TPri_PontoEntradaDTO.Create;
begin
  inherited;

  Nome := 'Pri_PontoEntrada';
end;

end.
