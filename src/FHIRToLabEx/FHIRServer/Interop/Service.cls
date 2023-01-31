Include HS.FHIRServer

/// <p>A customised class for using journaled alternatives of message classes <class>HS.FHIRServer.Interop.Request</class> and <class>HS.FHIRServer.Interop.Response</class></p>
/// 
Class FHIRToLabEx.FHIRServer.Interop.Service Extends HS.FHIRServer.Interop.Service
{

/// Process an incoming message into the production; dispatch it to the configured target.
/// The Interoperability contract requires that errors be returned as %Status here.
Method OnProcessInput(pRequest As HS.FHIRServer.Interop.Request, Output pResponse As HS.FHIRServer.Interop.Response) As %Status
{
	#dim tSC As %Status = $$$OK
	
	Try {
		If $$$HSTRACING {
			// Log a clone of pRequest, in case the contents are modified after this
			// point, for example by custom processing. Logging of QuickStream will
			// read the contents of the QuickStream into the log, effectively cloning
			// the contents.
			If pRequest.QuickStreamId'="" {
				Set quickStreamIn = ##class(HS.SDA3.QuickStream).%OpenId(pRequest.QuickStreamId)
				$$$HSTRACE("Request message", "pRequest,quickStreamIn", pRequest.%ConstructClone(1), quickStreamIn)
			} Else {
				$$$HSTRACE("Request message", "pRequest", pRequest.%ConstructClone(1))
			}
		}
		
		// Make sure the input message is sensible
		If 'pRequest.%IsA("HS.FHIRServer.Interop.Request") {
			Set tSC = $$$EnsError($$$EnsErrClassNotDerived,pRequest.%ClassName(1), "HS.FHIRServer.Interop.Request")
			Quit
		}

		Set tStart = $ZH

		// ================================================================================
		// Start of the customization: use journaled interoperability messages instead

		#Dim tRequest As FHIRToLabEx.FHIRServer.Interop.Request
		Set tRequest = ##class(FHIRToLabEx.FHIRServer.Interop.Request).FromHSRequest(pRequest)
		#Dim tResponse As FHIRToLabEx.FHIRServer.Interop.Response

		// Now dispatch with timeout
		Set tSC = ..SendRequestSync(..TargetConfigName, tRequest, .tResponse, ..Timeout)

		If ($IsObject($Get(tResponse))) {
			Set pResponse = tResponse.ToHSResponse()
		}

		// End of the customization (use journaled interoperability messages instead)
		// ================================================================================

		Set tEnd=$ZH, tElapsed=tEnd-tStart
		$$$FSLog("Request took " _ tElapsed _ " secs.  Status=" _ tSC)
		Quit:$$$ISERR(tSC)
		
		// Make sure the output message is sensible
		If $IsObject($Get(pResponse)) {
			If 'pResponse.%IsA("HS.FHIRServer.Interop.Response") {
				Set tSC = $$$EnsError($$$EnsErrClassNotDerived, pResponse.%ClassName(1), "HS.FHIRServer.Interop.Response")
				Quit
			}
		} Else {
			// Timeout on SendRequestSync does not cause it to return error.
			// The symptom of SendRequestSync timeout is lack of response object.
			$$$ThrowFHIR($$$HSFHIRErrEnsembleTimeout)
		}
		If $IsObject(pResponse.Response) {
			If 'pResponse.Response.%IsA("HS.FHIRServer.API.Data.Response") {
				Set tSC = $$$EnsError($$$EnsErrClassNotDerived, pResponse.Response.%ClassName(1), "HS.FHIRServer.API.Data.Response")
				Quit
			}
		}
		
	} Catch eException {
		Set tSC = eException.AsStatus()
	}
	
	Quit tSC
}

}
