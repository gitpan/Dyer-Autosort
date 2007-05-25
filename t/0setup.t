use Test::Simple 'no_plan';
use Cwd;
my $cwd = cwd;
my @tmps = (
"t/Testing_Client/incoming/011005- Reston 1 Final -\@REC.pdf",
"t/Testing_Client/incoming/011005- ROCKVILLE 1 FINAL -\@REC.pdf",
"t/Testing_Client/incoming/011007-RESTON 1 ESCROW FOLDER WORKPAPER-\@EWK.pdf",
"t/Testing_Client/incoming/012606-BOGDAN BUILDERS-033134-\@AP.pdf",
"t/Testing_Client/incoming/021005- ROCKVILLE 1 FINAL -\@REC.pdf",
"t/Testing_Client/incoming/021006-RESTON 1 ESCROW FOLDER-\@EWK.pdf",
"t/Testing_Client/incoming/021006-ROCKVILLE 1 ESCROW FOLDER-\@EWK.pdf",
"t/Testing_Client/incoming/022806-BRADLEY FOOD AND BEVERAGE-033870-\@AP.pdf",
"t/Testing_Client/incoming/031006-US TOWSON ESCROW REPORTS TRUST AND MAHT-\@REC.pdf",
"t/Testing_Client/incoming/031006-US Towson Reconciliation Issues-\@REC.xls",
"t/Testing_Client/incoming/031007-ROCKVILLE 1-\@REC.pdf",
"t/Testing_Client/incoming/041006-US Towson  Reconciliation Issues-\@REC.xls",
"t/Testing_Client/incoming/051106-DELL FINANCIAL SERVICES-037808-\@AP.pdf",
"t/Testing_Client/incoming/061006-RESTON 1 ESCROW FOLDER WORKPAPER-\@EWK.pdf",
"t/Testing_Client/incoming/061006-ROCKVILLE 1 ESCROW FOLDER WORKPAPER-\@EWK.pdf",
"t/Testing_Client/incoming/122706-BOGUSDAIMLER CHRYSLER TRUCK FINANCIAL-\@AP.pdf",
"t/Testing_Client/incoming/122706-DAIMLER CHRYSLER TRUCK FINANCIAL-041469-\@AP.pdf",
"t/Testing_Client/incoming/123102-ALPINE INVESTMENT GROUP 2002 TAX RETURN-\@TAX.pdf",
"t/Testing_Client/incoming/123102-Alpine Investment Group 2002 Workpaper File-\@TWK.pdf",
"t/Testing_Client/incoming/123103-ALPINE INVESTMENT GROUP 2003 TAX RETURN-\@TAX.pdf",
"t/Testing_Client/incoming/123104-ALPINE INVESTMENT GROUP 2004 TAX RETURN-\@TAX.pdf",
"t/Testing_Client/incoming/123104-Alpine Investment Group Workpaper File-\@TWK.pdf",
"t/Testing_Client/incoming/123105-ALPINE INVESTMENT GROUP LLC TAX RETURN-\@TAX.PDF",
"t/Testing_Client/incoming/123105-ALPINE INVESTMENT GROUP LLC WORKPAPER-\@TWK.pdf",
"t/Testing_Client/incoming/123105-RUFE ADAM TAX RETURN-\@TAX.PDF",
"t/Testing_Client/incoming/123105-RUFE ADAM WORKPAPER-\@TWK.pdf",
"t/Testing_Client/incoming/123105-SMITH AUSTIN TAX RETURN-\@TAX.PDF",
"t/Testing_Client/incoming/123105-SMITH AUSTIN WORKPAPER-\@TWK.pdf",
"t/Testing_Client/incoming/BOGUS-\@AP.pdf",
"t/Testing_Client/incoming/BOGUSDAIMLER CHRYSLER TRUCK FINANCIAL-\@AP.pdf",
"t/Testing_Client/incoming/PERRIER 23-\@API.pdf",
"t/Testing_Client/incoming/RESTON 1 011006 final-\@REC.pdf",
"t/Testing_Client/incoming/RESTON 1 011006-\@REC.pdf",
"t/Testing_Client/incoming/Reston 1 081005 final-\@REC.pdf",
"t/Testing_Client/incoming/Reston 1 101005 final-\@REC.pdf",
"t/Testing_Client/incoming/Reston 1 111005 final-\@REC.pdf",
"t/Testing_Client/incoming/RGS ESCROW FOLDER RESTON 1-111005-\@EWK.pdf",
"t/Testing_Client/incoming/RGS ESCROW FOLDER RESTON 1-121005-\@EWK.pdf",
"t/Testing_Client/incoming/Rockville 1 091005 final-\@REC.pdf",
"t/Testing_Client/incoming/ROCKVILLE 1 091005.pdf",
"t/Testing_Client/incoming/Rockville 1 101005 final-\@REC.pdf"
);
mkdir "$cwd/t/Testing_Client";

mkdir "$cwd/t/Testing_Client/incoming";

for (@tmps){
	my $abs = "$cwd/$_";
	open(FILE,">$abs");
	print FILE "bogus";
	close FILE;
	ok(-f $abs);
}




