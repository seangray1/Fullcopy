public with sharing virtual class ADCUtil_Params {
    
    protected Map<String, String> rawParams;
    
    public ADCUtil_Params() {
    	
    	this.rawParams = ApexPages.currentPage().getParameters();
    	try {
    	    this.load(this.rawParams);
    	} catch (ADCUtil_Exceptions.NotImplementedException e) {
    		System.debug(Logginglevel.WARN, 'ADCUtil_Params.{constructor}: the load function has not been implemented');
    	}
    	
    }
    
    public Map<String, String> toStringMap() {
    	
    	Map<String, String> paramMap = new Map<String, String>();
    	this.dump(paramMap);
    	return paramMap;
    	
    }
    
    protected virtual void load(Map<String, String> source) {
    	throw new ADCUtil_Exceptions.NotImplementedException('Parameter loading has not yet been defined');
    }
    
    protected virtual void dump(Map<String, String> target) {
    	throw new ADCUtil_Exceptions.NotImplementedException('Parameter dumping has not yet been defined');
    }
    
    protected String getString(Map<String, String> source, String paramName) {
    	
    	System.debug('ADCUtil_Params.getBoolean: Loading parameter. "'+paramName+'"="'+source.get(paramName)+'" in the source map');
    	
    	if (source.containsKey(paramName)) {
    		return source.get(paramName);
    	} else {
    		return null;
    	}
    	
    }
    
    protected void putString(Map<String, String> target, String paramName, String value) {
        
        if (value != null) {
            target.put(paramName, value);
        }
        
    }
    
    protected Boolean getBoolean(Map<String, String> source, String paramName) {
    	
    	System.debug('ADCUtil_Params.getBoolean: Loading parameter. "'+paramName+'"="'+source.get(paramName)+'" in the source map');
    	
    	if (source.containsKey(paramName)) {
    		try {
                return ADCUtil_Base.str2bool(source.get(paramName));
    		} catch (ADCUtil_Exceptions.BooleanConversionException e) {
    			return null;
    		}
        } else {
            return null;
        }
        
    }
    
    protected void putBoolean(Map<String, String> target, String paramName, Boolean value) {
    	
    	if (value != null) {
    		if (value == true) {
    			target.put(paramName, '1');
    		} else {
    			target.put(paramName, '0');
    		}
    	}
    	
    }
    
    
    
    private static testmethod void test() {
    	
    	PageReference ref = new PageReference('www.google.com');
    	
    	ref.getParameters().put('q', 'ADC');
    	ref.getParameters().put('param_bool_1', '1');
    	ref.getParameters().put('param_bool_2', '0');
    	ref.getParameters().put('param_bool_3', '****');
    	
    	Test.setCurrentPage(ref);
    	
    	ADCUtil_Params params = new ADCUtil_Params();
    	params.getString(params.rawParams, 'q');
    	params.getString(params.rawParams, 'DOES_NOT_EXIST');
    	params.getBoolean(params.rawParams, 'param_bool_1');
    	params.getBoolean(params.rawParams, 'param_bool_2');
    	params.getBoolean(params.rawParams, 'param_bool_3');
    	params.getBoolean(params.rawParams, 'DOES_NOT_EXIST');
    	
    	try {
    		params.toStringMap();
    	} catch (ADCUtil_Exceptions.NotImplementedException e) {
            System.debug(Logginglevel.INFO, 'Expected Exception...');
        }
        params.putString(params.rawParams, 'q', 'test');
        params.putBoolean(params.rawParams, 'b1', null);
        params.putBoolean(params.rawParams, 'b2', true);
        params.putBoolean(params.rawParams, 'b3', false);
    	
    }
    
}