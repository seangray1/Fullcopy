public without sharing class OpportunityJobControl {
    public static List <String> AlphaChar = new List<String>{
        'A', 'B', 'C', 'D', 'E', 'F', 
        'G', 'H', 'I', 'J', 'K', 'L', 
        'M', 'N', 'O', 'P', 'Q', 'R',
        'S', 'T', 'U', 'V', 'W', 'X',
        'Y', 'Z', '1', '2', '3', '4', 
        '5', '6', '7', '8', '9'};
    public static Map<String, String> DIVISION_TO_JOBCHAR = new Map<String, String> {
        'asbestos'               => '1',
        '1. asbestos'            => '1',
        'lead'                   => '2',
        '2. lead'                => '2',
        'bio'                    => '2',
        '3. bio'                 => '2',
        'lead/biohazard'         => '2',
        'lead/ biohazard'        => '2',
        'e.s.'                   => '3',
        'e/s'                    => '3', 
        '4. e.s.'                => '3',
        'environmental services' => '3', 
        'emergency svces'        => '3',
        'Emergency Svces'        => '3',
        'contents'               => '4',
        '5. contents'            => '4',
        'microbile'              => '5', 
        'microbial'              => '5',
        '6. microbial'           => '5',
        'mold'                   => '5',
        'catastrophes'           => '6', 
        'catastrophe'            => '6', 
        '7. catastrophe'         => '6',
        'constructions'          => '7',
        'construction'           => '7',
        '8. construction'        => '7',
        'marketing'              => '9',
        '9. marketing'           => '9'
    };
    
    
    public static Map<String, String> DIVISION_TO_JOBCHAR_2013 = new Map<String, String> {
        'asbestos/lead'          => '1',
        'asbestos'               => '1',
        '1. asbestos'            => '1', 
        'bio'                    => '1',
        'bio-hazard'             => '1',
        'biohazard'              => '1',
        'demolition'             => '1',
        'demolitions'            => '1',
        'lead'                   => '1',
        'lead/biohazard'         => '1',
        'lead/ biohazard'        => '1',
        'health services'        => '2',
        '2. health-service'      => '2',
        'e.s.'                   => '3',
        'e/s'                    => '3',
        '3. e.s.'                => '3',
        'emergency svces'        => '3',
        'Emergency Svces'        => '3',
        'environmental services' => '3', 
        'contents'               => '4',
        '4. contents'            => '4',
        'microbile'              => '5', 
        'microbial'              => '5',
        '5. microbial'           => '5',
        'mold'                   => '5',
        'catastrophes'           => '6', 
        'catastrophe'            => '6', 
        '6. catastrophe'         => '6',
        'constructions'          => '7',
        'construction'           => '7',
        '7. constructions'       => '7',
        'consulting'             => '7',
        'technical svces'        => '7',
        'marketing'              => '9',
        '9. marketing'           => '9'
    };
    
    
    public static Map<String, String> OFFICE_TO_JOBCHAR = new Map<String, String> {
        'orange'                 => '1',
        'corporate'              => '0',
        'chicago'                => '1', 
        'chatsworth'             => '2',
        'los angeles'            => '2',
        'texas'                  => '2',
        'dallas'                 => '2',
        'hayward'                => '3',
        'san francisco'          => '3', 
        'new england'            => '3',
        'san diego'              => '4', 
        'florida'                => '4', 
        'sacramento'             => '5', 
        'philadelphia'           => '5',
        'insland empire'         => '6',
        'inland empire'          => '6', 
        'riverside'              => '6', 
        'seattle'                => '6',
        'las vegas'              => '7', 
        'denver'                 => '7',
        'san jose'               => '8', 
        'houston'                => '8',
        'pheonix'                => '9',
        'phoenix'                => '9',
        'tuscon'                 => '9',
        'tucson'                 => '9',
        'flagstaff'              => 'A'
    };
    
    
    public static Map<String, String> OFFICE_SPEC_CHAR = new Map<String, String> {
        'chicago'                => '6',
        'tuscon'                 => '6', 
        'tucson'                 => '6',
        'texas'                  => '6',
        'dallas'                 => '6',
        'new england'            => '6',
        'florida'                => '6',
        'philadelphia'           => '6',
        'denver'                 => '6',
        'seattle'                => '6',
        'houston'                => '6'   
        
    };    
    
    /**
    From ATI Feedback Spreadsheet
    Division identifiers for GL prefix are (effective 1/1/2013):
    10 (Asbestos, Lead, Bio), 20 (Healthcare), 30 (E.S.), 40 (Contents),
    50 (Microbial), 60 (Catastrophe), 70 (Structure), 90 (Marketing)
    */
    public static Map<String, String> DIVISION_TO_GLPFX = new Map<String, String> {
        'asbestos'               => '10',
        '1. asbestos'            => '10',
        'lead'                   => '20', 
        '2. lead'                => '20',
        'bio'                    => '20',
        'biohazard'              => '20',
        '3. bio'                 => '20',
        'lead/biohazard'         => '20',
        'lead/ biohazard'        => '20',
        'e.s.'                   => '30',
        'e/s'                    => '30', 
        '4. e.s.'                => '30',
        'emergency svces'        => '30',
        'Emergency Svces'        => '30',
        'environmental services' => '30', 
        'contents'               => '40',
        '5. contents'            => '40',
        'microbile'              => '50', 
        'microbial'              => '50',
        '6. microbial'           => '50',
        'mold'                   => '50',
        'catastrophes'           => '60', 
        'catastrophe'            => '60', 
        '7. catastrophe'         => '60',
        'constructions'          => '70',
        'construction'           => '70',
        '8. construction'        => '70',
        'marketing'              => '90',
        '9. marketing'           => '90'
    };
    
    
    /**
    From ATI Feedback Spreadsheet
    Division identifiers for GL prefix are (effective 1/1/2013 - added consulting 10/29/2013):
    10 (Asbestos, Lead, Demolition), 20 (Health Science Service), 30 (E.S.), 40 (Contents),
    50 (Microbial, Bio), 60 (Catastrophe), 70 (Construction, Technical Service, Consulting), 90 (Marketing)
    */
    public static Map<String, String> DIVISION_TO_GLPFX_2013 = new Map<String, String> {
        'asbestos/lead'          => '10',
        'asbestos'               => '10',
        '1. asbestos'            => '10',
        'lead'                   => '10', 
        'demolition'             => '10',
        'biohazard'              => '10',
        'bio'                    => '10',
        'bio-hazard'             => '10',
        'lead/biohazard'         => '10',
        'lead/ biohazard'        => '10',
        'health services'        => '20',
        '2. health service'      => '20',
        'e.s.'                   => '30',
        'e/s'                    => '30',
        '3. e.s.'                => '30',
        'emergency svces'        => '30',
        'Emergency Svces'        => '30',
        'environmental services' => '30', 
        'contents'               => '40',
        '4. contents'            => '40',
        'microbile'              => '50', 
        'microbial'              => '50',
        '5. microbial'           => '50',
        'mold'                   => '50',
        'catastrophes'           => '60', 
        'catastrophe'            => '60', 
        '6. catastrophe'         => '60',
        'constructions'          => '70',
        'construction'           => '70',
        '7. construction'        => '70',
        'consulting'             => '70',
        'technical svces'        => '70',
        'marketing'              => '05',
        '9. marketing'           => '05'
    };
    
    /**
    From ATI Feedback Spreadsheet
    Office identifiers for GL prefix are: 10 (Corporate), 20 (Los Angeles),
    30 (San Francisco), 40 (San Diego), 50 (Sacramento), 60 (Riverside),
    70 (Las Vegas), 80 (San Jose), 90 (Phoenix), 91 (Tucson),
    11 (Chicago), 21 (Dallas), 31 (New England)
    */
    public static Map<String, String> OFFICE_TO_GLPFX = new Map<String, String> {
        'orange'                 => '10',
        'corporate'              => '01',
        'chicago'                => '11',
        'los angeles'            => '20',
        'dallas'                 => '21',
        'san francisco'          => '30', 
        'new england'            => '31',
        'san diego'              => '40', 
        'sacramento'             => '50', 
        'philadelphia'           => '51',
        'riverside'              => '60', 
        'seattle'                => '61',
        'houston'                => '81',
        'las vegas'              => '70',
        'denver'                 => '71', 
        'san jose'               => '80', 
        'pheonix'                => '90',
        'phoenix'                => '90',
        'tuscon'                 => '91',
        'tucson'                 => '91',
        'florida'                => '41',
        'flagstaff'              => 'A0'
    };
    
    public static TriggerStatus__c cfg = TriggerConfig.raw;
    
    
    public static void recalculateJobNumbers(List<Opportunity> newJobs, Map<Id, Opportunity> oldJobs) {
        
        // Determine which jobs need to have their job numbers recalculated
        List<Opportunity> jobs = new List<Opportunity>();
        
        // Depending on if we have old values or not...
        if (oldJobs == null) {
            
            // ... No old jobs means all jobs need recalculation
            // TODO: Should this just return?  Are there ever instances where
            // the job number should be calculated on Job insert?  I don't know
            // if there are...
            jobs.addAll(newJobs);
            
        } else {
            
            // ... Old job values means we need to determine if a dependent
            // field has changed before deciding whether or not to recalc
            for (Opportunity nj : newJobs) {
                
                // Get the old values of the job
                Opportunity oj = oldJobs.get(nj.Id);
                
                // If there is no old values, assume a recalc is necessary
                if (oj == null) {
                    jobs.add(nj);
                } else 
                {
                    Integer cfgSequenceT = Integer.valueOf(cfg.Job_Number_Sequence_Group__c);
                    Integer sequenceT = cfgSequenceT;
                    
                    try
                    {
                        sequenceT = Integer.valueOf(nj.Job_Number_Sequence_Group__c); 
                    }
                    catch(Exception e)
                    {
                        
                    }
                    
                    if(nj.Date_Time_Taken__c > date.newInstance(2013, 1, 1) && sequenceT >= cfgSequenceT)
                    {
                        
                    
                        // Otherwise, check if a dependency field was changed OR
                        // the resulting field has changed
                        if (nj.Job_Number_Sequence__c != oj.Job_Number_Sequence__c ||
                                nj.Job_Number_Sequence_Group__c != oj.Job_Number_Sequence_Group__c ||
                                // nj.Date_Time_Taken__c != oj.Date_Time_Taken__c ||
                                nj.Project_Manager__c != oj.Project_Manager__c ||
                                nj.Office__c != oj.Office__c ||
                                nj.Division__c != oj.Division__c // ||
                                //nj.Name != oj.Name ||
                                //nj.Job_Number__c != oj.Job_number__c
                                ) {
                            
                            // One of the important fields has changed.  This needs
                            // a job number recalc
                            jobs.add(nj);
                                }                       
                    }
                    
                }
                
            } // END of looping through new jobs
            
        } // END of check if is insert or is update
        
        // If there are no jobs to recalc, end
        if (jobs.isEmpty()) {
            return;
        }
        
        // Reclaculate job numbers
        setJobNumbers(jobs);
        
    }
    
    
    
    public static void setJobNumbers(List<Opportunity> jobs) {
        
        if (jobs == null || jobs.isEmpty()) {
            return;
        }
        
        // Get all of the owners that need to be looked up
        Set<Id> ownerIds = ADCUtil_SObject.generateIdSet(jobs, 'Project_Manager__c');
        Map<Id, User> owners = new Map<Id, User>(
            [SELECT Id, PM_Job_Code__c FROM User WHERE Id IN :ownerIds]
        );
        
        // Since leads is assumed to be read/write, simply set the job number
        for (Opportunity j : jobs) {
            
            // If a job number doesn't exist, assume that the job name has the
            // job number in it (since the job number is sometimes mapped
            // directly to the Name field for Opportunity)
            if (String.isBlank(j.Job_Number__c)) {
                System.debug(Logginglevel.INFO, 'OpportunityJobControl.setJobNumbers(job): The Job_Number__c field was blank, '+
                                                'attempting to use name value of '+j.Name+' instead...');
                j.Job_Number__c = j.Name;
            }
            
            // For any jobs that don't have a sequential value, make sure to derive
            // one from the job number
            if (j.Job_Number_Sequence__c == null) {
                System.debug(Logginglevel.WARN, 'OpportunityJobControl.setJobNumbers(job): No Job Number Sequence available');
            }
            
            // Determine the nicely formatted sequential job number
            Decimal sequenceRaw = j.Job_Number_Sequence__c;
            String sequenceStr = null;
            if (sequenceRaw != null) {
                Integer sequenceInt = (Integer) sequenceRaw.round();
                sequenceInt = Math.mod(sequenceInt, 100000);
                sequenceStr = ADCUtil_Base.forceStringLength(String.valueOf(sequenceInt), 5, '0', false);
            }
            
            // Set the job number for the lead
            DateTime timeTaken = j.Date_Time_Taken__c;
            if (timeTaken == null) timeTaken = j.CreatedDate;
            if (timeTaken == null) timeTaken = DateTime.now();
            j.Job_Number__c = OpportunityJobControl.getJobNumber(timeTaken.year(),
                                                      owners.get(j.Project_Manager__c),
                                                      j.Office__c,
                                                      j.Division__c,
                                                      sequenceStr);
            j.Name = j.Job_Number__c+ ' | '+j.Job_Name__c;
            if (!String.IsBlank(j.Job_Number__c)) {
                j.Job_Number_No_Dashes__c = ((String)j.Job_Number__c).replace('-','');
            }
            
        }
        
    }
    
    
    /**************************************************************************
     * Calculates the GL Account prefix field on jobs that should be passed
     * to Timberline as part of the integration.
     *
     */
    public static void setGLAccountPrefix(List<Opportunity> jobs) {
        
        // Go through each of the jobs and set the prefix value
        for (Opportunity j : jobs) {
            
            if(j.GL_Account_Prefix_Overwrite__c == false){
            
                // Determine the Date/time taken (used for Division mappings)
                DateTime timeTaken = j.Date_Time_Taken__c;
                if (timeTaken == null) timeTaken = j.CreatedDate;
                if (timeTaken == null) timeTaken = DateTime.now();
                Integer year = timeTaken.year();
                System.debug('OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+']: Year = '+year);
                
                // Get the appropriate mappings
                Map<String, String> officeMap = OFFICE_TO_GLPFX;
                Map<String, String> divisionMap = (year == null || year < 2013) ? DIVISION_TO_GLPFX : DIVISION_TO_GLPFX_2013;
                
                // Get the values from the job
                String division = (j.Division__c == null) ? null : j.Division__c.toLowerCase();
                System.debug('OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+']: Division = '+division);
                String office = (j.Office__c == null) ? null : j.Office__c.toLowerCase();
                System.debug('OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+']: Office = '+office);
                
                
                // Define the running GL Prefix
                String glPrefix = '1-';
                
                // Add the office Identifier
                if (office != null && officeMap.containsKey(office)) {
                    System.debug('OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+']: Office Code = '+officeMap.get(office));
                    glPrefix += officeMap.get(office);
                } else {
                    System.debug(Logginglevel.WARN, 'OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+
                                                    ']: Office code could not be found for '+office);
                    glPrefix += '##';
                }
                
                // Add the thing in the middle (the format is 1-XX-YY where XX is the
                // office and YY is the division)
                glPrefix += '-';
                
                // Add the 2 digit division code
                if (division != null && divisionMap.containsKey(division)) {
                    System.debug('OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+']: Division Code = '+divisionMap.get(division));
                    
                    /***
                    //If division equals to health services and year < 2017, then Glcode = 02
                    if(year < 2017 && division == 'health services')
                        glPrefix += '02';
                    ****/
                    
                    //if the division if marketing and corporate, enter 01. Otherwise, enter 05.
                    if(division == 'marketing' && office == 'corporate') {
                        glPrefix += '01';
                    }
                    else
                        glPrefix += divisionMap.get(division);
                        
                } else {
                    System.debug(Logginglevel.WARN, 'OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+
                                                    ']: Division Code could not be found for '+division);
                    glPrefix += '##';
                }
                
                // Set the value on the job
                j.GL_Account_Prefix__c = glPrefix;
            }
            
        }
        
        // All records have been properly updated
        return;
        
    }
    
    
    /**************************************************************************
     * This function was made largely to cause jobs to be numbered when cloned.
     * Essentially, when a new job is entered into the system, it will check
     * for other jobs with the same job number.  If one exists, then the job
     * number will be cleared out for the current job (essentially, this should
     * be called prior to the code that calculates job numbers)
     *
     * Since this is meant for cloning, it should only be called in a before
     * insert context.
     *
     */
    public static void preventDuplicateJobNumbers(List<Opportunity> jobs) {
        
        // Put all of the jobs into a job number bucket map (since Job Number
        // isn't required to be unique, we have to assume that buckets are
        // possible)
        Map<String, List<Opportunity>> numToJob = new Map<String, List<Opportunity>>();
        for (Opportunity j : jobs) {
            String jn = null;
            if (! String.isBlank(j.Job_Number__c)) {
                jn = j.Job_Number__c;
            } else if (! String.isBlank(j.Name)) {
                jn = j.Name;
            }
            if (! numToJob.containsKey(jn)) {
                numToJob.put(jn, new List<Opportunity>());
            }
            numToJob.get(jn).add(j);
        }
        system.debug('OpportunityJobControl.preventDuplicateJobNumbers' + numToJob.keySet());
        // Attempt to find jobs with the same job numbers
        List<Opportunity> conflictJobs = [SELECT Id, Job_Number__c FROM Opportunity WHERE Job_Number__c IN :numToJob.keySet()];
        
        // Go through jobs and invalidate any conflicts
        for (Opportunity cj : conflictJobs) {
            List<Opportunity> jobsToNullify = numToJob.get(cj.Job_Number__c);
            for (Opportunity j : jobsToNullify) {
                if (cj.Id == j.Id) continue; // In case this method is called on update
                System.debug('OpportunityJobControl.setGLAccountPrefix: Job['+j.Id+
                             ']: Recalculating job number due to duplicate value ('+cj.Job_Number__c+') on Job['+cj.id+']');
                j.Job_Number_Sequence__c = null;
                j.Job_Number__c = null;
                j.Job_Number_No_Dashes__c = null;
                j.Name = null;
            }
        }
        
    }
    
    /**************************************************************************
     * Generates a new job number.
     *
     * The format of the job number is as follows:
     * YPP-OD-MSSSS where
     *  Y    = A special value based on the year the record was created
     *  PP   = Project Manager Number
     *  O    = Office character. See OFFICE_TO_JOBCHAR
     *  D    = Division character. See DIVISION_TO_JOBCHAR
     *  M    = Either the most significant digit (left-most) of the sequential
     *         value or a special character based on office. See
     *         OFFICE_SPEC_CHAR
     *  SSSS = The 2nd thru 5th characters (1-indexed) of the sequential string
     */
    public static String getJobNumber(Integer year, User projectManager,
            String office, String divisionName, String sequential) {
        
        System.debug('OpportunityJobControl.getJobNumber: Generating job number: Year:'+year+', PM:'+projectManager+', Office:'+
                     office+', Division:'+divisionName+', Sequential:'+sequential+'');
        //List <String> AlphaChar = new List<String>{'A', 'B', 'C', 'D'};
        // Determine the different parts of the number
        String jn = '';
            
        // First character is the year.  The year follows very strange rules.
        // Basically, starting with 2000, the number starts with 1 and goes
        // through 2008 at which point the digit is 9.  In 2009, the numbering
        // then restarts at 1 and repeats
        if (year != null) {
            if (year < 2000) {
                jn += 'X';
            } else if(year >= 2000 && year < 2018){
                Integer d = Math.mod((year - 2000), 9) + 1;
                jn += String.valueOf(d);
           } else {
               Integer index = Math.mod(((year - 2018) + 36), 36);
               jn += alphachar[index];              
           }
        }
        jn = ADCUtil_Base.forceStringLength(jn, 1, '#');
        System.debug('OpportunityJobControl.getJobNumber: After Year: '+jn);
        
        // Second and third characters are project manager info
        if (projectManager != null && projectManager.PM_Job_Code__c != null) {
            jn += projectManager.PM_Job_Code__c;
        }
        jn = ADCUtil_Base.forceStringLength(jn, 3, '#');
        System.debug('OpportunityJobControl.getJobNumber: After Project Manager: '+jn);
        
        // Fourth character is office code
        if (office != null && OFFICE_TO_JOBCHAR.containsKey(office.toLowerCase())) {
            jn += OFFICE_TO_JOBCHAR.get(office.toLowerCase());
        }
        jn = ADCUtil_Base.forceStringLength(jn, 4, '#');
        System.debug('OpportunityJobControl.getJobNumber: After Office: '+jn);
        
        // Fifth character is based on division, also based on year.  Depending
        // on the year, a different division mapping will be used
        if (year != null && year < 2013) {
            if (divisionName != null && DIVISION_TO_JOBCHAR.containsKey(divisionName.toLowerCase())) {
                jn += DIVISION_TO_JOBCHAR.get(divisionName.toLowerCase());
            }
        } else if (year != null && 2013 <= year) {
            if (divisionName != null && DIVISION_TO_JOBCHAR_2013.containsKey(divisionName.toLowerCase())) {
                jn += DIVISION_TO_JOBCHAR_2013.get(divisionName.toLowerCase());
            }
        }
        jn = ADCUtil_Base.forceStringLength(jn, 5, '#');
        System.debug('OpportunityJobControl.getJobNumber: After Division: '+jn);
        
        // Characters 6-10 are the sequential elements, if the office is
        // contained in the OFFICE_SPEC_CHAR map contains the office, it means
        // that the first digit of the sequential should be replaced with the
        // value that comes back from that map
        if (office != null && OFFICE_SPEC_CHAR.containsKey(office.toLowerCase())) {
            jn += OFFICE_SPEC_CHAR.get(office.toLowerCase());
            System.debug('OpportunityJobControl.getJobNumber: After Office Special Character: '+jn);
            if (sequential != null) {
                jn += sequential.substring(1,5);
            }
        } else {
            if (sequential != null) {
                jn += sequential;
            }
        }
        jn = ADCUtil_Base.forceStringLength(jn, 10, '#');
        System.debug('OpportunityJobControl.getJobNumber: After Sequential Part: '+jn);
        
        // Put in hyphens to space out the stuff (###-##-#####)
        String jobNumber = jn.substring(0, 3) + '-' + jn.substring(3, 5) + '-' + jn.substring(5, 10);
        
        return jobNumber;
            
    }
    
    
    
    /**************************************************************************
     * Helper function for a trigger to determine if Job Forecasts must be
     * globally refreshed.  This will check through the jobs, see if any have
     * been flagged in such a way that it would imply a global refresh is being
     * requested.
     *
     * If any such jobs are found, a quick check is made to see if a refresh is
     * already in process.  If one IS, then the triggering jobs will be
     * updated with an error message specifying that a refresh is already in
     * effect and a link to the page where apex jobs can be monitored.
     *
     * If no Apex refresh jobs are in effect, then one will be kicked off at a
     * rate of 500 jobs per batch.
     *
     * @param jobs
     *         Contains a list of jobs from Trigger.new.  These jobs may be
     *         updated and, therefore, it is assumed that they are NOT 
     *         read-only.
     */
    public static void globalRefreshForecasts(List<Opportunity> jobs) {
        
        String logpfx = 'OpportunityJobControl.globalRefreshForecasts: ';
        
        // Find all jobs that actually are requesting a refresh
        Boolean isQuickRefresh = false;
        List<Opportunity> candidateJobs = new List<Opportunity>();
        for (Opportunity j : jobs) {
            if (j.Update_Forecasts_Global__c == true) {
                candidateJobs.add(j);
                j.Update_Forecasts_Global__c = false;
            }
            if (j.Update_Forecasts_Global_Fast__c == true) {
                candidateJobs.add(j);
                j.Update_Forecasts_Global_Fast__c = false;
                isQuickRefresh = true;
            }
        }
        
        // If we have no candidate jobs, abort
        if (candidateJobs.isEmpty()) {
            return;
        }
        
        System.debug(Logginglevel.WARN, logpfx+'Attempting to request a new ['+((isQuickRefresh)?'Fast':'Full')+'] Forecast Refresh');
        
        // Check if an update is already running
        AsyncApexJob aaj = null;
        try {
            
            aaj = [SELECT ID, JobType, MethodName, ExtendedStatus, ApexClassId,
                       Status, TotalJobItems, JobItemsProcessed,
                       NumberOfErrors, CreatedDate
                   FROM AsyncApexJob
                   WHERE (Status='Processing' OR Status='Queued') AND 
                       JobType='BatchApex' AND
                       ApexClassId='01p70000000TnWUAA0'
                   LIMIT 1];
            System.debug(Logginglevel.WARN, logpfx+'Found refresh job already in existence: '+aaj);
                   
        } catch (Exception e) {
            
              // Job could not be found
              aaj = null;
            
        }
        
        // If a job is running, we need to error out the records
        if (aaj != null) {
            
            // Determine the error message to display
            String msg = '';
            if (aaj.Status == 'Processing') {
                System.debug(Logginglevel.WARN, logpfx+'Batch job being processed');
                msg = 'Cannot globally refresh Forecast Data.  A request to refresh was submitted on '+aaj.CreatedDate.format()+
                      ' and is currently being processed. It has completed '+aaj.JobItemsProcessed+' of '+aaj.TotalJobItems+
                      ' batches. <a href="/apexpages/setup/listAsyncApexJobs.apexp?setupid=AsyncApexJobs">View detailed status here</a>';
            } else {
                System.debug(Logginglevel.WARN, logpfx+'Batch job is queued');
                msg = 'Cannot globally refresh Forecast Data.  A request to refresh was submitted on '+aaj.CreatedDate.format()+
                      ' and is currently queued. <a href="/apexpages/setup/listAsyncApexJobs.apexp?setupid=AsyncApexJobs">'+
                      'View detailed status here</a>';
            }
            
            // Error out jobs, displaying the error message
            System.debug(Logginglevel.WARN, logpfx+'Error out candidate jobs');
            for (Opportunity errJob : candidateJobs) {
                errJob.addError(msg);
            }
            
            return;
            
        }
        
        // We are good to begin a batch.  The methods used depends on the speed
        // (fast vs full)
       /* SynchForecastBatch b = new SynchForecastBatch();
        if (isQuickRefresh) {
            b.useFastMode = true;
        }
        Id batchInstanceId = Database.executeBatch(b, 500);
        System.debug(Logginglevel.INFO, logpfx+'Executed new Sync Forecast Batch with ID '+batchInstanceId);
        */
    }
    
    
    
    public static Integer getNextJobNumberSequence(String groupName) {
        
        // Need to determine the maximum sequential number to use
        Integer seq = -1;
        
        // Check for top level jobs
        try {
            if( groupName != null ){
                Opportunity j = [SELECT Id, Job_Number_Sequence__c
                            FROM Opportunity
                            WHERE ( Job_Number_Sequence__c != null AND Job_Number_Sequence_Group__c = :groupName)
                            ORDER BY Job_Number_Sequence__c DESC
                            LIMIT 1];
                
                if (j.Job_Number_Sequence__c != null) {
                    System.debug('OpportunityJobControl.getNextJobNumberSequence: Group['+groupName+']: Current Seq='+seq+', Seq from Job='+
                                 j.Job_Number_Sequence__c.intValue());
                    seq = Math.max(j.Job_Number_Sequence__c.intValue(), seq);
                }
            }
        } catch (Exception e) {
            // Leave the sequence unchanged since no job was found
            System.debug('OpportunityJobControl.getNextJobNumberSequence: Group['+groupName+']: No job found, leaving Seq at '+seq);
        }
        
        // Get the next value in the sequence
        if (seq == null || seq < 0) {
            seq = 0;
        } else {
            seq += 1;
        }
        
        // Special case - if the group ends in a 6, it means that we need to
        // start counting at 60000 in order to make sure that things line up
        if (groupName.endsWith('6') && seq < 60000) {
            seq += 60000;
        }
        
        System.debug('OpportunityJobControl.getNextJobNumberSequence: Group['+groupName+']: Sequence Value: '+seq);
        return seq;
        
    }
    
    
    /**************************************************************************
     * Wrapper function for set Job Number sequential that will also calculate
     * if any of the incoming leads should actually be counted
     *
     */
    public static void setJobNumberSequential(List<Opportunity> jobs, Map<Id, Opportunity> oldJobs) {
        
        // Each incoming job also needs to have it's groups set first so that
        // we can tell if the group has changed (thus, required a new number)
        OpportunityJobControl.setJobNumberIncGroups(jobs);
        
        // Get the jobs from the database again, just to be safe
        // We can't trust the oldJobs that came from the trigger, since it could be the wrong value when workflow rules cause an update
        if (oldJobs != null)
            oldJobs = new Map<Id, Opportunity>([SELECT Id, Job_Number__c, Job_Number_Sequence_Group__c 
                                                FROM Opportunity where (Id in :oldJobs.keySet())]);
        
        // Find all of the jobs that need an incremental
        List<Opportunity> candidateJobs = new List<Opportunity>();
        for (Opportunity j : jobs) {
            
            // Get the new and old record values
            Opportunity nj = j;
            Opportunity oj = (oldJobs == null) ? null : oldJobs.get(j.Id);
            
            // If the job number sequence is empty, attempt to get a new one
            if (nj.Job_Number_Sequence__c == null && nj.Job_Number__c != null) {
                try{
                    String newJobSequence = nj.Job_Number__c.right(5);
                    nj.Job_Number_Sequence__c = Integer.valueOf(newJobSequence);
                } catch (Exception e) {
                    System.debug(Logginglevel.WARN, 'OpportunityJobControl.setJobNumberSequential: Attempting to derive Job Number Sequence from "'+
                                                    j.Job_Number__c+'" ['+j.Id+'] failed with an exception: '+e.getMessage());
                    nj.Job_Number_Sequence__c = null;
                }
            }
            
            // If there has been a change between groups (this differs from the
            // Lead version in that JOBs should NOT attempt to generate a
            // sequential in the event that one has not been set.  That is
            // handled by the job numbering logic).  Also, if setting for the
            // first time, don't change the job
            if (nj.Job_Number_Sequence__c == null ||
                    (oj != null && oj.Job_Number_Sequence_Group__c != null && 
                    nj.Job_Number_Sequence_Group__c != oj.Job_Number_Sequence_Group__c)) {
            
                // We've found a candidate!
                candidateJobs.add(nj);
                
            }
        }
        
        // If there are no candidates, we are done
        if (candidateJobs.isEmpty()) {
            return;
        }
        
        // Otherwise, calculate sequentials for the values
        setJobNumberSequential(candidateJobs);
        return;
        
    }
    
    
    
    /**************************************************************************
     * Functionality for recalculating job incremental values in the event that
     * the office or some other crap changes.
     *
     */
    public static void setJobNumberSequential(List<Opportunity> jobs) {
        
        // Group the leads based on incrementor group (this should only create
        // 1 or 2 groups.  If it's more, that's bad news)
        Map<String, List<Opportunity>> gjobs = new Map<String, List<Opportunity>>();
        for (Opportunity j : jobs) {
            
            // Create a new bucket if necessary
            String g = j.Job_Number_Sequence_Group__c;
            if( g != null ){
                if (! gjobs.containsKey(g)) {
                    gjobs.put(g, new List<Opportunity>());
                }
                
                // Add the lead to the bucket
                gjobs.get(g).add(j);
            }
        }
        
        /***********************************************************************************************************************
        
        // If more than 1 bucket, warn (since we need to make 1 query per bucket)
        if (gjobs.size() > 1) {
            System.debug(Logginglevel.WARN, 'PMLeadControl.setJobNumberSequential: There are '+gjobs.size()+' lead groups in question. 
This could be bad for SOQL query limits');
        }
        ****************************************************************************************************************/
        
        // Go through each of the groups and calculate sequentials differently
        for (String g : gjobs.keyset()) {
            
            // Need to determine the maximum sequential number to use
            Integer customerSequence = OpportunityJobControl.getNextJobNumberSequence(g);
            
            List<Opportunity> jobsInGroup = gjobs.get(g);
            
            // Go through each of the accounts and update the account number.
            // Because of the other version of setJobNumberSequential which
            // wraps this one, we know that any leads are candidates.
            // Therefore, we know that the lead needs its sequence updated
            for (Opportunity j : jobsInGroup) {
                j.Job_Number_Sequence__c = customerSequence;
                customerSequence += 1;
            }
            
        }
        
        return;
        
    }
    
    
    /**************************************************************************
     *
     *
     * TO RETROFIT EXISTING JOBS:
     *    List<Opportunity> jobs = [SELECT Id, Office__c, Date_Time_Taken__c, CreatedDate FROM Opportunity WHERE Job_Number_Sequence_Group__c = null];
     *    OpportunityJobControl.setJobNumberIncGroups(jobs);
     *    update jobs;
     */
    public static void setJobNumberIncGroups(List<Opportunity> jobs) {
        
        // Set up the sequence groups for each lead
        for (Opportunity j : jobs) {
            
            Integer cfgSequenceT = Integer.valueOf(cfg.Job_Number_Sequence_Group__c);
            Integer sequenceT = cfgSequenceT;
                    
            try
            {
                sequenceT = Integer.valueOf(j.Job_Number_Sequence_Group__c); 
            }
            catch(Exception e)
            {
                
            }
            
            if(j.Date_Time_Taken__c > date.newInstance(2013, 1, 1) && sequenceT >= cfgSequenceT)
            {
                // Determine the year for the lead
                DateTime timeTaken = j.Date_Time_Taken__c;
                if (timeTaken == null) timeTaken = j.CreatedDate;
                if (timeTaken == null) timeTaken = DateTime.now();
                String yr = String.valueOf(timeTaken.year()); // Last clause ensures this always has a value
                System.debug('OpportunityJobControl.setJobNumberIncGroups: Job['+j.Id+']: Year Component: '+yr);
                
                // Check if the office is one of the 6-ers
                String office = (j.Office__c == null) ? null : j.Office__c.toLowerCase();
                if (office != null && OpportunityJobControl.OFFICE_SPEC_CHAR.containsKey(office)) {
                    office = '6';
                } else {
                    office = '0';
                }
                System.debug('OpportunityJobControl.setJobNumberIncGroups: Job['+j.Id+']: Office Component: '+office);
                
                // Combine the two together for the group!
                j.Job_Number_Sequence_Group__c = yr+office;
                System.debug('OpportunityJobControl.setJobNumberIncGroups: Job['+j.Id+']: Group: '+j.Job_Number_Sequence_Group__c);
            }
            
        }
        
    }

}