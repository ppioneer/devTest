/* Copyright (c) 2008-2014 Evariant */
@isTest
public class TestRestPrmPostInstallConfigurations {

    @isTest
	static void testInstallScript() {
	    RestPrmPostInstallConfigurations postinstall = new RestPrmPostInstallConfigurations ();
	    Test.testInstall(postinstall, null);
	    system.assert(true);
	}
}