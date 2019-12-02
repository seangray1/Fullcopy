public with sharing class ResourceSchedulerController {
  /*  
    /** The custom settings record associated with the scheduler 
    public SchedulerSettings__c CONFIG = SchedulerSettings__c.getInstance();
    
    /** Name of the parameter specifying the filter start date *
    public String PNAME_START_DATE = 'ressched_start';
    
    /** Name of the parameter specifying the filter end date *
    public String PNAME_END_DATE = 'ressched_end';
    
    /** Name of the parameter specifying the resource filter *
    public String PNAME_NAME_FILTER = 'ressched_q';
    
    /** Name of the parameter specifying the resource department filter *
    public String PNAME_DEPT_FILTER = 'ressched_d';
    
    /** Name of the parameter specifying the resource department filter *
    public String PNAME_OFFICE_FILTER = 'ressched_o';
    
    /** The starting date to filter the schedule on *
    public Date mParamStartDate = null;
    
    /** The ending date to filter the schedule on *
    public Date mParamEndDate = null;
    
    /** The string to use as a name filter *
    public String mParamNameFilter = null;
   
    /** The string to use as a department filter *
    public String mParamDeptFilter = null;
    
    /** The string to use as a office/location filter *
    public String mParamOfficeFilter = null;
    
    /** The date time representing the farthest left part of the timeline *
    public DateTime mTimelineStart = null;
    
    /** The date/time representing the farthest right part of the timeline *
    public DateTime mTimelineEnd = null;
    
    /** Allows for filtering the PMs that display in the first column *
    public String mParamPMFilter = null;
    
    /** List of all resources *
    public List<SchedulerResStruct> mResources = null;
    
    /** List of all bookings on the page.  This allows for easy access to the
     *  bookings by index *
    public List<SchedulerBookingStruct> mBookings = null;
    
    /** Cache for the result of the getAllDates function *
    public transient List<SchedulerDateStruct> mDatesCache = null;
    
    /** Contains all functionality related to the booking edit form **
    public BookingEditAjaxForm mEditBookingForm = null;
    
    /** Contains all functionality related to the filter form **
    public FilterForm mFilterForm = null;
    
    /** The width of a single day  on the scheduler *
    public Integer mDayWidth {get; private set;} 
    
    /** The minimum width (in pixels) of a day on the scheduler *
    protected Integer mMinDayWidth = 35;
    
    /** The approximate width of the scheduler (in pixels) *
    protected Integer mSchedulerWidth = 1500;
    
    
    /**************************************************************************
     * Initializes variables based on incoming parameters and user state
     *
    public ResourceSchedulerController() {
        
        ///////////////////////////////////////////////////
        // CHECK PRECONDITIONS
        
        // Make sure that the custom settings are present
        if (CONFIG == null) {
            throw new ADCUtil_Exceptions.IllegalStateException('A valid "Scheduler Settings" record was not found.  Please notify a system administrator.');
        }
        
        
        ///////////////////////////////////////////////////
        // RETRIEVE PARAMETERS
        
        // Retrieve page parameters
        Map<String, String> params = ApexPages.currentPage().getParameters();
        
        // If any parameters are absent, fall back on cookie values.  This
        // allows for searches to be 
        Map<String, System.Cookie> cks = ApexPages.currentPage().getCookies();
        
        if (params.get(PNAME_START_DATE) == null && cks.get(PNAME_START_DATE) != null) {
            params.put(PNAME_START_DATE, cks.get(PNAME_START_DATE).getValue());
        }
        
        if (params.get(PNAME_END_DATE) == null && cks.get(PNAME_END_DATE) != null) {
            params.put(PNAME_END_DATE, cks.get(PNAME_END_DATE).getValue());
        }
        
        if (params.get(PNAME_NAME_FILTER) == null && cks.get(PNAME_NAME_FILTER) != null) {
            params.put(PNAME_NAME_FILTER, cks.get(PNAME_NAME_FILTER).getValue());
        }
        
        if (params.get(PNAME_DEPT_FILTER) == null && cks.get(PNAME_DEPT_FILTER) != null) {
            params.put(PNAME_DEPT_FILTER, cks.get(PNAME_DEPT_FILTER).getValue());
        }
        
        if (params.get(PNAME_OFFICE_FILTER) == null && cks.get(PNAME_OFFICE_FILTER) != null) {
            params.put(PNAME_OFFICE_FILTER, cks.get(PNAME_OFFICE_FILTER).getValue());
        }
        
        System.debug('ResourceSchedulerController: The following parameters were found across URL and Cookies: '+params);
        
        ///////////////////////////////////////////////////
        // DEFAULT PARAMETERS
        
        // Use a default value of today if a start date is not specified
        mParamStartDate = Date.today();
        if (! ADCUtil_Base.isEmpty(params.get(PNAME_START_DATE))) {
            mParamStartDate = Date.parse(params.get(PNAME_START_DATE));
        }
        System.debug('ResourceSchedulerController: mParamStartDate='+mParamStartDate);
        
        // Use a default value of start date + 14 days if an end date is not
        // specified in the parameters
        mParamEndDate = mParamStartDate.addDays(14);
        if (! ADCUtil_Base.isEmpty(params.get(PNAME_END_DATE))) {
            mParamEndDate = Date.parse(params.get(PNAME_END_DATE));
        }
        System.debug('ResourceSchedulerController: mParamEndDate='+mParamEndDate);
        
        // Calculate the exact range of the timeline component
        mTimelineStart = ADCUtil_Base.addTimeComponent(mParamStartDate, 0, 0, 0);
        mTimelineEnd   = ADCUtil_Base.addTimeComponent(mParamEndDate, 23, 59, 59);
        
        // Calculate the minimum number of days to display on the timeline
        Integer minDays = 1;
        if (CONFIG.MinimumDays__c != null && minDays < CONFIG.MinimumDays__c ) {
            minDays = (Integer) CONFIG.MinimumDays__c.round();
        }
        System.debug('ResourceSchedulerController: minDays='+minDays);
        
        // Check if the timeline needs to be extended
        if (mTimelineEnd < mTimelineStart.addDays(minDays)) {
            mTimelineEnd = mTimelineStart.addDays(minDays + 1);
            mTimelineEnd = mTimelineEnd.addSeconds(-1);
        }
        System.debug('ResourceSchedulerController: mTimelineEnd='+mTimelineEnd);
        
        // Do not filter the resource data if no filter is specified
        mParamNameFilter = null;
        if (! ADCUtil_Base.isEmpty(params.get(PNAME_NAME_FILTER))) {
            mParamNameFilter = params.get(PNAME_NAME_FILTER);
        }
        System.debug('ResourceSchedulerController: mParamNameFilter='+mParamNameFilter);
        
        // Do not filter resource department if no filter is specified
        mParamDeptFilter = null;
        if (! ADCUtil_Base.isEmpty(params.get(PNAME_DEPT_FILTER))) {
            mParamDeptFilter = params.get(PNAME_DEPT_FILTER);
        }
        System.debug('ResourceSchedulerController: mParamDeptFilter='+mParamDeptFilter);
        
        // Do not filter resource department if no filter is specified
        mParamOfficeFilter = null;
        if (! ADCUtil_Base.isEmpty(params.get(PNAME_OFFICE_FILTER))) {
            mParamOfficeFilter = params.get(PNAME_OFFICE_FILTER);
        }
        System.debug('ResourceSchedulerController: mParamOfficeFilter='+mParamOfficeFilter);
        
        
        ///////////////////////////////////////////////////
        // INITIALIZE VARIABLES
        
        mEditBookingForm = new BookingEditAjaxForm(this);
        mFilterForm = new FilterForm(this);
        
        // Determine the number of days being displayed and widen the days as appropriate
        Decimal daysBetween = (mTimelineEnd.getTime() - mTimelineStart.getTime()) / (1000.0*60.0*60.0*24.0);
        System.debug('ResourceSchedulerController: daysBetween='+daysBetween);
        mDayWidth = Math.max((Integer)(mSchedulerWidth / daysBetween), mMinDayWidth);
        System.debug('ResourceSchedulerController: mDayWidth='+mDayWidth);
        
        
    }
    
    
    /**************************************************************************
     * Returns the Edit Booking Form
     *
    public BookingEditAjaxForm getEditBookingForm() {
        return mEditBookingForm;
    }
    
    
    /**************************************************************************
     * Returns the Filter form
     *
    public FilterForm getFilterForm() {
        return mFilterForm;
    }
    
    
    
    /**************************************************************************
     * Returns all of the Dates associated with the scheduler.  These are the
     * dates that will show up along the top of the scheduler
     *
    public List<SchedulerDateStruct> getDates() {
        
        // Use the cached version if possible
        if (this.mDatesCache != null) {
            return this.mDatesCache;
        }
        
        
        ///////////////////////////////////////////////////
        // LOCALIZE VARIABLES
        
        DateTime d1 = this.mTimelineStart;
        DateTime d2 = this.mTimelineEnd;
        
        Date startDate = Date.newInstance(d1.year(), d1.month(), d1.day());
        Date endDate = Date.newInstance(d2.year(), d2.month(), d2.day());
        
        
        ///////////////////////////////////////////////////
        // CHECK PRECONDITIONS
        
        // If the start date isn't present, the date range doesn't make sense
        if (startDate == null) {
            throw new ADCUtil_Exceptions.IllegalStateException('The start date is invalid: '+startDate);
        }
        
        // If the end date isn't present, the date range doesn't make sense
        if (endDate == null) {
            throw new ADCUtil_Exceptions.IllegalStateException('The end date is invalid: '+endDate);
        }
        
        // If the end date is before the start date, the range doesn't make
        // sense
        if (endDate <= startDate) {
            throw new ADCUtil_Exceptions.IllegalStateException('The date range is invalid: '+startDate+' - '+endDate);
        }
        
        
        ///////////////////////////////////////////////////
        // FUNCTION LOGIC
        
        // Initialize the cache
        this.mDatesCache = new List<SchedulerDateStruct>();
        
        // We don't have a cached version, so calculate the dates to be
        // displayed in the scheduler
        Integer index = 0;
        for (Date d = startDate; d <= endDate; d = d.addDays(1)) {
            
            // Create a new empty date struct
            SchedulerDateStruct newDate = new SchedulerDateStruct(this);
            newDate.dateValue = d;
            newDate.dateText = String.valueOf(d.day());
            newDate.index = index;
            
            // If this is the first item being displayed or the first of a
            // month, it is necessary to have month text as well
            if (index == 0 || d.day() == 1) {
                newDate.monthText = String.valueOf(d.month()) + '/' + String.valueOf(d.year());
            }
            
            // Add the date to the list
            this.mDatesCache.add(newDate);
            
            // Get the index ready for the next iteration
            index += 1;
            
        }
        
        // Return the dates
        return this.mDatesCache;
        
    }
    
    
    
    /**************************************************************************
     * Returns all of the proect managers associated with the scheduler.
     *
    public List<SchedulerResStruct> getResources() {
        
        // Use the cached version if possible
        if (mResources != null) {
            return mResources;
        }
        
        
        ///////////////////////////////////////////////////
        // LOCALIZE VARIABLES
        
        String pmFilter = this.mParamPMFilter;
        Date startDate = Date.valueOf(this.mTimelineStart);
        Date endDate = Date.valueOf(this.mTimelineEnd);
        
        
        ///////////////////////////////////////////////////
        // CHECK PRECONDITIONS
        
        // Validate that a "Resource" account has been defined
        if (CONFIG.InternalResourceAccountId__c == null) {
            throw new ADCUtil_Exceptions.IllegalStateException('The "Resource" account must be specified in the Scheduler Settings record');
        }
        
        
        ///////////////////////////////////////////////////
        // FIND RESOURCES
        
        // Begin writing the select criteria for the resources
        String resQuery = 'SELECT Id, FirstName, LastName, Title, Phone, Department, Office__c, Contact_Type__c ';
        
        // Generate a sub-query that will find all relevant resource assignments
        String subQuery = 'SELECT Id, Name, Project_Manager__c, Job__c, Scheduler_Display__c,'
                        + ' Start_Date__c, End_Date__c, Resource_Name__c, Notes__c,'
                        + ' Scheduler_Color__c, Resource_Type__c'
                        + ' FROM Job_Resources__r'
                        + ' WHERE (Start_Date__c > :startDate AND Start_Date__c < :endDate)'
                        + ' OR (End_Date__c > :startDate AND Start_Date__c < :endDate)'
                        + ' OR (Start_Date__c < :startDate AND End_Date__c > :endDate)'
                        + ' ORDER BY Start_Date__c ASC';
        
        // Generate Add the sub query into the original resource query
        resQuery += ', ('+subQuery+') FROM Contact';
        
        // Add in the intitial where clause which filters only those contacts
        // associated with that ATI resource account
        Id rescourceAccountId = (Id) CONFIG.InternalResourceAccountId__c;
        resQuery += ' WHERE AccountId = :rescourceAccountId';
        
        // If a name filter was specified, go with it
        if (mParamNameFilter != null && mParamNameFilter != '') {
            String tmpNameFilter = String.escapeSingleQuotes(mParamNameFilter);
            resQuery += ' AND (FirstName LIKE \'%'+tmpNameFilter+'%\'';
            resQuery += ' OR LastName LIKE \'%'+tmpNameFilter+'%\')';
        }
        
        // If department names were specified, go with them
        if (mParamDeptFilter != null && mParamDeptFilter != '') {
            
            // Department filters work by using an in clause, allowing any of
            // the comma-separated departments to show up
            List<String> tmpDeptList = mParamDeptFilter.split(',');
            
            Set<String> tmpDepts = new Set<String>();
            for (String s : tmpDeptList) {
                tmpDepts.add(String.escapeSingleQuotes(s));
            }
            
            String tmpDeptFilter = ADCUtil_Base.strJoin('\',\'', tmpDepts);
            tmpDeptFilter = '(\''+tmpDeptFilter+'\')';
            
            resQuery += ' AND Division__c IN '+tmpDeptFilter;
            
        }
        
        // If office names names were specified, go with them
        if (mParamOfficeFilter != null && mParamOfficeFilter != '') {
            
            // Department filters work by using an in clause, allowing any of
            // the comma-separated departments to show up
            List<String> tmpOfficeList = mParamOfficeFilter.split(',');
            
            Set<String> tmpOffices = new Set<String>();
            for (String s : tmpOfficeList) {
                tmpOffices.add(String.escapeSingleQuotes(s));
            }
            
            String tmpOfficeFilter = ADCUtil_Base.strJoin('\',\'', tmpOffices);
            tmpOfficeFilter = '(\''+tmpOfficeFilter+'\')';
            
            resQuery += ' AND Office__c IN '+tmpOfficeFilter;
            
        }
        
        // Start adding in any special filters based on those provided in the
        // parameters
        // TODO: Implement this
        
        // Add in the final ordering clause to make sure that things come out
        // in alpha order by last name then first
        resQuery += ' ORDER BY LastName ASC, FirstName ASC';
        
        // Find all of the contacts
        System.debug('ResourceSchedulerController.getResources: Using the following query to find resources:\n'+resQuery);
        List<Contact> resRecords = Database.query(resQuery);
        System.debug('ResourceSchedulerController.getResources: Found a total of '+resRecords.size());
        
        
        ///////////////////////////////////////////////////
        // GENERATE RESOURCE DATA STRUCTURES
        
        // Construct the resources
        mResources = new List<SchedulerResStruct>();
        mBookings = new List<SchedulerBookingStruct>();
        for (Contact c : resRecords) {
            
            // Remember this resource in the cache
            mResources.add(new SchedulerResStruct(c, mTimelineStart, mTimelineEnd, mBookings));
            
            // Store the resource's index
            Integer resourceIndex = mResources.size() - 1;
            mResources.get(resourceIndex).index = resourceIndex;
            
        }
        
        // The resources have been constructed
        return mResources;
        
    }
    
    
    
    
    
    
    
    /**************************************************************************
     *
     *
    public class SchedulerBookingStruct {
        
        /** The date/time that the booking begins *
        public DateTime start {get; set;}
        
        /** The date/time that the booking ends *
        public DateTime stop {get; set;}
        
        /** The SFDC record related to the resource booking *
        public Job_Resource__c bookingData {get; set;}
        
        /** The percent through the timeline that the booking should start *
        public String left {get; set;}
        
        /** The width of the booking (percentage based on the timeline) *
        public String width {get; set;}
        
        /** The color of the bar.  This should be based on the PM *
        public String color {get; set;}
        
        /** The index of this booking in the controller's mAllBookings list *
        public Integer index {get; set;}
        
        /** The maximum number of bookings that this overlaps with.  If a
         *  booking does not overlap, this is 0. *
        public Integer overlapCount;
        
        /** When overlapping, refers to the index, or ordering, that this
         *  booking is displayed relative to other overlapping bookings *
        public Integer overlapIndex;
        
        /** A list of all other bookings that this overlaps with.  This is
         *  crucial information for situations in which overlap counts change
         *  at later points in time *
        public List<SchedulerBookingStruct> overlapBookings;
        
        
        /**********************************************************************
         * Defaults any necessary variables
         *
        public SchedulerBookingStruct() {
            color = '#C7EDF2';
        }
        
        
        
        public String getOverlapClass() {
            return 'ol-'+overlapCount+'-'+overlapIndex;
        }
        
        /*
        
        -webkit-box-shadow: inset 0px 10px 30px 0px rgba(255, 255, 255, 0.7);
box-shadow: inset 0px 10px 30px 0px rgba(255, 255, 255, 0.7);

*
        public String getInlineStyle() {
            String posStyle = 'left:'+left+'%; width:'+width+'%; ';
            String baseColorStyle = 'background:'+color+'; ';
            return posStyle+baseColorStyle;
        }
        
        
        /**********************************************************************
         * Sets the overlap count, keeping it in sync with all overlapping
         * booking records.
         *
        public void setOverlapCount(Integer newCount) {
            
            // This function needs to recursively set the overlap count for
            // all overlapping bookings.  This should only ever INCREASE the
            // overlap count and never decrease it
            if (overlapCount == null || overlapCount < newCount) {
                overlapCount = newCount;
                for (SchedulerBookingStruct b : overlapBookings) {
                    b.setOverlapCount(newCount);
                }
            }
            
        }
    }
    
    
    /**************************************************************************
     *
     *
    public class SchedulerDateStruct {
        private ResourceSchedulerController ctrl;
        public Date dateValue {get; set;}
        public String dateText {get; set;}
        public Integer index {get; set;}
        public String monthText {get; set;}
        public String getLeft() {
            
            Integer leftPixels = (index * ctrl.mDayWidth);
            return String.valueOf(leftPixels) + 'px';
            
        }
        public SchedulerDateStruct(ResourceSchedulerController pctrl) {
            ctrl = pctrl;
        }
    }
    
    
    /**************************************************************************
     * Contains data to be looped through for a given Project Manager (row) in
     * the scheduler
     *
    public class SchedulerResStruct {
        
        /** The booking information for this resource as it pertains to the
         *  current timeline *
        public List<SchedulerBookingStruct> bookings {get; set;}
        
        /** The raw contact record for this resource *
        public Contact contactData {get; set;}
        
        /** The maximum number of overlaps across all bookings for this
         *  resource.  This value can be used to increase the size of the
         *  timeline to better accomodate for heavy overlap *
        public Integer maxOverlap = 0;
        
        /** The index of this booking in the controller's mAllResources list *
        public Integer index {get; set;}
        
        
        
        /**********************************************************************
         * Constructor
         *
        public SchedulerResStruct(Contact c, DateTime minDate, DateTime maxDate,
                List<SchedulerBookingStruct> allBookings){
            
            contactData = c;
            bookings = bookingFactory(c.Job_Resources__r, minDate, maxDate);
            
            // Add all of the bookings to the master bookings list as well to
            // make sure that they can be accessed by index
            for (Integer i = 0; i < bookings.size(); i++) {
                allBookings.add(bookings.get(i));
                bookings.get(i).index = allBookings.size() - 1;
            }
            
        }
        
        
        /**********************************************************************
         * Factory for attaching bookings to the scheduled resource
         *
        public List<SchedulerBookingStruct> bookingFactory(
                List<Job_Resource__c> bookings, DateTime startDate,
                DateTime stopDate) {
            
            // The maximum number of overlaps allowed
            Integer maxAllowedOverlap = 2;
            Map<Integer, SchedulerBookingStruct> overlap = new Map<Integer, SchedulerBookingStruct>();
            
            // Determine the length of time between start and stop
            Long start = startDate.getTime();
            Long stop = stopDate.getTime();
            Long timeRange = stop-start;
            System.debug('ResourceSchedulerController.SchedulerResStruct.bookingFactory: Timeline: '+startDate+'('+start+') -('+timeRange+')- '+stopDate+'('+stop+')');
            
            // Initialize the list to be returned
            List<SchedulerBookingStruct> newBookings = new List<SchedulerBookingStruct>();
            
            // Let's begin!
            for (Job_Resource__c b : bookings) {
                
                // Make sure that this record is valid
                if (b.Start_Date__c == null || b.End_Date__c == null) {
                    System.debug (Logginglevel.WARN, 'ResourceSchedulerController.SchedulerResStruct.bookingFactory: Booking ['+b.Id+'] was skipped because it was missing either start or end dates');
                    continue;
                }
                
                // Create a booking which contains basic information
                SchedulerBookingStruct newB = new SchedulerBookingStruct();
                newB.bookingData = b;
                newB.start = b.Start_Date__c;
                newB.stop = b.End_Date__c;
                System.debug('ResourceSchedulerController.SchedulerResStruct.bookingFactory: Looking at booking ['+b.Id+'] from '+newB.start+' - '+newB.stop+'.');
                
                // Set the positioning factors for the booking
                Double left = 100.0 * (newB.start.getTime() - start) / timeRange;
                left = (left < -5.0) ? -5.0 : left;
                Double width = 100.0 * (newB.stop.getTime() - newB.start.getTime()) / timeRange;
                width = (left + width > 105.0) ? (105.0 - left) : width;
                System.debug('ResourceSchedulerController.SchedulerResStruct.bookingFactory: Booking will be positioned '+left+'% left and be '+width+'% wide');
                
                newB.left = String.valueOf(left);
                newB.width = String.valueOf(width);
                
                // Initialize the overlapping bookings list for this booking
                newB.overlapBookings = new List<SchedulerBookingStruct>();
                
                // Expire any overlap bookings that are no longer pertinent, ie,
                // they end before the current booking begins
                Integer overlapLoopLimit = Math.min(maxOverlap, maxAllowedOverlap) + 1;
                for (Integer i = 0; i < overlapLoopLimit; i++) {
                    
                    // Get the current overlap
                    SchedulerBookingStruct curOverlap = overlap.get(i);
                    
                    // If the overlap exists and is in the past, feel free to
                    // remove it at this point.  This is possible because it
                    // means that this booking could never overlap with any
                    // future bookings
                    if (curOverlap != null && curOverlap.stop < newB.start) {
                        overlap.remove(i);
                    }
                    
                }
                
                // Now that the overlap map is clean, we need to add the
                // current booking at the minimum available overlap index
                Integer minOverlapIndex = null;
                Integer nOverlaps = 0;
                for (Integer i = 0; i < overlapLoopLimit; i++) {
                    
                    // Check on the status of the booking stored at index i
                    // within the overlap map
                    if (minOverlapIndex == null && overlap.get(i) == null) {
                        
                        // If There isn't an overlap booking in slot i, it 
                        // means that slot is available and should be used for 
                        // the current booking
                        minOverlapIndex = i;
                        
                    } else if (overlap.get(i) != null) {
                        
                        // Make sure that the new booking is aware of its
                        // overlapping records and make sure that the
                        // overlapping records are aware of rhte new booking
                        newB.overlapBookings.add(overlap.get(i));
                        overlap.get(i).overlapBookings.add(newB);
                        nOverlaps += 1;
                        
                    }
                    
                }
                
                // If we didn't find an open slot, it is necessary to either
                // expand the overlap map or assume the maximum overlap index
                // in the event that expanding the map would put the code over
                // the maxAllowedOverlap value
                if (minOverlapIndex == null) {
                    minOverlapIndex = Math.min(maxOverlap + 1, maxAllowedOverlap);
                }
                
                // Set the overlap index for this booking
                newB.overlapIndex = minOverlapIndex;
                overlap.put(minOverlapIndex, newB);
                
                // Set the total number of overlapping bookings for this record
                newB.setOverlapCount(nOverlaps);
                maxOverlap = Math.max(maxOverlap, nOverlaps);
                
                // Set up additional booking info
                newB.color = b.Scheduler_Color__c;
                
                // Booking is complete!
                newBookings.add(newB);
                
            }
            
            // All of the bookings have been generated
            return newBookings;
        
        }
        
    }
    
    
    
    public class FilterForm {
        
        private ResourceSchedulerController controller = null;
        
        public Scheduler_Filter_Form__c data {get; set;}
        
        public FilterForm(ResourceSchedulerController parentController) {
            
            // Remember the controller data
            controller = parentController;
            
            // Pull the form data into the SFDC record
            data = new Scheduler_Filter_Form__c();
            data.Start_Date__c = controller.mParamStartDate;
            data.End_Date__c = controller.mParamEndDate;
            data.Resource_Name__c = controller.mParamNameFilter;
            data.Division__c = controller.mParamDeptFilter;
            data.OfficePicklist__c = controller.mParamOfficeFilter;
            
        }
        
        public PageReference filterRefresh() {
            
            System.debug('ResourceSchedulerController.filterRefresh: Refreshing the filter');
            
            PageReference redirect = Page.ResourceScheduler;
            Map<String, String> params = redirect.getParameters();
            List<Cookie> cks = new List<Cookie>();
            
            System.debug('ResourceSchedulerController.filterRefresh: Form Start_Date__c: '+data.Start_Date__c);
            if (data.Start_Date__c != null) {
                
                System.debug('ResourceSchedulerController.filterRefresh: Adding start date to cookie and parms as "'+controller.PNAME_START_DATE+'"');
                params.put(controller.PNAME_START_DATE, data.Start_Date__c.format());
                cks.add( new Cookie(controller.PNAME_START_DATE, data.Start_Date__c.format(), null, -1, false) );
                
            } else {
                
                System.debug('ResourceSchedulerController.filterRefresh: Nullifying cookie named "'+controller.PNAME_START_DATE+'"');
                cks.add( new Cookie(controller.PNAME_START_DATE, null, null, -1, false) );
                
            }
            
            System.debug('ResourceSchedulerController.filterRefresh: Form End_Date__c: '+data.End_Date__c);
            if (data.End_Date__c != null) {
                
                System.debug('ResourceSchedulerController.filterRefresh: Adding start date to cookie and parms as "'+controller.PNAME_END_DATE+'"');
                params.put(controller.PNAME_END_DATE, data.End_Date__c.format());
                cks.add( new Cookie(controller.PNAME_END_DATE, data.End_Date__c.format(), null, -1, false) );
                
            } else {
                
                System.debug('ResourceSchedulerController.filterRefresh: Nullifying cookie named "'+controller.PNAME_END_DATE+'"');
                cks.add( new Cookie(controller.PNAME_END_DATE, null, null, -1, false) );
                
            }
            
            System.debug('ResourceSchedulerController.filterRefresh: Form Resource_Name__c: '+data.Resource_Name__c);
            if (data.Resource_Name__c != null && data.Resource_Name__c != '') {
                
                System.debug('ResourceSchedulerController.filterRefresh: Adding start date to cookie and parms as "'+controller.PNAME_NAME_FILTER+'"');
                params.put(controller.PNAME_NAME_FILTER, data.Resource_Name__c);
                cks.add( new Cookie(controller.PNAME_NAME_FILTER, data.Resource_Name__c, null, -1, false) );
                
            } else {
                
                System.debug('ResourceSchedulerController.filterRefresh: Nullifying cookie named "'+controller.PNAME_NAME_FILTER+'"');
                cks.add( new Cookie(controller.PNAME_NAME_FILTER, null, null, -1, false) );
                
            }
            
            System.debug('ResourceSchedulerController.filterRefresh: Form Division__c: '+data.Division__c);
            if (data.Division__c != null && data.Division__c != '') {
                
                System.debug('ResourceSchedulerController.filterRefresh: Adding start date to cookie and parms as "'+controller.PNAME_DEPT_FILTER+'"');
                params.put(controller.PNAME_DEPT_FILTER, data.Division__c);
                cks.add( new Cookie(controller.PNAME_DEPT_FILTER, data.Division__c, null, -1, false) );
                
            } else {
                
                System.debug('ResourceSchedulerController.filterRefresh: Nullifying cookie named "'+controller.PNAME_DEPT_FILTER+'"');
                cks.add( new Cookie(controller.PNAME_DEPT_FILTER, null, null, -1, false) );
                
            }
            
            System.debug('ResourceSchedulerController.filterRefresh: Form OfficePicklist__c: '+data.OfficePicklist__c);
            if (data.OfficePicklist__c != null && data.OfficePicklist__c != '') {
                
                System.debug('ResourceSchedulerController.filterRefresh: Adding start date to cookie and parms as "'+controller.PNAME_OFFICE_FILTER+'"');
                params.put(controller.PNAME_OFFICE_FILTER, data.OfficePicklist__c);
                cks.add( new Cookie(controller.PNAME_OFFICE_FILTER, data.OfficePicklist__c, null, -1, false) );
                
            } else {
                
                System.debug('ResourceSchedulerController.filterRefresh: Nullifying cookie named "'+controller.PNAME_OFFICE_FILTER+'"');
                cks.add( new Cookie(controller.PNAME_OFFICE_FILTER, null, null, -1, false) );
                
            }
            
            // If there are cookies, save them
            if (! cks.isEmpty()) {
                System.debug('ResourceSchedulerController.filterRefresh: Storing updated cookies in PageReference');
                redirect.setCookies(cks);
            }
            
            redirect.setRedirect(true);
            return redirect;
            
        }
        
    }
    
    
    
    public class BookingEditAjaxForm {
        
        private ResourceSchedulerController controller = null;
        
        public Integer pBookingIndex {get; set;}
        
        public Integer pResourceIndex {get; set;}
        
        public Double pNewLoc1 {get; set;}
        
        public Double pNewLoc2 {get; set;}
        
        public SchedulerBookingStruct booking {get; set;}
        
        public Job_Resource__c record {get; set;}
        
        public String errorMessages {get; set;}
        
        public String status {get; set;}
        
        
        
        public BookingEditAjaxForm(ResourceSchedulerController parentController) {
            
            // Initialize all of the values
            reset();
            controller = parentController;
            
        }
        
        
        public boolean getRenderForm() {
            
            System.debug(Logginglevel.DEBUG, 'ResourceScheduleController.BookingEditAjaxForm.getRenderForm: Checking if form fields should be rendered...');
            
            if (record == null) {
                System.debug(Logginglevel.DEBUG, 'ResourceScheduleController.BookingEditAjaxForm.getRenderForm: Form fields should not be rendered because there is no record');
                return false;
            }
            
            System.debug(Logginglevel.DEBUG, 'ResourceScheduleController.BookingEditAjaxForm.getRenderForm: Rendering form fields');
            return true;
            
        }
        
        public boolean getIsEditable() {
            
            // Special preconditions
            if (record == null) { return false; }
            if (record.Project_Manager__c == null) { return false; }
            
            // Only allow resources to be edited by 
            return controller.CONFIG.IsAbleToModifyBookings__c;
            
        }
        
        /**********************************************************************
         * Function called when loading the "Edit Booking" ajax form on the
         * page. This function preps the view state based on the record that 
         * the user is trying to edit.
         *
         * After this function is called, the form should be re-rendered so
         * that it contains the up-to-date information from the refreshed view
         * state.
         *
        public void load() {
            
            System.debug(Logginglevel.INFO, 'ResourceScheduleController.BookingEditAjaxForm.load: Loading record index '+pBookingIndex);
            status = '0';
            
            // Make sure that the location1 and 2 are in order
            if (pNewLoc2 != null && (pNewLoc1 == null || pNewLoc2 < pNewLoc1)) {
                Double tmp = pNewLoc1;
                pNewLoc1 = pNewLoc2;
                pNewLoc2 = tmp;
            }
            
            // Determine if we need a new booking
            if (pBookingIndex != null && 0 <= pBookingIndex &&
                    pBookingIndex < controller.mBookings.size()) {
                
                // We can use one of the bookings currently available
                booking = controller.mBookings.get(pBookingIndex);
                record = booking.bookingData;
                
            } else {
                
                // We need to allow the person to enter new information
                booking = new SchedulerBookingStruct();
                booking.bookingData = new Job_Resource__c();
                record = booking.bookingData;
                
                // Specify the assignee as the running user
                record.Project_Manager__c = UserInfo.getUserId();
                
                // Attempt to specify the resource name
                System.debug('ResourceScheduleController.BookingEditAjaxForm.load: Checking if resource was specified... pResourceIndex='+pResourceIndex+', controller.mResources.size()='+controller.mResources.size());
                if (pResourceIndex != null && 0 <= pResourceIndex &&
                        pResourceIndex < controller.mResources.size()) {
                    
                    SchedulerResStruct r = controller.mResources.get(pResourceIndex);
                    record.Resource_Name__c = r.contactData.Id;
                    System.debug('ResourceScheduleController.BookingEditAjaxForm.load: From resource index '+pResourceIndex+', setting Resource_Name__c='+record.Resource_Name__c);
                    
                    // If we can pre-fill the resource type, do it
                    if (r.contactData.Contact_Type__c != null && r.contactData.Contact_Type__c != '') {
                        record.Resource_Type__c = r.contactData.Contact_Type__c;
                    }
                    
                }
                
                // Determine a couple of useful values for when computing the
                // new dates
                Long timeRange = controller.mTimelineEnd.getTime() - controller.mTimelineStart.getTime();
                Long startTime = controller.mTimelineStart.getTime();
                
                // Attempt to specify the starting date
                if (pNewLoc1 != null) {
                    Long deltaPos = (timeRange * pNewLoc1).round();
                    DateTime startDate = DateTime.newInstance(startTime + deltaPos);
                    record.Start_Date__c = startDate;
                }
                
                // Attempt to specify the ending date
                if (pNewLoc2 != null) {
                    Long deltaPos = (timeRange * pNewLoc2).round();
                    DateTime endDate = DateTime.newInstance(startTime + deltaPos);
                    record.End_Date__c = endDate;
                } else if (pNewLoc1 != null) {
                    record.End_Date__c = record.Start_Date__c.addDays(1);
                }
                
            }
            
        }
    
    
    
        /**********************************************************************
         * Function called when the user attempts to save the booking on the
         * "Booking Edit" form.
         *
        public void save() {
            
            System.debug(Logginglevel.INFO, 'ResourceScheduleController.BookingEditAjaxForm.save: Beginning save of record: '+record);
            
            if (! getIsEditable()) {
                System.debug(Logginglevel.WARN, 'ResourceScheduleController.BookingEditAjaxForm.save: Record is not editable by this user, so the save was aborted');
                return;
            }
            
            // We need to set the name of the booking record equal to the job
            // "Name" in order for the printable work order thing to show up
            // correctly
            try {
                Job__c j = [SELECT Id, Job_Name__c FROM Job__c WHERE Id = :record.Job__c LIMIT 1];
                record.Name = j.Job_Name__c;
            } catch (Exception e) {
                System.debug(Logginglevel.WARN, 'ResourceScheduleController.BookingEditAjaxForm.save: Resource was not named because the associated job could not be found');
            }
            
            // Catch errors to display on the screen
            try {
            
                // Determine if this was a new booking
                if (record.Id == null) {
                    
                    // New booking record
                    insert record;
                    
                    // Invalidate the schedule cache since the timeline needs to be
                    // recalculated
                    // TODO: This can be recalculated smarter than this
                    controller.mResources = null;
                    
                } else {
                    
                    // Update the booking record
                    update record;
                    
                    // If any of the dates have changed, the timeline will need to be
                    // reclculated
                    if (booking.start != record.Start_Date__c || booking.stop != record.End_Date__c) {
                        controller.mResources = null;
                    }
                    
                    // TODO: We may not need to invalidate every time, but I'll
                    // wait to see waht the performance impact is first
                    controller.mResources = null;
                    
                }
                
                // No errors, reset the form state and return
                reset();
                status = '1';
                return;
                
            } catch (Exception e) {
                
                // Need to display an error on the screen
                status = '-1';
                System.debug(Logginglevel.ERROR, 'ResourceScheduleController.BookingEditAjaxForm.del: Error was thrown: '+e);
                ApexPages.addMessages(e);
                
            }
            
        }
        
        
        /**********************************************************************
         * Function called when the user attempts to save the booking on the
         * "Booking Edit" form.
         *
        public void del() {
            
            System.debug(Logginglevel.INFO, 'ResourceScheduleController.BookingEditAjaxForm.del: Beginning delete of record: '+record);
            
            if (! getIsEditable()) {
                System.debug(Logginglevel.WARN, 'ResourceScheduleController.BookingEditAjaxForm.del: Running user ['+UserInfo.getUserId()+'] is not the PM ['+record.Project_Manager__c+']');
            }
            
            // Catch errors to display on the screen
            try {
                
                // Determine if this was a new booking
                if (record.Id == null) {
                    
                    // Do nothing if there was no record
                    return;
                    
                } else {
                    
                    // Delete the booking record and invalidate the cache
                    delete record;
                    controller.mResources = null;
                    
                }
                
                // No errors, reset the form state and return
                reset();
                status = '1';
                return;
            
            } catch (Exception e) {
                
                // Need to display an error on the screen
                status = '-1';
                System.debug(Logginglevel.ERROR, 'ResourceScheduleController.BookingEditAjaxForm.del: Error was thrown: '+e);
                ApexPages.addMessages(e);
                
            }
            
        }
        
        
        public void cancel() {
            
            System.debug(Logginglevel.INFO, 'ResourceScheduleController.BookingEditAjaxForm.cancel: Cancelling booking edit');
            
            reset();
            status = '1';
            
        }
        
        
        /**********************************************************************
         * Resets the form state
         *
        private void reset() {
            
            pBookingIndex = null;
            pResourceIndex = null;
            pNewLoc1 = null;
            pNewLoc2 = null;
            booking = null;
            record = null;
            errorMessages = null;
            status = '0';
            
            
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    
    private static testmethod void test_init() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        controller.getEditBookingForm();
        controller.getFilterForm();
        controller.getDates();
        controller.getDates();
        controller.getResources();
        controller.getResources();
        
    }
    
    
    private static testmethod void test_initWithParams() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        
        ref.getParameters().put(controller.PNAME_START_DATE, '12/20/2012');
        ref.getParameters().put(controller.PNAME_END_DATE, '12/27/2012');
        ref.getParameters().put(controller.PNAME_NAME_FILTER, 'ADC');
        ref.getParameters().put(controller.PNAME_DEPT_FILTER, 'DOES NOT EXIST');
        ref.getParameters().put(controller.PNAME_OFFICE_FILTER, 'NOWHERE');
        
        controller = new ResourceSchedulerController();
        
    }
    
    
    private static testmethod void test_filterFunctions() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        
        ref.getParameters().put(controller.PNAME_START_DATE, '12/20/2012');
        ref.getParameters().put(controller.PNAME_END_DATE, '12/27/2012');
        ref.getParameters().put(controller.PNAME_NAME_FILTER, 'ADC');
        ref.getParameters().put(controller.PNAME_DEPT_FILTER, 'DOES NOT EXIST');
        ref.getParameters().put(controller.PNAME_OFFICE_FILTER, 'NOWHERE');
        
        controller = new ResourceSchedulerController();
        controller.getDates();
        controller.getResources();
        FilterForm form = controller.getFilterForm();
        
        form.data.Resource_Name__c = 'ADC2';
        
        PageReference redir = form.filterRefresh();
        Test.setCurrentPage(redir);
        
        controller = new ResourceSchedulerController();
        controller.getDates();
        controller.getResources();
        form = controller.getFilterForm();
        
        form.data.Start_Date__c = null;
        form.data.End_Date__c = null;
        form.data.Resource_Name__c = null;
        form.data.Division__c = null;
        form.data.OfficePicklist__c = null;
        
        redir = form.filterRefresh();
        Test.setCurrentPage(redir);
        
        controller = new ResourceSchedulerController();
        controller.getDates();
        controller.getResources();
        
    }
    
    
    private static testmethod void test_bookingFunctions1() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        controller.getResources();
        controller.getDates();
        
        BookingEditAjaxForm form = controller.getEditBookingForm();
        form.getRenderForm();
        form.pResourceIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.getRenderForm();
        form.cancel();
        
    }
    
    private static testmethod void test_bookingFunctions2() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        controller.getResources();
        controller.getDates();
        
        BookingEditAjaxForm form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pNewLoc1 = 0.2;
        form.pNewLoc2 = 0.1;
        form.load();
        form.save();
        
    }
    
    private static testmethod void test_bookingFunctions3() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        controller.getResources();
        controller.getDates();
        
        BookingEditAjaxForm form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.record.Resource_Type__c = 'test';
        Job__c parent = [SELECT Id FROM Job__c ORDER BY LastModifiedDate DESC LIMIT 1];
        form.record.Job__c = parent.Id;
        form.save();
        
    }
    
    private static testmethod void test_bookingFunctions4() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        controller.getResources();
        controller.getDates();
        
        BookingEditAjaxForm form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.record.Resource_Type__c = 'test';
        Job__c parent = [SELECT Id FROM Job__c ORDER BY LastModifiedDate DESC LIMIT 1];
        form.record.Job__c = parent.Id;
        form.save();
        controller.getResources();
        
        form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.record.Resource_Type__c = 'test2';
        form.record.Job__c = parent.Id;
        form.save();
        controller.getResources();
        
    }
    
    private static testmethod void test_bookingFunctions5() {
        
        PageReference ref = Page.ResourceScheduler;
        Test.setCurrentPage(ref);
        
        ResourceSchedulerController controller = new ResourceSchedulerController();
        controller.getResources();
        controller.getDates();
        
        BookingEditAjaxForm form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.record.Resource_Type__c = 'test';
        Job__c parent = [SELECT Id FROM Job__c ORDER BY LastModifiedDate DESC LIMIT 1];
        form.record.Job__c = parent.Id;
        form.save();
        controller.getResources();
        
        form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.record.Resource_Type__c = 'test2';
        form.record.Job__c = parent.Id;
        form.save();
        controller.getResources();
        
        form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pBookingIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.cancel();
        
        form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pBookingIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.save();
        controller.getResources();
        
        form = controller.getEditBookingForm();
        form.pResourceIndex = 0;
        form.pBookingIndex = 0;
        form.pNewLoc1 = 0.1;
        form.pNewLoc2 = 0.2;
        form.load();
        form.del();
        controller.getResources();
        
    }
    
    */
}