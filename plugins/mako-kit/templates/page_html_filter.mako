## Named boundary: prefer page-level HTML escaping for all expressions.
## Anti-pattern (banned without allow): expression_filter="n" or bare |n

<%page expression_filter="h"/>

<html>
<body>
<p>${title}</p>
</body>
</html>
