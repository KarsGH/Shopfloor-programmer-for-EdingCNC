# Shopfloor-programmer-for-EdingCNC

EdingCNC Shopfloor Programmer for Eding CNC based milling machines.
A tool to easy make simple shapes programmed at the machine.

[<img src="https://github.com/VelocityMaximus/Eding-Shopfloor-Programmer-mill-/blob/main/example_milling_shopfloor_programmer.jpg">](https://github.com/VelocityMaximus/Eding-Shopfloor-Programmer-mill-)

The differences of V0.4 over V0.3 are:
Extended the warm-up routine with a choice to only run a spindle warm-up, only do the axis
movements or do both. Further the spindle rpm and time values are made programmable.
Fixed a bug in the Circular Drilling code regarding the retract value
Added a parameter assignment table in the comment

This Macro set is written and tested for Eding 4.03.xx but will also run on the new V5.0 Beta-6 and higher.

# For the latest version -V0.4- you need the following files:

Shopfloor-code-V0.4.cnc
   This file contains the G-code needed to operate "Shopfloor Programmer". This is not a full macro.cnc file as with previous versions.
    You need to add this code to your own macro.cnc file! This to ensure current settings and addions do not get lost.

Shopfloor EUB19-32.txt
   This file contains the calls for the Extended User Buttons 19 until 32 and need to be copied into the cnc.ini file.

Shopfloor DialogPictiures+Icons.zip
   Make sure you download the version of 17 March 2023 (otherwise the Warm-Up dialog picture is not applicable).
   Unzip this into two directoties: "Shopfloor Dialogpictures" and "Shopfloor Icons19-32". The Dialog-Pictures and Icons will
   complete "Shopfloor Programmer" to an easy to use tool. 

Shopfloor - User Manual V0.4.pdf
  This is the English version of the user manual. From V0.4 on, only an Englisch manual will be supported.

Please see the User Manual for a full description of the installation and use of the "Shopfloor Programmer for EdingCNC"
