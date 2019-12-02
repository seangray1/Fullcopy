public with sharing class ADCUtil_Exceptions {
    
    public class BooleanConversionException extends Exception {}
    public class IllegalArgumentException extends Exception {}
    
    
    
    /**************************************************************************
     * Exception used for dealing with functions that rely on object state.
     * This exception is thrown if the object, ultimately, is in an invalid
     * state for the function to run
     */
    public class IllegalStateException extends Exception {}
    
    public class NotImplementedException extends Exception {}
    
}