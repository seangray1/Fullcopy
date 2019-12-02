/*
 * Helper class for the Contract Trigger - Rashmi Kalegowda(Perficient) - 10/26/2016
*/

public without sharing class ContractTriggerUtility {

    public final static string CONTRACT_STATUS_ACTIVATED = 'Activated';
    public final static string CONTRACT_STATUS_APPROVED = 'Approved';
    // helper method after Contract Insert
    public static void afterContractInsert( List<Contract> contracts ){
        updateERACheckboxOnAccounts( null, contracts );
    }
    
    // helper method after Contract Update
    public static void afterContractUpdate( Map<Id, Contract> oldContractsMap, List<Contract> newContracts ){
        updateERACheckboxOnAccounts( oldContractsMap, newContracts );       
    }
    
    //Set Account field ‘ERA’ checkbox to True when a related ERA record is created and the Status is set to ‘Active.’  
    //Set Account field ‘ERA’ checkbox to False when there are no ERA records associated with the Account where the Status is set to ‘Active.’
    private static void updateERACheckboxOnAccounts( Map<Id, Contract> oldContractsMap, List<Contract> newContracts ){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> userIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for( Contract con : newContracts ){
            Contract oldCon = oldContractsMap == null ? null : oldContractsMap.get( con.Id );
            if( (oldCon == null ) || ( oldCon.Status != con.Status && 
                                   (con.Status == CONTRACT_STATUS_ACTIVATED || oldCon.Status == CONTRACT_STATUS_ACTIVATED ) )){
                if( con.AccountId != null ){
                    accountIds.add( con.AccountId );
                }                
            }
            if( (oldCon == null ) || ( oldCon.Status != con.Status && 
                                     (con.Status == CONTRACT_STATUS_ACTIVATED  || con.Status == CONTRACT_STATUS_APPROVED))){
                 if( con.AE_Name__c != null){
                    userIds.add( con.AE_Name__c );
                }                         
            }
        }
        system.debug( accountIds );
        if( !accountIds.isEmpty() ){
            List<Account> accounts = [ SELECT Id, ERA__c, ( SELECT Id FROM Contracts WHERE Status =: CONTRACT_STATUS_ACTIVATED ) 
                                       FROM Account 
                                       WHERE Id IN :accountIds ];
            for( Account acc : accounts ){
                system.debug(acc);
                if( acc.Contracts.size() > 0 && !acc.ERA__c ){
                    acc.ERA__c = true;
                    accountsToUpdate.add( acc );
                }
                if( acc.Contracts.size() == 0 && acc.ERA__c ){
                    acc.ERA__c = false;
                    accountsToUpdate.add( acc );
                }
            }
        }
        
        if( !accountsToUpdate.isEmpty() ){
            update accountsToUpdate;
        }
       
    }
    
}