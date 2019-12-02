/* Author - Maharajan C
* Created - 26/03/2018
* Status - Developed
* Purpose - Move cases and chat transcripts when Live Chat lead is getting converted
*/
trigger ConvertLeadCasetoContactCase on Lead (after update) 
{
    List<Lead> BusinessAccLeadslst = new List<Lead>();
    List<Lead> PersonAccLeadlst = new List<Lead>();
    If(Trigger.isAfter)
    {
        If(Trigger.isUpdate)
        {
            for(Lead ld : Trigger.New)
            {
                if(ld.IsConverted == True && ld.ConvertedContactId != null && ld.Company !=null && ld.LeadSource == 'Live Chat')
                {
                    BusinessAccLeadslst.add(ld);
                } 
                
                if(ld.IsConverted == True && ld.ConvertedAccountId != null && ld.Company ==null && ld.LeadSource == 'Live Chat')
                {
                    PersonAccLeadlst.add(ld);
                }
            }
        }
    }
    
    If(BusinessAccLeadslst.size() > 0)
    {
        ConvertLeadCasetoAccorConCasehelper.convertBusinessAccount(BusinessAccLeadslst);
    }
    
    If(PersonAccLeadlst.size() > 0)
    {
        ConvertLeadCasetoAccorConCasehelper.convertPersonAccount(PersonAccLeadlst);
    }
    
}