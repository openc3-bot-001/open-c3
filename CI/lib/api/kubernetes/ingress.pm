package api::kubernetes::ingress;
use Dancer ':syntax';
use Dancer qw(cookie);
use Encode qw(encode);
use FindBin qw( $RealBin );
use JSON;
use POSIX;
use api;
use Format;
use Time::Local;
use File::Temp;
use api::kubernetes;

our %handle;
$handle{showinfo} = sub { return +{ info => shift, stat => shift ? $JSON::false : $JSON::true }; };

get '/kubernetes/ingress' => sub {
    my $param = params();
    my $error = Format->new( 
        namespace => qr/^[\w@\.\-]*$/, 0,
        status => qr/^[a-z]*$/, 0,
        ticketid => qr/^\d+$/, 1,
    )->check( %$param );

    return  +{ stat => $JSON::false, info => "check format fail $error" } if $error;
    my $pmscheck = api::pmscheck( 'openc3_ci_read', 0 ); return $pmscheck if $pmscheck;

    my ( $user, $company )= $api::sso->run( cookie => cookie( $api::cookiekey ), 
        map{ $_ => request->headers->{$_} }qw( appkey appname ));

    my $kubectl = eval{ api::kubernetes::getKubectlCmd( $api::mysql, $param->{ticketid}, $user, $company, 0 ) };
    return +{ stat => $JSON::false, info => "get ticket fail: $@" } if $@;

    my $filter = +{ namespace => $param->{namespace}, status => $param->{status} };
    my $argv = $param->{namespace} ? "-n $param->{namespace}" : "-A";
#TODO 不添加2>/dev/null 时,如果命名空间不存在ingress时，api.event 的接口会报错
    my ( $cmd, $handle ) = ( "$kubectl get ingress -o wide $argv 2>/dev/null", 'getingress' );
    return +{ stat => $JSON::true, data => +{ kubecmd => $cmd, handle => $handle, filter => $filter }} if request->headers->{"openc3event"};
    return &{$handle{$handle}}( `$cmd`//'', $?, $filter );
};

$handle{getingress} = sub
{
    my ( $x, $status, $filter ) = @_;
    return +{ stat => $JSON::false, data => $x } if $status;
    my @x = split /\n/, $x;

    my $failonly = ( $filter->{status} && $filter->{status} eq 'fail' ) ? 1 : 0;

    my ( @title, @r ) = split /\s+/, shift @x;
    unshift @title, 'NAMESPACE' if $filter->{namespace};
    splice @title,4, 0, splice @title, -2;

    map
    {
         $_ =~ s/, /,/g;
         $_ = "$filter->{namespace} $_" if $filter->{namespace};
         my @col = split /\s+/, $_, 4;

         my %r; map{ $r{$title[$_]} = $col[$_] }0..2;
         my @tempcol = split /\s+/, pop @col;
         $r{AGE} = pop @tempcol;
         $r{PORTS} = pop @tempcol if @tempcol && $tempcol[-1] =~ /^[\d\,]+$/;
         ( $r{HOSTS}, $r{ADDRESS} ) = split /\s+/, join( ' ', @tempcol ), 2;
         if( $r{ADDRESS} =~ s/^(\+ \d+ more\.\.\.)// )
         {
             $r{HOSTS} .= $1;
         }
         
        push @r, \%r if ( ! $failonly) || ( $failonly && ! $r{ADDRESS} );
    }@x;

    return +{ stat => $JSON::true, data => \@r, };
};

true;