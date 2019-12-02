/**
 * @author           DemandBlue
 * @version          1.0 
 * @date             29-Jan-2019
 * @lastModified	 4-Nov-2019
 * @Status           Developed
 * @description      Inbound Email Handler for creating New Jobs(Not Approved) - Job Object(ATI_Job__c)
 *
 */
global class PRLDE_ATIJobEmail implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
        Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        ATI_Job__c job = new ATI_Job__c();
        List < Contact > listcon = new List < Contact > ();
        List < Attachment > listAttachment = new List < Attachment > ();
        Contact newcon = new Contact();
        Account ESJobAcct = [SELECT AccountNumber, AccountSource, Account_Address__c, Account_Billing_CityStateZip__c, BillingAddress, BillingCity, BillingCountry, BillingLatitude, BillingLongitude, BillingPostalCode, BillingState, BillingStreet, Company_Type__c, ERA__c, FirstName, Id, IsPersonAccount, Mobile__c, Name, OwnerId, ParentId, PersonContactId, PersonMailingCity, PersonMailingCountry, PersonMailingLatitude, PersonMailingLongitude, PersonMailingPostalCode, PersonMailingState, PersonMailingStreet, PersonMobilePhone, PersonOtherAddress, PersonOtherCity, PersonOtherCountry, PersonOtherLatitude, PersonOtherLongitude, PersonOtherPhone, PersonOtherPostalCode, PersonOtherState, PersonOtherStreet, Person_Billing_City__c, Person_Billing_State__c, Person_Billing_Street__c, Phone, RecordTypeId, ShippingAddress, ShippingCity, ShippingCountry, ShippingLatitude, ShippingLongitude, ShippingPostalCode, ShippingState, ShippingStreet, Status__c, Type FROM Account WHERE Name = 'ES Job Account'];
        String firstmemName;
        String lastmemName;
        String firstinsName;
        String lastinsName;
        String threefirstmemName;
        String threefirstinsName;
        String emailaddressTrim;
        String lastNameLen;
        String siteZipcode;
        string lastmemNamelength;
        string businessAcctName = '';
        Id persId;
        String memberNameExact;
        String memberNameToChange;
        String insuredNameExact;  
        String insuredNameToChange;
        string mobilePhoneMax;
        string[] StoreDateofLoss;
        string StoreAllDateMonthYear;
        Date DateofLoss;
        string ClaimNumber;
        string lossDescriptionTrim = '';
        string typeOfLossTrim = '';
        string emailContent;
        Id newRecordTypeId = Schema.SObjectType.ATI_Job__c.getRecordTypeInfosByName().get('New Job (Not Approved)').getRecordTypeId();
        Id personRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Accounts').getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        String emailBody = email.PlainTextBody;
        emailBody = emailBody.remove('*');
        if (emailBody != null) {
            
            //Attach EmailBody in EmailContent as Notes
            emailContent = emailBody;

            if (emailBody.contains('From:') && emailBody.contains('To:') && emailBody.contains('Assignment Profile:') && emailBody.contains('Type:') && emailBody.contains('Instructions:') && emailBody.contains('Dates:')) {

                // Fetching the Location and mapping it to Project site Address, City , State and Code
                String locationOfProperty = emailBody.substringAfter('Location of Property:');
                String PropertyLocation = emailBody.substringAfter('Property Location:');
                String[] projectSiteAddress;
                if (locationOfProperty != '') {
                    projectSiteAddress = locationOfProperty.split(',');
                } else {
                    projectSiteAddress = PropertyLocation.split(',');
                }

                String siteAddress = projectSiteAddress[0];
                String siteCity = projectSiteAddress[1];
                if (siteCity.length() > 15) {
                    siteCity = siteCity.substring(0, 10);
                } else {
                    siteCity = siteCity;
                }
                String siteStateCode = projectSiteAddress[2];

                //splitting the  State and ZipCode with the help of Space
                String[] projectStateZipcode = siteStateCode.split(' ');
                String siteState = projectStateZipcode[1];
                String siteZipcodelength = projectStateZipcode[2];
                siteZipcode = projectStateZipcode[2].substringBefore('\n');

                //Splitting the first Name from FROM:
                string InsuredNameAfter = emailBody.substringAfter('Insured Name:');
                string InsuredNameAfterRemoveSpace = InsuredNameAfter.substringBefore('\n');
                
                List<string> InsuranceNameForJob = InsuredNameAfterRemoveSpace.split(' ');
                
              //  system.debug('InsuredNameAfterRemoveSpace ---> '+InsuranceNameForJob);
                
                string fromAccount = emailBody.substringAfter('From:').trim();
                Boolean lastFromDetailCapture = fromAccount.split('\n')[0].contains('.com');
                Boolean lastFromDataBoolean = true;
                if(lastFromDetailCapture)
                {
                do{

                    if(fromAccount.contains('From:'))
                    {
                        lastFromDataBoolean = fromAccount.trim().split('\n')[0].contains('.com') ? true : false;
                        system.debug(fromAccount.split('\n')[0]);
                        system.debug(lastFromDataBoolean);
                        if(lastFromDataBoolean)
                        {
                            fromAccount = fromAccount.substringAfter('From:').trim();
                            system.debug(lastFromDataBoolean);
                        }
                        else
                        {
                           
                            if(fromAccount.contains('From:'))
                            {
								fromAccount = fromAccount.substringBefore('From:').trim();                                
                            }
                            lastFromDataBoolean = false;
                            
                            system.debug(lastFromDataBoolean); 
                            
                        }
                    }
                    else
                    {
                        lastFromDataBoolean = false;
                    }
                    
                 }while(lastFromDataBoolean);
                }
                
             //   system.debug('fromAccount ---> '+fromAccount);
                
              /*  if(fromAccount.contains('From:'))
                {
                do{
                    fromAccount = fromAccount.substringAfter('From:');
                }while(fromAccount.contains('From:'));
                } */
                
                
                
               // system.debug('fromAccountContext -- > '+fromAccount);
                
              //  String fromAccount = emailBody.substringAfter('From:');
                String[] insurancename = fromAccount.split('-');
                system.debug('insurancename ----> '+insurancename);
                string accountName;
                string trimmedaccountName;

                string[] accNameAfterHypen = insurancename[1].split('\n');
                system.debug('accNameAfterHypen -------> '+accNameAfterHypen);
                string NameAfterHypen = accNameAfterHypen[0];
                system.debug('NameAfterHypen --------> '+NameAfterHypen);
                string FullName = insurancename[0] + '-' + NameAfterHypen;


                                if (FullName.contains('CC') || FullName.contains('USAA')) {

                    job.Lead_Source__c = 'Program - Contractor Connection';
                } 
              //  else if(NameAfterHypen.trim().split(' ')[0] == 'Alacrity')
                     else if(FullName.contains('Alacrity'))
                {
                    job.Lead_Source__c = 'Program - Alacrity Services';
                }
                else {

                 //   job.Lead_Source__c = 'Program' + ' - ' +NameAfterHypen.trim().split(' ')[0];
                    job.Lead_Source__c = 'None';
                }


                if (insurancename[0].trim() == 'CC') {

                    accountName = NameAfterHypen.trim().split(' ')[0];
                    system.debug('accountName:' + accountName);

                } else {

                    accountName = insurancename[0].remove('\n');
                    system.debug('accountName:' + accountName);
                }

                //Store  Claim Number from placeHolder Claim Number: or Member Number:

                if (fromAccount.contains('Claim Number:') || fromAccount.contains('Member Number:')) {
                    
                    if (fromAccount.contains('Member Number:'))
                    {
                       String memberNumber = fromAccount.substringAfter('Member Number:');
                    string memberNumbertrim = memberNumber.trim();
                    string[] StoreMemberNumber = memberNumbertrim.split(',');
                    job.Claim__c = StoreMemberNumber[0];
                    }
                    
                    if (fromAccount.contains('Claim Number:'))
                    {
                         ClaimNumber = fromAccount.substringAfter('Claim Number:');
                    string ClaimNumbertrim = ClaimNumber.trim();
                    string[] StoreClaimNumber = ClaimNumbertrim.split('\n');
                    job.Claim__c = StoreClaimNumber[0];
                    }
                    
                   
                }
                
                //Loss Report Number
                if(fromAccount.contains('Loss Report Number:')){
                    String lossReportNumber = fromAccount.substringAfter('Loss Report Number:');
                    string lossReportNumbertrim = lossReportNumber.trim();
                    string[] StorelossReportNumbertrimNumber = lossReportNumbertrim.split('\n');
                    job.Claim__c = job.Claim__c + ' - ' +StorelossReportNumbertrimNumber[0];
                    system.debug('Claim ---> '+job.Claim__c);
                }

                //Store DateofLoss

                if (fromAccount.contains('Date of Loss:')) {
                    StoreAllDateMonthYear = fromAccount.substringAfter('Date of Loss:');
                    string testtrim = StoreAllDateMonthYear.trim();
                    StoreDateofLoss = testtrim.split('\n');
                    DateofLoss = Date.parse(StoreDateofLoss[0]);
                    job.Date_of_Loss__c = DateofLoss;
                }

                //Splitting the Member Name by comma  and Insured Name by space
                if (fromAccount.contains('Member Name:')) {
                    String afterMemberName = fromAccount.substringAfter('Member Name:').trim(); 
                    system.debug('afterMemberName ----> '+afterMemberName.split('\n'));
                    String[] memberName = afterMemberName.split('\n');
                    if(memberName.size() > 0)
                    {
                        if(memberName[0].contains(','))
                    {
                        memberNameExact = memberName[0];
                        system.debug('After Member Name'+afterMemberName.split('\n')[0]);
                    }
                        else
                        {
                            memberNameToChange = lastNameToFirstNameChange(memberName[0]);
                        }
                        
                    firstmemName = memberName[0].trim();
                    string[] lasName = memberName[1].split('\n');
                    lastmemName = lasName[0];
                    threefirstmemName = firstmemName.left(5);
                        
                    
                    }
                } else if (fromAccount.contains('Insured Name:')) {
                    String afterInsuredName = fromAccount.substringAfter('Insured Name:').trim();
                    if(afterInsuredName.split('\n')[0].contains(','))
                    {
                        insuredNameExact = afterInsuredName.split('\n')[0];
                        system.debug('After Member Name'+insuredNameExact);
                    }
                    else
                    {
                        insuredNameToChange = lastNameToFirstNameChange(afterInsuredName.split('\n')[0]);
                    }
                     
					system.debug('afterInsuredName --> '+afterInsuredName.trim());
                    string test = afterInsuredName.trim();
                    system.debug('test --> '+test.split('\n')[0]);
                    system.debug('afterInsuredName --> '+afterInsuredName.trim());
                    if (afterInsuredName.contains('Day Phone:')) {
                        afterInsuredName = afterInsuredName.substringBefore('Day Phone:');
                    } else if (afterInsuredName.contains('Mobile Phone:')) {
                        afterInsuredName = afterInsuredName.substringBefore('Mobile Phone:');
                    } else {
                        afterInsuredName = afterInsuredName.substringBefore('Evening Phone:');
                    }

                    if (afterInsuredName.contains('Terminix')) {

                        firstinsName = 'Ernest';
                        lastinsName = 'Gibson';
                        threefirstinsName = 'Ern';

                    } else {


                        String[] insuredName = afterInsuredName.remove('\n').split(' ');
                        system.debug('@@@@@@@@@@' + insuredName);
                        if (insuredName.size() == 3) {

                            firstinsName = insuredName[0];
                            string lasName = insuredName[1] + ' ' + insuredName[2];
                            lastinsName = lasName;

                            threefirstinsName = insuredName[0].left(3);

                        } else if (insuredName.size() == 2) {

                            firstinsName = insuredName[0];
                            string lasName = insuredName[1];
                            lastinsName = lasName;

                            threefirstinsName = insuredName[0].left(3);

                        }

                    }

                }


                // Fetching Mobile Phone and Email Address for Person Accounts
                if (fromAccount.contains('Mobile Phone:')) {
                    String mobilePhone = fromAccount.substringAfter('Mobile Phone:');
                  //  system.debug('Mobile Phone' + mobilePhone);
                    mobilePhoneMax = mobilePhone.substring(0, 16);
                    system.debug('Mobile Phone Max' + mobilePhoneMax);
                }
                String emailaddress = fromAccount.substringAfter('Email Address:');

                emailaddressTrim = emailaddress.substringBefore('<mailto');


                job.Account__c = ESJobAcct.Id;

                // Fetching CR Name and Phone
                if (fromAccount.contains('CR Name:') || fromAccount.contains('CR Phone #:')) {
                    string afterCrName = fromAccount.substringAfter('CR Name:');
                    //split CR first and last Name with space
                    string[] crName = afterCrName.split(' ');
                    string firstCrName = crName[0];
                    string lastCrName = crName[1].substringbefore('CR');
                    string threefirstCrName = crName[0].left(3);
                    string crPhonelength = fromAccount.substringAfter('CR Phone #:');
                    string crPhone = crPhonelength.substring(0, 14);
                    // Check in system whether contact is available under business account
                    listcon = [SELECT AccountId, Account.RecordType.DeveloperName, FirstName, LastName FROM Contact
                        WHERE Contact_Type__c = 'Adjuster'
                        AND
                        FirstName LIKE: '%' + threefirstCrName + '%'
                        AND LastName =: lastCrName.trim()
                    ];
                    if (listcon.size() > 0) {
                        for (Contact con: listcon) {
                            job.Contact__c = con.Id;
                        }

                    } else {

                        newcon.LastName = lastCrName;
                        newcon.FirstName = firstCrName;
                        newcon.Contact_Type__c = 'Adjuster';
                        newcon.AccountId = ESJobAcct.Id;
                        newcon.Phone = crPhone;
                       
                        }
                     system.debug('newcon -->'+newcon);
                        insert newcon;
                    system.debug('newcon -->'+newcon);
                    }
                

                // Mapping to Job object
                //Checking and converting address First Letter to Capital using Regex Match
                system.debug('SiteAddress' + siteAddress);
                String addressToChange = siteAddress.tolowercase();
                String convertedAddress = '';
                Matcher matchercompile = Pattern.compile('(\\w+|\\W+)').matcher(addressToChange);
                while (matchercompile.find()) convertedAddress += matchercompile.group().capitalize();
                system.debug('Converted Address' + convertedAddress);

                job.Project_Site_Address__c = convertedAddress;

                String SiteCityToChange = siteCity.tolowercase();
                String convertedSiteCity = '';
                Matcher matcherSiteCitycompile = Pattern.compile('(\\w+|\\W+)').matcher(SiteCityToChange);
                while (matcherSiteCitycompile.find()) convertedSiteCity += matcherSiteCitycompile.group().capitalize();
                system.debug('convertedSiteCity' + convertedSiteCity);

                job.Project_Site_City__c = convertedSiteCity;
                job.Project_Site_State__c = siteState;
                job.Project_Site_Zipcode__c = siteZipcode;
                job.RecordTypeId = newRecordTypeId;
                if (ESJobAcct.Id != null) {
                    job.Project_Site_Contact_Account__c = ESJobAcct.Id;
                    job.Project_Site_Contact_Name__c = newCon.id;

                    job.Date_of_Loss__c = DateofLoss;

                  /*  ClaimNumber = fromAccount.substringAfter('Claim Number:');
                    string ClaimNumbertrim = ClaimNumber.trim();
                    string[] StoreClaimNumber = ClaimNumbertrim.split('\n');
                    job.Claim__c = StoreClaimNumber[0];

                    system.debug('!@@!@!@!@!'+ClaimNumber.length()); */
                }
                if (newcon.id != null) {
                    job.Contact__c = newcon.Id;
                }
                if (ESJobAcct.Id != null) {
                    job.Account__c = ESJobAcct.Id;
					job.Project_Site_Contact_Account__c = ESJobAcct.Id;
                    job.Project_Site_Contact_Name__c = newcon.Id;
                    
                    Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
                    Matcher matcher = nonAlphanumeric.matcher(ESJobAcct.Name);
                    string jobNameToInsert = matcher.replaceAll(' ');
                    jobNameToInsert  = firstLetterCaps(jobNameToInsert);
                    
                    system.debug('jobNameToInsert --> '+jobNameToInsert);
                    
                    if (jobNameToInsert.length() > 50) {
                        string trimmedjobname = jobNameToInsert.substring(0, 50);
                        job.Job_Name__c = trimmedjobname;
                        system.debug('JobName --> '+trimmedjobname);
                    } else {
                        job.Job_Name__c = jobNameToInsert;
                        system.debug('JobName --> '+jobNameToInsert); 
                    }

                }
               

                if (listcon.size() > 0) {
                    for (Contact con: listcon) {
                        job.Contact__c = con.Id;
                    }

                }

                //job.County__c='USA';
                job.Primary_Account__c = 'Insurance';
                job.Stage__c = 'Qualification';
                job.CloseDate__c = system.Today() + 5;
                // Added job Description
                if (fromAccount.contains('Loss Description:')) {
                    String lossDescription = fromAccount.substringAfter('Loss Description:');
                    string[] listLossDescription = lossDescription.split('\n');
                    lossDescriptionTrim = listLossDescription[0].trim();
                }
                if (fromAccount.contains('Type of Loss:')) {
                    String afterTypeOfLoss = fromAccount.substringAfter('Type of Loss:');
                    if (afterTypeOfLoss.contains('Desk Adjuster:')) {
                        afterTypeOfLoss = afterTypeOfLoss.substringBefore('Desk Adjuster:');
                    } else if (afterTypeOfLoss.contains('Adjuster Office Phone:')) {
                        afterTypeOfLoss = afterTypeOfLoss.substringBefore('Adjuster Office Phone:');
                    } else if (afterTypeOfLoss.contains('Third Party Name:')) {
                        afterTypeOfLoss = afterTypeOfLoss.substringBefore('Third Party Name:');
                    } else if (afterTypeOfLoss.contains('Property Access Name:')) {
                        afterTypeOfLoss = afterTypeOfLoss.substringBefore('Property Access Name:');
                    } else if (afterTypeOfLoss.contains('Property Access Phone:')) {
                        afterTypeOfLoss = afterTypeOfLoss.substringBefore('Property Access Phone:');
                    } else {
                        afterTypeOfLoss = afterTypeOfLoss.substringBefore('XA ID:');
                    }
                    typeOfLossTrim = afterTypeOfLoss.trim();
                }
                job.Description__c = lossDescriptionTrim + ' \n' + typeOfLossTrim;
                
                if(fromAccount.contains('Instructions:'))
                {
                    String instructionToAdd = fromAccount.substringAfter('Instructions:');
                    string[] listInstructionToAdd = instructionToAdd.split('\n');
                    job.Description__c = job.Description__c + ' \n' +listInstructionToAdd[0].trim();
                    system.debug('jobDescription ---> '+job.Description__c);
                }
                //Member Name
                if(memberNameExact <> null || memberNameToChange <> null)
                {
                    if(memberNameExact <> null)
                    {
                        job.Job_Name__c = memberNameExact;
                    }
                    else
                    {
                        
                    job.Job_Name__c = memberNameToChange;
                    system.debug('JobName --> '+memberNameToChange);
                    }
                }
                else if(insuredNameExact <> null || insuredNameToChange <> null)
                {
                    if(insuredNameExact <> null)
                    {
                        job.Job_Name__c = insuredNameExact;
                    }
                    else
                    {
                        
                    job.Job_Name__c = insuredNameToChange;
                    
                  
                    
                    }
                }
              
             

                //   if(locationOfProperty.contains('Los Angeles') || locationOfProperty.contains('LOS ANGELES'))
                if (locationOfProperty.containsIgnoreCase('Los Angeles')) {
                    job.City_of_LA__c = 'Yes';
                } else {
                    job.City_of_LA__c = 'No';
                }


            } else {

              
                string subjecttrim = email.subject;

                Pattern nonAlphanumeric = Pattern.compile('[^a-zA-Z0-9]');
                Matcher matcher = nonAlphanumeric.matcher(subjecttrim);
                string jobNameToInsert = matcher.replaceAll(' ');
                jobNameToInsert = firstLetterCaps(jobNameToInsert);
                string trimmedjobname;
                if (jobNameToInsert.length() >= 50) {
                    trimmedjobname = jobNameToInsert.substring(0, 50);
                } else {
                    trimmedjobname = jobNameToInsert;
                }
                system.debug(jobNameToInsert);

                string emailbodytext = email.plainTextBody;

                //job.Name = trimmedjobname;                  
                job.Job_Name__c = trimmedjobname;
                system.debug('JobName --> '+trimmedjobname);
                job.Account__c = ESJobAcct.Id;


                job.Lead_Source__c = 'Insurance Company';
                if (string.isblank(email.plainTextBody)) {
                    job.Project_Site_Address__c = 'Please update actual address';
                } else {
                    job.Project_Site_Address__c = '210 W Baywood Ave, Orange, CA 92865';
                }

                job.RecordTypeId = newRecordTypeId;
                job.Stage__c = 'Qualification';


            }
            
            if(job.Job_Name__c == null)
            {
                         Pattern nonAlphanumericValue = Pattern.compile('[^a-zA-Z0-9]');
                Matcher matchertext = nonAlphanumericValue.matcher(ESJobAcct.Name);
                string jobNameToInsertValue = matchertext.replaceAll(' ');
                jobNameToInsertValue = firstLetterCaps(jobNameToInsertValue);
                system.debug('jobNameToInsertValue --> '+jobNameToInsertValue);
                String JobNameReverse;
             //   String JobvaluesSplitForLoop = jobNameToInsertValue.split(' ');
                
                
                
                if (jobNameToInsertValue.length() > 50) {
                    string trimmedjobname = jobNameToInsertValue.substring(0, 50);
                    //string trimmedjobname1 =  jobNameToInsertValue.substring(0,1).toUpperCase() + jobNameToInsertValue.substring(1).toLowerCase();
                    
                    job.Job_Name__c = trimmedjobname;
                    system.debug('JobName --> '+trimmedjobname);
                } else {

                    job.Job_Name__c = jobNameToInsertValue;
                    system.debug('JobName --> '+jobNameToInsertValue);
                }   
            }
            

            
            system.debug('JobName ---> '+job.Job_Name__c);

            insert job;

        }

        if (email.binaryAttachments != null && email.binaryAttachments.size() > 0) {
            for (integer i = 0; i < email.binaryAttachments.size(); i++) {
                Attachment attachment = new Attachment();
                // attach to the newly created ATI_Job__c record
                attachment.ParentId = job.Id;
                attachment.Name = email.binaryAttachments[i].filename;
                attachment.Body = email.binaryAttachments[i].body;
                listAttachment.add(attachment);
            }
            if (listAttachment.isEmpty()) {
                insert listAttachment;
            }
        }
        List < note > NoteLists = new List < Note > ();
        Note noteObj = new Note();
        noteObj.Title = 'Email Content';
        noteObj.Body = emailContent;
        noteObj.ParentId = job.id;
        NoteLists.add(noteObj);
        if (!NoteLists.isEmpty()) {
            insert noteObj;
        }

        return result;
    }
    
    public string firstLetterCaps(String letterToCapsChange)
    {
        string modifiedWord = '';
        String[] splitWords = letterToCapsChange.tolowercase().split(' ');
        for(string splitWord:splitWords)
        {
            modifiedWord = modifiedWord + splitWord.Capitalize()+' ';
        }
        system.debug('modifiedWord'+modifiedWord);
        return modifiedWord.trim();
    }
    
    public string lastNameToFirstNameChange(String nameToChange)
    {
        String[] nameToChangeSplit = nameToChange.split(' ');
        string nameToReturn;
        
        for(integer i=nameToChangeSplit.size() - 1 ;i >=0;i--)
        {
            String modifiedNameToReturn = firstLetterCaps(nameToChangeSplit[i]);
			nameToReturn = nameToReturn == null ? modifiedNameToReturn + ',' : nameToReturn + ' '+modifiedNameToReturn;      
        }
        system.debug('Name changed  ---> '+nameToReturn);
        return nameToReturn;
    }
}