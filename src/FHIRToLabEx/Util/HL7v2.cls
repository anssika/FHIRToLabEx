Class FHIRToLabEx.Util.HL7v2
{

/// w ##class(FHIRToLabEx.Util.HL7v2).GetNextMessageControlID()
ClassMethod GetNextMessageControlID() As %String
{
	#Dim tNextMessageControlID As %String = $ZTimeStamp		// UTC time (in $Horolog format) in the precision of ms
	Set tNextMessageControlID = $Translate(tNextMessageControlID, ",.")
	Set tNextMessageControlID = tNextMessageControlID _ "-" _ $Increment(^FHIRToLabEx.ToHL7v2.MessageControlID)

	If (^FHIRToLabEx.ToHL7v2.MessageControlID >= 10000000) {
		// $Increment is atomic and does not require locking
		Do $Increment(^FHIRToLabEx.ToHL7v2.MessageControlID, -899999)
	}

	Return tNextMessageControlID
}

}
