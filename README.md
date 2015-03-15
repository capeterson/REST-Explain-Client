REST-Explain-Client
===================

<a href="https://githubsfdeploy.herokuapp.com?owner=capeterson&repo=REST-Explain-Client">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

A simple apex and visualforce based client for the [SOQL Explain API pilot](http://www.salesforce.com/us/developer/docs/api_rest/Content/dome_query_explain.htm).

Before use, regardless of how you install this, you must create a remote site setting under Setup | Security Controls | Remote Site Settings for the URL of your instance. For example https://na10.salesforce.com or https://something.my.salesforce.com

Is it available as a managed package, installable from this link: https://login.salesforce.com/packaging/installPackage.apexp?p0=04tF0000000FjD0

If you decide to use this code unmanged you can deploy it via a useful [web-based deployment tool Andrew Fawcett wrote](https://github.com/afawcett/githubsfdeploy) or via any other metadata API tools, like the Force.com IDE or MavensMate.

If you aren't sure if managed or unmaged is the right choice take a look at [this blog post](http://www.ca-peterson.com/2011/09/picking-right-package.html) which should help explain the differences. In short, unless you plan on modifying the code included the manged version is probobly the right choice.

![](http://github.com/capeterson/REST-Explain-Client/raw/master/sample/case-demo.png)
