-- Prefer keeping checks enabled. Do not pragma Suppress in product paths.
-- Overflow / range / access checks catch real defects; Suppress hides them.
procedure No_Suppress is
   X : Integer := Integer'Last;
begin
   X := X + 1;  -- keep checks; handle Constraint_Error if needed
end No_Suppress;
