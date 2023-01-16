Class FHIRToLabEx.Transform.ToHL7v2.MSH Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.3.1:ACK' targetDocType='2.3.1:ACK' create='existing' language='objectscript' >
<assign value='"Patient System"' property='target.{MSH:SendingApplication.namespaceID}' action='set' />
<assign value='"LIS"' property='target.{MSH:ReceivingApplication.namespaceID}' action='set' />
<assign value='"Test LIS"' property='target.{MSH:ReceivingFacility.namespaceID}' action='set' />
<assign value='$Translate($ZDateTime($Horolog, 3), " -:")' property='target.{MSH:DateTimeOfMessage.timeofanevent}' action='set' />
<assign value='"2.3"' property='target.{MSH:VersionID}' action='set' />
<assign value='"8859/1"' property='target.{MSH:PrincipalLanguageOfMessage.identifier}' action='set' />
<assign value='"Test PatientSystem"' property='target.{MSH:SendingFacility.namespaceID}' action='set' />
<assign value='##class(FHIRToLabEx.Util.HL7v2).GetNextMessageControlID()' property='target.{MSH:MessageControlID}' action='set' />
</transform>
}

}
