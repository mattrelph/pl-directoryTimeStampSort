# pl-directoryTimeStampSort
Sorts a directory of files by their time stamp into sub directories - Perl Script

Taking a directory full of files, and putting them in folders based on the date of their last modification

Works good for lots of things, logs, pictures, piles of HL7 pharmacy requests, you name it!

Some error checking. Should stop and report to shell on any error As always, use at your own risk

1st Argument = Source Path 2nd Argument = Destination Path 3rd Argument = Option Flags (-xxxx)

Example use (Perl Script in bash):

perl scriptName Source Destination -xxxx

Possible future additions: Filter by extension, relative paths, more error checking
