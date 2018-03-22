unit Service.Parametros;

interface

uses
  Service.GenericObject;

type
  TParametros = class(TGenericObject)
  private
    FPathDb     : String;
    FUserDb     : String;
    FPassDb     : String;
    FReloadTime : String;
    FLogFile    : String;
    FParametros : String;

    procedure Buscar;
    procedure ValidarSintaxe;
    function GetReloadTime : Integer;
  public
    property PathDb     : String  read FPathDb;
    property UserDb     : String  read FUserDb;
    property PassDb     : String  read FPassDb;
    property ReloadTime : Integer read GetReloadTime;
    property LogFile    : String  read FLogFile;
    property Parametros : String  read FParametros;

    constructor Create;
  end;

implementation

uses
  Service.Exceptions, System.SysUtils;

{ TParametros }

procedure TParametros.Buscar;
var
  I: Integer;
begin
  FPathDb     := ParamStr(2);
  FUserDb     := ParamStr(4);
  FPassDb     := ParamStr(6);
  FReloadTime := ParamStr(8);
  FLogFile    := ParamStr(10);

  for I := 1 to ParamCount do
  begin
    if FParametros.IsEmpty then
    begin
      FParametros := ParamStr(I);
    end
    else
    begin
      FParametros := FParametros + ' ' + ParamStr(I);
    end;
  end;
end;

constructor TParametros.Create;
begin
  inherited;

  ValidarSintaxe;
  Buscar;
end;

function TParametros.GetReloadTime: Integer;
begin
  Result := (StrToIntDef(FReloadTime, 2) * 60) div 5;
end;

procedure TParametros.ValidarSintaxe;
begin
  if not (ParamCount in [8, 10]) then
  begin
    raise EParametros.Create('Número de parâmetros informados inválido!');
  end;

  if LowerCase(ParamStr(1)) <> '-pathdb' then
  begin
    raise EParametros.Create('O primeiro parâmetro deverá ser -pathdb');
  end;

  if LowerCase(ParamStr(3)) <> '-userdb' then
  begin
    raise EParametros.Create('O terceiro parâmetro deverá ser -userdb');
  end;

  if LowerCase(ParamStr(5)) <> '-passdb' then
  begin
    raise EParametros.Create('O quinto parâmetro deverá ser -passdb');
  end;

  if LowerCase(ParamStr(7)) <> '-reloadtime' then
  begin
    raise EParametros.Create('O sétimo parâmetro deverá ser -reloadtime');
  end;

  if ParamCount = 9 then
  begin
    if LowerCase(ParamStr(9)) <> '-logfile' then
    begin
      raise EParametros.Create('O nono parâmetro deverá ser -logfile');
    end;
  end;
end;

end.
