/// 
Class FHIRToLabEx.Rule.FHIRRequestRouter Extends Ens.Rule.Definition
{

Parameter RuleAssistClass = "EnsLib.MsgRouter.RuleAssist";

XData RuleDefinition [ XMLNamespace = "http://www.intersystems.com/rule" ]
{
<ruleDefinition alias="" context="EnsLib.MsgRouter.RoutingEngine" production="FHIRTOLABEXPKG.FoundationProduction">
<ruleSet name="" effectiveBegin="" effectiveEnd="">
<rule name="FromPatientSystems" disabled="false">
<when condition="(%request.Request.RequestPath StartsWith &quot;Patient&quot;)&amp;&amp;((%request.Request.RequestMethod=&quot;GET&quot;) &#124;&#124; ((%request.Request.RequestPath Contains &quot;_search&quot;)&amp;&amp;(%request.Request.RequestMethod=&quot;POST&quot;)))">
<send transform="" target="FHIRResourceRepository"></send>
</when>
<when condition="(%request.Request.RequestPath StartsWith &quot;Patient&quot;) &amp;&amp; ((%request.Request.RequestMethod=&quot;POST&quot;) &#124;&#124; (%request.Request.RequestMethod=&quot;PUT&quot;) &#124;&#124; (%request.Request.RequestMethod=&quot;DELETE&quot;))">
<send transform="" target="FHIRPatientProcessor"></send>
</when>
<when condition="(%request.Request.RequestPath StartsWith &quot;ServiceRequest&quot;)&amp;&amp;((%request.Request.RequestMethod=&quot;GET&quot;) &#124;&#124; ((%request.Request.RequestPath Contains &quot;_search&quot;)&amp;&amp;(%request.Request.RequestMethod=&quot;POST&quot;)))">
<send transform="" target="FHIRResourceRepository"></send>
</when>
<when condition="(%request.Request.RequestPath StartsWith &quot;ServiceRequest&quot;) &amp;&amp; ((%request.Request.RequestMethod=&quot;POST&quot;) &#124;&#124; (%request.Request.RequestMethod=&quot;PUT&quot;) &#124;&#124; (%request.Request.RequestMethod=&quot;DELETE&quot;))">
<send transform="" target="FHIRServiceRequestProcessor"></send>
</when>
<when condition="(%request.Request.RequestPath StartsWith &quot;DiagnosticReport&quot;)&amp;&amp;((%request.Request.RequestMethod=&quot;GET&quot;) &#124;&#124; ((%request.Request.RequestPath Contains &quot;_search&quot;)&amp;&amp;(%request.Request.RequestMethod=&quot;POST&quot;)))">
<send transform="" target="FHIRResourceRepository"></send>
</when>
<when condition="(%request.Request.RequestPath StartsWith &quot;DiagnosticReport&quot;) &amp;&amp; (%request.Request.RequestMethod=&quot;DELETE&quot;)">
<send transform="" target="FHIRResourceRepository"></send>
</when>
<otherwise>
<send transform="" target="FHIRInteractionNotSupported"></send>
</otherwise>
</rule>
</ruleSet>
</ruleDefinition>
}

}
