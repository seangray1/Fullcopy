public class ScheduleController {
    
    public List<WrapperClass> wrapSchedule{get;set;}
    public Integer count{get;set;}
    public List<Schedule_Line_Item__c> delScheduleLineItem;
    public Schedule__c ScheduleRecord;
    public String job{get;set;}
    ApexPages.StandardController ExtCon;
  

    //These are the values will auto populate on the first 10 lines
    public static List<String> FirstValues = new List<String>{
      'Appliances',
        'Cabinetry',
        'Cleaning',
        'Contents',
        'General Demolition',
        'Doors','Drywall', 
        'Electrical', 
        'Floor Covering Carpet',
        'Floor Covering Wood',
        'Finish Carpentry', 
        'Framing/Rough Carpentry', 
        'Heat, Vent & A/C', 
        'Insulation', 
        'Plumbing', 
        'Painting', 
       'Roofing', 
       'Siding', 
       'Window Vinyl'
    };
    
    public ScheduleController(ApexPages.StandardController controller) {
         this.ExtCon = controller;
         ScheduleRecord = (Schedule__c)controller.getRecord();        
         getScheduleLineItem();
         job = ScheduleRecord.ATI_Job__c;          
    }
    
    public void getScheduleLineItem(){     
         wrapSchedule = new List<WrapperClass>();
         Integer listCount = 0;
         ID ScheduleID = ExtCon.getID();
         
         system.debug('This is the Id Reurning: ' + ScheduleID);
        
         //Query records if page returns an Id         
         for(Schedule_Line_Item__c Scheduleline:[Select id, Name, Completion_Date__c, Products__c, Product_Options__c, Start_Date__c, Schedule__c From Schedule_Line_Item__c  
                                         WHERE Schedule__c =:ScheduleID])
         {
             WrapperClass wrapSchedulelineineItem = new WrapperClass(listCount,Scheduleline);
             wrapSchedule.add(wrapSchedulelineineItem);
             listCount = listCount + 1;             
         }
            
        
         //For Creation of new Schedule...wrapSchedule will be empty since query returned no results
         //New Schedule must contain 3 empty line items
         if(wrapSchedule.isEmpty()==true){
             wrapSchedule = new List<WrapperClass>();
             createLineItem();
         }
    }

    //Create 3 empty Schedule Line Items
    public void createLineItem(){       
        integer i;
        for(i = 0;i<19;i++){
             Schedule_Line_Item__c Schedule = new Schedule_Line_Item__c();
             Schedule.Products__c = FirstValues[i];
             Schedule.Product_Options__c = FirstValues[i];
             WrapperClass wc = new WrapperClass(i,Schedule);
             wc.Schedule.Order__c = i+1;
             WrapSchedule.add(wc);
        }
    }
     //Method for delete button of the VF page...add deleted items to temporary list(delInvoiceLineItems)
    //temp list will be used to delete records once user hits save
    public void deleteLineItem(){
        delScheduleLineItem = new List<Schedule_Line_Item__c>();
        if(wrapSchedule.size()>0){
            for(integer i=0;i<wrapSchedule.size();i++){ 
                if(count==wrapSchedule[i].indx){
                    if(wrapSchedule[i].Schedule.id!=null){
                    delScheduleLineItem.add(wrapSchedule[i].Schedule);
                    }
                    wrapSchedule.remove(i);

                }
                resetLineItemOrder();
            }
          if(wrapSchedule.size()==0){
              createLineItem();
          }
        }
    }
    //reset order of Line items...Line Items must always start at 1
    public void resetLineItemOrder(){
        for(integer i=0;i<wrapSchedule.size();i++){
            wrapSchedule[i].schedule.Order__c = i+1;
        }
    
    }
    
    //Method for adding empty line items to pageblocktable 
    public void addrow(){
        Schedule_Line_Item__c Schedule = new Schedule_Line_Item__c();
        WrapperClass wc = new WrapperClass(WrapSchedule.size()+1,Schedule);
        WrapSchedule.add(wc);
        resetLineItemOrder();

    }    

    
    public PageReference quickSaveSchedule(){   
        
        PageReference pv;
    
        
        ExtCon.save();
        
        try{
              saveLineItem(ExtCon.getID());
              getScheduleLineItem();

            system.debug('What is the pv returning? '+ pv);
            
            
        }catch(Exception e){
            ApexPages.Message emsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());    
            ApexPages.addMessage(emsg);
        }        
        
        return pv;
    }
    
    public pageReference saveSchedule(){
     
        PageReference pv;

        ExtCon.save();
        
        try{
            
            saveLineItem(ExtCon.getID());
                
            system.debug('What is the pv returning? '+ pv);
            
        } catch(exception e){
            ApexPages.Message ErrorMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
            ApexPages.addMessage(ErrorMsg);
        }
        
        pv = ExtCon.view();
       
        return pv;
    }
    
    public void saveLineItem(ID ScheduleID){ 
  
        List<Schedule_Line_Item__c> saveScheduleLineItem = new List<Schedule_Line_Item__c>();

        //try{
        for(WrapperClass wc:wrapSchedule){
           if(wc.Schedule.Products__c != null && wc.Schedule.Products__c != ''){
                if(wc.Schedule.id==null){
                    wc.Schedule.Schedule__c = ScheduleID;
                } 

                saveScheduleLineItem.add(wc.Schedule);
            } 

        } 
        
        upsert saveScheduleLineItem;
        if(delScheduleLineItem!=null){
            delete delScheduleLineItem;
        }
        
        ScheduleRecord = (Schedule__c)this.ExtCon.getRecord(); 

    }
     
    public class WrapperClass{
        public Integer indx{get;set;}
        public Schedule_Line_Item__c Schedule{get;set;}    
        public WrapperClass(Integer indx,Schedule_Line_Item__c Schedule){
            this.indx = indx;
            this.Schedule = Schedule;
        }
    
    }

}