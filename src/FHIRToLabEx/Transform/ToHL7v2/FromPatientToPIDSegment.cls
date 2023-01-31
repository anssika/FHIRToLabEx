Class FHIRToLabEx.Transform.ToHL7v2.FromPatientToPIDSegment Extends Ens.DataTransform
{

ClassMethod Transform(pSource As %RegisteredObject, Output pHL7v2Segment As EnsLib.HL7.Segment) As %Status
{
	#Dim pPatient As %DynamicObject = pSource

	#Dim tStatus As %Status = $$$OK
	#Dim i As %Integer

	// Create the segment
	//
	Set pHL7v2Segment = ##class(EnsLib.HL7.Segment).%New()
	Do pHL7v2Segment.PokeDocType("2.3.1:PID")
	Do pHL7v2Segment.SetValueAt($Piece(pHL7v2Segment.DocTypeName,"-"),0)

	// Identifiers
	// 
	// PLEASE NOTE: these mappins are not correct - their purpose is to demonstrate HOW you can do the mappings, NOT WHAT mappings to do
	//
	Set i = 0
	While (pPatient.identifier.%Get(i) '= "") {
		#Dim tIdentifier As %DynamicObject = pPatient.identifier.%Get(i)
		// 3=PatientIdentifierList
		Set tStatus = pHL7v2Segment.SetValueAt(tIdentifier.value, "3("_i_").1")
		Set tStatus = pHL7v2Segment.SetValueAt(tIdentifier.system, "3("_i_").4.1")
		If (tIdentifier.use '= "") {
			Set tStatus = pHL7v2Segment.SetValueAt(tIdentifier.use, "3("_i_").5")
		}
		// 2=PatientID
		If (tIdentifier.system = "urn:oid:1.2.246.21") {
			Set tStatus = pHL7v2Segment.SetValueAt(tIdentifier.value, "2.1")
			Set tStatus = pHL7v2Segment.SetValueAt(tIdentifier.system, "2.4.1")
			If (tIdentifier.use '= "") {
				Set tStatus = pHL7v2Segment.SetValueAt(tIdentifier.use, "2.4.5")
			}
		}

		Set i = i + 1
	}

	// Name
	// 
	// PLEASE NOTE: these mappins are not correct - their purpose is to demonstrate HOW you can do the mappings, NOT WHAT mappings to do
	//
	// 5=PatientName
	If ((pPatient.name = "") || (pPatient.name.%Get(0) = "") || (pPatient.name.%Get(1) '= "")) {
		Return $$$ERROR($$$GeneralError, "Exactly 1 name for Patient is expected.")
	}
	Set tStatus = pHL7v2Segment.SetValueAt(pPatient.name.%Get(0).family, "5.1.1")
	#Dim tGivenNames As %String = pPatient.name.%Get(0).given.%Get(0)
	Set i=1
	While (pPatient.name.%Get(0).given.%Get(i) '= "") {
		Set tGivenNames = tGivenNames _ " " _ pPatient.name.%Get(0).given.%Get(i)
		Set i = i + 1
	}
	Set tStatus = pHL7v2Segment.SetValueAt(tGivenNames, "5.2")

	// ...

	Quit tStatus
}

/// Do ##class(FHIRToLabEx.Transform.ToHL7v2.FromPatientToPIDSegment).Test()
ClassMethod Test()
{
	#Dim tQuickStream As HS.SDA3.QuickStream = ##class(HS.SDA3.QuickStream).%OpenId("T18")
	Write "tQuickStream = " _ tQuickStream, !
	#Dim tPatient As %DynamicObject = {}.%FromJSON(tQuickStream)
	Write "tPatient = " _ tPatient, !

	#Dim tStatus As %Status
	#Dim tSegment As EnsLib.HL7.Segment
	Set tStatus = ..Transform(tPatient, .tSegment)

	Write "tSegment.DocTypeName = " _ tSegment.DocTypeName, !
	Write "tSegment.OutputToString() = " _ tSegment.OutputToString(), !
}

}
