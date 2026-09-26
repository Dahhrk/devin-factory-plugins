-- Prefer typed conversions, representation clauses, or Streams over Unchecked_Conversion.
-- When a conversion instance is intentional and reviewed, keep ada-rg-allow on that line.
package No_Unchecked_Conversion is
   pragma Pure;
   type Meter is new Float;
   type Second is new Float;
   function To_Meter (S : Second) return Meter is (Meter (Float (S)));
end No_Unchecked_Conversion;
