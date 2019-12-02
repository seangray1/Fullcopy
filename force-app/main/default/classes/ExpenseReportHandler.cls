/*
Versoin 1.0
Created by   - Prabha Kalaivani Kannan
Date         - 07/06/2016
Purpose      - Handler class for UpdateApprovedBy trigger on Expense__c object
*/
public class ExpenseReportHandler
{
    public static void updateApprovedBy(List<Expense__c> expenses)
    {   
        // Get all the expense ids whose 'Status' is Approved and 'Approved By' needs to be updated
        Set<Id> expenseIds= new Set<Id>();
        for(Expense__c exp : expenses)
        {
            if(exp.Status__c == 'Approved' && exp.Approved_by__c == null){
                expenseIds.add(exp.Id);
            }
        }
        
        if(!expenseIds.isEmpty()){            
            // Get all the approval process steps of all the expenses which needs an update
            Map<Id,ProcessInstance> expenseApprInstance = new Map<Id,ProcessInstance>();
            for(ProcessInstance processIns : [SELECT Id, LastModifiedById, Status, TargetObjectId,
                                                     (SELECT Id, ActorId, StepStatus FROM Steps)
                                              FROM ProcessInstance 
                                              WHERE TargetObjectId IN :expenseIds AND 
                                                    Status = 'Approved']){
                expenseApprInstance.put(processIns.TargetObjectId, processIns);
            }
                                                                                                    
            Id approverId;
            Integer index;
            Map<Id,Id> expApproverIdMap = new Map<Id,Id>();
            if( !expenseApprInstance.isEmpty() ){
                for(Expense__c exp: [SELECT Id,Status__c,Approved_By__c 
                                     FROM Expense__c 
                                     WHERE Id IN :expenseApprInstance.keySet()]){  
                    index = expenseApprInstance.get(exp.Id).Steps.size()-1;
                    while(index >= 0)
                    {
                        if(expenseApprInstance.get(exp.Id).Steps[index].StepStatus == 'Approved')
                        {
                            approverId = expenseApprInstance.get(exp.Id).Steps[index].ActorId;
                            expApproverIdMap.put(exp.Id, approverId);
                            break;
                        }
                        index--;
                    }
                }
            
                Map<Id,String> userIdNameMap = new Map<Id,String>();
                if( !expApproverIdMap.isEmpty() ){
                    for(User usr : [SELECT Id,Name FROM User WHERE Id IN :expApproverIdMap.values()]){
                        userIdNameMap.put(usr.Id,usr.Name);
                    }
                    
                    for(Expense__c exp : expenses){
                        if(expApproverIdMap.containsKey(exp.Id)){
                            exp.Approved_By__c = userIdNameMap.get(expApproverIdMap.get(exp.Id));
                        }
                    }
                }
            }
        }
    }      
}