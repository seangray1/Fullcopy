/**
* @author           kanitha Priya P
* @version          1.0
* @date             27-07-2017
* @status           Developed
* @Description      The purpose of this trigger is to avoid users from making two locations default for a single office.
*  A single office can have only one default location.
**/
trigger MRLocationTrigger on MRLocation__c (before insert,before update) {

    public List<MRLocation__c> MRLst = new List<MRLocation__c>();
    public Map<Id,MRLocation__c> MRMap = new Map<Id,MRLocation__c>();
    public Set<Id> Off_Id = new Set<Id>();
    public List<String> Div = new List<String>();
    
    for(MRLocation__c loc : Trigger.New)
    {
        Off_Id.add(loc.Office__r.Id);
        Div.add(loc.Division__c);
    }
    // Fetches all the related MR Locations based on office and division from Job
    MRLst = PRLDE_DataUtility.FetchMRLocations(Off_Id,Div);

    //Update Operation
    if(Trigger.isUpdate)
    {
        for(MRLocation__c loc : Trigger.Old)
        {
            MRMap.put(loc.Id,loc);
        }
        for(MRLocation__c locNew : Trigger.New)
        {
            if(MRMap.get(locNew.Id).IsDefault__c != true && locNew.IsDefault__c == true)
            {
                for(MRLocation__c locLst : MRLst)
                {
                    system.debug(Logginglevel.info,'==locNew + locLst =='+locNew+' '+locLst);
                    
                    if(locNew.Id != locLst.Id && locNew.Office__c == locLst.Office__r.Id && locNew.Division__c == locLst.Division__c && locLst.IsDefault__c == true )
                    {
                        //If an existing location of same office and division has IsDefault set to true, an error messge will be thrown
                        locNew.addError('The Office '+locLst.Office__r.Name+' has another Location '+LocLst.Name+' with IsDefault set to true');
                    }
                }
            }
        
        }
    }
    //Insert Operation
    if(Trigger.isInsert)
    {
        for(MRLocation__c locNew : Trigger.New)
        {
            if(locNew.IsDefault__c == true)
            {
                for(MRLocation__c locLst : MRLst)
                {
                    system.debug(Logginglevel.info,'==locNew + locLst =='+locNew+' '+locLst);
                    
                    if(locNew.Office__c == locLst.Office__r.Id && locNew.Division__c == locLst.Division__c && locLst.IsDefault__c == true )
                    {
                        //If an existing location of same office and division has IsDefault set to true, an error messge will be thrown
                        locNew.addError('The Office '+locLst.Office__r.Name+' has another Location '+LocLst.Name+' with IsDefault set to true');
                    }
                }
            }
        
        }
    }
}