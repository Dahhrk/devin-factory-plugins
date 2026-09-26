import React, { useRef } from 'react';
import { createRoot } from 'react-dom/client';
import DOMPurify from 'isomorphic-dompurify';

export function Ok({ html }: { html: string }) {
  const ref = useRef<HTMLDivElement>(null);
  return (
    <div ref={ref}>
      <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />
    </div>
  );
}

// Documented intentional seam; allow on the smell line.
const _legacy = findDOMNode as unknown; // react-rg-allow: fixture documents allow marker for intentional findDOMNode seam
void _legacy;

const el = document.getElementById('root');
if (el) createRoot(el).render(<Ok html="<b>x</b>" />);
