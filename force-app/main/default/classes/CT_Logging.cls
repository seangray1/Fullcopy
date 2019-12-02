/*
* @auther      : Cloud Sherpas
* @date        : 03/20/2013
* @description : Apex class for Logging framework
*/ 
public class CT_Logging
{
    public static final String SEVERITY_INFO = 'Info';
    public static final String SEVERITY_ERROR = 'Error';
    public static final String SEVERITY_DEBUG = 'Debug';
    
    private static String strSeverity = '';
    private static String strContext = '';
    private static String strMessage = '';
    private static String strJobId = '';
    
    private static List<Log__c> INFO_log = new List<Log__c>();
    private static List<Log__c> DEBUG_log = new List<Log__c>();
    private static List<Log__c> ERROR_log = new List<Log__c>();
    
    /*
    * @auther      : Cloud Sherpas
    * @date        : 03/20/2013
    * @description : Apex method for Saving Logs
    * @parameters  : Nothing
    * @returns     : Nothing
    */
    public static void SaveLogs() 
    {
        try
        {
            List<Log__c> toWrite = new List<Log__c>();
        
            // We always save the error logs
            if(ERROR_log.size() > 0) toWrite.addAll(ERROR_log);
            ERROR_log = new List<Log__c>();
            
            if (strSeverity == SEVERITY_INFO) { // If severity is INFO, we don't log debug
                if(INFO_log.size() > 0) toWrite.addAll(INFO_log);
                INFO_log = new List<Log__c>();
            }
            else if (strSeverity == SEVERITY_DEBUG) { // If severity is DEBUG, we log everything
                if(INFO_log.size() > 0) toWrite.addAll(INFO_log);
                INFO_log = new List<Log__c>();
                
                if(DEBUG_log.size() > 0) toWrite.addAll(DEBUG_log);
                DEBUG_log = new List<Log__c>();
            }
            
            if (!toWrite.IsEmpty())
                insert toWrite;
        }
        catch(Exception e)        
        {
            System.debug('Error : ' + e.getMessage());
        }
    }
           
    /*
    * @auther      : Cloud Sherpas
    * @date        : 03/20/2013
    * @description : Apex method for Appending messages to Message variable in Log
    * @parameters  : Severity, Context, Message
    * @returns     : Nothing
    */ 
    public static void addMessage(String Severity, String Context, String Message)
    {
        Log__c log = new Log__c(Context__c = Context, JobId__c = strJobId, 
                Severity__c = Severity, Message__c = Message);
        
        if (Severity == SEVERITY_INFO)
            INFO_log.add(log);
        else if (Severity == SEVERITY_ERROR)
            ERROR_log.add(log);
        else if (Severity == SEVERITY_DEBUG)
            DEBUG_log.add(log);
    }
    
    /*
    * @auther      : Cloud Sherpas
    * @date        : 03/20/2013
    * @description : Apex method for Setting Job Id
    * @parameters  : JobId
    * @returns     : Nothing
    */ 
    public static void setJobId(String JobId)
    {
        strJobId = JobId;
    }
    
    /*
    * @auther      : Cloud Sherpas
    * @date        : 03/20/2013
    * @description : Apex method for Setting Severity
    * @parameters  : Severity
    * @returns     : Nothing
    */ 
    public static void setSeverity(String Severity)
    {
        strSeverity = Severity;
    }
    
    /*
    * @auther : Cloudtrigger LLC 
    * @date : 04/05/2013
    * @description : Apex test method for testing CT_Logging Class
    * @parameters : Nothing
    * @returns : Nothing
    */ 
    static testMethod void test_Logging()
    {
        Test.startTest();
        CT_Logging.addMessage('Debug', 'Context 2', 'test debug');        
        
        CT_Logging.SaveLogs();
        
        CT_Logging.setSeverity('Info');
        
        CT_Logging.addMessage('Info', 'Context 1', 'test info');
     
        CT_Logging.addMessage('Debug', 'Context 2', 'test debug');        
        
        CT_Logging.addMessage('Error', 'Context 3', 'test error');
        
        CT_Logging.setJobId('xxx');
        
        CT_Logging.SaveLogs();      
        Test.stopTest();
    }    
}