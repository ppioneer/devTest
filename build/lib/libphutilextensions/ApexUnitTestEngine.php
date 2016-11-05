<?php
	class ApexUnitTestEngine extends ArcanistUnitTestEngine {
		function run() {
			$console = PhutilConsole::getConsole();
			$projectRoot = $this->getWorkingCopy()->getProjectRoot();
			$buildFile = $projectRoot . '/build/build.xml';
			passthru('ant -buildfile ' . $buildFile . ' unitTest', $return_var);

			$result = new ArcanistUnitTestResult();
			if ($return_var == 0)
			{
				$result -> setResult( ArcanistUnitTestResult::RESULT_PASS);
			}
			else
			{
				$result -> setResult(ArcanistUnitTestResult::RESULT_FAIL);
			}

			return array($result);
		}
	}
?>