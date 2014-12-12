library Load32;
{this DLL is written to be called from WinERMS}

uses
  Forms,
  Loadunit in 'LOADUNIT.PAS' {Form1};

{$R *.RES}

exports
       ermsRunTool;
       {this function is a ,
        passing the database path and active DDE topic,
        which then loads the conservation tool,
        runtool.exe with command line parameters for
        DATABASE and TOPIC in that order}

begin
end.
