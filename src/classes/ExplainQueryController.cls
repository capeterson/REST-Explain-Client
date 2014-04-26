public with sharing class ExplainQueryController {

    private String instance;
    transient public String soql { get; set; }
    transient public String retJSON { get; set; }
    transient public String explain { get; set; }
    transient public String error { get; set; }
    
    public List<Plan> indexes { get; set; }

    //determine what URL prefix we're removing, c for unmanaged, soql-explain for managed.
    private static String currentPrefix{
        get{
            String prefix = ExplainQueryController.class.getName().substringBefore('ExplainQueryController');
            if(prefix.endsWith('.'))
                prefix = prefix.removeEnd('.');
            if(String.isEmpty(prefix)){
                return 'c';
            }else{
                return prefix.replaceAll('_','-'); //underscores in namespaces are converted to hypens in domain names
            }
        }
    }
    
    //visualforce domains aren't API-enabled, so we need to figure out what the proper endpoint
    public ExplainQueryController() {
        // retrieve the instance used to create endpoint URL
        instance = URL.getSalesforceBaseUrl().getHost();
        
        // check for my domain
        if (instance.contains('--'+currentPrefix+'.') && !instance.startsWith(currentPrefix+'.')) {
            instance = instance.substring(0, instance.indexOf('--'+currentPrefix+'.')) + '.my.salesforce.com';
        }
        else {
            // strip out the starting 'c.' values
            instance = instance.removeStart(currentPrefix+'.');
            instance = instance.replace('.visual.force.com', '.salesforce.com');
        }
        instance = 'https://' + instance;
    }    
    
    public PageReference showExplainPlan() {
        HTTPRequest req = new HTTPRequest();
        req.setHeader('Authorization','Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type','application/json');
        
        req.setEndpoint(instance + '/services/data/v30.0/query/?explain=' + EncodingUtil.urlEncode(soql, 'UTF-8'));
        req.setMethod('GET');
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        String status = res.getStatus();
        Integer statusCode = res.getStatusCode();
        retJSON = res.getBody();
        
        indexes = new List<Plan>();
        String text = '';
      
        // check if we had an error
        if (statusCode != 200) {
            JSONParser parser = JSON.createParser(retJSON);
            String err = '';
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) { 
                    text = parser.getText();
                    parser.nextToken();
                    
                    if ((text == 'message') || (text == 'errorCode')) {
                        text = parser.getText();
                        err += ' ' + text;
                    }
                }
            }
            MyException e = new MyException(status + ' - ' + err);
            ApexPages.addMessages(e);
        }
        else {           
            ExplainResponse response = (ExplainResponse) JSON.deserialize(retJSON, ExplainResponse.class);
            indexes = response.plans;     
        }    
               
        return null;
    }
    
    public class ExplainResponse{
        public List<Plan> plans {get; set;}
    }
    
    public class Plan {
        public Double cardinality { get; set; }
        public List<String> fields { get; set; }
        public String leadingOperationType { get; set; }
        public Double relativeCost { get; set; }
        public Double sObjectCardinality { get; set; }
        public String sObjectType { get; set;}
    }
    
    public class MyException extends Exception {}
    
    public String genTestJSON () {
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeFieldName('plans');
        gen.writeStartArray();
        
        /*gen.writeStartObject();
        gen.writeStringField('cardinality', '1');
        gen.writeFieldName('fields');
        gen.writeStartArray();
        gen.writeString('CreatedDate');
        gen.writeEndArray();
        gen.writeStringField('leadingOperationType', 'Index');
        gen.writeStringField('relativeCost', '0.0');
        gen.writeStringField('sobjectCardinality', '3');
        gen.writeStringField('sobjectType', 'Merchandise');
        gen.writeEndObject();

        gen.writeStartObject();
        gen.writeStringField('cardinality', '1');
        gen.writeFieldName('fields');
        gen.writeStartArray();
        gen.writeEndArray();
        gen.writeStringField('leadingOperationType', 'TableScan');
        gen.writeStringField('relativeCost', '0.65');
        gen.writeStringField('sobjectCardinality', '3');
        gen.writeStringField('sobjectType', 'Merchandise');
        gen.writeEndObject();*/
       
        gen.writeStartObject();
        gen.writeStringField('cardinality', '739');
        gen.writeFieldName('fields');
        gen.writeStartArray();
        gen.writeEndArray();
        gen.writeStringField('leadingOperationType', 'TableScan');
        gen.writeStringField('relativeCost', '0.8267833333333333');
        gen.writeStringField('sobjectCardinality', '10000');
        gen.writeStringField('sobjectType', 'MyCase__c');
        gen.writeEndObject();


        gen.writeEndArray();
        
        gen.writeEndObject();
        return gen.getAsString();
    }
    
}