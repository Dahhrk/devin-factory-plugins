{ Boundary: prefer New / managed types over GetMem (unchecked heap API).
  GetMem is banned by delphi-rg-gate. Escape: delphi-rg-allow with rationale on the smell line. }
procedure AllocThing(out P: PThing);
begin
  New(P);
  try
    P^.X := 0;
  except
    Dispose(P);
    raise;
  end;
end;
