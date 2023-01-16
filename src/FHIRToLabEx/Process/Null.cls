/// 
Class FHIRToLabEx.Process.Null Extends Ens.BusinessProcessBPL
{

/// BPL Definition
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='Ens.Request' height='2000' width='2000' >
<sequence xend='200' yend='399' >
<empty name='Do Nothing' xpos='401' ypos='282' />
</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
