using System;
using System.Management.Automation;

namespace PSNetScanners;

internal static class ExceptionHelpers
{
    internal static void WriteTimeoutError(this Exception exception, PSCmdlet cmdlet) =>
        cmdlet.WriteError(new ErrorRecord(
            new TimeoutException("Timeout has been reached.", exception),
            "TimeOutReached",
            ErrorCategory.OperationTimeout,
            cmdlet));

    internal static ErrorRecord CreateProcessing(this Exception exception, object context) =>
        new(exception, errorId: "ProcessingTaskFailure", ErrorCategory.ConnectionError, context);

    internal static void WriteUnspecifiedError(this Exception exception, PSCmdlet cmdlet) =>
        cmdlet.WriteError(new ErrorRecord(
            exception, "UnspecifiedCmdletError", ErrorCategory.NotSpecified, cmdlet));
}
