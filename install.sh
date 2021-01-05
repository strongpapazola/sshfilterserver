apt install -qq -y iptables-persistent
mkdir /opt/
rm -r /opt/sshfilter/
iptables -D INPUT -j SSHFILTER
iptables -F SSHFILTER
mkdir -p /opt/sshfilter/
apt install curl -y
curl http://exppar.bisaai.id/sshfilter.sh -o /opt/sshfilter/sshfilter.sh
chmod +x /opt/sshfilter/sshfilter.sh
curl http://exppar.bisaai.id/sshfilter.service -o /etc/systemd/system/sshfilter.service
systemctl enable sshfilter.service
systemctl restart sshfilter.service
systemctl daemon-reload
systemctl restart sshfilter.service
#wget -qO- http://exppar.bisaai.id/install.sh | bash -s --
