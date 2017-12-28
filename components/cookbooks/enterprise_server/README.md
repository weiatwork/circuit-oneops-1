<style>
@import url(http://fonts.googleapis.com/css?family=Roboto:400,300);
body, div, td, span {
	font-family: 'Roboto', sans-serif;
}
table, tr, td, th { border: 1px solid;}
th { text-align: left; font-size: 12pt;}
table tr td { vertical-align: top; }
</style>

# Enterprise Server Cookbook #
Enterprise server is a cookbook designed to install TomEE/ Enterprise Server.
A Java EE 7 server with Hibernate, Hibernate validation, Hazelcast, and Common
core components such as configuration, logging and SOA-RI client.

e.g.
### Requirements
- `java` - required to run the application server
- `ssl` - required to enable HTTPS traffic
- `javaservicewrapper` -  required to wrap java and make it reportable

#Attributes

Below are a list of attributes which effect differnt parts of the installation and maintenance process.

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
	  <th colspan="4">Installation</th>
  </tr>
  <tr>
    <td><tt>['entsrv']['install_dir']</tt></td>
    <td>String</td>
    <td>Absolute system path in which the binary will be installed.</td>
    <td><tt>/app</tt></td>
  </tr>

  <tr>
    <td><tt>['entsrv']['instal_repo']</tt></td>
    <td>String</td>
    <td>
    	<ul>
			<li>Release Repository</li>
			<li>SNAPSHOT Repository - Used for testing</li>
		</ul>
    </td>
    <td><tt>Release Repository</tt></td>
  </tr>

  <tr>
    <td><tt>['entsrv']['instal_version']</tt></td>
    <td>String</td>
    <td>Version to install</td>
    <td><tt>LATEST</tt></td>
  </tr>
</table>

#Usage

### enterprise-server::default
Include `enterprise-server` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[enterprise-server]"
  ]
}
```

### License and Authors
(c) Copyright OneOps, All rights reserved.

Authors:
<ul>
	<li>OneOps Team</li>
</ul>
