unit spatDLLmanager;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TSpatDLLManagerForm = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  SpatDLLManagerForm: TSpatDLLManagerForm;

function initspat(param : PChar) : integer; cdecl;
function disposespat : integer; cdecl;
function setparam(iParam, iValue : integer) : integer; cdecl;
function retrieveparam(iParam : integer) : integer; cdecl;
function startprocessing(iProcess : integer) : integer; cdecl;

implementation

{$R *.DFM}

function initspat(param : PChar) : integer; cdecl; external 'gmtest0.exe';
function disposespat : integer; cdecl; external 'gmtest0.exe';
function setparam(iParam, iValue : integer) : integer; cdecl; external 'gmtest0.exe';
function retrieveparam(iParam : integer) : integer; cdecl; external 'gmtest0.exe';
function startprocessing(iProcess : integer) : integer; cdecl; external 'gmtest0.exe';

end.
