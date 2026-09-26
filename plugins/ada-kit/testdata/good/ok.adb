procedure Ok is
   X : Integer := 0;
begin
   X := X + 1;
   -- Documented intentional seam; keep allow on the smell line when needed.
   pragma Suppress (Overflow_Check); -- ada-rg-allow: fixture documents allow marker for intentional Suppress seam
end Ok;
