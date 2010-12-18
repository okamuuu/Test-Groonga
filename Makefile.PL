use inc::Module::Install;
name 'Test-Groonga';
all_from 'lib/Test/Groonga.pm';

tests 't/*.t';
author_tests 'xt';

requires 'Class::Accessor::Lite' => 0.05;
requires 'File::Spec';
requires 'File::Temp';
requires 'Time::HiRes';
requires 'IO::Socket::INET';

test_requires 'Test::More';
test_requires 'Test::Exception';
test_requires 'LWP::Simple';
auto_set_repository;
auto_include;
WriteAll;
