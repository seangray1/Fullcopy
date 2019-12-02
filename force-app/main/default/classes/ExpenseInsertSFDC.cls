public class ExpenseInsertSFDC{
    
    Integer count = 0;
    public List<Expense_Line_Item__c> expenseContect{get; set;}
    //public List<Invoice_Line_Item__c> delContact{get; set;}
    
    public ApexPages.StandardController controller;
     private Expense_Line_Item__c ELI2; ///
     
    public ExpenseInsertSFDC(ApexPages.StandardController controller) {
       
       expenseContect= new List<Expense_Line_Item__c>();
       //delContact = new List<Invoice_Line_Item__c>(); 
       
       this.ELI2 = (Expense_Line_Item__c)controller.getRecord();
    }
    
    public void addrow(){
        count++;
        if(count<=10)
            expenseContect.add(new Expense_Line_Item__c());
        
    }
    
    public void removerow(){
    
         if(expenseContect.size()>0){ 
                expenseContect.remove(expenseContect.size()-1);
        }
    }
    
    public PageReference save(){
       
        List<Expense_Line_Item__c> dummyList = new List<Expense_Line_Item__c>();
        List<Expense_Line_Item__c> totalExpenseList = new List<Expense_Line_Item__c>();
        List<Expense_Line_Item__c> insertExpenseList = new List<Expense_Line_Item__c>();
        
       
        insertExpenseList.add(ELI2);
        
        
        system.debug('@@@@@@@@@@before insertExpenseList: '+insertExpenseList); 
        
        for(Integer i =0;i<expenseContect.size();i++){
            dummyList.add(ELI2);
        }
        
        totalExpenseList = dummyList.deepclone();
        
        
        //Expense_Line_Item__c exp = new Expense_Line_Item__c();
        
        List<Expense_Line_Item__c> epp = [select expense__c, id, Serial_Number__c, Number_of_item__c from Expense_Line_Item__c where expense__c =:ELI2.expense__c limit 100];
       
        
        Integer no = 0;
        Decimal Serial = 0.0;
        for(Expense_Line_Item__c exp: epp){
            
            if(epp.size()>=1 && no < exp.Number_of_item__c)
                no = (integer)exp.Number_of_item__c;
                
            else
                no = no;
        }
        no = no+1;
        Serial = no+0.0;
        
        System.debug('no is now::::::::::::::::::::::::::::::::::::::::::'+no);
        System.debug('no is now::::::::::::::::::::::::::::::::::::::::::'+Serial);
        
        //ELI2.Number_of_item__c = no+1;    
        
        
                
        
        system.debug('@@@@@@@@@@totalExpenseList : '+totalExpenseList);
        
        for(Integer i =0;i<totalExpenseList.size();i++){
            totalExpenseList[i].Contact__c = expenseContect[i].Contact__c;
            system.debug('@@@@@@@@@@totalExpenseList[i].Contact__c: '+totalExpenseList[i].Contact__c);
            if(totalExpenseList[i].Contact__c != null)
                insertExpenseList.add(totalExpenseList[i]);
            system.debug('@@@@@@@@@@ in loop insertExpenseList: '+insertExpenseList); 
         
        }
        
        system.debug('@@@@@@@@@@ out loop totalExpenseList: '+totalExpenseList);         
        system.debug('@@@@@@@@@@insertExpenseList: '+insertExpenseList); 
            
        
        for(Integer i = 0; i<insertExpenseList.size();i++){
            
            if(i==0)
              	insertExpenseList[i].Number_of_Item__c = no;
            if(insertExpenseList[i].Contact__c != null){
                insertExpenseList[i].Amount__c = insertExpenseList[i].Amount__c/insertExpenseList.size();
                
                insertExpenseList[i].Serial_Number__c = serial + 0.1;
                serial = insertExpenseList[i].Serial_Number__c; 
                }
            else{
                insertExpenseList[i].Amount__c = insertExpenseList[i].Amount__c;
           		
            }
                
        }
        
        try{
            insert insertExpenseList;
        }catch (DmlException e){
            system.debug('The ID is null');
        }      
        
            
        PageReference redirect= new PageReference('/'+ELI2.Expense__c);    
        redirect.setRedirect(true);
        return redirect;  
        
       
    } 
        
}