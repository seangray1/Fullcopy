@isTest
private class CreateBonusRecsExtensions_Test {
    static testMethod void createBonusRecsTest(){
        Test.setCurrentPage( Page.CreateCommissionRecs );
        
        CreateBonusRecsExtensions ext = new CreateBonusRecsExtensions( new ApexPages.StandardController( new AE_Bonus__c()));
        Test.startTest();
        for( AE_Bonus__c b : ext.bonuses ){
            b.Annual_Quota__c = 100000;
        }
        ext.saveBonuses();
        Test.stopTest();
    }
}