public class CreateBonusRecsExtensions {
    private final List<string> MARKETING_REP_PROFILE_NAME = new List<string>{'Marketing Representative', 'Teresa Delatorre - Custom'};
    private final string Q1 = 'Q1';
    private final string BONUS_YEAR = String.valueOf( Date.today().year() );
    public List<AE_Bonus__c> bonuses { get; set; }
    private List<String> quarters = new List<String>{ 'Q2', 'Q3', 'Q4'};
    private Map<Id, User> userMap;
    private Map<String, AE_Bonus__c> existingBonussMap;
    
    public CreateBonusRecsExtensions( ApexPages.StandardController controller ){
        bonuses = new List<AE_Bonus__c>();
        /***
         Changed the criteria AND Office__c =: currentUser.Office__c to manager is the current user. 
        ****/
        User currentUser = [ SELECT Id, Office__c 
                             FROM User 
                             WHERE Id =: UserInfo.getUserId() ];
        userMap = new Map<Id, User>( [ SELECT Id, Name 
                        FROM USER 
                        WHERE Profile.Name IN : MARKETING_REP_PROFILE_NAME 
                            AND ManagerID =: currentUser.id 
                            AND isActive = true] );
        existingBonussMap = new Map<String, AE_Bonus__c>();
        for( AE_Bonus__c comm : [ SELECT Id, Quarter_Billed__c, AE_Name__c, Year_Billed__c, Name, Annual_Quota__c 
                                    FROM AE_Bonus__c 
                                    WHERE AE_Name__c IN : userMap.keySet() 
                                        AND Year_Billed__c =: BONUS_YEAR ] ){
            existingBonussMap.put( comm.AE_Name__c + comm.Quarter_Billed__c, comm );               
        }
        for( User u : userMap.values() ){
            AE_Bonus__c com ;
            if(!existingBonussMap.isEmpty() &&  existingBonussMap.containsKey( u.Id + Q1) ){
                com = existingBonussMap.get( u.Id + Q1 );
            }else{
                com = new AE_Bonus__c( name = u.Name, AE_Name__c = u.Id, Quarter_Billed__c = Q1, 
                                         Year_Billed__c = BONUS_YEAR );
                com.Name += '-' + com.Quarter_Billed__c + ' ' + com.Year_Billed__c ;
            }
            
            bonuses.add( com );
        }        
    }
    
    public pageReference saveBonuses(){
        try{
            List<AE_Bonus__c> bonusesToUpsert = new List<AE_Bonus__c>();
            for( AE_Bonus__c com : bonuses ){
                if( com.Annual_Quota__c != null ){
                    bonusesToUpsert.add( com );
                    for( String quarter : quarters ){
                        AE_Bonus__c nextQCom;
                        if( !existingBonussMap.isEmpty() && existingBonussMap.containsKey( com.AE_Name__c+ quarter ) ){
                            nextQCom = existingBonussMap.get( com.AE_Name__c+ quarter );
                        }else{
                            nextQCom = new AE_Bonus__c( name = userMap.get(com.AE_Name__c).Name, AE_Name__c = com.AE_Name__c, 
                                                                        Quarter_Billed__c = com.Quarter_Billed__c, Year_Billed__c = com.Year_Billed__c );
                            nextQCom.Quarter_Billed__c = quarter;
                            nextQCom.Name += '-' + nextQCom.Quarter_Billed__c + ' ' + nextQCom.Year_Billed__c ;
                        }
                        nextQCom.Annual_Quota__c = com.Annual_Quota__c;
                        bonusesToUpsert.add( nextQCom );
                    }
                }
            }
            if( !bonusesToUpsert.isEmpty() ){
                upsert bonusesToUpsert;
            }            
        }catch( Exception ex ){
            Apexpages.addMessage( new ApexPages.message( ApexPages.Severity.ERROR, 'There was an error creating Bonus Records. '+
                                                        'Please contact your system administrator for further assistance.') );
            return null;
        }
        return new pageReference('/' + AE_Bonus__c.sobjecttype.getDescribe().getKeyPrefix() );
    }
    
    public pageReference cancel(){
        return null;
    }
}