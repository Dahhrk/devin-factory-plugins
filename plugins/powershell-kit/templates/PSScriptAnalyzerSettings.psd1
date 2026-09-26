@{
    Severity     = @('Error', 'Warning')
    IncludeRules = @(
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingWriteHost',
        'PSAvoidUsingPlainTextForPassword',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidGlobalVars'
    )
}
