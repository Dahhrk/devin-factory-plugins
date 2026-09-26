import DOMPurify from 'isomorphic-dompurify';

export function TrustedHtml({ html }: { html: string }) {
  return <div dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(html) }} />;
}
