unit Winmask;

interface

uses wintypes,winprocs,dialogs,sysutils;

function mSetHandle(flags : word; bytes : longint) : tHandle;
procedure mDisposeHndl(var handle : tHandle);

implementation

function mSetHandle(flags : word; bytes : longint) : tHandle;
begin
     Result := globalAlloc(flags,bytes);
     if Result = 0 then
     begin
          if (globalcompact(bytes) < bytes) then
          begin
               messagedlg('Unable to Allocate enough Memory - Halting',mtInformation,[mbAbort],0);
               halt;
          end
          else
          begin
               Result := globalAlloc(flags,bytes);
               if Result = 0 then
               begin
                    messagedlg('Failed to assign handle after successful compact - halting',mtInformation,[mbAbort],0);
                    halt;
               end;
          end;
     end;
end;

procedure mDisposeHndl(var handle : tHandle);
begin
     globalrealloc(handle,0,GMEM_MODIFY+GMEM_DISCARDABLE);
     while (globalUnlock(handle) <> bool(0)) do
     begin
     end;
     GlobalDiscard(handle);
end;
end.
