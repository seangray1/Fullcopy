/*
    Run PDFController_Test for testclass.
*/

public class DisplayChildRecordsController 
{

    public string ChildRecordQueryString {get;set{
        ChildRecordQueryString = value;
        SetParentQueryString();
    }}
    
    public PDFController ParentPageController
    {
        get;
        set {
            ParentPageController = value;
            SetParentQueryString();
        }
    }
    
    public DisplayChildRecordsController ()
    {
      
    }
    
    private void SetParentQueryString()
    {
        if (ParentPageController != null && !string.isBlank(ChildRecordQueryString ))
        {
            ParentPageController.setParamsmethod(ChildRecordQueryString );
        }
    }
    
}