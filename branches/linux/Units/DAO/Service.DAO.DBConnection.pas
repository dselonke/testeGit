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
  System.SysUtils, Service.Parametros, Data.SqlExpr, DbxDevartInterbase;

{ TDBConnection }

procedure TDBConnection.ConfigurarConnection;
var
  Parametros : TParametros;
begin
  Parametros := nil;

  try
    Parametros := TParametros.Create;

    Connection.ConnectionName := 'Devart InterBase';
    Connection.DriverName     := 'DevartInterBase';

    Connection.Params.Clear;

    Connection.Params.Add('DataBase=' + Trim(Parametros.PathDb));

    Connection.Params.Add('DriverUnit=DbxDevartInterBase');
    Connection.Params.Add('DriverPackageLoader=TDBXDynalinkDriverLoader,DBXCommonDriver170.bpl');
    Connection.Params.Add('MetaDataPackageLoader=TDBXDevartInterBaseMetaDataCommandFactory,DbxDevartInterBaseDriver170.bpl');
    Connection.Params.Add('ProductName=DevartInterBase');
    Connection.Params.Add('GetDriverFunc=getSQLDriverInterBase');
    Connection.Params.Add('LibraryName=dbexpida40.dll');
    Connection.Params.Add('VendorLib=gds32.dll');
    Connection.Params.Add('User_Name=' + Trim(Parametros.UserDb));
    Connection.Params.Add('Password=' + Trim(Parametros.PassDb));
    Connection.Params.Add('SQLDialect=3');
    Connection.Params.Add('MaxBlobSize=-1');
    Connection.Params.Add('LocaleCode=0000');
    Connection.Params.Add('DevartInterBase TransIsolation=ReadCommitted');
    Connection.Params.Add('Interbase TransIsolation=ReadCommited' );
    Connection.Params.Add('WaitOnLocks=True');
    Connection.Params.Add('CharLength=1');
    Connection.Params.Add('EnableBCD=True');
    Connection.Params.Add('OptimizedNumerics=True');
    Connection.Params.Add('LongStrings=True');
    Connection.Params.Add('UseQuoteChar=False');
    Connection.Params.Add('FetchAll=False');
    Connection.Params.Add('DeferredBlobRead=False');
    Connection.Params.Add('DeferredArrayRead=False');
    Connection.Params.Add('UseUnicode=False');
    Connection.Params.Add('BlobSize=-1');
    Connection.Params.Add('CommitRetain=False');
    Connection.Params.Add('ErrorResourceFile=');
    Connection.Params.Add('Trim Char=False');
    Connection.Params.Add('TrimChar=False');
    Connection.Params.Add('ServerCharSet=ISO8859_1');
    Connection.Params.Add('CharSet=ISO8859_1');
    Connection.Params.Add('RoleName=RoleName');

    Connection.LoginPrompt := False;
    Connection.Open;
  finally
    System.SysUtils.FreeAndNil(Parametros);
  end;
end;

constructor TDBConnection.Create;
begin
  inherited;

  Connection := TSQLConnection.Create(nil);

  ConfigurarConnection;
end;

destructor TDBConnection.Destroy;
begin
  System.SysUtils.FreeAndNil(FConnection);

  inherited;
end;

end.
