/// Simulation of a LIS
Class FHIRToLabEx.TestEnv.LIS.Process Extends Ens.BusinessProcess [ ClassType = persistent, ProcedureBlock ]
{

/// Name of the business host to send HL7v2 messages to
Property TargetConfigName As Ens.DataType.ConfigName [ InitialExpression = "LIS_Out" ];

Parameter SETTINGS = "TargetConfigName:Basic";

Method OnRequest(pRequest As %Persistent, Output pResponse As %Persistent) As %Status
{
	#Dim tStatus As %Status = $$$OK

	/* ********************************************************************************
	**	If request is an ORM O01 message then do nothing
	*/

	If (pRequest.%IsA("EnsLib.HL7.Message")) {
		$$$LOGINFO("Accepted an HL7 message with message type " _ pRequest.GetValueAt("MSH:9"))
		Return $$$OK
	}

	/* ********************************************************************************
	**	Check that the request is a FHIRToLabEx.TestEnv.LIS.Message.ProcessAnOrderRequest
	*/

	If ('pRequest.%IsA("FHIRToLabEx.TestEnv.LIS.Message.ProcessAnOrderRequest")) {
		Return $$$ERROR($$$GeneralError, "Unexpected type of request " _ pRequest.%ClassName(1))
	}

	/* ********************************************************************************
	**	Get the next unprocessed order if any
	*/

	$$$LOGINFO("Looking for the next unprocessed order ...")
	#Dim tLastProcessedOrderId As %Integer = $Get(^FHIRToLabEx.TestEnv.LIS.Process.Last, 0)
	#Dim tHostName As %String = ..%ConfigName
	#Dim tId, tMessageBodyId As %Integer
	&Sql(Select Top(1) Id, MessageBodyId Into :tId, :tMessageBodyId From Ens.MessageHeader
			Where TargetConfigName = :tHostName
			  And MessageBodyClassName = 'EnsLib.HL7.Message'
			  And Id > :tLastProcessedOrderId
			Order By Id Asc)
	If (SQLCODE < 0) {
		// ToDo: use %Status instead
		Throw ##class(%Exception.SQL).CreateFromSQLCODE(SQLCODE, %msg)
	}
	If (SQLCODE = 100) {
		$$$LOGINFO("No new orders found. Id of the latest processed order message (message header) is " _ tLastProcessedOrderId)
		Return $$$OK
	}

	$$$LOGINFO("Found, message id = " _ tId _ ", body id = " _ tMessageBodyId)
	#Dim tHL7OrderMessage As EnsLib.HL7.Message = ##class(EnsLib.HL7.Message).%OpenId(tMessageBodyId)

	/* ********************************************************************************
	**	Process the order -> create an ORU R01 message
	*/

	$$$LOGINFO("Creating HL7 v2 message...")
	// Create the specific HL7v2 message: ORM O01
	#Dim tHL7Message As EnsLib.HL7.Message = ##class(EnsLib.HL7.Message).%New()
	Do tHL7Message.PokeDocType("2.3:ORU_R01")		// This is the document type for ORM O01 messages

	// MSH
	Do tHL7Message.SetValueAt("ORU", "MSH:9.1")
	Do tHL7Message.SetValueAt("R01", "MSH:9.2")
	Do tHL7Message.SetValueAt(tHL7OrderMessage.GetValueAt("MSH:5.1"), "MSH:3.1")
	Do tHL7Message.SetValueAt(tHL7OrderMessage.GetValueAt("MSH:3.1"), "MSH:5.1")
	Do tHL7Message.SetValueAt(tHL7OrderMessage.GetValueAt("MSH:6.1"), "MSH:4.1")
	Do tHL7Message.SetValueAt(tHL7OrderMessage.GetValueAt("MSH:4.1"), "MSH:6.1")

	// PID
	Set tStatus = tHL7Message.SetValueAt(tHL7OrderMessage.GetValueAt("PIDgrp.PID"), "PIDgrpgrp(1).PIDgrp.PID")
	If ($$$ISERR(tStatus)) Return tStatus

	// OBR
	Set tStatus = tHL7Message.SetValueAt(tHL7OrderMessage.GetValueAt("ORCgrp(1).OBRuniongrp.OBRunion.OBR"), "PIDgrpgrp(1).ORCgrp(1).OBR")
	If ($$$ISERR(tStatus)) Return tStatus
	Set tStatus = tHL7Message.SetValueAt(tHL7OrderMessage.GetValueAt("ORCgrp(1).ORC:2.1"), "PIDgrpgrp(1).ORCgrp(1).OBR:2(1).1")

	// OBX
	Set tStatus = tHL7Message.SetValueAt("OBX|1|NM|2001^S -K^LAB-KL-98|1|4.5|mmol/l^mmol/l^PYL-ML2|3.5-5.2||||F|||199809291002",
							"PIDgrpgrp(1).ORCgrp(1).OBXgrp(1).OBX")
	If ($$$ISERR(tStatus)) Return tStatus

	/* ********************************************************************************
	**	Send to HL7v2 message routing production
	*/
	$$$LOGINFO("Sending HL7 v2 message...")
	Set tStatus = ..SendRequestAsync(..TargetConfigName, tHL7Message, 0)
	If ($$$ISERR(tStatus)) Return tStatus

	/* ********************************************************************************
	**	Save the ID of the latest processed order
	*/

	Set ^FHIRToLabEx.TestEnv.LIS.Process.Last = tId

	Return tStatus
}

Storage Default
{
<Data name="ProcessDefaultData">
<Subscript>"Process"</Subscript>
<Value name="1">
<Value>TargetConfigName</Value>
</Value>
</Data>
<DefaultData>ProcessDefaultData</DefaultData>
<Type>%Storage.Persistent</Type>
}

}
