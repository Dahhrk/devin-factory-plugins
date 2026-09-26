## Named boundary: prefer static <%include> paths over interpolated names.
## Anti-pattern (banned without allow): <%include file="/views/${user_view}.mako"/>

<%include file="header.mako"/>
<p>body</p>
<%include file="footer.mako"/>
