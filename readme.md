# AmutaQ!

AmutaQ! ist ein Backup-Tool für ESXI-Server. Es basiert auf einer Sammlung von aufeinander abgestimmter Bash-Skripte.
Zur Datenablage verwendet es ein deduplizierendes Dateisystem.

## Beschreibung
* Das Tool sichert die konfigurierten Maschinen auf eine Bufferdisk (*/mnt/bufferdisk*)
* die Sicherung kann mit einer Cloner-VM in eine eingerichtete Clone-Maschine z.B. auf einem anderen Server kopiert werden
* die Sicherung wird auf eine USB-Disk oder einen NFS-Speicher geschrieben. Dieser Vorgang kann asyncron zu den Backups durchgeführt werden.
* der USB-/NFS-Speicher ist mit einem deduplizierenden Dateisystem formatiert(*ddumbfs*).
* Das kopierte Backup auf dem USB-/NFS-Speicher wird per CRC-Check mit dem auf der Bufferdisk verglichen.
* Das laufende System kann mit Signal-Dateien beeinflusst werden.
* Die Bufferdisk und die USB-/NFS-Speicher können mit LUKS verschlüsselt werden.

## Einrichtung

### Installation
Die Installation ist auf der Console auszuführen.
Die Konfiguration wird dann über die grafische Oberfläche ausgeführt.
#### Erforderliche Hardware
Empfohlene Hardware
- 8 GB Arbeitsspeicher
- mind. 2 TB HDD als Bufferdisk zusätzlich zur Root-HDD
- empfohlen 2 Netzwerkkarten mit mind. 1 Gbit.
- USB-3.0 Anschlüsse für die USB-Disks
- 3 USB-3.0-Festplatten mit mind. 2 TB Kapazität

#### Installation einer Linux-Distribution
Zuerst wird auf dem zukünftigen Backup-PC oder einer virtuellen Maschine eine bebianbasierte Linux-Distribution installiert.  
Getestet ist das System auf Linux Mint. Es gibt einen Installer für Mint 17 und für Mint 20.
Es muss der Benutzer "dasi" angelegt werden.

#### Netzwerk konfigurieren
Es wird empfohlen 2 Netzwerke einzurichten. Eins für mit Zugang zum Internet und ein weiteres ausschließlich für die Backup-Daten.  
Idealerweise ist das Netzwerk zum Internet nicht mit dem Produktivsystem verbunden, sondern zu einem eigenen Wartungsnetz.

Es wird außerdem empfohlen, den NetworkManager zun entfernen und die Konfiguration über die */etc/network/interfaces* vorzunehmen.
Dafür den NetworkManager stoppen und deaktivieren.
```
	systemctl stop networkmanager
	systemctl disable networkmanager
```
Die Datei */etc/network/interfaces* kann beispielsweise so aussehen:
```
	auto lo
		iface lo inet loopback

	auto eth0   # Interface für Internet
#		iface eth0 inet dhcp		# für DHCP-Config
		iface eth0 inet static	# für manuelle Config
		address 192.168.0.1			# Ihre Daten eingeben
		netmask 255.255.255.0
		gateway 192.168.0.254
		broadcast 192.168.0.255 
		dns-nameservers 192.168.0.254

		
	auto eth1	#Interface für getrenntes Backup-Netz
		iface eth1 inet static
		address 192.168.1.1
		netmask 255.255.255.0
```
Auch Konfigurationen mit nur einer Netzwerkkarte mit VLANs oder als STP-Bridge mit VLANs sind ebenso möglich.  
Auf eine Beschreibung wird hier verzichtet. Weitere Informationen gibt es im Internet.

#### root SSH-Zugang einrichten
Ein root-Passwort erstellen mit
```
	sudo passwd
```
Dann den ssh-Service installieren
```
	apt install ssh
````
Die Datei */etc/ssh/sshd_config* bearbeiten und den Schalter
**PermitRootLogin yes** setzen  
```
	service sshd restart
```
Ein Zugang per Zertifikat ist auch möglich. Dies wird hier nicht erläutert. Anleitungen dazu sind im Internet zu finden.
#### AmutaQ!-Pakete kopieren
Das AmutaQ!-Paket und das AmutaQ!-Install-Paket müssen nun entpackt werden:
```
tar xvf AmutaQ![-install].tgz -C /
```

Um die Dateien aus dem GIT zu laden sind folgende Befehle nötig:
```
apt install git
cd /opt
git clone https://github.com/kdeiss/AmutaQ-installer.git AmutaQ\!-install
git clone https://github.com/kdeiss/AmutaQ.git AmutaQ\!
```
#### AmutaQ!-Install
Nun ist das install-Skript auszuführen.
```
cd /opt/AmutaQ\!-install/INSTALL
./install
```
Der Installer lädt einige Pakete nach und bereitet das System vor.
#### Bufferdisk formatieren
Nun muss die Bufferdisk formatiert werden und in der */etc/fstab* eingetragen werden.

Wird eine Verschlüsselung der Bufferdisk gewünscht, kann dafür das Skript */opt/AmutaQ\!-install/format_crypt_buffdisk* bzw. */opt/AmutaQ\!/crypt/format_crypt_buffdisk* verwendet werden.  
Hier ist als Parameter der Devicename anzugeben, z.B. *sdb* (ohne */dev/*).  
Es kann auch ein zweites Laufwerk als zweiter Parameter angegeben werden. Dann wird ein
Software-RAID 0 (Strip) über beide Laufwerke erstellt.
#### Konfiguration
Nun ist die grafische Oberfläche zu starten. Es ist auch möglich, diese per Remotedesktop zu starten.  
Auf dem Desktop ist ein Ordner *AmutaQ!* abgelegt.  
Darin befindet sich ein Link ***setup AmutaQ!***. Mit diesem Skript wird die AmutaQ!-Config erstellt und bearbeitet.  
Hier sind die Serverdaten des zu sichernden Servers und der jeweiligen VMs einzugeben.  
Weitere Konfigurationen sind weiter unten im Dokument beschrieben.

Anschließend werden mit dem Link ***setup Mail*** die Einstellungen zum Mailserver konfiguriert. Hierüber
werden Statusdaten des Sicherungssystems versendet.

#### USB-Disks initialisieren.
Zum initialisieren bitte die USB-Disks nun an den PC anschließen.  
Die USB-Disks werden mit dem Link *Format USB Disk* initialisiert.  
Zuerst erfolgt die Auswahl des einzurichtenden Laufwerks. Es wird vorab geprüft, ob ein Laufwerk bereits initialisert ist.  
Folgen Sie den Anweisungen des Programms.  
Ob der Datenträger verschlüsselt werden soll, wird bei einer Frage abgefragt.
#### ESXi-Hosts vorbereiten
Auf dem ESXi-Server muss nun ein zusätzlicher NFS-Datenspeicher eingerichtet. Dieser muss folgenden Namen haben:
```
BUFFERDISK_192.168.1.1
```
Die IP-Adresse muss entsprechend angepasst werden.
#### erster Start
Das System ist nun eingerichtet. Der erste Start erfolgt mit dem Start des Dienstes *ddumbfs*.
```
service ddumbfs start
```
Es wird dann die erste USB-Disk geöffnet und anschließend das erste Backup gestartet.

Auch nach einem Neustart des Computers wird das Skript automatisch gestartet. Ist die Bufferdisk verschlüsselt,
muss nach dem Hochfahren einmalig das Passwort für die Entschlüsselung der Bufferdisk eingegeben werden.
Dazu bitte einmal per ssh oder auf der Konsole als root einloggen.
### Bufferdisk
Für Bufferdisk kann ein normal formatiertes Volume verwendet werden, das unter */mnt/bufferdisk* gemountet wird.

### USB-/NFS-Speicher
Die USB-Disks werden mit dem Tool *tools/x-formatdisk* durchgeführt. Das Tool muss in der grafischen Oberfläche gestartet werden.
In dem interaktiven Tool wird die zu formatierende Disk und die Verschlüsselung gewählt.
Die Einbindung in die */etc/fstab* sowie die Konfiguration im AmutaQ! wird automatisch vorgenommen.

Die Namensgebung des Mountpoins der Volumes ist unabhängig von den */dev/sdX* -Namen, da in der */etc/fstab* die UUID der USB-Disk angegeben wird.

### Verschlüsselung
Im System ist die Möglichkeit eingebaut, die Bufferdisk und die USB-Speicher zu verschlüsseln.

Die **Bufferdisk** kann das mit dem Tool *tools/format_crypt_buffdisk* verschlüsselt werden.
Als Parameter wird das zu verschlüsselde Device (ohne 1!) (z.B. *sdb*) angegeben.  
Das Tool erstellt auch entsprechende Einträge in */etc/fstab* und */etc/crypttab*.  
Wird ein zweites Device als Parameter angegeben, wird ein verschlüsseltes RAID 0 aus 2 Festplatten erstellt.Wird ein zweites Device als Parameter angegeben, wird ein verschlüsseltes RAID 0 aus 2 Festplatten erstellt.
Es ist sicherzustellen, dass beide Festplatten die gleiche Kapazität haben und für beste Performance vom gleichen Typ sind.  
Die Bufferdisk wird mit einem manuell einzugebenden Schlüssel geschützt.  
Das Passwort muss nach einem Neustart des Systems manuell eingegeben werden.
Dazu wird beim ersten Login durch die *rc.local* das Skript *tools/mount_bufferdisk* gestartet, das zur Eingabe des Schlüssels auffordert,
die Bufferdisk öffnet, einbindet und das AmutaQ!-System starten lässt.

Die Verschlüsselung der **USB-Disks** wird mit dem Tool *tools/x-formatdisk* durchgeführt, indem die entsprechende Frage mit **Ja** beantwortet wird.  
Zur Entschlüsselung der USB-Disks ist ebenfalls ein Schlüssel nötig. Dieser Schlüssel wird mit dem Format-Tool automatisch erstellt.  
Das Öffnen und Schließen der Verschlüsselung der USB-Disks wird vom AmutaQ! automatisch durchgeführt.  
Wurde die Bufferdisk mit dem Tool verschlüsselt, wird der Schlüssel für die USB-Disk von der Bufferdisk abgeleitet.
Ist die Bufferdisk nicht verschlüsselt, wird eine Schlüsseldatei unter */mnt/bufferdisk/.crypt* erstellt.

Möchte man die verschlüsselte USB-Disk am gleichen System manuell öffnen, kann das Tool *crypt/cryptdisk_open_manual* verwendet werden.  
Das anschließende Mounten muss dann ebenfalls manuell gemacht werden.  
Das Schließen der Verschlüsselung passiert nach dem manuellen umount mit dem Systemtool *cryptdisk_stop*.  
Als Parameter wird der jeweilige Device-Name, wie ihn auch AmutaQ! verwendet, angegeben, z.B. *sdc1*  (mit 1!).

Damit nach einem Ausfall des AmutaQ!-Systems zugriff auf die USB-Disks möglich ist, sollte zusätzlich ein **manueller Schlüssel** eingetragen werden, der an einer sicheren Stelle abgelegt wird.  
Dafür ist das Tool *crypt/crypt_addkey* vorhanden. Als Parameter wird wieder der Device-Name angegeben.  
Es kann dann manuell ein neuer Key eingegeben werden. Es können bis zu 7 zusätzliche Schlüssel vergeben werden.

Weitergehende Informationen zum Thema Verschlüsselung können im Internet unter dem Thema LUKS gefunden werden.  
Beispielsweise auf das Entfernen eingegebener Schlüssel wird hier nicht eingegangen und ist nicht Bestandteid von AmutaQ!.

### Cloner-VM
Das System kann so ausgelegt werden, dass bei einem Hardwareausfall SOFORT von jeder VM eine Clone-VM mit Stand des letzten Backups gestartet und betrieben werden kann.
Dazu wird nach dem Backupvorgang eine Cloner-VM gestartet, die das aktuelle Backup in eine bereits vorhandene Kopie der Maschine schreibt.
Die Kopie der Maschine sollte sinnvollerweise auf einem anderen Host gespeichert sein.  
Das Clone-System ist grundsätzlich unabhängig vom Backupsystem.

Das Starten der Cloner-VMs wird vom AmutaQ! ausgeführt und überwacht.
Solange Cloner aktiv sind, wird das Kopieren auf USB-/NFS-Speicher mittels Signal-Datei blockiert.

Folgende Namenskonvention auf dem ESXi-Server müssen eingehalten werden:
* Maschinenname Origial-VM: **WICHTIGE_MASCHINE01**
* Clone der VM (auf anderer Hardware):  **WICHTIGE_MASCHINE01**_-CLONE_
* Die Cloner-VM, die die Daten übertägt: _CLONER4_**WICHTIGE_MASCHINE01**

Die Cloner-VM liegt auf dem gleichen Host wie die Kopie der Maschine. Der Cloner hat als Festplatten einerseits alle Festplatten der Kopie,
andererseits die Festplatten des Backups, die per NFS auf dem ESXI-Server bereitgestellt sind.
Die VM wird so eingerichtet, dass sie selber Zugriff auf die Bufferdisk per NFS hat, um Logfiles zu schreiben.
Weiter hat sie auch Zugriff aufs Internet zur Versendung von Status-Mails.
Idealerweise hat die Maschine dafür 2 separate Netzwerkadapter.

Im AmutaQ! gibt es einen Satz von Skripten die das Clonen in der Cloner-VM ausführen. Im Kern ist es das *doclone*-Skript.
Zusätzlich muss in einem maschinenspezifischen Skript konfiguriert werden, welche eingebundende Festplatte auf welche geklont wird.
Log-Files werden auf die Bufferdisk in einen definierten Ordner geschrieben.
Über diesen Ordner kommunizieren die Cloner mit Lock-Files miteinander und verhindern z.B. das Ausführen von mehreren Clonern gleichzeitig.
Dadurch wird auf der Bufferdisk ein sequenzielles Lesen zu ermöglicht.

## Konfiguration

### Single Server
im Ordner *etc/* ist die Datei AmutaQ!.conf für die Konfiguration zuständig.  
Wie im Kapitel Installation beschrieben, kann die Konfiguration auch über die grafische Oberfläche durchgeführt werden.
### Multiple Server
Um mehrere Server zu sichern werden mehrere .conf-Dateien erstellt. Diese erhalten die Endung .0, .1 usw.
Jede Datei enthält die Server-Angaben des zu sichernden Servers und der enthaltenen Maschinen.

Die Dateien werden dann der Reihe nach abgearbeitet. Die jeweils aktive Datei wird in die Datei ohne .X kopiert.  
### allgemeine Konfiguration
* VMUSER = ssh-Benutzer des Servers
* VMPASSWORD = ssh-Passwort des Servers
* VMHOST = IP-Adresse des Servers
* VMLIST = Auflistung der zu sichernden VMs auf der Maschine. Zu trennen mit Leerzeichen
* DDDEVICELIST = Auflistung der vorhandenen DDumb-USB-/NFS-Speicher und deren Namen in der */etc/fstab*
* BACKUPNETWORK_IP = IP-Adresse der Backup-Netzwerkkarte auf der aktuellen Maschine
### Backup-Spezifische Einstellungen
* BACKUPTOOL = Welches Backup-Tool soll verwendet werden? Standard = LAMW
    * LAMW = Das aktuelle Tool für ESXI-Server bis V 6.5
	* BAZAAR = ein altes Tool für ESXI-Server bis V 5.5 (mit Einschränkungen)
* KEEPVERSIONS = Anzahl der Backups die auf der Bufferdisk bleiben sollen
* KEEPVERSIONSONFINALTARGET = maximale Anzahl der Backups auf dem USB-/NFS-Speicher. Standard = 50. 
Dieser Wert wird anhand Speicher-Kapazität regelmäßig pro Volume neu berechnet, so dass der Speicher niemals überläuft. (Siehe *FILLMAX*)
* PARANOIAMODE = Der Paranoiamode steuert, ob Backups von dem ESXI-Server zuerst auf die
Bufferdisk oder direkt auf den USB-/NFS-Speicher geschrieben wird. Standard = 0.
    * Ein Wert von -1 schreibt alle Backups direkt auf den USB-/NFS-Speicher.
	* Ein Wert von 0 schreibt alle Backups zuerst auf die Bufferdisk und anschließend asyncron auf den USB-/NFS-Speicher
	* Ein Wert > 0 schreibt die Anzahl direkt auf den USB-/NFS-Speicher und anschließend ein Backup asyncron.
* HOUSEKEEPERAGE = löscht alle Backups ohne CRC-Check älter als diese Einstellung. Standard = +20
* FILLMAX = Übersteigt der verwendete Speicher auf dem USB-/NFS-Speicher diese Prozentangabe,
wird die Anzahl der verbleibenden Backups auf der Disk angepasst. Standard = 85
* LAZYBONEFLAG = Gibt an, ob nach Sicherung aller Maschinen das Backup angehalten wird. Standard = 1.
    * Ein Wert = 1 stoppt das Backup nach Ende des letzten Durchlaufs.
	* Der Wert = 0 startet sofort ein neues Backup nach Abschluß des letzten Durchlaufs.
### Async-Einstellungen
* ALLOWCRCINBACKGROUND = Darf der CRC-Check des USB-/NFS-Speichers im Hintergrund laufen? Standard = 0
* ALLOWCRCSOURCEINBACKGROUND = Darf der CRC-Check der Bufferdisk im Hintergrund laufen? Standard = 1
### Weitere Einstellungen
Diese Werte müssen standardmäßig nicht angepasst werden
* DDUMBVOL = Mountpoint des deduplizierenden Dateisystems. Standard = /mnt/ddumbfs
* ASYNCTARGET = Pfad, in dem die Backups im async-Modus abgelegt werden. Standard = $DDUMBVOL/bazaar
* VMBACKUPTARGET = Pfad, in dem die Backups auf der Bufferdisk abgelegt werden. Standard = /mnt/bufferdisk/bazaar
* BAZAARVCB = binary des bazaarvcb-Tools (auslaufend). Standard = /usr/local/bin/bazaarvcb
* SPOOLDIR = Pfad, in dem die Async-Spools hinterlegt werden. Standard = /opt/AmutaQ!/backup/spool
* SIGNAL = Pfad, in dem Signal-Dateien gesucht und geschrieben werden. Standard = /opt/AmutaQ!/backup/signal
* RSYNC_LOG = Dateipfad zur Haupt-Log-File. Standard = /var/log/nfs1.log
* ASYNC_LOG = Dateipfad zur Async-Log-File. Standard = /var/log/async.log
### USV-Einstellungen
* MINBATTERY = Anzahl der verbleibenden Minuten, bis das Herunterfahren beginnen soll

TODO: Config-Datei in AmutaQ!.conf hinterlegen
### E-Mail
TODO
### zukünftige Konfigurationen
* CPUPOOL4DDUMB =
* CLOUDDISK =
* SPOOLD4CLOUD =

## Betrieb
### Backup-System
Gestartet wird das System beim Powerup des Systems mit dem Mount-Skript, das wiederum über das Init-System gestartet wird.
Danach läuft das Backup-System in einer Endlosschleife.

Der Betrieb wird mit Signal-Dateien *backup/signal* und Spool-Dateien *backup/spool* gesteuert.
Weitere relevante Daten werden z.B. im */tmp/*-Ordner oder im Log-Ordner des Clone-Systems abgelegt.

Zu den meisten Signalen gibt es im Signal-Ordner ein Skript, das dieses Signal erstellt, und möglicherweise sogar überwacht.
### Async-Copy-System
Das Async-Copy-System ist unabhängig vom Backup-Skript selber. Das Async wird über einen Cron-Eintrag regelmäßig alle 5 Minuten
gestartet. Es prüft ob Spool-Dateien vorhanden sind und arbeitet diese dann ab.
### Signal-Dateien
Sind keine Signaldateien vorhanden, startet das Backup selbstständig und läuft im Dauermodus weiter.
#### wait
Ist in der Config-Datei der LAZYBONEFLAG = 1, wird nach einem Backup das Signal *wait* gesetzt.
Ist dieses Signal vorhanden, wartet das Backupsystem, bis das Signal verschwindet. 

Im *wait*-Modus werden regelmäßig die Signal-Dateien *switch* und *softswitch* geprüft.
#### waita
Dieses Signal versetzt das Async-Copy-System in einen Wartemodus. Sobald das Signal weg ist, wird weiter kopiert.
Außerdem wird der Hintergrund-CRC-Check der Bufferdisk pausiert.

Im Normalfall wird das Signal vom Cloner-System verwendet.
#### stop
Dieses Signal bewirkt ein endgültiges Beenden des Backup-Skripts. Ein erneutes Starten muss anschließend manuell erfolgen.
Auch ein eventuell laufendes Async-Skript wird mit dem Signal beendet.
Solange das Signal vorhanden ist, lässt sich das System auch nicht wieder starten.
#### astop
Dieses Signal bewirkt ein Beenden des Async-Skripts und verhindert ein erneutes starten.
#### crcstopS
Dieses Signal bewirkt ein Beenden des Hintergrund-CRC-Checks für die Bufferdisk.
Siehe auch die Konfiguration *ALLOWCRCSOURCEINBACKGROUND*.
#### switch
Dieses Signal löst einen Wechsel des USB-/NFS-Speichers aus. In der Regel sind 2 USB-Disks gleichzeitig angeschlossen. Dann wird auf das nächste Device gewechselt.
Dabei wird das DDUMBFS geschlossen, die Index-Datei auf der Disk gesichert, das alte Laufwerk getrennt, das neue Laufwerk und das neue DDUMBFS gemountet.
Sind Dayofweek-Platten eingerichtet werden diese mit dem Befehl an den jeweiligen Tagen geöffnet.
#### softswitch
Dieses Signal löst auch einen Wechsel des USB-/NFS-Speichers aus. Jedoch wird vorher abgewartet, bis alle laufenden Async-Spools abgearbeitet sind.
#### reload
Dieses Signal lässt das Backupsystem beenden. Es startet sich jedoch unmittelbar wieder selbst.
Es kann z.B. nach einem Update der Skripte verwendet werden, um die neuen Skripte zu laden.
#### skipcrc
Dieses Signal verhindert die Ausführung des CRC-Checks nach dem Kopieren auf den USB-/NFS-Speicher.
Das Signal wird automatisch bei NFS-Speichern gesetzt und nach dem Umount des NFS-Speichers automatisch wieder entfernt.

Um einen NFS-Speicher doch per CRC zu prüfen, kann auf der jeweiligen Festplatte im DDUMBFS
im Ordner *bazaar* eine Signaldatei Namens *noskipcrc* erstellt. Dieses Disk-Signal verhindert das setzen des *skipcrc*
#### donotswitch
Wenn dieses Signal gesetzt ist, wird ein mit *switch* eingeleiteter USB-/NFS-Speicherwechsel nicht durchgeführt.
#### donotcheck
dieses Signal verhindert den Check des DDUMBFS beim Mounten. Es ist ein manuelles Signal.
#### noautostart
dieses Signal verhindert einen Autostart des Mounts und des Backupsystems beim Restart des PCs. Es ist ein manuelles Signal.
### Signal-Skripte
Hier werden nur die Skripte in dem Ordner beschrieben, die mehr tun, als nur das Signal zu setzen.
#### reboot.sh
Dieses Skript setzt das *stop*-Signal, wartet, bis alle Skripte ordnungsgemäß beendet wurden und leitet dann einen Reboot des PCs ein.
#### kill.sh
Dieses Skript setzt das *stop*-Signal, wartet kurz und beginnt dann, ausgeführte Programme per kill zu beenden.
Dadurch wird z.B. ein laufendes Backup **abgebrochen**, und nicht wie bei *stop* ordnungsgemäß zu Ende ausgeführt.
#### stop.sh
Dieses Skript setzt das *stop*-Signal und wartet, bis alle Skripte ordnungsgemäß beendet wurden.
Währenddessen werden die Log-Files auf dem Bildschirm angezeigt.
### Spool-Dateien
Die Spool-Dateien werden vom Backup-System erstellt und enthalten Quell- und Zielangaben zu der jeweiligen VM.
Diese Datei wird vom Async-Copy-System eingelesen und der Reihe nach abgearbeitet.

## Logging
Das System erstellt relaiv ausführliche Log-Dateien.

Die Speicherorte werden in der Konfigurationsdatei gesetzt.

Im Ordner *log/* sind einige Skripte zum bequemen betrachten der Logs vorhanden.
## Wartung
### USB-/NFS-Speicher
Nach längerer Zeit der Benutzung eines USB-/NFS-Speichers fragmentiert die Festplatte zwangsweise und die Performance, vor allem beim CRC-Check, lässt deutlich nach.
Die Backup-Durchlaufzeit erhöht sich dann deutlich. Dann ist ein Neuerstellen des DDUMBFS nötig. Dazu gibt es das Skript *ddumbfs/reinit_fs*.  
Das Skript wird über die SSH-Konsole aufgerufen. Als Parameter wird der gemountete Ordner angegben (z.B. */mnt/sdc1*). Zuvor muss der *l0/ddumbfs*-Ordner gelöscht werden.  
Das Skript erstellt auf der gemounteten Disk ein neues DDUMBFS. Sowohl Formatierung als auch Verschlüsselung bleiben dabei bestehen.
Daher müssen auch keine Konfigurationsdateien angepasst werden.  
Das Tool kann auch bei per NFS verbundenen Disks verwendet werden.

## Problemlösung
Das System an sich läuft relaiv Stabil. Es ist jedoch auch einer Vielzahl von äußeren Einflüssen ausgesetzt. Dazu gehören:
- manueller USB-HDD-Wechsel
- Netzwerkverbindung / Switche
- ESXi-Hosts
- Snapshot-Erstellung
- NFS-Speicher auf anderen Systemen
- Internet-Verbindung (für E-Mails)
- Interne Hardware-Ausfälle

Jeder dieser Einflüsse kann das System zum Absturz oder zum aufhängen bringen.
Einzelne Einflüsse sind bereits in die Entwicklung eingeflossen und entsprechende Abwehrmaßnahmen eingebaut.
Eine generelle Lösungsmöglichkeit für die anderen Probleme sind nicht vorhanden.
Es hilft hier immer, sich die Log-Dateien im Detail anzusehen, um zu prüfen, an welcher Stelle sich das System unnormal verhält.
Die Maßnahmen sind dann an die gewonnenen Erkenntnisse anzupassen.
