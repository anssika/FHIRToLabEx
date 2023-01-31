Class FHIRTOLABEXPKG.FoundationProduction Extends Ens.Production [ Not ProcedureBlock ]
{

XData ProductionDefinition
{
<Production Name="FHIRTOLABEXPKG.FoundationProduction" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>1</ActorPoolSize>
  <Item Name="Ens.Activity.Operation.Local" Category="" ClassName="Ens.Activity.Operation.Local" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="HS.Util.Trace.Operations" Category="" ClassName="HS.Util.Trace.Operations" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="FHIRRequestRouter" Category="From_PatientSystem,Solution" ClassName="EnsLib.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="BusinessRuleName">FHIRToLabEx.Rule.FHIRRequestRouter</Setting>
    <Setting Target="Host" Name="ResponseFrom">FHIRInteractionNotSupported,FHIRResourceRepository,FHIRServiceRequestProcessor,FHIRPatientProcessor</Setting>
  </Item>
  <Item Name="From_FHIR_API" Category="From_PatientSystem,Solution" ClassName="FHIRToLabEx.FHIRServer.Interop.Service" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TargetConfigName">FHIRRequestRouter</Setting>
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
  </Item>
  <Item Name="FHIRServiceRequestProcessor" Category="From_PatientSystem,Solution" ClassName="FHIRToLabEx.Process.FHIRServiceRequestProcessor" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
  </Item>
  <Item Name="FHIRInteractionNotSupported" Category="From_PatientSystem,Solution" ClassName="FHIRToLabEx.Process.FHIRInteractionNotSupported" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="FHIRResourceRepository" Category="From_PatientSystem,Solution,From_LIS" ClassName="FHIRToLabEx.FHIRServer.Interop.Operation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
  </Item>
  <Item Name="Null" Category="Etc" ClassName="FHIRToLabEx.Process.Null" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="From_Test" Category="Etc" ClassName="EnsLib.HL7.Service.FileService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.3</Setting>
    <Setting Target="Host" Name="TargetConfigNames">Null</Setting>
    <Setting Target="Adapter" Name="FileSpec">*</Setting>
    <Setting Target="Adapter" Name="FilePath">C:\FIleInOut\FHIRToLabEx\HL7v2TestIn\</Setting>
    <Setting Target="Host" Name="DefCharEncoding">utf-8</Setting>
  </Item>
  <Item Name="To_Laboratory" Category="Solution,From_PatientSystem" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">localhost</Setting>
    <Setting Target="Adapter" Name="Port">51003</Setting>
  </Item>
  <Item Name="HL7v2MessageProcessor" Category="Solution,From_LIS" ClassName="FHIRToLabEx.Process.HL7v2MessageProcessor" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="From_Laboratory" Category="From_LIS,Solution" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.3</Setting>
    <Setting Target="Host" Name="TargetConfigNames">HL7v2MessageProcessor</Setting>
    <Setting Target="Host" Name="Framing">MLLP</Setting>
    <Setting Target="Adapter" Name="Port">51002</Setting>
  </Item>
  <Item Name="FHIRPatientProcessor" Category="From_PatientSystem,Solution" ClassName="FHIRToLabEx.Process.FHIRPatientProcessor" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="TraceOperations">*FULL*</Setting>
  </Item>
  <Item Name="LIS" Category="TestEnv" ClassName="FHIRToLabEx.TestEnv.LIS.Process" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
  <Item Name="LIS_Out" Category="TestEnv" ClassName="EnsLib.HL7.Operation.TCPOperation" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="IPAddress">localhost</Setting>
    <Setting Target="Adapter" Name="Port">51002</Setting>
  </Item>
  <Item Name="LIS_InitiatorService" Category="TestEnv" ClassName="FHIRToLabEx.TestEnv.LIS.Service" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="CallInterval">3600000</Setting>
  </Item>
  <Item Name="LIS_In" Category="TestEnv" ClassName="EnsLib.HL7.Service.TCPService" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Host" Name="MessageSchemaCategory">2.3</Setting>
    <Setting Target="Adapter" Name="Port">51003</Setting>
    <Setting Target="Host" Name="Framing">MLLP</Setting>
    <Setting Target="Host" Name="TargetConfigNames">LIS</Setting>
  </Item>
  <Item Name="FHIRToLabEx.Util.Service" Category="" ClassName="FHIRToLabEx.Util.Service" PoolSize="0" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
  </Item>
</Production>
}

}
