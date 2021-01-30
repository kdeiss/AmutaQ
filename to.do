11/19
erweiterung maschinespez. config files 
um lamw steuerung zu verbessern

10/19
xrestore.vmm ==> 755


vmware/xvmdk2host 
auswahl von host bei multi systemen OK
auswahl von ziel-datastore OK

z.B. mit 
CMDL="sshpass -p "$VMPASSWORD" ssh -o StrictHostKeyChecking=no $VMUSER@$VMHOST"
$CMDL vim-cmd hostsvc/datastore/listsummary


im nfs log wird das pw angezeigt für running !!!  OK
Beim setup wird neue maschinenliste nicht geschrieben !  OK
nfs export muss bei ip wechsel angepasst werden !
restore script cmd: bei fehler wird directory nicht erzeugt lässt er es geschehen steigt erst aus wenn vmx nicht kopiert wird  OK
datastore name dringend global !!!!
nur eine instanz von restore erlauben
mount: cannot access bazaar.tmp (no async)

INSTALL
logfiles muessen platt gemacht werden
smb auf user / nur die vmware freigabe lassen
installer: relative dateipfade !
screen installieren
pfade stimmen nicht für crontab

import disk !
restore: parameter auslesen aus rep
nfstemp loeschen !



asynctarget und ddumbfs auflösen - zwei unterschiedliche variablen! OK
system in wartemodus bevor backup geschrieben wird ! OK
async logfile aus conf
nfs1.log kommandoueile falsches logformat OK
pyzmail passwort verstecken OK
logausgabe von backup-single reduziert OK
logrotation OK
umount script neu (4.10.14) back into devel branch !!!!!!!!! OK
logrotte script neu (4.10.14) back into devel branch !!!!!!!!! OK
reclaim script (4.10.14) back into devel branch !!!!!!!!! OK

asynccopy alles findet statt in ddumbfs.tmp !  OK


pyzmail conf in /etc OK
mount scripte fuer konsole chmod 777 ??
rmold OK

