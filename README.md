## Router OS Config File Munger
I created this project so I have a tool that can convert Mikrotik RouterOS config files from a router so they it can be used with another different model of router. As an example I once manually converted the config file of my main router a CCR2004 to work with a CRS305. This conversion process involved commenting out certain sections of the config and testing it out on the alternate (backup) router to see if it works.

The File Munger uses a set of rules which you need to define which will:

find config file sections or commands and comment them out
insert new commands


## Example

## How to use

