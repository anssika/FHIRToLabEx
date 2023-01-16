/// 
Class FHIRToLabEx.Process.FHIRInteractionNotSupported Extends (Ens.BusinessProcess, HS.HC.Util.Trace.Helper) [ ClassType = persistent, ProcedureBlock ]
{

Method OnRequest(pRequest As HS.FHIRServer.Interop.Request, Output pResponse As HS.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK
	Set tStatus = ##class(FHIRToLabEx.Util.FHIRMessage).FHIRServerInteropResponseError(.pResponse,
							"404 Not Found", "error", "not-supported")

	If $$$HSTRACING {
		If pResponse.QuickStreamId'="" {
			Set quickStreamIn = ##class(HS.SDA3.QuickStream).%OpenId(pResponse.QuickStreamId)
			$$$HSTRACE("Response QuickStream", "quickStreamOut", pResponse, quickStreamIn)
		} Else {
			$$$HSTRACE("Response message", "pResponse", pResponse)
		}
	}

	Return pResponse
}

Storage Default
{
<Data name="FHIRInteractionNotSupportedDefaultData">
<Subscript>"FHIRInteractionNotSupported"</Subscript>
<Value name="1">
<Value>TraceOperations</Value>
</Value>
</Data>
<DefaultData>FHIRInteractionNotSupportedDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
