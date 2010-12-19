use inc::Module::Install;
name 'Test-Groonga';
all_from 'lib/Test/Groonga.pm';

tests 't/*.t';
author_tests 'xt';

requires 'File::Spec';
requires 'File::Temp';
requires 'File::Which';
requires 'Test::TCP';

test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'LWP::UserAgent';
auto_set_repository;
auto_include;
WriteAll;
