public with sharing class ADCUtil_Base {
    
    /**************************************************************************
     * Wrapper function for the more advanced version of strJoin().  This will
     * always use the empty string as a default value.  Otherwise, functions
     * the exact same as strJoin() with 3 arguments.
     *
     * @param delimiter:
     *          This string will be injected between each element in the values
     *          collection.
     * @param values:
     *          A collection of values which will be output in the resulting
     *          delimited string.  The function is implemented in such a way
     *          that these objects will be converted to strings using the
     *          standard String.valueOf(...) function.  If an object cannot be
     *          converted to a string in this way, it should not be included as
     *          part of this collection.  The exception to this rule is that
     *          null values will always be converted to the empty string in
     *          order to reduce the chance or stray null pointer exceptions.
     */
    public static String strJoin( String delimiter,
                                  List<String> values ) {
        return strJoin(delimiter, values, '');
    }
        
    
    
    /**************************************************************************
     * Creates a delimited string from each of the elements in the list
     * "values".  If no elements exist in the list, the default value will be
     * returned instead.  This functionality is useful for situations such as
     * a where clause in a dynamic SOQL query where '()' will return a syntax
     * error.  In such situations, it can be helpful to have some type of dummy
     * value in the event that no elements exist
     *
     * @param delimiter:
     *          This string will be injected between each element in the values
     *          collection.
     * @param values:
     *          A collection of values which will be output in the resulting
     *          delimited string.  The function is implemented in such a way
     *          that these objects will be converted to strings using the
     *          standard String.valueOf(...) function.  If an object cannot be
     *          converted to a string in this way, it should not be included as
     *          part of this collection.  The exception to this rule is that
     *          null values will always be converted to the empty string in
     *          order to reduce the chance or stray null pointer exceptions.
     * @param defaultVal:
     *          This value will be returned in the event that the values
     *          argument is either null or empty.
     * @param skipNulls:
     *          If this parameter is true, a null value will not be included in
     *          the output string and will not add another delimiter.  If
     *          false, all null values in "values" will be treated as the
     *          empty string.  For example, assuming values = {'a', null, 'b',
     *          'c'}, skipNulls = true will result in 'a,b,c',
     *          skipNulls = false will result in 'a,,b,c'
     */
    public static String strJoin( String delimiter,
                                  List<String> values,
                                  String defaultVal,
                                  boolean skipNulls ) {
        
        // If the delimiter is null, throw an exception
        if( delimiter == null ) {
            throw new ADCUtil_Exceptions.IllegalArgumentException();
        }
        
        // Check if there are values to use. If not, simply return default
        if( values == null || values.isEmpty() ) {
            return defaultVal;
        }
        
        // The output value that will be returned by this funciton
        String output = null;
        
        // Go through each of the items that we need to output
        for( String v : values ) {
        	
        	// Allow the caller to completely skip null values
        	if (skipNulls == true && v == null) {
                
                System.debug(Logginglevel.FINE, 'ADCUtil_Base.strJoin: Value was skipped because it was null');
            
        	} else {
                
	            // Convert the value to a string.  Note that null values are always
	            // converted to the empty string
	            String s = (v != null) ? String.valueOf(v) : '';
	            
	            // If this is the first item, don't use a delimiter.  Otherwise, 
	            // append a delimiter and the current item.
	            if( output == null ) {
	                output = s;
	            } else {
	                output += delimiter + s;
	            }
	            
        	}
            
        }
        
        // Return the delimited string
        return output;
        
    }
    
    
    /**************************************************************************
     * Convenience function using a default value of "false" for skipNulls
     */
    public static String strJoin( String delimiter,
                                  List<String> values,
                                  String defaultVal ) {
        return strJoin(delimiter, values, defaultVal, false);
    }
    
    
    
    /**************************************************************************
     * Overload for the short strJoin call using sets instead of lists
     */
    public static String strJoin( String delimiter, Set<String> values) {
        List<String> newVals = new List<String>();
        newVals.addAll(values);
        return strJoin(delimiter, newVals);
    }
    
    
    
    /**************************************************************************
     * Overload for the long strJoin call using sets instead of lists
     */
    public static String strJoin( String delimiter,
                                  Set<String> values,
                                  String defaultVal) {
        List<String> newVals = new List<String>();
        newVals.addAll(values);
        return strJoin(delimiter, newVals, defaultVal);
    }
    
    
    /**************************************************************************
     * Inverts the key/value pairs in a mapping. The result of this function is
     * undefined in the event that the parameter map contains a many-to-one
     * relationship between keys and values, i.e., there are multiple keys that
     * result in the same value.  In the resulting map, assuming k1 and k2 are
     * keys in the original that both  result in v, it is undefined what the
     * resulting map, r, will return when performing r.get(v).
     */
    public static Map<String, String> invertMap(Map<String, String> oldMap) {
        if (oldMap == null) {
        	return null;
        }
        Map<String, String> newMap = new Map<String, String>();
        for (String k : oldMap.keySet()) {
            newMap.put(oldMap.get(k), k);
        }
        return newMap;
    }
    
    
    
    /**************************************************************************
     * This is supposed to be a function that forces a string to be a certain
     * length by either padding it with a character or truncating data.  It is
     * currently implemented HORRIBLY and could really use both additional
     * features (deciding to truncate/pad front or back of string) and a non-
     * recursive implementation (since that is just overkill)
     */
    public static String forceStringLength( String s, Integer len, String padChar, boolean rightPad) {
    	
    	// DEFAULT PARAMETER VALUES
    	if (s == null) {
            s = '';
        }
        if (len == null) {
            len = s.length();
        }
    	if (padChar == null) {
    		padChar = ' ';
    	}
    	
    	// FUNCTION!
    	if (s.length() < len) {
    		if (rightPad) {
    			return ADCUtil_Base.forceStringLength(s+padChar, len, padChar, rightPad);
    		} else {
    			return ADCUtil_Base.forceStringLength(padChar+s, len, padChar, rightPad);
    		}
    	} else if (len < s.length()) {
    		return s.substring(0, len);
    	} else {
    		return s;
    	}
    	
    }
    
    
    public static String forceStringLength( String s, Integer len, String padChar) {
    	return ADCUtil_Base.forceStringLength(s, len, padChar, true);
    }
    
    
    
    /**************************************************************************
     * Used to add a time component to a pre-existing date
     */
    public static DateTime addTimeComponent(Date d, Integer hour, Integer minute, Integer second) {
    	return DateTime.newInstance(d.year(),
    	                            d.month(),
    	                            d.day(), 
    	                            hour,
    	                            minute,
    	                            second);
    }
    
    
    
    /**************************************************************************
     * Converts a string to a boolean value.  The following case-insensitive
     * string values are recognized:<br/>
     * <br/>
     * <b>TRUE:</b> 'true', 't', 'yes', 'y', '1'<br/>
     * <b>FALSE:</b> 'false', 'f', 'no', 'n', '0'
     *
     * @param val:
     *          The string value to be converted to a boolean.  This value is
     *          case insensitive and must match one of the recognized boolean
     *          string values.  If not, the ADCUtil_Exceptions.BooleanConversionException will be
     *          thrown.
     */
    public static Boolean str2bool(String val) {
        
        // Null is a bad value
        if( val == null ) {
            
            // Attempting to convert an unrecognized value
            throw new ADCUtil_Exceptions.BooleanConversionException('Cannot convert a null string to a boolean value');
            
        }
        
        // Test the possible string values
        if( val.equalsIgnoreCase('TRUE') ||
                val.equalsIgnoreCase('T') ||
                val.equalsIgnoreCase('YES') ||
                val.equalsIgnoreCase('Y') ||
                val.equalsIgnoreCase('1') ) {
            
            // String value matched one of the recognized "true" strings
            return true;
            
        } else if( val.equalsIgnoreCase('FALSE') ||
                val.equalsIgnoreCase('F') ||
                val.equalsIgnoreCase('NO') ||
                val.equalsIgnoreCase('N') ||
                val.equalsIgnoreCase('0') ) {
        
            // String value matched one of the recognized "false" strings
            return false;
        
        } else {
            
            // Attempting to convert an unrecognized value
            throw new ADCUtil_Exceptions.BooleanConversionException('Unable to convert string "' + val +'" to a boolean value.');
            
        }
        
    }
    
    
    
    /**************************************************************************
     * Returns true if the incoming object is some type of "Empty" value.  This
     * is defined by if the input object is the literal "null" or if the
     * function String.valueOf(val) returns the empty string.<br/>
     * <br/>
     * One caveat of this function is that any exceptions thrown by the
     * String.valueOf function will be caught, logged, and suppressed returning
     * a value of false.<br/>
     * <br/>
     * TODO: Improve this function by allowing it to take lists and return true
     * if the list is either null or empty.  That would be wicked.
     *
     * @param val:
     *          The value to be tested
     * @return:
     *          True if the val parameter is either null or some equivilent
     *          blank value.  Otherwise, the function will return false
     */
    public static Boolean isEmpty(Object val) {
        
        // An exception means that String.valueOf failed.  Assume not empty in
        // this situation
        try {
            
            // Check if the value is null or an empty equivalent
            if( val == null || String.valueOf(val).equals('') ) {
                return true;
            } else {
                return false;
            }
            
        } catch (Exception e) {
            
            // It is assumed that any errors mean the input data was not null,
            // but simply incompatible with String.valueOf().
            System.debug(Logginglevel.WARN, 'ADCUtil_Base.isEmpty: An exception was encounted when testing if "' + val + '" is empty.  The function will return false.  The exception was: "'+e.getMessage()+'"');
            return false;
            
        }
        
    }
    
    
    
    /**************************************************************************
     * Provides a simple mechanism for supplying default values in the event
     * that the input string is "empty" (see the "isEmpty()" function for
     * definition of "empty").  If the val parameter is not empty, it will be
     * returned.  If it is empty, the default value will be returned
     *
     * @param val:
     *         The value which will be returned if it is not empty.
     * @param defaultVal:
     *         The value which will be returned in the event that val is
     *         empty.
     * @return:
     *         Either val or defaultVal depending on if val is empty or not.
     */
    public static String isEmptyDefault(String val, String defaultVal) {
        return ( !isEmpty(val) ) ? val : defaultVal;
    }
    
    
    
    /**************************************************************************
     * Helper function for retrieving the nth element in a set.  While, this
     * generally doesn't make sense (since sets can be in any order) it is
     * primarily useful for getting the first (and only) element from a one-
     * element set without having to jump through hoops.
     *
     * @param s:
     *         A set of values from which the index'th value should be pulled
     * @param index:
     *         The index of the value to pull from s
     * @return:
     *         Returns the value stored at the index'th location within the Set
     */
    public static String setGet(Set<String> s, Integer index) {
        List<String> c = new List<String>(s);
        return c.get(index);
    }
    
    
    
    /**************************************************************************
     * Same as String setGet but for Ids
     */
    public static Id setGet(Set<Id> s, Integer index) {
        List<Id> c = new List<Id>(s);
        return c.get(index);
    }
    
    
    
    /**************************************************************************
     * Same as String setGet but for Integers
     */
    public static Integer setGet(Set<Integer> s, Integer index) {
        List<Integer> c = new List<Integer>(s);
        return c.get(index);
    }
    
    
    
    
    /****************************************************************************
    *
    *		DATETIME FUNCTIONS.
    *
    ****************************************************************************/
    
    public static string GET_DIFFERENCE_DATETIME_SECONDS = 'DifferenceInSeconds';
    public static string GET_DIFFERENCE_DATETIME_MINUTES ='DifferenceInMinutes';
    
    public static double getDifferenceDateTime(datetime firstDT, datetime secondDT, string type)
    {
    	if(firstDT != null && secondDT != null)
    	{
    		if(type == GET_DIFFERENCE_DATETIME_SECONDS )
	    	{
	    		return getDifferenceInSeconds(firstDT, secondDT);
	    	}
	    	else if(type == GET_DIFFERENCE_DATETIME_MINUTES )
	    	{
	    		return getDifferenceInMinutes(firstDT,secondDT);
	    	}
	    	else
	    	{
	    		return null;
	    	}
    	}
    	else
    	{
    		return null;
    	}
    }
    
    public static double getDifferenceInMinutes(datetime firstDT, datetime secondDT)
    {  
   		long dt1 = firstDT.getTime() / 1000 / 60;  //getTime gives us milliseconds, so divide by 1000 for seconds  
   		long dt2 = secondDT.getTime() / 1000 / 60;
   		double d = dt1 - dt2;
   		return d;
	}
    
    public static double getDifferenceInSeconds(datetime firstDT, datetime secondDT)
    {  
   		long dt1 = firstDT.getTime() / 1000;  //getTime gives us milliseconds, so divide by 1000 for seconds  
   		long dt2 = secondDT.getTime() / 1000;
   		double d = dt1 - dt2;
   		return d;
	}
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////
    //
    // << TEST CODE >>
    //
    ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////
    
    
    
    /** Tests various features of the base str join (not wrapper) function */
    private static testmethod void test_strJoin_base_1() {
    	
    	// Test control    	
    	System.assertEquals('a,b,c', strJoin(',', new List<String>{'a','b','c'}, '???', false));
    	
    	// Test missing delimiter
    	try {
    		strJoin(null, new List<String>{'a','b','c'}, '???', false);
    		System.assert(false, 'Illegal Argument Exception not thrown');
    	} catch (ADCUtil_Exceptions.IllegalArgumentException e) {
    		Integer no_op = 0; // This exception is desired
    	}
    	
    	// Test missing values results in defualt
    	// THERE IS A BUG.  If "ignoreNulls" is true and the list contains only
    	// null values, the expected result would be that this function returns
    	// the default.  The actual result will be an empty string
    	System.assertEquals('???', strJoin(',', null, '???', false));
    	System.assertEquals('???', strJoin(',', new List<String>(), '???', false));
    	
    	// Test handling of null values when skip nulls is both true and false
    	System.assertEquals('a,,d', strJoin(',', new List<String>{'a',null,'','d'}, '', true));
        System.assertEquals('a,,,d', strJoin(',', new List<String>{'a',null,'','d'}, '', false));
    	
    }
    
    /** Tests wrapper functions for the strJoin method */
    private static testmethod void test_strJoin_wrappers_1() {
    	
    	System.assertEquals('a,,c', strJoin(',', new List<String>{'a',null,'c'}));
    	System.assertEquals('',     strJoin(',', (List<String>) null));
    	
    	System.assertEquals('a,,c', strJoin(',', new List<String>{'a',null,'c'}, '???'));
        System.assertEquals('???',  strJoin(',', (List<String>) null, '???'));
        
        // We cannot assert the output of strJoin on a set because the ordering
        // of the elements is undefined.  Instead, just make sure that the
        // functions run
        strJoin(',', new Set<String>{'a',null,'c'});
        strJoin(',', new Set<String>{'a',null,'c'}, '???');
        
    }
    
    /** Tests basic features of inverting a map */
    private static testmethod void test_invertMap_1() {
    	
    	// Test null input
    	Map<String, String> m = null;
    	System.assertEquals(null, invertMap(m));
    	
    	// Test empty input
    	m = new Map<String, String>();
    	System.assertEquals(0, invertMap(m).size());
    	
    	// Test base case (map is one-to-one)
    	m.put('1', 'a');
    	m.put('2', 'b');
    	m.put('3', 'c');
    	System.assertEquals('a', m.get('1'));
    	System.assertEquals('b', m.get('2'));
    	System.assertEquals('c', m.get('3'));
    	System.assertEquals(3, invertMap(m).size());
    	System.assertEquals('1', invertMap(m).get('a'));
    	System.assertEquals('2', invertMap(m).get('b'));
    	System.assertEquals('3', invertMap(m).get('c'));
    	
    }
    
    
    private static testmethod void test_forceStringLength_1() {
    	
    	// Test simple case
    	System.assertEquals('00012', forceStringLength('12', 5, '0', false));
    	
    	// Test default parameters
    	System.assertEquals('', forceStringLength(null, null, null, false));
    	System.assertEquals('test', forceStringLength('test', null, null, false));
    	System.assertEquals(' test', forceStringLength('test', 5, null, false));
    	
    	// Test padding on right or left
    	System.assertEquals('  X', forceStringLength('X', 3, ' ', false));
        System.assertEquals('X  ', forceStringLength('X', 3, ' ', true));
        
        // Test truncation?  Truncation ignores direction and always cuts off
        // the right side of the string
        System.assertEquals('1234', forceStringLength('12345', 4, ' ', true));
        System.assertEquals('1234', forceStringLength('12345', 4, ' ', false));
        
        // Wrapper function
        System.assertEquals(forceStringLength('X', 3, ' ', true), forceStringLength('X', 3, ' '));
    	
    }
    
    
    private static testmethod void test_addTimeComponent_1() {
    	
    	Date d1 = Date.newInstance(2012, 9, 18);
    	DateTime dt1 = addTimeComponent(d1, 1, 2, 3);
    	DateTime dt2 = DateTime.newInstance(2012, 9, 18, 1, 2, 3);
    	
    	System.assertEquals(dt2.getTime(), dt1.getTime());
    	
    }
    
    private static testmethod void t_isEmptyDefault() {
        System.assertEquals( 'test',
                ADCUtil_Base.isEmptyDefault('test', 'default') );
        System.assertEquals( 'default',
                ADCUtil_Base.isEmptyDefault('', 'default') );
    }
    
    private static testmethod void t_isEmpty() {
        System.assertEquals(false, ADCUtil_Base.isEmpty('test'));
        System.assertEquals(false, ADCUtil_Base.isEmpty(15.2));
        System.assertEquals(true, ADCUtil_Base.isEmpty(''));
        System.assertEquals(true, ADCUtil_Base.isEmpty((String) null));
        System.assertEquals(true, ADCUtil_Base.isEmpty((SObject) null));
        System.assertEquals(true, ADCUtil_Base.isEmpty((Decimal) null));
    }
    
    private static testmethod void t_str2bool() {
        System.assertEquals( true, ADCUtil_Base.str2bool('1') );
        System.assertEquals( true, ADCUtil_Base.str2bool('true') );
        System.assertEquals( true, ADCUtil_Base.str2bool('t') );
        System.assertEquals( true, ADCUtil_Base.str2bool('yes') );
        System.assertEquals( true, ADCUtil_Base.str2bool('y') );
        System.assertEquals( true, ADCUtil_Base.str2bool('TrUE') );
        System.assertEquals( true, ADCUtil_Base.str2bool('YES') );
        
        System.assertEquals( false, ADCUtil_Base.str2bool('0') );
        System.assertEquals( false, ADCUtil_Base.str2bool('false') );
        System.assertEquals( false, ADCUtil_Base.str2bool('f') );
        System.assertEquals( false, ADCUtil_Base.str2bool('no') );
        System.assertEquals( false, ADCUtil_Base.str2bool('n') );
        System.assertEquals( false, ADCUtil_Base.str2bool('fALSe') );
        System.assertEquals( false, ADCUtil_Base.str2bool('NO') );
        
        try{
            ADCUtil_Base.str2bool(null); 
            System.assert(false, 'No exception thrown');
        } catch (ADCUtil_Exceptions.BooleanConversionException e) {/* Desired Outcome */}
        
        try{
            ADCUtil_Base.str2bool('Not a boolean'); 
            System.assert(false, 'No exception thrown');
        } catch (ADCUtil_Exceptions.BooleanConversionException e) {/* Desired Outcome */}
        
        try{
            ADCUtil_Base.str2bool('             true            '); 
            System.assert(false, 'No exception thrown');
        } catch (ADCUtil_Exceptions.BooleanConversionException e) {/* Desired Outcome */}
    }
    
    
    
    private static testmethod void test_setget_1() {
        
        // Since this function was really only meant to get values from a one-
        // element set, the tests will only cover that case.  For all other
        // instances, the results are undefined.
        System.assertEquals(1, setGet(new Set<Integer>{1}, 0));
        System.assertEquals('a', setGet(new Set<String>{'a'}, 0));
        System.assertEquals('00DQ0000003LSFR', setGet(new Set<Id>{'00DQ0000003LSFR'}, 0));
        
    }
    
    private static testmethod void test_timeDiffMinutes_1() {
    	
    	System.assertEquals(
    	    -60,
    	    getDifferenceInMinutes(
    	        DateTime.newInstance(2012, 9, 18, 1, 0, 0),
    	        DateTime.newInstance(2012, 9, 18, 2, 0, 0)));
    	
    	System.assertEquals(
            60,
            getDifferenceInMinutes(
                DateTime.newInstance(2012, 9, 18, 2, 0, 0),
                DateTime.newInstance(2012, 9, 18, 1, 0, 0)));
        
        System.assertEquals(
            -2,
            getDifferenceInMinutes(
                DateTime.newInstance(2012, 9, 18, 1, 5, 0),
                DateTime.newInstance(2012, 9, 18, 1, 7, 0)));
        
        System.assertEquals(
            -60,
            getDifferenceInSeconds(
                DateTime.newInstance(2012, 9, 18, 1, 1, 0),
                DateTime.newInstance(2012, 9, 18, 1, 2, 0)));
        
        System.assertEquals(
            60,
            getDifferenceInSeconds(
                DateTime.newInstance(2012, 9, 18, 1, 2, 0),
                DateTime.newInstance(2012, 9, 18, 1, 1, 0)));
        
        System.assertEquals(
            -2,
            getDifferenceInSeconds(
                DateTime.newInstance(2012, 9, 18, 1, 1, 5),
                DateTime.newInstance(2012, 9, 18, 1, 1, 7)));
    	
    	System.assertEquals(
            1,
            getDifferenceDateTime(
                DateTime.newInstance(2012, 9, 18, 1, 2, 0),
                DateTime.newInstance(2012, 9, 18, 1, 1, 0),
                GET_DIFFERENCE_DATETIME_MINUTES));
        
        System.assertEquals(
            60,
            getDifferenceDateTime(
                DateTime.newInstance(2012, 9, 18, 1, 2, 0),
                DateTime.newInstance(2012, 9, 18, 1, 1, 0),
                GET_DIFFERENCE_DATETIME_SECONDS));
        
        System.assertEquals(
            null,
            getDifferenceDateTime(
                DateTime.newInstance(2012, 9, 18, 1, 2, 0),
                DateTime.newInstance(2012, 9, 18, 1, 1, 0),
                'INCORRECT_VALUE'));
        
        System.assertEquals(
            null,
            getDifferenceDateTime(
                null,
                null,
                GET_DIFFERENCE_DATETIME_SECONDS));
    }
    
}