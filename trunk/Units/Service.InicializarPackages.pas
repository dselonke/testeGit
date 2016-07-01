unit Service.InicializarPackages;

interface

procedure InicializarPriCompilador;

implementation

uses
  {$IFDEF MSWINDOWS}Winapi.Windows,{$ENDIF} System.SysUtils;

procedure InicializarPriCompilador;
var
  Package : THandle;
begin
  {$IFDEF MSWINDOWS}
  Package := GetModuleHandle('PriCompilador.bpl');
  {$ENDIF}

  if Package <> 0 then
  begin
    InitializePackage(Package);
  end;
end;

initialization
begin
  InicializarPriCompilador;
end;

end.
