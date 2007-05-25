use Test::Simple 'no_plan';
use File::Path;
use Cwd;

ok( File::Path::rmtree( cwd().'/t/Testing_Client' ));

