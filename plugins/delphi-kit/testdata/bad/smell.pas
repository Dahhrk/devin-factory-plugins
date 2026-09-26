unit Smell;

{ Intentional smells for delphi-rg-gate discrimination (not product code). }

interface

implementation

type
  TThing = record
    X: Integer;
    Y: Integer;
  end;

procedure BadPath;
label
  Done;
var
  P: Pointer;
  T: TThing;
begin
  GetMem(P, 64);
  with T do
  begin
    X := 1;
    Y := 2;
  end;
  WriteLn('lib console leak');
  goto Done;
Done:
end;

end.
