## Router OS Config File Munger
I created this project so I have a tool that can convert Mikrotik RouterOS config files from a router so it can be used with a different model of router. My initial interest was so I could run my home router config an a different  backup router just in case if needed. As an example, I once manually converted the config file of my main router a CCR2004 to work with a CRS305. This conversion process involved commenting out certain sections of the config and testing it out on the alternate (backup) router to see if it works.

The File Munger uses a set of rules which you need to define which will:

1. Find config file sections or commands and comment them out
2. Insert new command(s) after a section
3. Find and Replace text in the file

## Example

For example this section of config

```
...
/interface bridge port
add bridge=GuestBridge interface=vlanGuest internal-path-cost=10 path-cost=10
add bridge=bridge interface=sfp-sfpplus2_LAN internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether2 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether3 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether4 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether5 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether6 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether7 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether8 internal-path-cost=10 path-cost=10
...
```

Will be transformed by these rules

```
...
    "comment_lines": {
      "/interface bridge port": {
        "prefixes": [
          "add bridge=bridge interface=sfp-sfpplus2",
          "add bridge=bridge interface=ether6",
          "add bridge=bridge interface=ether7",
          "add bridge=bridge interface=ether8"
        ],
        "mode": "add"
      }
...
```
Which results with this

```
...
/interface bridge port
add bridge=GuestBridge interface=vlanGuest internal-path-cost=10 path-cost=10
#add bridge=bridge interface=ether2 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether2 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether3 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether4 internal-path-cost=10 path-cost=10
add bridge=bridge interface=ether5 internal-path-cost=10 path-cost=10
#add bridge=bridge interface=ether6 internal-path-cost=10 path-cost=10
#add bridge=bridge interface=ether7 internal-path-cost=10 path-cost=10
#add bridge=bridge interface=ether8 internal-path-cost=10 path-cost=10
...
```

## How to use

This program is written and tested with Python 3.11 and it depends on having Python installed where you are going to use it.

```
Usage: python ConfigMunger.py [-h] [--rules RULES] input_file
E.g. python ConfigMunger.py 'example.rsc' '--rules' 'rules.json'
```

You will need to modify the rules.json file to suit your particular outcome(s) you are wanting to achieve.

I personally use this tool in conjunction with https://github.com/ytti/oxidized which integrates my router config into a private github repo which then runs a github action on push which then automatically converts my main router config into backup configs to run on my other routers if/when needed.

This video on exporting and importing RouterOS Config is also handy.
<br>
<br>
<a href="http://www.youtube.com/watch?feature=player_embedded&v=jBC7mScNUjw
" target="_blank"><img src="http://img.youtube.com/vi/jBC7mScNUjw/0.jpg" 
alt="IMAGE ALT TEXT HERE" width="240" height="180" border="10" /></a>
