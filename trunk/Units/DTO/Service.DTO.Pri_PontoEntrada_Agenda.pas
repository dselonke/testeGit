unit Service.DTO.Pri_PontoEntrada_Agenda;

interface

uses
  UPri_GenericDTO;

type
  TTipoAgenda = (Agendado, Periodico);

  TPri_PontoEntrada_AgendaDTO = class(TPri_GenericDTO)
  private
    FFkPontoEntrada      : Integer;
    FHora                : String;
    FMinuto              : String;
    FMes                 : String;
    FDia                 : String;
    FDiaSemana           : String;
    FTipo                : TTipoAgenda;
    FCalcProximaExecucao : TDateTime;

    function GetCalcDsTipoAgenda : String;
  public
    constructor Create;

    property FkPontoEntrada   : Integer     read FFkPontoEntrada write FFkPontoEntrada;
    property Tipo             : TTipoAgenda read FTipo           write FTipo;
    property DiaSemana        : String      read FDiaSemana      write FDiaSemana;
    property Mes              : String      read FMes            write FMes;
    property Dia              : String      read FDia            write FDia;
    property Hora             : String      read FHora           write FHora;
    property Minuto           : String      read FMinuto         write FMinuto;

    property CalcDsTipoAgenda    : String    read GetCalcDsTipoAgenda;
    property CalcProximaExecucao : TDateTime read FCalcProximaExecucao write FCalcProximaExecucao;
  end;

  TIdxPontoEntrada_Agenda = record
    Tipo      : Integer;
    DiaSemana : Integer;
    Mes       : Integer;
    Dia       : Integer;
    Hora      : Integer;
    Minuto    : Integer;
  end;

implementation

uses
  System.TypInfo;

{ TPri_PontoEntrada_AgendaDTO }

constructor TPri_PontoEntrada_AgendaDTO.Create;
begin
  inherited;

  Nome := 'Pri_PontoEntrada_Agenda';
end;

function TPri_PontoEntrada_AgendaDTO.GetCalcDsTipoAgenda: String;
begin
  Result := GetEnumName(TypeInfo(TTipoAgenda), Integer(FTipo));
end;

end.
