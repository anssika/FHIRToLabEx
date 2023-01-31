/// <p>A customised class for using journaled alternatives of message classes <class>HS.FHIRServer.Interop.Request</class> and <class>HS.FHIRServer.Interop.Response</class></p>
/// 
Class FHIRToLabEx.FHIRServer.Interop.Operation Extends HS.FHIRServer.Interop.Operation
{

XData MessageMap
{
<MapItems>
	<MapItem MessageType="FHIRToLabEx.FHIRServer.Interop.Request">
		<Method>DispatchRequest2</Method>
	</MapItem>
</MapItems>
}

Method DispatchRequest2(pInteropRequest As FHIRToLabEx.FHIRServer.Interop.Request, Output pInteropResponse As FHIRToLabEx.FHIRServer.Interop.Response) As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tRequest As HS.FHIRServer.Interop.Request = $$$NULLOREF
	#Dim tResponse As HS.FHIRServer.Interop.Response = $$$NULLOREF

	Try {
		Set tRequest = pInteropRequest.ToHSRequest()
		Set tStatus = ..DispatchRequest(tRequest, .tResponse)
 $$$LOGINFO("tResponse = " _ tResponse)
		If ($IsObject(tResponse)) {
 $$$LOGINFO("pInteropResponse = " _ pInteropResponse)
			Set pInteropResponse = ##class(FHIRToLabEx.FHIRServer.Interop.Response).FromHSResponse(tResponse)
		}
	} Catch tException {
		Set tStatus = tException.AsStatus()
	}

	// Clear the QuickStreams: of both the request and the response
	#Dim tQuickStream As HS.SDA3.QuickStream
	If ($IsObject(tRequest) && (tRequest.QuickStreamId '= "")) {
		Set tQuickStream = ##class(HS.SDA3.QuickStream).%OpenId(tRequest.QuickStreamId)
		Do tQuickStream.Clear(1)
	}
	If ($IsObject(tResponse) && (tResponse.QuickStreamId '= "")) {
		Set tQuickStream = ##class(HS.SDA3.QuickStream).%OpenId(tResponse.QuickStreamId)
		Do tQuickStream.Clear(1)
	}

	Return tStatus
}

}
