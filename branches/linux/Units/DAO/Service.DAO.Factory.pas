unit Service.DAO.Factory;

interface

uses
  Service.DAO.Generic, Data.SqlExpr, Data.DBXCommon, UPri_GenericDTO;

type
  TFactoryDAO = class(TGenericDAO)
  private
    FConecBanco : String;
    FTransacao  : TDBXTransaction;
  public
    property ConecBanco : String read FConecBanco;

    function BuscaQuery(Dto: TPri_GenericDTO; NomeMetodo : String) : TSQLQuery;
    function BuscarRegistro(Dto : TPri_GenericDTO; NomeMetodo : String) : Boolean;
    function ExecuteMetodo(NomeMetodo : String; Dto : TPri_GenericDTO) : Boolean;
    procedure IniciarTransacao;
    procedure FinalizarTransacao(Comitar : Boolean);
    function VerificarTransacao : Boolean;

    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.Classes, System.SysUtils, Service.Exceptions;

{ TFactoryDAO }

function TFactoryDAO.BuscaQuery(Dto: TPri_GenericDTO; NomeMetodo: String): TSQLQuery;
var
  ClassDAO     : TGenericDAO;
  GenericDAO   : TPersistentClass;
  getFunction  : function(Classe : TPri_GenericDTO) : TSQLQuery of object;
begin
  Result := nil;

  if not Assigned(Dto) then
  begin
    Exit;
  end;

  try
    getFunction := nil;
    ClassDAO    := nil;

    GenericDAO  := GetClass('T' + Dto.Nome + ConecBanco + 'DAO');

    if GenericDAO <> nil then
    begin
      ClassDAO := TGenericDAO(GenericDAO.Create);

      @getFunction := ClassDAO.MethodAddress(NomeMetodo);

      if @getFunction <> nil then
      begin
        ClassDAO.Connection := Self.Connection;

        Result := getFunction(Dto);
      end
      else
      begin
        raise EFactoryDAO.Create(Format('Método não encontrado: T%s%sDAO.%s.', [Dto.Nome, ConecBanco, NomeMetodo]));
      end;
    end
    else
    begin
      raise EFactoryDAO.Create(Format('Classe não encontrada: T%s%sDAO.', [Dto.Nome, ConecBanco]));
    end;
  finally
    System.SysUtils.FreeAndNil(ClassDAO);
  end;
end;

function TFactoryDAO.BuscarRegistro(Dto: TPri_GenericDTO; NomeMetodo: String): Boolean;
var
  ClassDAO     : TGenericDAO;
  GenericDAO   : TPersistentClass;
  getFunction  : function(Classe : TPri_GenericDTO) : Boolean of object;
begin
  Result := False;

  try
    getFunction := nil;
    ClassDAO    := nil;

    GenericDAO  := GetClass('T' + Dto.Nome + ConecBanco + 'DAO');

    if GenericDAO <> nil then
    begin
      ClassDAO := TGenericDAO(GenericDAO.Create);

      @getFunction := ClassDAO.MethodAddress(NomeMetodo);

      if @getFunction <> nil then
      begin
        ClassDAO.Connection := Self.Connection;

        Result := getFunction(Dto);
      end
      else
      begin
        raise EFactoryDAO.Create(Format('Método não encontrado: T%s%sDAO.%s.', [Dto.Nome, ConecBanco, NomeMetodo]));
      end;
    end
    else
    begin
      raise EFactoryDAO.Create(Format('Classe não encontrada: T%s%sDAO.', [Dto.Nome, ConecBanco]));
    end;
  finally
    System.SysUtils.FreeAndNil(ClassDAO);
  end;
end;

constructor TFactoryDAO.Create;
begin
  inherited;

  FConecBanco := 'Firebird';
  FTransacao  := nil;
end;

destructor TFactoryDAO.Destroy;
begin
  if VerificarTransacao then
  begin
    FinalizarTransacao(False);
  end;

  inherited;
end;

function TFactoryDAO.ExecuteMetodo(NomeMetodo: String; Dto: TPri_GenericDTO): Boolean;
var
  ClassDAO     : TGenericDAO;
  GenericDAO   : TPersistentClass;
  getFunction  : function(Classe : TPri_GenericDTO) : Boolean of object;
begin
  Result := False;

  try
    getFunction := nil;
    ClassDAO    := nil;

    GenericDAO  := GetClass('T' + Dto.Nome + ConecBanco + 'DAO');

    if GenericDAO <> nil then
    begin
      ClassDAO := TGenericDAO(GenericDAO.Create);

      @getFunction := ClassDAO.MethodAddress(NomeMetodo);

      if @getFunction <> nil then
      begin
        ClassDAO.Connection := Self.Connection;

        Result := getFunction(Dto);
      end
      else
      begin
        raise EFactoryDAO.Create(Format('Método não encontrado: T%s%sDAO.%s.', [Dto.Nome, ConecBanco, NomeMetodo]));
      end;
    end
    else
    begin
      raise EFactoryDAO.Create(Format('Classe não encontrada: T%s%sDAO.', [Dto.Nome, ConecBanco]));
    end;
  finally
    System.SysUtils.FreeAndNil(ClassDAO);
  end;
end;

procedure TFactoryDAO.FinalizarTransacao(Comitar: Boolean);
begin
  if Comitar then
  begin
    Connection.CommitFreeAndNil(FTransacao);
  end
  else
  begin
    Connection.RollbackFreeAndNil(FTransacao);
  end;
end;

procedure TFactoryDAO.IniciarTransacao;
begin
  if Assigned(FTransacao) then
  begin
    Connection.RollbackIncompleteFreeAndNil(FTransacao);
  end;

  FTransacao := Connection.BeginTransaction;
end;

function TFactoryDAO.VerificarTransacao: Boolean;
begin
  if not Assigned(Connection) then
  begin
    Result := False;
  end
  else
  begin
    Result := Connection.InTransaction;
  end;
end;

end.
