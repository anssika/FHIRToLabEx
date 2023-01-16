Class FHIRToLabEx.Util.DemoHelper.ProcessLabOrder Extends FHIRToLabEx.Util.DemoHelper
{

ClassMethod OnBody() As %Status
{
	#Dim tStatus As %Status = $$$OK
	#Dim tException As %Exception.AbstractException

	#Dim tJSON As %String

	Try {

		&Html<<p><a href="FHIRToLabEx.Util.DemoHelper.cls">Home</a></p>>

		#Dim tCountUnprocessed As %Integer = ..ListActiveOrders()
		&Html<To process the oldest order in the laboratory, please restart business service <strong>LIS_InitiatorService</strong><br>>
		If (tCountUnprocessed = 0) {
			&Html<<strong>There are currently no orders to process.</strong></p>>
		}

		Do ..ListActiveOrders(1)

	}
	Catch tException {
		//Set tStatus = tException.AsStatus()
		#Dim tError As %String = tException.DisplayString()
		&Html<<p>#(tError)#</p>>
	}

	Return tStatus
}

}
