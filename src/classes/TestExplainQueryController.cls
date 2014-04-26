@isTest
private class TestExplainQueryController {
	
	//simple mock responses - not intelligent enough to respond to different input
	public class ExplainSuccessMock implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req){
			HTTPResponse res = new HTTPResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(
				'{"plans":[{"cardinality":26,"fields":[],"leadingOperationType":"TableScan","relativeCost":2.4333333333333336,"sobjectCardinality":26,"sobjectType":"Case"}]}'
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
	static void explainCaseTableScan(){
		Test.setCurrentPage(Page.ExplainQuery);
		Test.setMock(HTTPCalloutMock.class, new ExplainSuccessMock());
		ExplainQueryController con = new ExplainQueryController();
		con.soql = 'SELECT id FROM Case';
		con.showExplainPlan();

		System.assertEquals(1, con.plans.size());
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
}