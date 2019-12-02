public without sharing class BillingForecastTriggerUtility {
    
    
     public static void afterBillingForecastInsert( List<Forecast__c> newForecasts ){
        recalculateCommissionRecords( null, newForecasts );
    }
    
    
    public static void afterBillingForecastUpdate( Map<Id, Forecast__c> oldForecastsMap, List<Forecast__c> newForecasts ){
        recalculateCommissionRecords( oldForecastsMap, newForecasts );
    }
    
    public static void beforeBillingForecastInsert( List<Forecast__c> newForecasts ){
        populateAEsOnForecasts( newForecasts );
    }
    
    public static void populateAEsOnForecasts( List<Forecast__c> newForecasts ){
        Set<Id> jobIds = new Set<Id>();
        Map<Id, ATI_Job__c> jobsMap ;
        Set<String> forecastYears = new Set<String>();
        Map<String, AE_Bonus__c> userInfoToBonusMap = new Map<String, AE_Bonus__c>();
        for( Forecast__c f : newForecasts ){
            if( f.ATI_Job__c != null ){
                jobIds.add( f.ATI_Job__c );
            }
            if( f.Invoice_Date__c != null ){
                forecastYears.add( String.valueof( f.Invoice_Date__c.Year() ));
            }
        }
        if( !jobIds.isEmpty() ){
            Set<Id> userIds = new Set<Id>();
            jobsMap = new Map<Id, ATI_Job__c>([ SELECT Id, Account_Executive_1__c, Account_Executive_2__c, Account__r.Type 
                                                FROM ATI_Job__c 
                                                WHERE Id IN: jobIds ]);
            for( ATI_Job__c job : jobsMap.values() ){
                if( job.Account_Executive_1__c != null ){
                    userIds.add( job.Account_Executive_1__c );                                     
                }
                if( job.Account_Executive_2__c != null ){
                    userIds.add( job.Account_Executive_2__c );                                     
                }
            }
            if( !userIds.isEmpty() ){
                for( AE_Bonus__c bonus : [SELECT Id, AE_Name__c, Year_Billed__c, Quarter_Billed__c 
                                          FROM AE_Bonus__c WHERE AE_Name__c IN :userIds AND Year_Billed__c = :forecastYears ]){
                                              if( !userInfoToBonusMap.containsKey( bonus.AE_Name__c + bonus.Year_Billed__c + bonus.Quarter_Billed__c )){
                                                  userInfoToBonusMap.put( bonus.AE_Name__c + bonus.Year_Billed__c + bonus.Quarter_Billed__c, bonus );
                                              }
                                          }                 
            }
            
            for( Forecast__c f : newForecasts ){
                if( f.ATI_Job__c != null ){
                    ATI_Job__c job = jobsMap.get( f.ATI_Job__c );
                    if( job != null && f.Invoice_Date__c != null ){
                        String quarter = JobAEBonusTriggerHandler.getCurrentQuarter( f.Invoice_Date__c );
                        String year = String.valueof( f.Invoice_Date__c.year() );
                        if( userInfoToBonusMap.containsKey( job.Account_Executive_1__c + year + quarter ) ){
                            f.AE1_Bonus__c = userInfoToBonusMap.get( job.Account_Executive_1__c + year + quarter ).Id;
                        }
                        if( userInfoToBonusMap.containsKey( job.Account_Executive_2__c + year + quarter ) ){
                            f.AE2_Bonus__c = userInfoToBonusMap.get( job.Account_Executive_2__c + year + quarter ).Id;
                        } 
                    }
                }
            }
        }
    }
    
    private static void recalculateCommissionRecords( Map<Id, Forecast__c> oldForecastsMap, List<Forecast__c> newForecasts ){
        Set<Id> commissionIds = new Set<Id>();
        for( Forecast__c f : newForecasts ){
            Forecast__c oldForecast = oldForecastsMap == null ? null : oldForecastsMap.get( f.Id );
            if( oldForecast == null || oldForecast.Revenue_Amount__c != f.Revenue_Amount__c ){
                if( f.AE1_Bonus__c != null ){
                    commissionIds.add( f.AE1_Bonus__c );
                }
                if( f.AE2_Bonus__c != null ){
                    commissionIds.add( f.AE2_Bonus__c );
                }
            }
        }
        updateCommissionRecords( commissionIds );
    }
    
    public static void updateCommissionRecords( Set<Id> commissionIds ){
        Map<Id, AE_Bonus__c> commissionsMap = new Map<Id, AE_Bonus__c>();
        if( !commissionIds.isEmpty() ){
            commissionsMap = new Map<Id, AE_Bonus__c>([ SELECT Id, AE_Name__c, AE_Name__r.Office__c, Total_Leads_Per_Quarter__c,
                                                       AE_Name__r.State__c,Quarter_Billed__c, Year_Billed__c                                                              
                                                       FROM AE_Bonus__c 
                                                       WHERE Id IN : commissionIds ]);
        }
        updateCommissionRecords( commissionsMap );
    }
    
    public static void updateCommissionRecords(  Map<Id, AE_Bonus__c> commissionsMap ){
        Map<Id, Set<ATI_Job__c>> commIdToOppsMap = new Map<Id, Set<ATI_Job__c>>();
        for( ATI_Job__c job : [ SELECT Id, Account_Executive_1__r.State__c, Account_Executive_2__r.State__c, 
                                CreatedDate, AE_1_Bonus__c, AE_2_Bonus__c, 
                                Office2__r.State__c, Job_Type__c, CloseDate__c
                                FROM ATI_Job__c 
                                WHERE AE_1_Bonus__c IN :commissionsMap.keySet() OR 
                                AE_2_Bonus__c IN :commissionsMap.keySet() ]){
                                    if( !commIdToOppsMap.containsKey( job.AE_1_Bonus__c ) ){
                                        commIdToOppsMap.put( job.AE_1_Bonus__c , new Set<ATI_Job__c>{ job } );
                                    }else{
                                        commIdToOppsMap.get( job.AE_1_Bonus__c ).add( job );
                                    }
                                    if( !commIdToOppsMap.containsKey( job.AE_2_Bonus__c ) ){
                                        commIdToOppsMap.put( job.AE_2_Bonus__c , new Set<ATI_Job__c>{ job } );
                                    }else{
                                        commIdToOppsMap.get( job.AE_2_Bonus__c ).add( job );
                                    }
                                }
        Map<Id, Set<Forecast__c>> commIdToForecastsMap = new Map<Id, Set<Forecast__c>>();
        for( Forecast__c f : [SELECT Id, Revenue_Amount__c, Invoice_Date__c, Split_Percent__c, 
                              AE1_Bonus__c, AE2_Bonus__c, ATI_Job__r.Job_Type__c 
                              FROM Forecast__c 
                              WHERE AE1_Bonus__c IN :commissionsMap.keySet() OR 
                              AE2_Bonus__c IN: commissionsMap.keySet()] ){
                                  if( !commIdToForecastsMap.containsKey( f.AE1_Bonus__c ) ){
                                      commIdToForecastsMap.put( f.AE1_Bonus__c, new Set<Forecast__c>{ f });                          
                                  }else{
                                      commIdToForecastsMap.get( f.AE1_Bonus__c ).add( f );
                                  }
                                  if( !commIdToForecastsMap.containsKey( f.AE2_Bonus__c ) ){
                                      commIdToForecastsMap.put( f.AE2_Bonus__c, new Set<Forecast__c>{ f });                          
                                  }else{
                                      commIdToForecastsMap.get( f.AE2_Bonus__c ).add( f );
                                  }
                              }
        recalculateCommissionRecords( commissionsMap,  commIdToOppsMap, commIdToForecastsMap);        
    }
    
    public static void recalculateCommissionRecords( Map<Id, AE_Bonus__c> commissionsMap, 
                                                    Map<Id, Set<ATI_Job__c>> commIdToOppsMap, 
                                                    Map<Id, Set<Forecast__c>> commIdToForecastsMap ){
                                                        List<AE_Bonus__c> commissionsToUpdate = new List<AE_Bonus__c>();               
                                                        Set<Id> jobIds = new Set<Id>();
                                                        if( !commissionsMap.isEmpty() ){                                            
                                                            Set<Id> userIds = new Set<Id>();    
                                                            for( AE_Bonus__c bonus : commissionsMap.values() ){
                                                                bonus = calculateRevenue( bonus, commIdToForecastsMap.get( bonus.Id ) );
                                                                bonus = calculateLeads( bonus, commIdToOppsMap.get( bonus.Id ) );
                                                                system.debug(bonus);
                                                                commissionsToUpdate.add( bonus );                
                                                            }
                                                        }
                                                        system.debug(commissionsToUpdate);
                                                        if( !commissionsToUpdate.isEmpty()  ){
                                                            update commissionsToUpdate;
                                                        }
                                                    }
    
    
    private static AE_Bonus__c calculateRevenue( AE_Bonus__c comm, Set<Forecast__c> forecasts ){
        Decimal billedNewRevenue = 0, billedRevenue = 0;
        if( forecasts != null && !forecasts.isEmpty() ){
            for( Forecast__c f : forecasts ){            
                if( f.Revenue_Amount__c != null && f.Revenue_Amount__c != 0 && f.Split_Percent__c > 0 && 
                   (f.AE1_Bonus__c == comm.Id || f.AE2_Bonus__c == comm.Id )){
                       if( f.ATI_Job__r.Job_Type__c == 'New Business' ){
                           billedNewRevenue += (f.Revenue_Amount__c * f.Split_Percent__c)/100;
                       }
                       billedRevenue += (f.Revenue_Amount__c * f.Split_Percent__c)/100;
                       
                   }            
            }
        }
        comm.Total_Billed_Revenue_this_Quarter__c = billedRevenue;
        comm.New_Business_Billed_Revenue_this_Quarter__c = billedNewRevenue;
        return comm;
    }
    
    private static AE_Bonus__c calculateLeads( AE_Bonus__c comm, Set<ATI_Job__c> jobs ){
        Integer noOfLeads = 0, noOfLeadsOutside = 0;
        if( jobs != null && !jobs.isEmpty() ){
            for( ATI_Job__c job : jobs ){
                 if( comm.Quarter_Billed__c == JobAEBonusTriggerHandler.getCurrentQuarter( date.newinstance(job.CreatedDate.year(), job.CreatedDate.month(), job.CreatedDate.day()) ) &&                
                   comm.Year_Billed__c == string.valueOf( job.CreatedDate.year() ) ){
                       if( comm.AE_Name__r.State__c != job.Office2__r.State__c && comm.AE_Name__r.State__c != null ){
                           noOfLeadsOutside += 1; 
                       }
                       noOfLeads += 1;
                   } 
            }
        }
        comm.Total_Leads_Per_Quarter__c = noOfLeads;        
        comm.Leads_Outside_my_Territory__c = noOfLeadsOutside;
        return comm;
    }
}