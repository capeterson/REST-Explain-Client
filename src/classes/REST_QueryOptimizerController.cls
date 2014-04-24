public with sharing class REST_QueryOptimizerController {

    private String instance;
    transient public String soql { get; set; }
    transient public String retJSON { get; set; }
    transient public String explain { get; set; }
    transient public String error { get; set; }
    
    public List<cIndex> indexes { get; set; }
    
    public REST_QueryOptimizerController() {
        // retrieve the instance used to create endpoint URL
        instance = URL.getSalesforceBaseUrl().getHost();
        
        // check for my domain
        if (instance.contains('--c.') && !instance.startsWith('c.')) {
            instance = instance.substring(0, instance.indexOf('--c.')) + '.my.salesforce.com';
        }
        else {
            // strip out the starting 'c.' values
            instance = instance.substring(2);
            
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
        //retJSON=genTestJSON();
        
        indexes = new List<cIndex>();
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
        public List<cIndex> plans {get; set;}
    }
    
    public class cIndex {
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