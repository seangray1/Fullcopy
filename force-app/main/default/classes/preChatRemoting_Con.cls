/// Objective    : Checks the Contacts are presented or not for the Live Agent Visitor Email ID from the Prechat Form///
/// Created By   : Maharajan.C   ///
/// Created Date : 12/02/2018    ///

public class preChatRemoting_Con  
{
    public preChatRemoting_Con() 
    {

    }
    @RemoteAction
    public static contact getcontact(string contactemail)
    {
        Contact testContact=new Contact();
        testContact=[Select Id,Name from Contact where email=:contactemail limit 1];
        return testContact;
    }

}