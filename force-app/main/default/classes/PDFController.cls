Public class PDFController{

    //Create a list of string for fields
    public static List<String> ADDL_FIELDS;
    public static List<String> PrintValue;
    public List<sObject> lineItems {get; set;} 
    
    public string ChildRecordsQuery {get;set;}
    
    private Id RecordId {get;set;}
 
 
    public PDFController ExtController {get;set;}
 
    //write the controller method
    Public PDFController(ApexPages.StandardController controller){
        
        ExtController = this;
        RecordId  = controller.getId();
        
        if (! Test.isRunningTest()) {
            controller.addFields(SfObjectHelper.GetObjectFieldsById(RecordId  ));
        }
    }
    
    public void setParamsmethod(string childQuery){
        ChildRecordsQuery = childQuery;
        getChildRecords();
    }

    private void getChildRecords()
    {       
        lineItems = database.query(ChildRecordsQuery);
    }
}