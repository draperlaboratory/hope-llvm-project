import itertools
import json

from xml.sax.saxutils import quoteattr as quo

import lit.Test


def by_suite_and_test_path(test):
    # Suite names are not necessarily unique.  Include object identity in sort
    # key to avoid mixing tests of different suites.
    return (test.suite.name, id(test.suite), test.path_in_suite)


class JsonReport(object):
    def __init__(self, output_file):
        self.output_file = output_file

    def write_results(self, tests, elapsed):
        unexecuted_codes = {lit.Test.EXCLUDED, lit.Test.SKIPPED}
        tests = [t for t in tests if t.result.code not in unexecuted_codes]
        # Construct the data we will write.
        data = {}
        # Encode the current lit version as a schema version.
        data['__version__'] = lit.__versioninfo__
        data['elapsed'] = elapsed
        # FIXME: Record some information on the lit configuration used?
        # FIXME: Record information from the individual test suites?

        # Encode the tests.
        data['tests'] = tests_data = []
        for test in tests:
            test_data = {
                'name': test.getFullName(),
                'code': test.result.code.name,
                'output': test.result.output,
                'elapsed': test.result.elapsed}

            # Add test metrics, if present.
            if test.result.metrics:
                test_data['metrics'] = metrics_data = {}
                for key, value in test.result.metrics.items():
                    metrics_data[key] = value.todata()

            # Report micro-tests separately, if present
            if test.result.microResults:
                for key, micro_test in test.result.microResults.items():
                    # Expand parent test name with micro test name
                    parent_name = test.getFullName()
                    micro_full_name = parent_name + ':' + key

                    micro_test_data = {
                        'name': micro_full_name,
                        'code': micro_test.code.name,
                        'output': micro_test.output,
                        'elapsed': micro_test.elapsed}
                    if micro_test.metrics:
                        micro_test_data['metrics'] = micro_metrics_data = {}
                        for key, value in micro_test.metrics.items():
                            micro_metrics_data[key] = value.todata()

                    tests_data.append(micro_test_data)

            tests_data.append(test_data)

        with open(self.output_file, 'w') as file:
            json.dump(data, file, indent=2, sort_keys=True)
            file.write('\n')


_invalid_xml_chars_dict = {c: None for c in range(32) if chr(c) not in ('\t', '\n', '\r')}


def remove_invalid_xml_chars(s):
    # According to the XML 1.0 spec, control characters other than
    # \t,\r, and \n are not permitted anywhere in the document
    # (https://www.w3.org/TR/xml/#charsets) and therefore this function
    # removes them to produce a valid XML document.
    #
    # Note: In XML 1.1 only \0 is illegal (https://www.w3.org/TR/xml11/#charsets)
    # but lit currently produces XML 1.0 output.
    return s.translate(_invalid_xml_chars_dict)


class XunitReport(object):
    def __init__(self, output_file):
        self.output_file = output_file
        self.skipped_codes = {lit.Test.EXCLUDED,
                              lit.Test.SKIPPED, lit.Test.UNSUPPORTED}

    def write_results(self, tests, elapsed):
        tests.sort(key=by_suite_and_test_path)
        tests_by_suite = itertools.groupby(tests, lambda t: t.suite)

        with open(self.output_file, 'w') as file:
            file.write('<?xml version="1.0" encoding="UTF-8"?>\n')
            file.write('<testsuites time="{time:.2f}">\n'.format(time=elapsed))
            for suite, test_iter in tests_by_suite:
                self._write_testsuite(file, suite, list(test_iter))
            file.write('</testsuites>\n')

    def _write_testsuite(self, file, suite, tests):
        skipped = sum(1 for t in tests if t.result.code in self.skipped_codes)
        failures = sum(1 for t in tests if t.isFailure())

        name = suite.config.name.replace('.', '-')
        # file.write(f'<testsuite name={quo(name)} tests="{len(tests)}" failures="{failures}" skipped="{skipped}">\n')
        file.write('<testsuite name={name} tests="{tests}" failures="{failures}" skipped="{skipped}">\n'.format(
            name=quo(name), tests=len(tests), failures=failures, skipped=skipped))
        for test in tests:
            self._write_test(file, test, name)
        file.write('</testsuite>\n')

    def _write_test(self, file, test, suite_name):
        path = '/'.join(test.path_in_suite[:-1]).replace('.', '_')
        # class_name = f'{suite_name}.{path or suite_name}'
        class_name = suite_name + '.' + (path or suite_name)
        name = test.path_in_suite[-1]
        time = test.result.elapsed or 0.0
        # file.write(f'<testcase classname={quo(class_name)} name={quo(name)} time="{time:.2f}"')
        file.write('<testcase classname={class_name} name={name} time="{time:.2f}"'.format(
            class_name=quo(class_name), name=quo(name), time=time))

        if test.isFailure():
            file.write('>\n  <failure><![CDATA[')
            # In the unlikely case that the output contains the CDATA
            # terminator we wrap it by creating a new CDATA block.
            output = test.result.output.replace(']]>', ']]]]><![CDATA[>')
            if isinstance(output, bytes):
                output = output.decode("utf-8", 'ignore')

            # Failing test  output sometimes contains control characters like
            # \x1b (e.g. if there was some -fcolor-diagnostics output) which are
            # not allowed inside XML files.
            # This causes problems with CI systems: for example, the Jenkins
            # JUnit XML will throw an exception when ecountering those
            # characters and similar problems also occur with GitLab CI.
            output = remove_invalid_xml_chars(output)
            file.write(output)
            file.write(']]></failure>\n</testcase>\n')
        elif test.result.code in self.skipped_codes:
            reason = self._get_skip_reason(test)
            # file.write(f'>\n  <skipped message={quo(reason)}/>\n</testcase>\n')
            file.write('>\n  <skipped message={reason}/>\n</testcase>\n'.format(
                reason=quo(reason)))
        else:
            file.write('/>\n')

    def _get_skip_reason(self, test):
        code = test.result.code
        if code == lit.Test.EXCLUDED:
            return 'Test not selected (--filter, --max-tests)'
        if code == lit.Test.SKIPPED:
            return 'User interrupt'

        assert code == lit.Test.UNSUPPORTED
        features = test.getMissingRequiredFeatures()
        if features:
            return 'Missing required feature(s): ' + ', '.join(features)
        return 'Unsupported configuration'


class TimeTraceReport(object):
    def __init__(self, output_file):
        self.output_file = output_file
        self.skipped_codes = {lit.Test.EXCLUDED,
                              lit.Test.SKIPPED, lit.Test.UNSUPPORTED}

    def write_results(self, tests, elapsed):
        # Find when first test started so we can make start times relative.
        first_start_time = min([t.result.start for t in tests])
        events = [self._get_test_event(
            x, first_start_time) for x in tests if x.result.code not in self.skipped_codes]

        json_data = {'traceEvents': events}

        with open(self.output_file, "w") as time_trace_file:
            json.dump(json_data, time_trace_file, indent=2, sort_keys=True)

    def _get_test_event(self, test, first_start_time):
        test_name = test.getFullName()
        elapsed_time = test.result.elapsed or 0.0
        start_time = test.result.start - first_start_time if test.result.start else 0.0
        pid = test.result.pid or 0
        return {
            'pid': pid,
            'tid': 1,
            'ph': 'X',
            'ts': int(start_time * 1000000.),
            'dur': int(elapsed_time * 1000000.),
            'name': test_name,
        }
