@isTest
public class Test_ConvertLeadcasetoContactCase {
    Static testmethod void testDuplicateLead()
    {
        Lead l  = new Lead(LastName = 'Lead Last Name', Street = 'Test Street', City = 'Test City', 
                           State = 'TN', Country = 'India', PostalCode = '627001', Status = 'Working - Contacted', LeadSource = 'Live Chat');
        insert l;  
        Lead le = new Lead(Company = 'Test Lead', LastName = 'Lead Last Name2', Street = 'Test Street', City = 'Test City',
                           State = 'TN', Country = 'India', PostalCode = '627002', Status = 'Working - Contacted', LeadSource = 'Live Chat');
        insert le;  
        
        List<case> caselst = new List<Case>();
        Case c1 = new Case(subject = 'This is the Test Case', Status = 'New', Origin = 'Live Chat', Lead__c = l.Id);
        caselst.add(c1);
        Case c2 = new Case(subject = 'This is the Test Case1', Status = 'New', Origin = 'Live Chat', Lead__c = le.Id);
        caselst.add(c2);
        if(caselst.size() > 0)
        {
            insert caselst;
        }
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        List<LiveChatTranscript> livechatlst = new List<LiveChatTranscript>();
        LiveChatTranscript tx1 = new LiveChatTranscript( chatKey = '123', liveChatVisitorId = visitor.id, LeadId = l.Id);
        livechatlst.add(tx1);
        LiveChatTranscript tx2 = new LiveChatTranscript( chatKey = '234', liveChatVisitorId = visitor.id, LeadId = le.Id);
        livechatlst.add(tx2);
        if(livechatlst.size() > 0)
        {
             insert livechatlst;
        }
        
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(le.id);
        lc.setDoNotCreateOpportunity(True);
        LeadStatus convertStatus = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvert lc1 = new database.LeadConvert();
        lc1.setLeadId(l.id);
        lc1.setDoNotCreateOpportunity(True);
        LeadStatus convertStatus1 = [Select Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc1.setConvertedStatus(convertStatus1.MasterLabel);
        
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        
        Database.LeadConvertResult lcr1 = Database.convertLead(lc1);
        System.assert(lcr1.isSuccess());
    }
}