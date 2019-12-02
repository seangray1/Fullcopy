/******************************************************************************
 * Extension for 
 */
public class SchedulePDFController{
    
    /** List of Schedule__c fields that do not exist on the VF page that need to
     *  be referenced elsewhere in the code */
    public static List<String> ADDL_FIELDS = new List<String> {
        'Name',
        'Current_PDF_Version__c',
        'ATI_job__c',
        'Project_Site_Address__c',
        'Project_Manager__c',
        'Project_Director__c',
        'Schedule_Number_Incremental__c'
    };
    
    /** The Schedule to generate a PDF for */
    public Schedule__c Schedule {get; set;}
    
    public List<Schedule_Line_Item__c> lineItems {get; set;}
        public Integer getLineItemsSize() {        return lineItems.size();
    }
    

    /**************************************************************************
     * 
     */
    public SchedulePDFController(ApexPages.StandardController controller) {
        
        // Add any additional fields
        if (! Test.isRunningTest()) {            controller.addFields(SchedulePDFController.ADDL_FIELDS);
        }
        
        // Initialize local variables
        Id ScheduleId = controller.getId();
        String fields = ADCUtil_Base.strJoin(',', ADDL_FIELDS, 'Id');
        Schedule = (Schedule__c) Database.query('SELECT '+fields+' FROM Schedule__c WHERE (Id = :ScheduleId) ORDER BY CreatedDate DESC LIMIT 1');
        
        // Retrieve all of the relevant line items
        lineItems = [SELECT  Id, Name, Completion_Date__c, Products__c, Product_Options__c, Start_Date__c, Schedule__c FROM schedule_Line_Item__c WHERE schedule__c = :schedule.Id order by Start_Date__c ASC Nulls Last ];
        
        System.debug('SchedulePDFController: Generating Schedule for '+Schedule);
        
    }
    

    
}