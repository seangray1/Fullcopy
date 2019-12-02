@isTest
public class UpdateAttachmentTest {
	@isTest static void check(){
      	Test.startTest();
		List<String> Ids = new List<String>();
		Ids.Add('0067000000gdOzxAAE');

        List<Attachment> Attachments = new List<Attachment>();
        Attachment attach = new Attachment();
        attach.parentID = 'a6eV0000000cgwHIAQ';
        attach.Name = '15 HM Pitt LAB Result 1 (2).pdf';
        Attachments.add(attach);
        
        UpdateAttachment objUpdateAttachment = new UpdateAttachment(Ids);
		Database.QueryLocator ql = objUpdateAttachment.start(null);
		objUpdateAttachment.execute(null,Attachments);
		objUpdateAttachment.Finish(null);
        
    	Test.stopTest();
	}
}