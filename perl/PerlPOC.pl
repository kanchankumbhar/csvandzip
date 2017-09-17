#!C:\Strawberry\perl\bin\perl

use strict;
use warnings;
use XML::Writer;
use IO::File;
use File::Path;
use File::Copy;
use DateTime;
use Time::Piece;
use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use File::Basename;
use POSIX qw(strftime);

my $csvfilepath = "C:/temp/Vinu/Perl_code/csvfilelist.csv"; 
my $retentionFilePath="C:/temp/Vinu/Perl_code/RetentionCode.csv"; 
my $batchfilepath = "C:/temp/Vinu/Perl_code/batch_data/batchxml/batch.xml";
my $requestfilepath = "C:/temp/Vinu/Perl_code/batch_data/request.xml";
my $file = $csvfilepath or die "Need to get CSV file on the command line\n";
my @fields =""; 
my @rFields="";
my $rootFolder="C:/temp/Vinu/Objects";
my $sum = 0;
my $destinationPath = "C:/temp/Vinu/Perl_code/batch_data/Objects";

open(my $data, '<', $file) or die "Could not open '$file' $!\n";

my @names = (".css", ".png", ".js");

#print "$rootFolder";

#batch.xml Creation 

  my $output = IO::File->new(">$batchfilepath");
  my $writer = XML::Writer->new(OUTPUT => $output, DATA_MODE => 1, DATA_INDENT=>2);
  $writer->startTag("batch","Server" => "CMSCBP");
 
while (my $line = <$data>) {
  chomp $line;
 
  @fields = split "," , $line;
 # print "$fields[0] $fields[1] $fields[2] $fields[3] $fields[4] $fields[5] $fields[6] $fields[7] $fields[8]\n";
  
  
  
  
  #node_module and readme.txt exclusion START HERE

	my $substr="/node_module/";
	my $substr1="readme.txt";
	my $str=$fields[1];
	
	print "Start Validation\n";
if (index($str, $substr) != -1 || index($str, $substr1) != -1) {
    print "$str contains $substr\n";
}
else{
 

  
  #Expiry date compare START HERE

my $localdate = strftime "%m/%d/%Y", localtime;
#print "\n**$localdate";

my $Expirydate = $fields[8];
my $TSexpiryDate = "$Expirydate";
#print "\n**$TSexpiryDate";


my $dateformat = "%m/%d/%Y";

my $date1 = "$localdate";
my $date2 = "$TSexpiryDate";

$date1 = Time::Piece->strptime($date1, $dateformat);
$date2 = Time::Piece->strptime($date2, $dateformat);

if ($date2 < $date1) {
   # print "\nexpired";
} else {
    # print "\nNot expired";
	  $writer->startTag("uow");


#Expiry date compare END HERE
  
  
  open(my $retentionData, '<', $retentionFilePath) or die "Could not open '$retentionFilePath' $!\n";
  while (my $line1 = <$retentionData>) {
   chomp $line1;
   @rFields = split "," , $line1;
   #print "$rFields[0] $rFields[1] $rFields[2]\n";
	if($rFields[0] eq $fields[0]){
		$fields[0]=$rFields[1];
		#last;
		#print "In\n";
	}
   }
   
   # Copy to Destination Objects folder START
   my $temp= join "", "$rootFolder","/","$fields[1]";
   
   
   my($name,$path1,$suffix)=fileparse($fields[1]);
   
   #print "$path1\n";
   
    my @values = split('Objects/', $path1);

	my $appendToDestination="";
  foreach my $val (@values) {
	if($val ne ".\\"){
	$appendToDestination=$val;
   # print "$val\n";
	}
  }
  
  my $destinationPath=join "","$destinationPath","/","$appendToDestination";
   
   
  #print "$destinationPath\n";
   
   if (! -d $destinationPath)
			{
			  my $dirs = eval { mkpath($destinationPath) };
			  die "Failed to create $destinationPath: $@\n" unless $dirs;
			}

			copy($temp,$destinationPath) or die "Failed to copy $temp: $!\n";
			 
			
 # Copy to Destination Objects folder END
 
 
  $writer->startTag("item","type" => "document","itemtype" => "TmSte");
  $writer->startTag("attribute","type" => "string" , "name" => "RM_DOC_TYP_TXT");
  $writer->characters("$fields[0]");
  $writer->endTag("attribute");
  
  $writer->startTag("attribute","type" => "string" , "name" => "TmSte_PthWNm");
  $writer->characters("$fields[1]");
  $writer->endTag("attribute");
  
  
  $writer->startTag("attribute","type" => "string" , "name" => "TmSte_CtntAuth");
  $writer->characters("$fields[2]");
  $writer->endTag("attribute");
  
  $writer->startTag("attribute","type" => "string" , "name" => "TmSte_CtntOwnr");
  $writer->characters("$fields[3]");
  $writer->endTag("attribute");  
  
  $writer->startTag("attribute","type" => "string" , "name" => "TmSte_MetaKywrd");
  $writer->characters("$fields[4]");
  $writer->endTag("attribute");  
  
  $writer->startTag("attribute","type" => "string" , "name" => "TmSte_LstModBy");
  $writer->characters("$fields[5]");
  $writer->endTag("attribute");
  
  $writer->startTag("attribute","type" => "string" , "name" => "TmSte_LstMod");
  $writer->characters("$fields[6]");
  $writer->endTag("attribute");
  
  $writer->startTag("attribute","type" => "string" , "name" => "TmSte_BrnchNm");
  $writer->characters("$fields[7]");
  $writer->endTag("attribute");
  
   $writer->startTag("attribute","type" => "string" , "name" => "RM_EVNT_DT");
  $writer->characters("$fields[8]");
  $writer->endTag("attribute");
 
  $writer->endTag("item");
 $writer->endTag("uow");
  
}
}
}

 
  $writer->endTag("batch");
  $writer->end();
  $output->close();
  
  #Request.xml Creation   
  my $requestxml = IO::File->new(">$requestfilepath");
  my $writerrequest = XML::Writer->new(OUTPUT => $requestxml, DATA_MODE => 1, DATA_INDENT=>2);
  $writerrequest->xmlDecl("UTF-8");
  $writerrequest->doctype( 'request',undef,'request.dtd' );
 $writerrequest->startTag("request","type" => "store");
 
 $writerrequest->startTag("appId");
  $writerrequest->characters("TMSITESTORE");
  $writerrequest->endTag("appId");
  
  $writerrequest->startTag("priority");
  $writerrequest->characters("10");
  $writerrequest->endTag("priority");
  
  $writerrequest->startTag("store","stageType" =>"package","type"=>"PFGXMLV1");
  $writerrequest->startTag("stageName");
  $writerrequest->characters("YYYYMMDD_HHMM.zip");
  $writerrequest->endTag("stageName");
  $writerrequest->startTag("compression");
  $writerrequest->characters("ZIP");
  $writerrequest->endTag("compression");
  
  $writerrequest->endTag("store");
  $writerrequest->endTag("request");
  $requestxml->close();  
	 
	 
	 
	 
   #Zip Creation 
   my $zip = Archive::Zip->new();

   print "Start ZIP ";
   
   #Prepare zipfile name using timestamp START HERE

my $ymd = DateTime->now(time_zone => "local")->ymd('');
my $hms = DateTime->now(time_zone => "local")->hms('');
my $con_name = join "", "$ymd", "_" , "$hms";
my $zipname ="C:/temp/Vinu/Perl_code/batch_data/$con_name.zip";
print $zipname;

#Prepare zipfile name using timestamp END HERE	
   
   
   
   
  # Add a file from disk
   $zip->addTree('C:/temp/Vinu/Perl_code/batch_data/batchxml', '');
   $zip->addTree( 'C:/temp/Vinu/Perl_code/batch_data/Objects', 'Objects');
   


   # Save the Zip file
   unless ( $zip->writeToFileNamed($zipname) == AZ_OK ) {
       die 'write error';
   }

