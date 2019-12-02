/**************************************************************************************************
 * Caching implementation of common Describe functionality in Salesforce.<br/>
 * <br/>
 * The purpose of this class to to ease the process of managing describe data and to all but
 * eliminate any concerns related to Describe limits.  Essentially, this class is implemented in
 * such a way that the minimum number of limited Describe calls are used.  To do this, it caches
 * most of the describe results in some maps and uses the cached versions whenever possible.<br/>
 * <br/>
 * The one instance in which to avoid this functionality is when heap size becomes an issue.  It is
 * possible, due to the number of caches created, that certain features could take a significant
 * toll on the overall heap size of the application.  While it is usually not one of the main
 * concerns, it could come up as a problem at some point.  As a future TODO, it would be helpful
 * to include cache-purging functions which will allow the caller to manually remove cached items
 * which will never be used again.<br/>
 */
public with sharing class ADCUtil_Describe {
   
    /** Cache for global describe information (object name to type token) */
    private static Map<String, Schema.SObjectType> mGlobalDescribe = null;
   
    /** Cache for ID prefix to object name mapping */
    private static Map<String, String> mGlobalPrefixDescribe = null;
   
    /** Since the ID prefix cache is a little more involved, keep a flag which denotes if the cache
     *  has been completely built */
    private static boolean mGlobalPrefixDescribeIsComplete = false;
   
    /** Cache for object describe information */
    private static Map<String, Schema.DescribeSObjectResult> mDescribeInfos = null ;
   
    /** Cache for field describe data */
    private static Map<String, Map<String, Schema.SObjectField>> mFieldInfos = null ;
   
    /** Cache for child relationship information data */
    private static Map<String, Map<String, Schema.ChildRelationship>> mChildInfos = null ;
   
   
   
    /**********************************************************************************************
     * Retrieves the Global describe map (Mapping from Object Name or SObjectType).<br/>
     * <br/>
     * Cached implementation of the standard Schema.getGlobalDescribe() method.  This method is
     * used for giving an API-Name-to-SOBject-Class mapping.  This mapping, then, allows for easy
     * access to do things like create a new SObject by object name or look up fields by object
     * name.
     * 
     * 
     *
     */
    public static Map<String, Schema.SObjectType> getGlobalDescribe() {
        if (mGlobalDescribe == null) {
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getGlobalDescribe: Generating values to cache.' );
            mGlobalDescribe = Schema.getGlobalDescribe();
        }
        return mGlobalDescribe;
    }
   
   
   
    /**********************************************************************************************
     * Retrieves an SObject type token for a given object name.
     *
     */
    public static Schema.SObjectType getTypeByName(String typeName) {
        return ADCUtil_Describe.getGlobalDescribe().get(typeName);
    }
   
   
   
    /**********************************************************************************************
     * Retrieves the SObject type name based on an ID prefix.  This is most useful when it is
     * necessary to retrieve SObject records based only on an ID with not additional information.
     *
     * @param keyPrefix:
     *         The 3-character ID prefix associated with an Object. This can be found by getting
     *         substring (0,3) of an ID value
     * @return:
     *         The name of the object associated with that prefix for the current environment. This
     *         object name can then be provided to getDescribeInfo to pull down further information
     *         about the SObject in question.
     */
    public static String getTypeNameByPrefix(String keyPrefix) {
        
        System.debug('ADCUtil_Describe.getTypeNameByPrefix: Looking for type with prefix "'+keyPrefix+'"');
        
        // If the global prefix describe is null, create it
        if (mGlobalPrefixDescribe == null) {
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getTypeNameByPrefix: Generating cache container.' );
            mGlobalPrefixDescribe = new Map<String, String>();
        }
       
        // Attempt to find the requested prefix in the map
        String foundTypeName = mGlobalPrefixDescribe.get(keyPrefix);
        if (foundTypeName != null) {
            System.debug('ADCUtil_Describe.getTypeNameByPrefix: Found type "'+foundTypeName+'" from the cache');
            return foundTypeName;
        }
       
        // If the result wasn't found and the map has not been completely built out, attempt to
        // search for more possibilities
        if (mGlobalPrefixDescribeIsComplete == false) {
           
            // Get any objects we have not yet tried
            Set<String> objectsToSearch = getGlobalDescribe().keySet().clone();
            objectsToSearch.removeAll(mGlobalPrefixDescribe.keySet());
           
            // Go through the results, building out the cache and searching
            for (String objectName : objectsToSearch) {
               
                // Get the describe information for this object
                Schema.DescribeSObjectResult d = ADCUtil_Describe.getDescribeInfo(objectName);
               
                // Get the ID associated with this information
                String prefix = d.getKeyPrefix();
                System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getTypeNameByPrefix: Caching mapping between "' +prefix+'" and "'+objectName+'"');
                mGlobalPrefixDescribe.put (prefix, objectName);
               
                // If the ID is correct, use it, if not, keep looking
                if (keyPrefix.equals(prefix)) {
                    System.debug('ADCUtil_Describe.getTypeNameByPrefix: Found type "'+objectName+'" based on prefix['+prefix+'] == keyPrefix['+keyPrefix+']');
                    return objectName;
                }
               
            } // Finished looping through available object types.
           
        } else {
           
            // The map was complete when the search was performed, the result doesn't exist
            return null ;
           
        }
       
        // We managed to go through the entire set of objects and not find what we needed.
        // At the very least, flag the cache as complete
        mGlobalPrefixDescribeIsComplete = true;
        return null ;
       
    }
   
   
   
    /**********************************************************************************************
     * Retrieves object describe information for a given object type.
     *
     */
    public static Schema.DescribeSObjectResult getDescribeInfo(String typeName) {
       
        // Check if a cache map exists.  If not, create a new one.
        if (mDescribeInfos == null) {
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getDescribeInfo: Generating cache container.' );
            mDescribeInfos = new Map<String, Schema.DescribeSObjectResult>();
        }
       
        // Check if the describe data for the requested object name has already been cached.
        if (! mDescribeInfos.containsKey(typeName)) {
           
            // No cached version exists for this object.  Get the describe information.
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getDescribeInfo: Caching describe info for "'+typeName+'".');
            Schema.DescribeSObjectResult d = ADCUtil_Describe.getTypeByName(typeName).getDescribe();
            mDescribeInfos.put(typeName, d);
           
        }
       
        // Return the cached version of the describe information
        return mDescribeInfos.get(typeName);
       
    }
   
   
   
    /**********************************************************************************************
     * Retrieves the map between field name and field describe information for an object.
     *
     * @limits: Each call to this function using a unique typeName will result in one additional
     *             describe call.  Since the results are cached, subsequent calls for that object
     *             will not count against this limit.
     *
     */
    public static Map<String, Schema.SObjectField> getFieldsMap(String typeName) {
       
        // Check if the cache exists, if not, create it
        if (mFieldInfos == null) {
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getFieldsMap: Generating cache container.');
            mFieldInfos = new Map<String, Map<String, Schema.SObjectField>>();
        }
       
        // Check if a cache exists for the specific object
        if (! mFieldInfos.containsKey(typeName) ) {
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getFieldsMap: Caching fields map for "'+typeName+ '".');
            Map<String, Schema.SObjectField> fMap = getDescribeInfo(typeName).fields.getMap();
            mFieldInfos.put( typeName, fMap );
        }
       
        // Use the cached value
        return mFieldInfos.get(typeName);
       
    }
    
    
    
    public static Set<String> getAllFieldNames(String typeName) {
    	return ADCUtil_Describe.getFieldsMap(typeName).keySet();
    }
   
   
   
    /**********************************************************************************************
     * Convenience function that gets the describe info for each of the fields.  Since this can
     * get VERY large VERY fast, it is recommended that either the second parameter be used to
     * limit the total number of fields or that getDescribe() is simply called on an individual
     * field from getFieldsMap, e.g., getFieldsMap('Account').get('Name').getDescribe().  Also, due
     * to the inherent size issues, the result of this function is not cached.  This shouldn't
     * have any issues with limits since it is the "fields" call that increments the limits
     * counter, not the getDescribe() call.
     *
     * @param typeName: The name of the SObject Type whose fields are being described
     * @param whichFields: Optional (can be null) parameter that reduces the overall amount of data
     *             returned by this function.  If whichFields is defied, the function will return
     *             describe data only for fields in the intersection between whichFields and the set
     *             of all available fields on the object.
     *
     */
    public static Map<String, Schema.DescribeFieldResult> getFieldsDescribeMap(String typeName, Set<String> whichFields) {
       
        // Get the fields information
        Map<String, Schema.SObjectField> fields = ADCUtil_Describe.getFieldsMap(typeName);
       
        // Determine which fields to look up
        Set<String> fieldsToLookUp = fields.keySet().clone();
       
        // If the caller provided a sub-set of fields to use, select that
        if (whichFields != null) {
            fieldsToLookUp.retainAll(whichFields);
        }
       
        // Now, go through each of the fields and generate a describe map
        Map<String, Schema.DescribeFieldResult> fieldInfos = new Map<String, Schema.DescribeFieldResult>();
        for (String fieldName : fieldsToLookUp) {
            fieldInfos.put(fieldName, fields.get(fieldName).getDescribe());
        }
        return fieldInfos;
       
    }
   
   
   
    /**********************************************************************************************
     * Retrieves the field describe information for a given object/field.
     *
     */
    public static Schema.DescribeFieldResult getFieldDescribe(String typeName, String fieldName) {
        return ADCUtil_Describe.getFieldsMap(typeName).get(fieldName).getDescribe();
    }
   
   
   
    /**********************************************************************************************
     * Utility function that returns the subset from getFieldDescribeMap containing only those
     * fields that are writeable.
     *
     */
    public static Map<String, Schema.SObjectField> getWriteableFieldsMap(String typeName) {
       
        Map<String, Schema.SObjectField> writeableFields = new Map<String, Schema.SObjectField>();
        Map<String, Schema.SObjectField> allFields = getFieldsMap(typeName);
        for (String fieldName : allFields.keySet()) {
            Schema.DescribeFieldResult f = allFields.get(fieldName).getDescribe();
            if (! f.isCalculated() && ! f.isAutonumber() ) {
                writeableFields.put(fieldName, allFields.get(fieldName));
            }
        }
        return writeableFields;
    }
   
   
   
    /**********************************************************************************************
     * Function for loading information about child relationships for a given object.
     *
     * @see: http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_methods_system_sobject_describe.htm#apex_childRelationship_methods
     *
     */
    public static Map<String, Schema.ChildRelationship> getChildRelationshipsMap(String typeName) {
       
        // Check if the cache exists, if not, create it
        if (mChildInfos == null) {
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getChildRelationshipsMap: Generating cache container.' );
            mChildInfos = new Map<String, Map<String, Schema.ChildRelationship>>();
        }
       
        // Check if a cache exists for the specific object
        if (! mChildInfos.containsKey(typeName) ) {
            System.debug(Logginglevel.INFO, 'ADCUtil_Describe.getChildRelationshipsMap: Caching child relationships map for "'+typeName+'".');
            List<Schema.ChildRelationship> cList = getDescribeInfo(typeName).getChildRelationships();
           
            Map<String, Schema.ChildRelationship> cMap = new Map<String, Schema.ChildRelationship>();
            for (Schema.ChildRelationship childInfo : cList) {
                cMap.put( childInfo.getRelationshipName(), childInfo );
            }
           
            mChildInfos.put( typeName, cMap );
        }
       
        // Use the cached value
        return mChildInfos.get(typeName);
       
    }
   
   
}