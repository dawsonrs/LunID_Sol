# LunID_Sol
Lun ID script for Solaris
Solaris LUN information gathering script

Checks Solaris server for fibre channel LUNs and reports on their details
for mpxio devices, the LUNID is the character string from positions 25-28 in the CxTxDxSx notation.
for non-mpxio devices, the LUNID is just the same as the volume number and is the "d" number in the CxTxDxSx notation.

How to run: execute the script by hand locally on any server or use whatever automation tooling is available. A summary is returned for each LUN with the field headings as follows:
# field order:
# LUNID,VOL NO,CAPACITY(MB),DISK_DEVICE,ARRAY_TYPE,ARRAY_SERIAL
