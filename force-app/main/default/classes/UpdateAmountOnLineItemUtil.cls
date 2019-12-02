/*
* Utility Class for Trigger UpdateAmountOnLineItem - s.jeyarammoorthy - 6/28/2016 
*/
public class UpdateAmountOnLineItemUtil {
    
    public static void UpdateOperations(Map<Id,Expense_Line_Item__c> oldExpensesMap , 
                                        Map<Id,Expense_Line_Item__c> newExpensesMap ){
		set<id>expenseIds = new set<id>();
		set<id>lineItemIds = new set<id>();
		set<string>names = new set<String>();  
        for(Expense_Line_Item__c opp: newExpensesMap.values()){
            Expense_Line_Item__c oldExpense = oldExpensesMap.get(opp.id);
       		if( oldExpense.Amount__c != opp.Amount__c  ){ 
       			expenseIds.add(opp.expense__c);
        		lineItemIds.add(opp.id);
        		names.add(opp.name);
            }
        }
        map<id,double> Accountmap = new map<id,double>();

		Integer count = 0;
		//Decimal total1 = 0.0;
        if( !names.isEmpty() ){
            for(AggregateResult q : [SELECT sum(amount__c)total1, count(id)count1, expense__c 
                                     FROM Expense_Line_Item__c 
                                     WHERE expense__c IN: expenseIds and name IN: names group by expense__c]){
                system.debug('Total::::::::::::::::::::::::::::::::::::::'+Accountmap.put((id)q.get('expense__c'),(double)q.get('total1')));
                count++;
                system.debug('count:::::::::::::::::::::::::::::::::::' + count);
            
            }        		
            List<Expense_Line_Item__c> LineItemsToUpdate = new List<Expense_Line_Item__c>();
            if( LineItemRunner.firstRun){
                Double amount1 = 0.0;
                integer counter = 0;
                for(Expense_Line_Item__c i : [SELECT Id,amount__c,expense__c 
                                              FROM Expense_Line_Item__c 
                                              WHERE expense__c IN :expenseIds and name IN: names]){
                                                  amount1 = accountMap.get(i.expense__c);
                                                  counter++;
				}
                system.debug('amount:::::::::::::::::::::::::::::::::::' + amount1);
                system.debug('counter:::::::::::::::::::::::::::::::::::' + counter);
                Double total = 0.0;
                
                if(trigger.isUpdate && count>0){
                    total = amount1/counter;  
                }
                
    			system.debug('count1:::::::::::::::::::::::::::::::::::' + count);
                system.debug('trigger:::::::::::::::::::::::::::::::::::' + trigger.isDelete);
                system.debug('2nd total:::::::::::::::::::::::::::::::::::' + total);
                for(Expense_Line_Item__c o : [SELECT Id,amount__c,expense__c 
                                              FROM Expense_Line_Item__c 
                                              WHERE expense__c IN :expenseIds and name IN: names]){
					o.amount__c=total;
					LineItemsToUpdate.add(o);
				}            	
    			LineItemRunner.firstrun=false;
			}
        	if( !LineItemsToUpdate.isEmpty() ){
        		update LineItemsToUpdate;
        	}
        }
    }
    
    public static void deleteOperations(List<Expense_Line_Item__c> lstExpenseLineItem){
        set<id>expenseIds = new set<id>();
		set<id>lineItemIds = new set<id>();
		set<string>names = new set<String>();  
        for(Expense_Line_Item__c p : lstExpenseLineItem){
            expenseIds.add(p.expense__c);
            lineItemIds.add(p.id);
            names.add(p.name);            
        }
        
        map<id,double> Accountmap = new map<id,double>();
        
        Integer count = 0;
        //Decimal total1 = 0.0;
        if( !expenseIds.isEmpty() && !names.isEmpty() ){
            for(AggregateResult q : [SELECT sum(amount__c)total1, count(id)count1, expense__c 
                                     FROM Expense_Line_Item__c 
                                     WHERE expense__c IN: expenseIds and name IN: names group by expense__c]){
                system.debug('Total::::::::::::::::::::::::::::::::::::::'+Accountmap.put((id)q.get('expense__c'),(double)q.get('total1')));
                count++;
                system.debug('count:::::::::::::::::::::::::::::::::::' + count);
            }
        
            List<Expense_Line_Item__c> lineItemsToUpdate = new List<Expense_Line_Item__c>();
            if( LineItemRunner.firstRun){
                Double amount1 = 0.0;
                integer counter = 0;
                for(Expense_Line_Item__c i : [Select Id,amount__c,expense__c from Expense_Line_Item__c where expense__c IN :expenseIds and name IN: names]){
                    amount1 = accountMap.get(i.expense__c);
                    counter++;                    
                }
                system.debug('amount:::::::::::::::::::::::::::::::::::' + amount1);
                system.debug('counter:::::::::::::::::::::::::::::::::::' + counter);
                Double total = 0.0;
                if(trigger.isDelete && count>0){
                    counter = counter - 1;
                    if(counter>0)
                        total = amount1/counter;
                    else
                        total = 0.0;
                }
                for(Expense_Line_Item__c o : [SELECT Id,amount__c,expense__c 
                                              FROM Expense_Line_Item__c 
                                              WHERE expense__c IN :expenseIds AND name IN: names]){
                    o.amount__c=total;
                    lineItemsToUpdate.add(o);
                }
                lineItemRunner.firstrun=false;
            }
            if( !lineItemsToUpdate.isEmpty() ){
            	update lineItemsToUpdate;
            }
        }
    }
}