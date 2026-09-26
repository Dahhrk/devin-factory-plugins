-- Intentional smells for ada-rg-gate discrimination (not product code).
with Ada.Unchecked_Conversion;
procedure Smell is
   type A is new Integer;
   type B is new Integer;
   function Conv is new Ada.Unchecked_Conversion (A, B);
   X : A := 1;
   Y : B;
   pragma Suppress (All_Checks);
begin
   Y := Conv (X);
end Smell;
