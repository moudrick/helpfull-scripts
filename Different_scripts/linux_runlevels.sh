#!/bin/sh
echo '
Linux RunLevels:
0 – System halt i.e the system can be safely powered off with no activity.
1 – Single user mode.
2 – Multiple user mode with no NFS(network file system).
3 – Multiple user mode under the command line interface and not under the graphical user interface.
4 – User-definable.
5 – Multiple user mode under GUI (graphical user interface) and this is the standard runlevel for most of the LINUX based systems.
6 – Reboot which is used to restart the system.
--------------------------------------------------
Runlevel 0 = poweroff.target (runlevel0.target)
Runlevel 1 = rescue.target (runlevel1.target)
Runlevel 2 = multi-user.target (runlevel2.target)
Runlevel 3 = multi-user.target (runlevel3.target)
Runlevel 4 = multi-user.target (runlevel4.target)
Runlevel 5 = graphical.target (runlevel5.target)
Runlevel 6 = reboot.target (runlevel6.target)
'

echo "RunLevels for current system:
`ls -l /lib/systemd/system/runlevel*`"

echo "Example. RunLevels of sshd: `systemctl show -p WantedBy sshd.service`"
echo "Current RunLevel: `systemctl get-default`"

# Change default runlevel
# ln -sf /lib/systemd/system/runlevel3.target /etc/systemd/system/default.target

# Get services for RunLevel chkconfig -list or systemctl list-dependencies multi-user.target

echo "Data for current RunLevel"
runlevel
echo '
Change RunLevels
sudo telinit 0 - shutdown system
sudo telinit 1 - run single user mode
...
sudo telinit 6 - reboot system
'
