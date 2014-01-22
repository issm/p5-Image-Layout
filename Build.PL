use 5.008;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->subclass(
    code => q{
        # run prove
        sub ACTION_test {
            my $self = shift;
            my $tests = $self->find_test_files;

            require App::Prove;
            my $prove = App::Prove->new();
            #$prove->process_args('-l', '-r', @$tests);
            $prove->process_args('-l', '-r', 't');
            $prove->run();
        }
    }
)->new(
    module_name         => 'Image::Layout',
    license             => 'perl',
    dist_author         => q{IWATA, Susumu <issmxx@gmail.com>},
    dist_version_from   => 'lib/Image/Layout.pm',
    #release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
        'Test::LeakTrace' => '0.14',
    },
    requires => {
        'Class::Accessor::Lite' => '0.05',
        'Class::Load'           => '0.20',
        'Data::Validator'       => '1.02',
        'MouseX::Types'         => '0.06',
        'Test::Deep'            => '0.110',
        'Try::Tiny'             => '0.12',
        'Furl'                  => '2.03',
        'URI'                   => '1.60',
        'Image::Size'           => '3.232',
    },
    add_to_cleanup     => [ 'Image-Layout-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
