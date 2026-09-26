import { useRef, useEffect } from 'react';

export function Measured() {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => {
    console.debug(ref.current?.offsetHeight);
  }, []);
  return <div ref={ref} />;
}
