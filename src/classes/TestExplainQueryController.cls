@isTest
private class TestExplainQueryController {
	
	//simple mock responses - not intelligent enough to respond to different input
	public class ExplainSuccessMock implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HTTPResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(
				'{"plans":[{"cardinality":0,"fields":[],"leadingOperationType":"TableScan","notes":[{"description":"Not considering filter for optimization because unindexed","fields":["IsDeleted","FakeField"],"tableEnumOrId":"Contact"},{"description":"Not considering filter for optimization because unindexed","fields":["Title"],"tableEnumOrId":"Contact"}],"relativeCost":0.6666666666666666,"sobjectCardinality":20,"sobjectType":"Contact"},{"cardinality":0,"fields":[],"leadingOperationType":"Other","notes":[{"description":"Not considering filter for optimization because unindexed","fields":["IsDeleted"],"tableEnumOrId":"Contact"},{"description":"Not considering filter for optimization because unindexed","fields":["Title"],"tableEnumOrId":"Contact"}],"relativeCost":0.6666666666666666,"sobjectCardinality":20,"sobjectType":"Contact"}]}'
			);
			res.setStatusCode(200);
			return res;
		}
	}
	public class ExplainErrorMock implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HTTPResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody('[{"message":"unexpected token: <EOF>","errorCode":"MALFORMED_QUERY"}]');
			res.setStatusCode(418);
			res.setStatus('I\'m a teapot'); //seriosuly, this is the RFC-compliant HTTP 418 response
			return res;
		}
	}
	
	@isTest
	static void explainContactTableScan(){
		Test.setCurrentPage(Page.ExplainQuery);
		Test.setMock(HTTPCalloutMock.class, new ExplainSuccessMock());
		ExplainQueryController con = new ExplainQueryController();
		con.soql = 'SELECT id, name FROM Contact WHERE Title = \'VP, Facilities\' ORDER BY Id LIMIT 10';
		con.showExplainPlan();

		System.assertEquals(2, con.plans.size());
		System.assertEquals('IsDeleted, FakeField', con.plans[0].notes[0].getCSVFields());
		System.assertEquals('TableScan', con.plans[0].leadingOperationType);
	}

	@isTest
	static void malformedQuery(){
		Test.setCurrentPage(Page.ExplainQuery);
		Test.setMock(HTTPCalloutMock.class, new ExplainErrorMock());
		ExplainQueryController con = new ExplainQueryController();
		con.soql = 'how do I SOQL??!';
		con.showExplainPlan();

		System.assertEquals(0, con.plans.size());
		System.assertEquals(true, ApexPages.hasMessages(ApexPages.Severity.Error), 'No errors processed from response');
	}

	@isTest
	static void deriveAPIEndpoint(){
		Map<String,String> hostStyles = new Map<String,String>{
			'mydomain--sandboxname--ns.cs0.visual.force.com' => 'https://mydomain--sandboxname.cs0.my.salesforce.com',
			'ns.na15.visual.force.com' => 'https://na15.salesforce.com',
			'mydomain--ns.na13.visual.force.com' => 'https://mydomain.na13.my.salesforce.com' //the pod in the URL doesn't seem to do any harm, and further complicates parsing logic to remove
		};
		ExplainQueryController.currentPrefix = 'ns';
		for(String vfUrl: hostStyles.keySet()){
			System.assertEquals(
				hostStyles.get(vfUrl),
				ExplainQueryController.deriveAPIEndpoint(vfUrl)
			);
		}
	}
}