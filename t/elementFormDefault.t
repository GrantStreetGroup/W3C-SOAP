#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use Path::Class;
use Data::Dumper qw/Dumper/;
use File::ShareDir qw/dist_dir/;
use Template;
use W3C::SOAP::XSD::Parser;

my $dir = file($0)->parent;

plan( skip_all => 'Test can only be run if test directory is writable' ) if !-w $dir;

# set up templates
my $template = Template->new(
    INCLUDE_PATH => dist_dir('W3C-SOAP').':'.$dir->subdir('../templates'),
    INTERPOLATE  => 0,
    EVAL_PERL    => 1,
);
# create the parser object
my $parser = W3C::SOAP::XSD::Parser->new(
    location      => $dir->file('elementFormDefault-qualified.xsd').'',
    template      => $template,
    lib           => $dir->subdir('lib').'',
    ns_module_map => {},
    module_base   => 'ElementFormDefault',
);
$parser->write_modules;

my (@classes) = eval { $parser->dynamic_classes };
ok !$@, "Create dynamic classes correctly"
    or BAIL_OUT($@);

dynamic_modules(@classes);
done_testing();
exit;

sub dynamic_modules {
    my ($qual, $unqual) = @_;

    my $unobject = $unqual->new(
        process_record => {
            type          => 'TEST',
            timestamp     => '2013-08-26T00:00:00',
            correlationId => '1234',
            billingId     => '4321',
        }
    );

    ok $unobject, 'Get a new unobject';
    ok $unobject->process_record, 'Currectly set element';
    is $unobject->process_record->type, 'TEST', 'Currectly set element';

    my $object = $qual->new(
        re_process_record => {
            type          => 'TEST',
            timestamp     => '2013-08-26T00:00:00',
            correlationId => '1234',
            billingId     => '4321',
        }
    );

    ok $object, 'Get a new object';
    ok $object->process_record, 'Currectly set element';
    is $object->process_record->type, 'TEST', 'Currectly set element';
}


