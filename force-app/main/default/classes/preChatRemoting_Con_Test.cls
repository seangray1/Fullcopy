@Istest
public class preChatRemoting_Con_Test 
{
    Static String ConEmail;
    public static testmethod void preChatTest()
    {
        Account CreateAccount = new Account(Name = 'TestAccount',BillingStreet='TestStreet',BillingCity = 'Test City',BillingState = 'TS',
                                            BillingPostalCode = '879',BillingCountry = 'Test Country');
        Insert CreateAccount;
        
        Contact CreateContact = new Contact(LastName = 'Test', Email = 'test1@gmail.com',AccountId =CreateAccount.Id);
        insert CreateContact;
        ConEmail = CreateContact.Email;
        preChatRemoting_Con ConstructorCover = new preChatRemoting_Con();
        preChatRemoting_Con.getcontact(ConEmail);
    }
    
}