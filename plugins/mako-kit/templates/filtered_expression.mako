## Named boundary: prefer |h (or page expression_filter="h") over |n raw.
## Anti-pattern (banned without allow): ${user_html | n}

<%page expression_filter="h"/>
<p>${user_html | h}</p>
