Class FHIRToLabEx.Util.DemoHelper Extends %CSP.Page
{

Parameter FHIRENDPOINTURL = "/fhirtolabex/fhir/r4";

ClassMethod OnPage() As %Status
{
	#Dim tStatus As %Status = $$$OK

	&html<
		<html>
			<head>
				<style> 
					table, th, td {
					  border: 1px solid black;
					  border-collapse: collapse;
					}
				</style>
			</head>
			<body>
		>


	Set tStatus = ..OnBody()

	&html<
			</body>
		</html>
		>

	Return tStatus
}

ClassMethod OnBody() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	Try {

		&Html<<h2>Phase 0: Reset FHIR Repo</h2>>

		&Html<<p>Delete the FHIR endpoint #(..#FHIRENDPOINTURL)# and create it again.</p>>
		&Html<>

		&Html<<h2>Phase 1: Make an order (ServiceRequest)</h2>>

		#Dim tCountPatients As %Integer = ..GetPatients()
		&Html<<p>
		#(tCountPatients)# Patient resources currently in the repository<br>
		<a href="FHIRToLabEx.Util.DemoHelper.PostAPatient.cls">POST a new Patient</a><br>
		>
		If (tCountPatients > 0) {
			&Html<<a href="FHIRToLabEx.Util.DemoHelper.PostAServiceRequest.cls">POST a new ServiceRequest</a><br>>
		}
		&Html<</p>>


		&Html<<h2>Phase 2: Laboratory processes an order (and sends results)</h2>>

		#Dim tCountUnprocessed As %Integer = ..GetActiveOrders()
		&Html<<p>
		#(tCountUnprocessed)# order(s) waiting to be processed in the laboratory<br>
		>
		&Html<<a href="FHIRToLabEx.Util.DemoHelper.ProcessLabOrder.cls">View laboratory orders</a><br>>
		If (tCountUnprocessed > 0) {
			&Html<Please restart business service <strong>LIS_InitiatorService</strong>
				to process the oldest order in the laboratory<br>>
		}
		&Html<</p>>


		&Html<<h2>Phase 3: Application reads the results</h2>>

		#Dim tCountResults As %Integer = ..GetResults()
		&Html<<p>
		#(tCountResults)# DiagnosticReport resources currently in the repository<br>
		>
		If (tCountResults > 0) {
			&Html<<a href="FHIRToLabEx.Util.DemoHelper.SearchResults.cls">Search for the latest DiagnosticReport resources</a><br>>
		}
		Else {
			&Html<There are no results available at the moment<br>>
		}
		&Html<</p>>
	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

/// Returns the count ServiceRequest resources found
ClassMethod GetRequests(Output pBundle As %DynamicObject, pQueryString As %String = "") As %Integer
{
	#Dim tRequest As HS.FHIRServer.Interop.Request
	Set tRequest = ..FHIRRequest("GET", "ServiceRequest", pQueryString)
	#Dim tResponse As HS.FHIRServer.Interop.Response = ..InvokeFHIR(tRequest, .pBundle)
	If ($IsObject($Get(pBundle))) {
		Return pBundle.total
	}

	Return 0
}

/// Returns the count orders that are not fullfilled by Laboratory
ClassMethod GetActiveOrders(Output pList As %ListOfObjects, pListProcessed As %Boolean = 0) As %Integer
{
	If ('$IsObject($Get(pList))) Set pList = ##class(%ListOfObjects).%New()

	#Dim tLastProcessedOrderId As %Integer = $Get(^FHIRToLabEx.TestEnv.LIS.Process.Last, 0)

    #Dim tStatement As %SQL.Statement = ##class(%SQL.Statement).%New()

    #Dim tSQL As %String
    Set tSQL = "Select Id, MessageBodyId From Ens.MessageHeader" _
				" Where TargetConfigName = 'LIS'" _
			  	" And MessageBodyClassName = 'EnsLib.HL7.Message'"
	If (pListProcessed) {
		Set tSQL = tSQL _ " And Id <= ?"
	}
	Else {
		Set tSQL = tSQL _ " And Id > ?"
	}
	Set tSQL = tSQL _ " Order By Id Asc"
    #Dim tStatus As %Status = tStatement.%Prepare(tSQL)
    If ($$$ISERR(tStatus)) {
        Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)
    }

    #Dim tResultSet As %SQL.StatementResult
    Set tResultSet = tStatement.%Execute(tLastProcessedOrderId)

    While (tResultSet.%Next()) {
        Do pList.Insert(##class(EnsLib.HL7.Message).%OpenId(tResultSet.MessageBodyId))
    }

    Return pList.Count()
}

ClassMethod ListActiveOrders(pListProcessed As %Boolean = 0) As %Integer
{
	#Dim tCountMessages As %Integer
	#Dim tMessages As %ListOfObjects
	#Dim iMessage As %Integer
	#Dim tMessage As EnsLib.HL7.Message

	Set tCountMessages = ..GetActiveOrders(.tMessages, pListProcessed)

	If (pListProcessed) {
		&Html<<h2>Processed Lab Orders (ORM R01 messages)</h2>>
	}
	Else {
		&Html<<h2>Unprocessed Lab Orders (ORM R01 messages)</h2>>
	}

	&Html<<p><table>>
	&Html<<tr><th>Id (of body)</th><th>identifier</th><th>patientID</th></tr>>
	For iMessage = 1:1:tCountMessages {
		Set tMessage = tMessages.GetAt(iMessage)
		&Html<<tr>>
		&Html<<td>#(tMessage.%Id())#</td>>
		&Html<<td>#(tMessage.GetValueAt("ORCgrp(1).ORC:2.1"))#</td>>
		&Html<<td>#(tMessage.GetValueAt("PIDgrp.PID:2.1"))#</td>>
		&Html<</tr>>
	}
	&Html<</table></p>>

	Return tCountMessages
}

ClassMethod ListRequests()
{
	#Dim tKey As %String
	#Dim tCountResults As %Integer
	#Dim tResources As %ArrayOfObjects
	#Dim iResult As %Integer
	#Dim tResult As %DynamicObject
	#Dim tBundle As %DynamicObject
	#Dim i As %Integer
	#Dim tObject As %DynamicAbstractObject

	Set tCountResults = ..GetRequests(.tBundle, "_sort=-_lastUpdated")

	Set tResources = ##class(%ArrayOfObjects).%New()
	For iResult = 1:1:tCountResults {
		Set tResult = tBundle.entry.%Get(iResult-1).resource
		Do tResources.SetAt(tResult, $ZDateTimeH($Translate(tResult.meta.lastUpdated, "TZ", " "), 3))
	}

	&Html<<h2>ServiceRequest resources</h2>>

	&Html<<p><table>>
	&Html<<tr>
			<th>id</th>
			<th>meta.lastUpdated</th>
			<th>identifiers</th>
			<th>status</th>
			<th>subject.reference</th>
			</tr>>
	Set tKey = tResources.Next("")
	While (tKey '= "") {
		Set tResult = tResources.GetAt(tKey)

		If ('$IsObject(tResult)) {
			&Html<tBundle = #(tBundle)#<br>>
			&Html<tBundle.entry = #(tBundle.entry)#<br>>
			Return
		}
		&Html<<tr>>
		&Html<<td>#(tResult.id)#</td>>
		&Html<<td>#(tResult.meta.lastUpdated)#</td>>
		&Html<<td>>
		If (tResult.identifier '= "") {
			For i=0:1:99 {
				Set tObject = tResult.identifier.%Get(i)
				If ('$IsObject(tObject)) Quit
				Write:i ", "
				&Html<#(tObject.value)#>
			}
		}
		&Html<</td>>
		&Html<<td>#(tResult.status)#</td>>
		&Html<<td>#(tResult.subject.reference)#</td>>
		&Html<</tr>>

		Set tKey = tResources.Next(tKey)
	}
	&Html<</table></p>>
}

ClassMethod ListPatients()
{
	#Dim tKey As %String
	#Dim tCountResults As %Integer
	#Dim tResources As %ArrayOfObjects
	#Dim iResult As %Integer
	#Dim tResult As %DynamicObject
	#Dim tBundle As %DynamicObject
	#Dim i As %Integer
	#Dim tObject As %DynamicAbstractObject

	Set tCountResults = ..GetPatients(.tBundle, "_sort=-_lastUpdated")

	Set tResources = ##class(%ArrayOfObjects).%New()
	For iResult = 1:1:tCountResults {
		Set tResult = tBundle.entry.%Get(iResult-1).resource
		Do tResources.SetAt(tResult, $ZDateTimeH($Translate(tResult.meta.lastUpdated, "TZ", " "), 3))
	}

	&Html<<h2>Patient resources</h2>>

	&Html<<p><table>>
	&Html<<tr>
			<th>id</th>
			<th>meta.lastUpdated</th>
			<th>identifiers</th>
			</tr>>
	Set tKey = tResources.Next("")
	While (tKey '= "") {
		Set tResult = tResources.GetAt(tKey)

		If ('$IsObject(tResult)) {
			&Html<tBundle = #(tBundle)#<br>>
			&Html<tBundle.entry = #(tBundle.entry)#<br>>
			Return
		}
		&Html<<tr>>
		&Html<<td>#(tResult.id)#</td>>
		&Html<<td>#(tResult.meta.lastUpdated)#</td>>
		&Html<<td>>
		If (tResult.identifier '= "") {
			For i=0:1:99 {
				Set tObject = tResult.identifier.%Get(i)
				If ('$IsObject(tObject)) Quit
				Write:i ", "
				&Html<#(tObject.value)#>
			}
		}
		&Html<</td>>
		&Html<</tr>>

		Set tKey = tResources.Next(tKey)
	}
	&Html<</table></p>>
}

/// Returns the count Patient resources found
ClassMethod GetPatients(Output pBundle As %DynamicObject, pQueryString As %String = "") As %Integer
{
	#Dim tRequest As HS.FHIRServer.Interop.Request
	Set tRequest = ..FHIRRequest("GET", "Patient", pQueryString)
	#Dim tResponse As HS.FHIRServer.Interop.Response = ..InvokeFHIR(tRequest, .pBundle)
	If ($IsObject($Get(pBundle))) {
		Return pBundle.total
	}

	Return 0
}

/// Returns the count DiagnosticReport resources found
ClassMethod GetResults(Output pBundle As %DynamicObject, pQueryString As %String = "") As %Integer
{
	#Dim tRequest As HS.FHIRServer.Interop.Request
	Set tRequest = ..FHIRRequest("GET", "DiagnosticReport", pQueryString)
	#Dim tResponse As HS.FHIRServer.Interop.Response = ..InvokeFHIR(tRequest, .pBundle)
	If ($IsObject($Get(pBundle))) {
		Return pBundle.total
	}

	Return 0
}

ClassMethod InvokeFHIR(pRequest As HS.FHIRServer.Interop.Request, Output pResponseBody As %DynamicObject = {$$$NULLOREF}) As HS.FHIRServer.Interop.Response
{
	#Dim tStatus As %Status = $$$OK

	#Dim tService As FHIRToLabEx.Util.Service
	Set tStatus = ##class(Ens.Director).CreateBusinessService("FHIRToLabEx.Util.Service", .tService)
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

 	#Dim tResponse As HS.FHIRServer.Interop.Response
	Set tStatus = tService.ProcessInput(pRequest, .tResponse)
	If ($$$ISERR(tStatus)) Throw ##class(%Exception.StatusException).CreateFromStatus(tStatus)

	If ('$IsObject(tResponse)) {
		Throw ##class(%Exception.General).%New("ERROR", "2022",, "Timeout when waiting for response from business host '" _ tService.TargetConfigName _ "' to request '" _ pRequest.Request.RequestPath _ "'")
	}

	If (tResponse.QuickStreamId '= "") {
		#Dim tQuickStream As HS.SDA3.QuickStream = ##class(HS.SDA3.QuickStream).%OpenId(tResponse.QuickStreamId)
		Set pResponseBody = {}.%FromJSON(tQuickStream)
	}

	Return tResponse
}

ClassMethod FHIRRequest(pRequestMethod As %String, pRequestPath As %String, pQueryString As %String = "", pBody As %DynamicObject = {$$$NULLOREF}) As HS.FHIRServer.Interop.Request
{
	#Dim tRequest As HS.FHIRServer.Interop.Request = ##class(HS.FHIRServer.Interop.Request).%New()
	Set tRequest.Request.SessionApplication = ..#FHIRENDPOINTURL
	Set tRequest.Request.RequestMethod = pRequestMethod
	Set tRequest.Request.RequestPath = pRequestPath
	Set tRequest.Request.QueryString = pQueryString
	Set tRequest.Request.RequestFormatCode = "JSON"
	Set tRequest.Request.ResponseFormatCode = "JSON"

	If ($IsObject(pBody)) {
		Set tQuickStream = ##class(HS.SDA3.QuickStream).%New()
		Do tQuickStream.Write(pBody.%ToJSON())
		Set tRequest.QuickStreamId = tQuickStream.%Id()
	}

	Return tRequest
}

}
