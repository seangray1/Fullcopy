public class GeneratePDFWaiverLT {
    @AuraEnabled
    public static Waiver__c getWaiver(String waiverId){
        Waiver__c val = [	select 	Id, 
                         			Waiver_Or_Letter_Type__c,
                         			Approved_By_Id__c,
                         			Conga_URL__c 
                         	from Waiver__c 
                         	where Id =: waiverId];
        return val;
    }
    
}