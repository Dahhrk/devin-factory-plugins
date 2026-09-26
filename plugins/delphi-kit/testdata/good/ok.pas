unit Ok;

interface

implementation

type
  TThing = record
    X: Integer;
    Y: Integer;
  end;

procedure GoodPath;
var
  P: Pointer;
  T: TThing;
begin
  New(P); // typed path preferred in product; fixture uses New
  T.X := 1;
  T.Y := 2;
  // Documented intentional seam; keep allow on the smell line.
  WriteLn('fixture'); // delphi-rg-allow: fixture documents allow marker for intentional WriteLn seam
end;

end.
