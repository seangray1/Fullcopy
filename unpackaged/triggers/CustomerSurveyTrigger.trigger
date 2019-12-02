/*
* Generic trigger for Customer_Survey__c - s.jeyarammoorthy - 6/28/2016 
*/
trigger CustomerSurveyTrigger on Customer_Survey__c ( before insert, before update,after insert,after update,before delete) 
{
        
    //  custom start
    // Defining the operation here.
    // We need to identify which Opportunities we want to make change/trigger.  work with all insert and/Or all update and/or all delete etc

    if (Trigger.isBefore && Trigger.IsInsert)
    {
            CustomerSurveyFieldUpdate.CustomerSurveyFieldUpdate( trigger.new );
    }
}