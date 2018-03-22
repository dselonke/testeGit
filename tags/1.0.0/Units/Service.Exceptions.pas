unit Service.Exceptions;

interface

uses
  System.SysUtils;

type
  EServiceGeneric = class(Exception);

  EParametros = class(EServiceGeneric)
  public
    constructor Create(const Msg: string);
  end;

  EFactoryDAO = class(EServiceGeneric)
  public
    constructor Create(const Msg: string);
  end;

  ECDSUtils = class(EServiceGeneric)
  public
    constructor Create(const Msg: string);
  end;

  ECompilador = class(EServiceGeneric)
  public
    constructor Create(const Msg: string);
  end;

implementation

uses
  Service.Help;

{ EParametros }

constructor EParametros.Create(const Msg: string);
var
  Help : THelp;
begin
  Help := nil;

  try
    Help := THelp.Create;
    Help.Escrever;
  finally
    System.SysUtils.FreeAndNil(Help);
  end;

  inherited Create('Os parâmetros informados estão inválidos:' + sLineBreak + Msg);
end;

{ EFactoryDAO }

constructor EFactoryDAO.Create(const Msg: string);
begin
  inherited Create('Exceção no Service.DAO.Factory:' + sLineBreak + Msg);
end;

{ ECDSUtils }

constructor ECDSUtils.Create(const Msg: string);
begin
  inherited Create('Exceção no Service.Utils.CDS:' + sLineBreak + Msg);
end;

{ ECompilador }

constructor ECompilador.Create(const Msg: string);
begin
  inherited Create('Ocorreu um erro ao compilar o código-fonte!' + sLineBreak + 'Erro: ' + Msg);
end;

end.
