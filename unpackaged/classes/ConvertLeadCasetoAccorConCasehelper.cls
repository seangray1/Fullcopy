/* Author - Preludesys
* Created - 26/03/2018
* Status - Developed
* Purpose - Helper Class to Move cases and chat transcripts when Live Chat lead is getting converted
*/
public class ConvertLeadCasetoAccorConCasehelper {
    Public static void convertBusinessAccount(List<Lead> Leadlist)
    {
            List<Case> CaseList = new List<Case>();
            List<livechattranscript>LiveChatTranscriptList = new list<livechattranscript>();
            Map<Id,Id> LeadContactId = new Map<Id,Id>();
            Map<Id,List<case>> LeadCaseMap = new Map<Id,List<case>>(); 
            Map<Id,List<LiveChatTranscript>> LeadTranscriptMap = new Map<Id,List<LiveChatTranscript>>();  
            List<Case> CaseToUpdate = new List<Case>();  
            List<livechattranscript>LiveChatTranscriptListToUpdate = new list<livechattranscript>();
            for(Lead ld : Leadlist)
            {
                if(ld.IsConverted == True && ld.ConvertedContactId != null && ld.Company !=null && ld.LeadSource == 'Live Chat')
                {
                    LeadContactId.put(ld.Id, ld.ConvertedContactId);
                } 
                
            }
            
            CaseList = [Select Id, Lead__c, contactId from case where Lead__c IN: LeadContactId.keyset()];
            LiveChatTranscriptList = [select id,ContactId,LeadId from LiveChatTranscript where LeadId In :LeadContactId.keyset()];
           // List<Lead> LeadstoProcess = [select id,ConvertedContactId,ConvertedAccountId, (Select Id,AccountId,ContactId,Lead__c from Cases__r), 
           //                              (select Id,AccountId,ContactId,LeadId from LiveChatTranscripts) from Lead where Id IN: LeadContactId.keyset()];
            If(CaseList.size() > 0)
            {      
                for(Case cs : CaseList)
                {
                    List<case> casetmplst = new List<case>();
                    if(LeadCaseMap.containsKey(cs.Lead__c))
                    {
                        casetmplst = LeadCaseMap.get(cs.Lead__c);
                        casetmplst.add(cs);
                    }
                    else
                    {
                        casetmplst = new List<Case>();
                        casetmplst.add(cs);
                    }
                    LeadCaseMap.put(cs.Lead__c,casetmplst);
                }
                
                
                for(lead leads : Leadlist)
                {
                    List<Case> checkcaselstsize = LeadCaseMap.get(leads.Id);
                    if(checkcaselstsize.size() > 0)
                    {
                        for(case Cases : checkcaselstsize)
                        {
                            Case c = new case(Id = Cases.Id);
                            c.ContactId = LeadContactId.get(Cases.Lead__c);
                            CaseToUpdate.add(c);           
                        }   
                    }     
                }
            }
            
             If(LiveChatTranscriptList.size() > 0)
            {      
                for(LiveChatTranscript ChatTranscript : LiveChatTranscriptList)
                {
                    List<LiveChatTranscript> ChatTranscriptTmplst = new List<LiveChatTranscript>();
                    if(LeadTranscriptMap.containsKey(ChatTranscript.LeadId))
                    {
                        ChatTranscriptTmplst = LeadTranscriptMap.get(ChatTranscript.LeadId);
                        ChatTranscriptTmplst.add(ChatTranscript);
                    }
                    else
                    {
                        ChatTranscriptTmplst = new List<LiveChatTranscript>();
                        ChatTranscriptTmplst.add(ChatTranscript);
                    }
                    LeadTranscriptMap.put(ChatTranscript.LeadId,ChatTranscriptTmplst);
                }
                
                
                for(lead leads : Leadlist)
                {   
                    List<LiveChatTranscript> ChatTranscriptlstsize = LeadTranscriptMap.get(leads.Id);
                    if(ChatTranscriptlstsize.size() > 0)
                    {
                    for(LiveChatTranscript ChatTranscript : ChatTranscriptlstsize)
                        {
                            LiveChatTranscript Trans = new LiveChatTranscript(Id = ChatTranscript.Id);
                            Trans.ContactId = LeadContactId.get(ChatTranscript.LeadId);
                            LiveChatTranscriptListToUpdate.add(Trans);           
                        }    
                    }
                    
                }
            }
            
            If(CaseToUpdate.size() > 0)
            {
                update CaseToUpdate;
            }
            if(LiveChatTranscriptListToUpdate.size() > 0)
            {
                update LiveChatTranscriptListToUpdate;
            }
            
    }
    
    
Public static void convertPersonAccount(List<Lead> Leadlist)
    {
            List<Case> PersonAccCaseList = new List<Case>();
            List<livechattranscript> PersonAccLiveChatTranscriptList = new list<livechattranscript>();
            Map<Id,Id> PersonAccLeadAccountId = new Map<Id,Id>();
            Map<Id,List<case>> PersonAccLeadCaseMap = new Map<Id,List<case>>(); 
            Map<Id,List<LiveChatTranscript>> PersonAccLeadTranscriptMap = new Map<Id,List<LiveChatTranscript>>();  
            List<Case> PersonAccCaseToUpdate = new List<Case>();  
            List<livechattranscript> PALiveChatTranscriptListToUpdate = new list<livechattranscript>();
            for(Lead ld : Leadlist)
            {
                if(ld.IsConverted == True && ld.ConvertedAccountId != null && ld.Company ==null && ld.LeadSource == 'Live Chat')
                {
                    PersonAccLeadAccountId.put(ld.Id, ld.ConvertedAccountId);
                } 
                
            }
            
            PersonAccCaseList = [Select Id, Lead__c, AccountId, contactId from case where Lead__c IN: PersonAccLeadAccountId.keyset()];
            PersonAccLiveChatTranscriptList = [select id, AccountId, ContactId, LeadId from LiveChatTranscript where LeadId In :PersonAccLeadAccountId.keyset()];
            If(PersonAccCaseList.size() > 0)
            {      
                for(Case cs : PersonAccCaseList)
                {
                    List<case> casetmplst = new List<case>();
                    if(PersonAccLeadCaseMap.containsKey(cs.Lead__c))
                    {
                        casetmplst = PersonAccLeadCaseMap.get(cs.Lead__c);
                        casetmplst.add(cs);
                    }
                    else
                    {
                        casetmplst = new List<Case>();
                        casetmplst.add(cs);
                    }
                    PersonAccLeadCaseMap.put(cs.Lead__c,casetmplst);
                }
                
                
                for(lead leads : Leadlist)
                {
                    List<Case> checkcaselstsize = PersonAccLeadCaseMap.get(leads.Id);
                    if(checkcaselstsize.size() > 0)
                    {
                        for(case Cases : checkcaselstsize)
                        {
                            Case c = new case(Id = Cases.Id);
                            c.AccountId = PersonAccLeadAccountId.get(Cases.Lead__c);
                            PersonAccCaseToUpdate.add(c);           
                        }   
                    }     
                }
            }
            
             If(PersonAccLiveChatTranscriptList.size() > 0)
            {      
                for(LiveChatTranscript ChatTranscript : PersonAccLiveChatTranscriptList)
                {
                    List<LiveChatTranscript> ChatTranscriptTmplst = new List<LiveChatTranscript>();
                    if(PersonAccLeadTranscriptMap.containsKey(ChatTranscript.LeadId))
                    {
                        ChatTranscriptTmplst = PersonAccLeadTranscriptMap.get(ChatTranscript.LeadId);
                        ChatTranscriptTmplst.add(ChatTranscript);
                    }
                    else
                    {
                        ChatTranscriptTmplst = new List<LiveChatTranscript>();
                        ChatTranscriptTmplst.add(ChatTranscript);
                    }
                    PersonAccLeadTranscriptMap.put(ChatTranscript.LeadId,ChatTranscriptTmplst);
                }
                
                
                for(lead leads : Leadlist)
                {   
                    List<LiveChatTranscript> ChatTranscriptlstsize = PersonAccLeadTranscriptMap.get(leads.Id);
                    if(ChatTranscriptlstsize.size() > 0)
                    {
                    for(LiveChatTranscript ChatTranscript : ChatTranscriptlstsize)
                        {
                            LiveChatTranscript Trans = new LiveChatTranscript(Id = ChatTranscript.Id);
                            Trans.AccountId = PersonAccLeadAccountId.get(ChatTranscript.LeadId);
                            PALiveChatTranscriptListToUpdate.add(Trans);           
                        }    
                    }
                    
                }
            }
            
            If(PersonAccCaseToUpdate.size() > 0)
            {
                update PersonAccCaseToUpdate;
            }
            if(PALiveChatTranscriptListToUpdate.size() > 0)
            {
                update PALiveChatTranscriptListToUpdate;
            }
            
    }
    

}