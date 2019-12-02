public without sharing class OpportunityAEBonusTriggerHandler {

    public static final string OPP_CREDIT_REQ_STATUS = 'Approved';
    public static final list<string> PROFILE_MARKETING_REP = new List<string>{'Marketing Representative', 'Teresa Delatorre - Custom'};
    public static final string OPP_TEAM_ROLE_ACC_EXEC1 = 'Account Executive 1';
    public static final string OPP_TEAM_ROLE_ACC_EXEC2 = 'Account Executive 2';
    public static final string TASK_TYPE_LUNCH_LEARN = 'Lunch and Learn';
    public static final string OPP_RTYPE_JOB_APPROVED_DEV_NAME = 'Job_Approved';

    // helper method to populate AEs on Opportunity
    public static void populateAEs( Map<Id, Opportunity> oldMap, List<Opportunity> newOpps ){ /*
        Set<id> userIds = new Set<Id>();
        Set<String> createdDateYears = new Set<String>();
        for( Opportunity opp : newOpps ){
            Opportunity oldOpp = oldMap != null ? oldMap.get( opp.Id ) : null;
            if( oldOpp == null || oldOpp.Account_Executive_1__c != opp.Account_Executive_1__c || 
               oldOpp.Account_Executive_2__c != opp.Account_Executive_2__c ){
                if( opp.Account_Executive_1__c != null ){
                    userIds.add( opp.Account_Executive_1__c );
                }
                if( opp.Account_Executive_2__c != null ){
                    userIds.add( opp.Account_Executive_2__c );
                }
                if( opp.createdDate != null ){
                    createdDateYears.add( String.valueOf(opp.createdDate.year() ));
                }
            }            
        }
        if( !userIds.isEmpty() && !createdDateYears.isEmpty()){
            Map<String, AE_Bonus__c> aeBonusInfosmap = getUserCommissionRecs( userIds, createdDateYears );
            for( Opportunity opp : newOpps ){
                string quarter = getCurrentQuarter( Date.valueOf(opp.CreatedDate));
                string year = String.valueOf( opp.CreatedDate.year() );
                if( opp.Account_Executive_1__c  == null || aeBonusInfosmap.isEmpty() ){
                    opp.AE_1_Bonus__c = null;
                }else{
                    //com.AE_Name__c + com.Year_Billed__c + com.Quarter_Billed__c
                    if( !aeBonusInfosmap.isEmpty() && aeBonusInfosmap.containsKey( opp.Account_Executive_1__c + year + quarter )){
                        opp.AE_1_Bonus__c = aeBonusInfosmap.get( opp.Account_Executive_1__c + year + quarter ).Id;
                    }else{
                        opp.AE_1_Bonus__c = null;
                    }
                }
                if( opp.Account_Executive_2__c  == null || aeBonusInfosmap.isEmpty() ){
                    opp.AE_2_Bonus__c = null;
                }else{
                    if( !aeBonusInfosmap.isEmpty() && aeBonusInfosmap.containsKey( opp.Account_Executive_2__c + year + quarter )){
                        opp.AE_2_Bonus__c = aeBonusInfosmap.get( opp.Account_Executive_2__c + year + quarter ).Id;
                    }else{
                        opp.AE_2_Bonus__c = null;
                    }                    
                }                
                if( opp.AE_1_Bonus__c == opp.AE_2_Bonus__c ){
                    opp.AE_2_Bonus__c = null;
                }                
            }   
        } */
    }
    
    public static string getCurrentQuarter(){
        Date todaysDate = Date.today();
        return getCurrentQuarter( todaysDate );
    }
    
    public static string getCurrentQuarter( Date currentDate ){
        if( currentDate.month() <= 3 ){
            return 'Q1';
        }
        else if( currentDate.month() > 3 && currentDate.month() <= 6 ){
            return 'Q2';
        }
        else if( currentDate.month() > 6 && currentDate.month() <= 9 ){
            return 'Q3';
        }
        else {
            return 'Q4';
        }
    }
    
    public static Map<Id, List<Invoice__c>> getRelatedInvoices( Set<Id> oppIds ){
        Map<Id, List<Invoice__c>> invoicesMap = new Map<Id, List<Invoice__c>>();
        for( Invoice__c inv : [ SELECT Id, Opportunity__c FROM Invoice__c WHERE Opportunity__c IN: oppIds ] ){
            if( invoicesMap.containsKey( inv.Opportunity__c ) ){
                invoicesMap.get( inv.Opportunity__c ).add( inv );
            }else{
                invoicesMap.put( inv.Opportunity__c, new List<Invoice__c>{ inv } );
            }
        }
        return invoicesMap;
    }
    
    public static Map<Id, List<Forecast__c>> getRelatedForecasts( Set<Id> oppIds ){
        Map<Id, List<Forecast__c>> forecastsMap = new Map<Id, List<Forecast__c>>();
        for( Forecast__c f : [ SELECT Id, Opportunity__c FROM Forecast__c WHERE Opportunity__c IN: oppIds ] ){
            if( forecastsMap.containsKey( f.Opportunity__c ) ){
                forecastsMap.get( f.Opportunity__c ).add( f );
            }else{
                forecastsMap.put( f.Opportunity__c, new List<Forecast__c>{ f } );
            }
        }
        return forecastsMap;
    }
 /*   public static Map<String, AE_Bonus__c> getUserCommissionRecs( Set<Id> userIds, Set<String> years ){
        Map<String, AE_Bonus__c> aeBonusInfomap = new Map<String, AE_Bonus__c>();
        if( !userIds.isEmpty() ){
            for(AE_Bonus__c com : [ SELECT Id, AE_Name__c, Lunch_and_Learns__c, Year_Billed__c, Quarter_Billed__c
                                     FROM AE_Bonus__c 
                                     WHERE AE_Name__c IN: userIds 
                                     AND Year_Billed__c IN: years] ){
                if( !aeBonusInfomap.containsKey(com.AE_Name__c + com.Year_Billed__c + com.Quarter_Billed__c )){
                    aeBonusInfomap.put( com.AE_Name__c + com.Year_Billed__c + com.Quarter_Billed__c , com );                             
                }
            }
        }
        return aeBonusInfomap;
    }
    
    public static Map<Id, AE_Bonus__c> getUserCommissionRecs( Set<Id> userIds ){
        Map<Id, AE_Bonus__c> userIdToCommissions = new Map<Id, AE_Bonus__c>();
        if( !userIds.isEmpty() ){
            for(AE_Bonus__c com : [ SELECT Id, AE_Name__c, Lunch_and_Learns__c
                                     FROM AE_Bonus__c 
                                     WHERE AE_Name__c IN : userIds 
                                     AND Quarter_Billed__c =: getCurrentQuarter() 
                                     AND Year_Billed__c =: String.valueOf( Date.today().year() )] ){
                                         userIdToCommissions.put( com.AE_Name__c, com );                             
                                     }
        }
        return userIdToCommissions;
    }
    
    public static void calculateCommissions( Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> oppsMap ){
        Set<Id> commissionIds = new Set<Id>();
        for( Opportunity opp: oppsMap.values() ){
            Opportunity oldOpp = oldOppsMap == null? null : oldOppsMap.get( opp.Id );
            if( oldOpp == null || oldOpp.AE_1_Bonus__c != opp.AE_1_Bonus__c || oldOpp.AE_2_Bonus__c != opp.AE_2_Bonus__c ){
                if( opp.AE_1_Bonus__c != null ){
                    commissionIds.add( opp.AE_1_Bonus__c );
                }
                if( opp.AE_2_Bonus__c != null ){
                    commissionIds.add( opp.AE_2_Bonus__c );
                }
            }
        }
        if( !commissionIds.isEmpty() ){
            BillingForecastTriggerUtility.updateCommissionRecords(commissionIds);
        }
    }
    
    public static void populateAEsOnInvoices( Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> oppsMap ){
        Set<Id> oppIds = new Set<Id>();        
        List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
        for( Opportunity opp : oppsMap.values() ){
            Opportunity oldOpp = oldOppsMap.get( opp.Id );
            if( opp.AE_1_Bonus__c != oldOpp.AE_1_Bonus__c || opp.AE_2_Bonus__c != oldOpp.AE_2_Bonus__c ){
                oppIds.add( opp.Id );
            }
        }        
        
        Map<Id, List<Invoice__c>> oppIdToInvoices = getRelatedInvoices( oppIds );
        if( !oppIdToInvoices.isEmpty() ){
            for( Id oppId : oppIdToInvoices.keySet() ){
                for( Invoice__c inv : oppIdToInvoices.get( oppId ) ){
                    if( inv != null ){
                        inv.AE_1_Bonus__c = oppsMap.get( oppId ).AE_1_Bonus__c;
                        inv.AE_2_Bonus__c = oppsMap.get( oppId ).AE_2_Bonus__c;
                        invoicesToUpdate.add( inv );
                    }
                }
            }
        }
        if( !invoicesToUpdate.isEmpty() ){
            update invoicesToUpdate;
        }
        
    }
    
    
    public static void populateAEsOnForecasts( Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> oppsMap ){
        List<Forecast__c> forecastsToUpdate;
        Set<Id> aeUserIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Set<String> forecastYears = new Set<String>();
        Map<String, AE_Bonus__c> userInfoToBonusMap = new Map<String, AE_Bonus__c>();
        for( Opportunity opp : oppsMap.values() ){
            Opportunity oldOpp = oldOppsMap.get( opp.Id );
            if( opp.Account_Executive_1__c != oldOpp.Account_Executive_1__c || opp.Account_Executive_2__c != oldOpp.Account_Executive_2__c ){
                if( opp.Account_Executive_1__c != null ){
                    aeUserIds.add( opp.Account_Executive_1__c );
                }
                if( opp.Account_Executive_2__c != null ){
                    aeUserIds.add( opp.Account_Executive_2__c );
                }
                oppIds.add( opp.Id );
            }
        }
        if( !aeUserIds.isEmpty() ){
            forecastsToUpdate = [ SELECT Id,Invoice_Date__c,Opportunity__c 
                                  FROM Forecast__c 
                                  WHERE Opportunity__c IN : oppIds ];
            if( forecastsToUpdate != null && !forecastsToUpdate.isEmpty() ){
                for( Forecast__c f : forecastsToUpdate ){
                    if( f.Invoice_Date__c != null ){
                        forecastYears.add( String.valueof( f.Invoice_Date__c.Year() ));
                    }
                }   
                
                for( AE_Bonus__c bonus : [SELECT Id, AE_Name__c, Year_Billed__c, Quarter_Billed__c 
                                          FROM AE_Bonus__c WHERE AE_Name__c IN :aeUserIds AND Year_Billed__c = :forecastYears ]){
                    if( !userInfoToBonusMap.containsKey( bonus.AE_Name__c + bonus.Year_Billed__c + bonus.Quarter_Billed__c )){
                        userInfoToBonusMap.put( bonus.AE_Name__c + bonus.Year_Billed__c + bonus.Quarter_Billed__c, bonus );
                    }
                }
                for( Forecast__c f : forecastsToUpdate ){
                    if( f.Opportunity__c != null ){
                        Opportunity opp = oppsMap.get( f.Opportunity__c );
                        if( opp != null && f.Invoice_Date__c != null ){
                            String quarter = OpportunityAEBonusTriggerHandler.getCurrentQuarter( f.Invoice_Date__c );
                            String year = String.valueof( f.Invoice_Date__c.year() );
                            if( userInfoToBonusMap.containsKey( opp.Account_Executive_1__c + year + quarter ) ){
                                f.AE1_Bonus__c = userInfoToBonusMap.get( opp.Account_Executive_1__c + year + quarter ).Id;
                            }else{
                                f.AE1_Bonus__c = null;
                            }
                            if( userInfoToBonusMap.containsKey( opp.Account_Executive_2__c + year + quarter ) ){
                                f.AE2_Bonus__c = userInfoToBonusMap.get( opp.Account_Executive_2__c + year + quarter ).Id;
                            }else{
                                f.AE2_Bonus__c = null;
                            }
                        }
                    }
                }
            }
        }           

        if( forecastsToUpdate != null && !forecastsToUpdate.isEmpty() ){
            update forecastsToUpdate;
        }
        
    }
    
    public static void afterCreditRequestApproved( Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> newOppsMap ){
        Set<String> creditReqEmails = new Set<String>();
        try{            
            for( Opportunity opp : newOppsMap.values() ){
                Opportunity oldOpp = oldOppsMap.get( opp.Id );
                if( opp.Credit_Request_Status__c != oldOpp.Credit_Request_Status__c && 
                    opp.Credit_Request_Status__c == OPP_CREDIT_REQ_STATUS ){
                    if( opp.Credit_Request_Submitter_Email__c != null ){
                        creditReqEmails.add( opp.Credit_Request_Submitter_Email__c );        
                    }
                }
            }
            if( !creditReqEmails.isEmpty() ){
                Map<String, Id> userEmailToId = new Map<String, Id>();
                for( User u : [ SELECT Id, Email FROM User WHERE Email IN : creditReqEmails] ){
                    userEmailToId.put( u.email, u.id );
                }
                for( Opportunity opp : newOppsMap.values() ){
                    Opportunity oldOpp = oldOppsMap.get( opp.Id );
                    if( opp.Credit_Request_Status__c != oldOpp.Credit_Request_Status__c && 
                        opp.Credit_Request_Status__c == OPP_CREDIT_REQ_STATUS && opp.Credit_Request_Submitter_Email__c != null ){
                        Id currentUserId = userEmailToId.get( opp.Credit_Request_Submitter_Email__c );    
                        //If there is already an AE 1 associated with that job that the requester is requesting credit for, 
                        //instead of wiping all AE's out we would add the requester as AE 2 and set both AE 1 and AE 2 to a 50% split. 
                        if( opp.Account_Executive_1__c != null && opp.Account_Executive_2__c == null && 
                           opp.Account_Executive_1__c != currentUserId ){
                            opp.Account_Executive_2__c = currentUserId; 
                        }else if( opp.Account_Executive_2__c != null && opp.Account_Executive_1__c == null && 
                           opp.Account_Executive_2__c != currentUserId ){
                            opp.Account_Executive_1__c = currentUserId; 
                        }else if( opp.Account_Executive_1__c == null && opp.Account_Executive_2__c == null ){
                            //If there is not an AE 1, then the Requester is added as the AE 1 with a 100% split (as is happening now)
                            opp.Account_Executive_1__c = currentUserId;
                        }else if( opp.Account_Executive_1__c != null && opp.Account_Executive_2__c != null &&
                                  opp.Account_Executive_1__c != currentUserId ){
                            //If there is already an AE 1 and an AE 2 on a job and someone requests credit, 
                            //then it gives them an error(already an AE1 And AE 2 assigned, please contact the Marketing Manager etc.)
                            opp.addError( 'You may not request credit for a job with 2 AE\'s assigned. Please contact Marketing Manager'+
                                         ' for assistance' );
                        }
                    }
                }            
            }
        }catch( DmlException ex ){
             system.debug( ex.getMessage() );            
        } 
    } */
    
    
    /*
     * • When a Job is created, the associated Contact’s owner should be added into the 
     * ‘Account Executive 1’ lookup field, IF that user’s profile is Marketing Representative
    o   That same user populated into ‘Account Executive 1’ lookup field, 
should then be created as Job Team (Opportunity Team) Member with the role of ‘Account Executive 1’
    o   This user should then be created as an Opportunity Split Member with a Split Type of ‘Revenue.’  If there is no Account Executive 2 (explained below), then the Split should be set to 100%.  If there is an Account Executive 2, then the Split should be set to 50%.
    o   A user should have the option to manually change the Account Executive 1 lookup field, which will then delete the associated Opportunity Team and Opportunity Split Member and add the updated person as the Opportunity Team and Opportunity Split Member.
    o   A user should also have the option to manually edit/delete the Opportunity Percentages
    */
    public static Map<Id, Contact> getOpportunityContacts( List<Opportunity> opps ){
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Contact> contactsMap;
        for( Opportunity opp : opps ){
            if( opp.Contact__c != null ){
                contactIds.add( opp.Contact__c );
            }
        }
        if( !contactIds.isEmpty() ){
            contactsMap = new Map<Id, Contact>(
                            [ SELECT Id, OwnerId 
                             FROM Contact
                             WHERE Id IN : contactIds AND Owner.Profile.Name IN : PROFILE_MARKETING_REP ]);            
        }
        return contactsMap;
    }
    
    public static Map<Id, Account> getOpportunityAccounts( List<Opportunity> opps ){
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountsMap;
        for( Opportunity opp : opps ){
            if( opp.AccountId != null ){
                accountIds.add( opp.AccountId );
            }
        }
        if( !accountIds.isEmpty() ){
            accountsMap = new Map<Id, Account>([ SELECT Id, OwnerId
                                                 FROM Account 
                                                 WHERE Id IN :accountIds AND Owner.Profile.Name  IN: PROFILE_MARKETING_REP ]);
        }
        return accountsMap;
    }
    
    public static void populateAEOnApprovedOpps( Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> newOppsMap ){
        List<Opportunity> opps = new List<Opportunity>();
        List<RecordType> rtypes = [ SELECT Id FROM RecordType 
                                    WHERE DeveloperName =: OPP_RTYPE_JOB_APPROVED_DEV_NAME 
                                        AND SobjectType = 'Opportunity' ];
        if( !rtypes.isEmpty() ){            
            for( Opportunity opp : newOppsMap.values() ){
                Opportunity oldopp = oldOppsMap.get( opp.Id );
                if( oldOpp.RecordTypeId != opp.RecordTypeId && opp.RecordTypeId == rtypes[0].Id ){
                    opps.add( opp );
                }
            }
        }/*
        if( !opps.isEmpty() ){
            Map<Id, Contact> contactsMap = getOpportunityContacts( opps );
            Map<Id, Account> accountsMap = getOpportunityAccounts( opps );            
        
            if( contactsMap != null || accountsMap != null ){
                for( Opportunity o : opps ){
                    Opportunity opp = newOppsMap.get( o.Id );
                    if( opp.Contact__c != null && contactsMap != null && contactsMap.containsKey(opp.Contact__c)){
                        opp.Account_Executive_1__c = contactsMap.get( opp.Contact__c).OwnerId;
                    }
                    if( opp.AccountId != null && accountsMap != null && accountsMap.containsKey(opp.AccountId) ){
                        opp.Account_Executive_2__c = accountsMap.get( opp.AccountId ).OwnerId;
                    }
                    if( opp.Account_Executive_1__c == opp.Account_Executive_2__c ){
                        opp.Account_Executive_2__c = null;
                    }
                    if( opp.Account_Executive_1__c == null && opp.Account_Executive_2__c != null ){
                        opp.Account_Executive_1__c = opp.Account_Executive_2__c;
                        opp.Account_Executive_2__c = null;
                    }
                }
            }
        } */
    }
        
    public static void addTeamMembersOppSplitsOnInsert( List<Opportunity> newOpps ){
        updateTeamMembersAndAESplits( newOpps );
    }
    
    public static void updateTeamMembersOnAEChange(  Map<Id, Opportunity> oldOppsMap, Map<Id, Opportunity> newOppsMap ){
        List<Opportunity> updatedOpportunities = new List<Opportunity>();
            
        for(Opportunity opp : newOppsMap.values()) {
            Opportunity oldOpp = oldOppsMap.get(opp.id);
            if (opp.Account_Executive_1__c != oldOpp.Account_Executive_1__c ||
                opp.Account_Executive_2__c != oldOpp.Account_Executive_2__c) {
                updatedOpportunities.add(opp);        
            }
        }
        updateTeamMembersAndAESplits( updatedOpportunities );
    }
    
    public static void updateTeamMembersAndAESplits( List<Opportunity> opps ){
        List<OpportunityTeamMember> otmToInsert = new List<OpportunityTeamMember>();
        List<OpportunitySplit> oppSplitsToUpsert = new List<OpportunitySplit>();
        List<OpportunityTeamMember> otmToDelete = new List<OpportunityTeamMember>();
        List<OpportunitySplit> oppSplitsDelete = new List<OpportunitySplit>();
        
        if (!opps.isEmpty()) {
            // Get existing opp splits
            Map<Id, List<OpportunitySplit>> existingOppSplitsMap = new Map<Id, List<OpportunitySplit>>();
            
            for (OpportunitySplit os : [SELECT Id, OpportunityId, SplitPercentage, SplitOwnerId 
                                                        FROM OpportunitySplit 
                                        WHERE opportunityId IN:opps]) {
                if (!existingOppSplitsMap.containsKey(os.OpportunityId)) {
                    existingOppSplitsMap.put(os.OpportunityId, new List<OpportunitySplit> {os});
                } else {
                    existingOppSplitsMap.get(os.OpportunityId).add(os);
                }
            }
            Set<Id> oppIds = (new Map<Id, Opportunity>(opps)).keySet();
            Map<Id, List<OpportunityTeamMember>> existingOTMMap = new Map<Id, List<OpportunityTeamMember>>();
            for (OpportunityTeamMember otm : [SELECT Id, OpportunityId, UserId, TeamMemberRole  
                                              FROM OpportunityTeamMember
                                              WHERE OpportunityId IN :oppIds]) {
                System.debug('OTMId: ' + otm.TeamMemberRole);
                if (!existingOTMMap.containsKey(otm.OpportunityId)) {
                    existingOTMMap.put(otm.OpportunityId, new List<OpportunityTeamMember> {otm});
                } else {
                    existingOTMMap.get(otm.OpportunityId).add(otm);
                }
            }            
            
            for (Opportunity opp : opps) {
                // Construct list of opp team members to be inserted
                if( opp.Account_Executive_1__c != null && opp.OwnerId != opp.Account_Executive_1__c ){
                    otmToInsert.add(new OpportunityTeamMember(UserId=opp.Account_Executive_1__c, 
                                                              OpportunityId = opp.Id, 
                                                              OpportunityAccessLevel='Edit',
                                                              TeamMemberRole='Account Executive 1'));
                }
                
                if( opp.Account_Executive_2__c != null && 
                    opp.OwnerId != opp.Account_Executive_2__c && 
                    opp.Account_Executive_1__c != opp.Account_Executive_2__c){
                    otmToInsert.add(new OpportunityTeamMember(UserId=opp.Account_Executive_2__c, 
                                                              OpportunityId = opp.Id, 
                                                              OpportunityAccessLevel='Edit',
                                                              TeamMemberRole='Account Executive 2'));  
                }
                if( !existingOTMMap.isEmpty() ){
                    System.debug( existingOTMMap );                   
                    system.debug( opp );
                    if( existingOTMMap.containsKey(opp.Id)){
                        for( OpportunityTeamMember otm : existingOTMMap.get(opp.Id) ){
                            system.debug( otm );                            
                            if( otm != null && otm.UserId != opp.OwnerId ){                        
                                if( otm.TeamMemberRole == 'Account Executive 2' || otm.TeamMemberRole == 'Account Executive 1'){
                                    otmToDelete.add( otm ); 
                                }
                            }
                        }                               
                    }
                }
            }
            
            // Insert opp splits for new members    
            for( Opportunity opp : opps ){
                //Opportunity opp = newOppsMap.get( otm.OpportunityId );
                Decimal splitPercent = 0;
                if( (opp.Account_Executive_1__c != null && opp.Account_Executive_1__c == opp.Account_Executive_2__c ) ||
                    (opp.Account_Executive_1__c != null && opp.Account_Executive_2__c == null ) ||
                    (opp.Account_Executive_2__c != null && opp.Account_Executive_1__c == null )){
                    splitPercent = 100;
                }else{
                    if( opp.Account_Executive_1__c != null && opp.Account_Executive_2__c != null ){
                        splitPercent = 50;
                    }
                }
                system.debug('RK ---- ae1' +  opp.Account_Executive_1__c );
                system.debug('RK ---- ae2' +  opp.Account_Executive_2__c );
                system.debug('RK ---- ownerid' +  opp.OwnerId );
                if( opp.Account_Executive_1__c != null && opp.OwnerId != opp.Account_Executive_1__c ){
                    system.debug('ae1');
                    OpportunitySplit os = new OpportunitySplit( OpportunityId = opp.Id, 
                                                                splitOwnerId = opp.Account_Executive_1__c, 
                                                                splitPercentage = splitPercent );
                    oppSplitsToUpsert.add( os );                
                }
                
                if( opp.Account_Executive_2__c != null && opp.OwnerId != opp.Account_Executive_2__c && 
                    opp.Account_Executive_1__c != opp.Account_Executive_2__c){
                        system.debug('ae2');
                    OpportunitySplit os = new OpportunitySplit( OpportunityId = opp.Id, splitOwnerId = opp.Account_Executive_2__c, splitPercentage = splitPercent );
                    oppSplitsToUpsert.add( os );                
                }
                for( OpportunitySplit os1 : existingOppSplitsMap.get(opp.Id) ){
                    system.debug('existingoppsplitsmap');
                    if( os1.SplitOwnerId == opp.OwnerId ){
                        system.debug('matched ownerid');
                        splitPercent = 0;
                        if (opp.Account_Executive_1__c == null && opp.Account_Executive_2__c == null) {
                            // only owner no AEs split percent = 100
                            splitPercent = 100;
                        } else if (opp.Account_Executive_1__c == opp.OwnerId && opp.Account_Executive_2__c == null ) {
                            // AE1 is owner no AE2 split percent = 100
                            splitPercent = 100;
                        } else if (opp.Account_Executive_2__c == opp.OwnerId && opp.Account_Executive_1__c == null) {
                            // AE2 is owner no AE1 split percent = 100
                            splitPercent = 100;
                        } else if (opp.Account_Executive_1__c == opp.OwnerId && opp.Account_Executive_1__c == opp.Account_Executive_2__c) {
                            // AE1 and AE2 both are owner - split percent = 100
                            splitPercent = 100;
                        } else if (opp.Account_Executive_1__c == opp.OwnerId && opp.Account_Executive_2__c != opp.OwnerId) {
                            // AE 1 exists and ae1 is owner and AE2 exists but not owner - split percent = 50
                            splitPercent = 50;
                        } else if (opp.Account_Executive_1__c != opp.OwnerId && opp.Account_Executive_2__c == opp.OwnerId) {
                            // AE1 exists but no owner and AE2 exists and is owner - split percent = 50
                            splitPercent = 50;
                        } else {
                            // AE1 and AE2 both are not owners but both exist - split percent = 0
                            splitPercent = 0;
                        }
                        os1.SplitPercentage = splitPercent;
                        oppSplitsToUpsert.add( os1 );
                    }else{
                        oppSplitsDelete.add( os1 );
                    }
                }
                
            }           
            // Delete the old splits 
            if( !oppSplitsDelete.isEmpty() ){                
                system.debug(oppSplitsDelete);
                delete oppSplitsDelete;
            }
            
            // Delete the old team member
            if( !otmToDelete.isEmpty() ){
                system.debug(otmToDelete);
                delete otmToDelete;
            }
            system.debug( [SELECT Id, OpportunityId, SplitPercentage, SplitOwnerId 
                                                        FROM OpportunitySplit 
                                        WHERE opportunityId IN:opps] );
            // Insert opp team member
            if( !otmToInsert.isEmpty() ){
                system.debug(otmToInsert);
                insert otmToInsert;
            }
            system.debug( [SELECT Id, OpportunityId, SplitPercentage, SplitOwnerId 
                                                        FROM OpportunitySplit 
                                        WHERE opportunityId IN:opps] );
            if( !oppSplitsToUpsert.isEmpty() ){                
                system.debug(oppSplitsToUpsert);
                Database.upsert( oppSplitsToUpsert );
            }
        }
    }
    public static void createOppPrimaryContactRoles( Map<Id, Opportunity> oldOppsMap, List<Opportunity> newOpps ){
        List<OpportunityContactRole> ocrsToInsert = new List<OpportunityContactRole>();
        for( Opportunity opp : newOpps ){
            Opportunity oldOpp = oldOppsMap == null ? null : oldOppsMap.get( opp.Id );
            if( ( oldOpp == null || oldOpp.Contact__c != opp.Contact__c ) && opp.Contact__c != null ){
                OpportunityContactRole ocr = new OpportunityContactRole( opportunityId = opp.Id, contactId = opp.Contact__c, IsPrimary = true);
                ocrsToInsert.add( ocr );
            }
        }
        if( !ocrsToInsert.isEmpty() ){
            insert ocrsToInsert;
        }
    }    
    
    public static void updateLastPreviousJobDateOnAccount( List<Opportunity> newOpps ){
        Set<Id> accountIds = new Set<Id>();
        List<Account> accountsToUpdate = new List<Account>();
        for( Opportunity opp : newOpps ){
            accountIds.add( opp.AccountId );
        }
        if( !accountIds.isEmpty() ){
            for( Account acc : [ SELECT Id, Last_Job_Date__c, Previous_Job_Date__c, 
                                        ( SELECT Id, CreatedDate FROM Opportunities ORDER BY CreatedDate DESC Limit 2) 
                                 FROM Account 
                                 WHERE Id IN : accountIds ] ){
                if( acc.Opportunities != null && !acc.Opportunities.isEmpty() ){
                    Boolean hasAccountChanged = false;
                    if( acc.Last_Job_Date__c != acc.Opportunities[0].createdDate ){
                        DateTime dT = acc.Opportunities[0].createdDate;
                        acc.Last_Job_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        hasAccountChanged = true;
                    }
                    if( acc.Opportunities.size() > 1 && acc.Opportunities[1].createdDate != acc.Previous_Job_Date__c ){
                        DateTime dT = acc.Opportunities[1].createdDate;
                        acc.Previous_Job_Date__c = date.newinstance(dT.year(), dT.month(), dT.day());
                        hasAccountChanged = true;
                    }
                    if( hasAccountChanged ){
                        accountsToUpdate.add( acc );
                    }
                }                                     
            }            
            if( !accountsToUpdate.isEmpty() ){
                update accountsToUpdate;
            }
        }
    }
}