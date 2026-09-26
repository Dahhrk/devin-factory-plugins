## Intentional smells for mako-rg-gate (not product).
<%page expression_filter="n"/>
<%include file="/views/${user_view}.mako"/>
<p>${user_html | n}</p>
<p>${other |n}</p>
