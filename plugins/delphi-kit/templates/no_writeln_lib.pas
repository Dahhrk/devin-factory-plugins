{ Boundary: library units (.pas/.pp) must not WriteLn to console.
  Prefer Result / logging facade. CLI programs (.dpr/.lpr) may WriteLn.
  WriteLn in libs is banned by delphi-rg-gate. Escape: delphi-rg-allow with rationale. }
function Describe(const Msg: string): string;
begin
  Result := Msg; // caller logs; no WriteLn in unit
end;
