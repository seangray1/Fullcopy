public class SendERAforSignatureLT {
    
    @AuraEnabled
    public static Contract getContract(String contractId){
        Contract res = [select Id, Status, Echo_Sign_URL__c from Contract where Id=: contractId];
        return res;
    }
    

}