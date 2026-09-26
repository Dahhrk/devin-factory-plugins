{ Boundary: prefer explicit record/object qualifiers over with-statement.
  with ... do is banned by delphi-rg-gate. Escape: delphi-rg-allow with rationale. }
procedure SetThing(var T: TThing);
begin
  T.X := 1;
  T.Y := 2;
end;
