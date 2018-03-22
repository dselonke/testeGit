unit Service.Help;

interface

uses
  Service.GenericObject;

type
  THelp = class(TGenericObject)
  public
    procedure Escrever;
  end;

implementation

uses
  System.SysUtils;

{ THelp }

procedure THelp.Escrever;
var
  Excecutavel : String;
begin
  Excecutavel := ExtractFileName(ParamStr(0));

  Writeln('');
  Writeln('Uso: ');
  Writeln('     ', Excecutavel, ' -pathdb "caminho" -userdb usuario -passdb senha -reloadtime tempo');
  Writeln('     ', Excecutavel, ' -pathdb "caminho" -userdb usuario -passdb senha -reloadtime tempo -logfile "caminho"');
  Writeln('');
  Writeln('  -pathdb       Caminho do banco de dados do Priorize.');
  Writeln('  -userdb       Usuário do banco de dados do Priorize.');
  Writeln('  -passdb       Senha do usuário do banco de dados do Priorize.');
  Writeln('  -reloadtime   Ciclo do tempo em minutos que irá conectar no banco e recarregar as tarefas');
  Writeln('  -logfile      Caminho onde será salvo o log gerado por este aplicativo (este parâmetro é opcional).');
  Writeln('');
end;

end.
