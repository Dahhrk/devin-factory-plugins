{ Boundary: prefer structured loops / Exit / raise over goto.
  goto is banned by delphi-rg-gate. Escape: delphi-rg-allow with rationale on the smell line. }
procedure HandleCodes(const Code: Integer);
begin
  case Code of
    1: DoA;
    2: DoB;
  else
    DoOther;
  end;
end;
