unit Service.DAO.DBConnection;

interface

uses
  UPri_GenericDAO;

type
  TDBConnection = class(TPri_GenericDAO)
  private
    procedure ConfigurarConnection;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils,
  Service.Parametros,
  FireDAC.Comp.Client,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.DataSet;

{ TDBConnection }

procedure TDBConnection.ConfigurarConnection;
var
  Parametros : TParametros;

begin
  Parametros := nil;


  try
    Parametros := TParametros.Create;

    Connection.DriverName := 'FB';
    Connection.TxOptions.Isolation := xiReadCommitted;
    Connection.UpdateOptions.LockWait := true;
    Connection.Params.Clear;

    Connection.Params.Add('DataBase=' + Trim(Parametros.PathDb));
    Connection.Params.Add('DriverID=FB');
    Connection.Params.Add('RoleName=');
    Connection.Params.Add('User_Name='+ Trim(Parametros.UserDb));
    Connection.Params.Add('Password='+ Trim(Parametros.PassDb));
    Connection.Params.Add('SQLDialect=3');
    Connection.Params.Add('BlobSize=-1');
    Connection.Params.Add('ErrorResourceFile=');
    Connection.Params.Add('LocaleCode=0000');
    Connection.Params.Add('WaitOnLocks=True');
    Connection.Params.Add('CharLength=0');
    Connection.Params.Add('EnableBCD=True');
    Connection.Params.Add('OptimizedNumerics=True');
    Connection.Params.Add('LongStrings=True');
    Connection.Params.Add('UseQuoteChar=False');
    Connection.Params.Add('ServerCharSet=ISO8859_1');
    Connection.Params.Add('CharSet=ISO8859_1');
    Connection.Params.Add('UseUnicode=False');
    Connection.Params.Add('FetchAll=False');
    Connection.Params.Add('DeferredBlobRead=False');
    Connection.Params.Add('DeferredArrayRead=False');
    Connection.Params.Add('TrimFixedChar=True');
    Connection.Params.Add('TrimVarChar=False');
    Connection.Params.Add('ForceUsingDefaultPort=False');
    Connection.Params.Add('ForceUnloadClientLibrary=False');

    // Connection.TableScope := [tsSysTable, tsTable, tsView];

    Connection.LoginPrompt := False;
    Connection.Open;


  finally
    System.SysUtils.FreeAndNil(Parametros);
  end;
end;

constructor TDBConnection.Create;
begin
  inherited;

  Connection := TFDConnection.Create(nil);

  ConfigurarConnection;
end;

destructor TDBConnection.Destroy;
begin
  System.SysUtils.FreeAndNil(FConnection);

  inherited;
end;

end.
