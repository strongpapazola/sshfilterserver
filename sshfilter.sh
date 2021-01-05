while [ True ];do
if [ ! `which iptables` ]
then
 apt -qq -y install iptables
fi

if [ ! `which iptables-save` ]
then
 apt -qq -y install iptables-persistent
fi

if [ ! `which curl` ]
then
 apt -qq -y install curl
fi

# GET IP AND PORT FROM SSH
IPS=$(curl --silent -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.89 Safari/537.36" https://strongpapazola.github.io/main/sshtunnel.json);
PORTS=$(cat /etc/ssh/sshd_config | grep "Port" | grep [0-9] | cut -d ' ' -f 2)
TEMPIPS=$(cat /tmp/sshfilter)
#remove=$(iptables -L SSHFILTER -n --line-numbers | grep RETURN | cut -d ' ' -f 1 | sort -nr)

UPDATERULESECHO(){
# CLEAR CONNECTION
echo "iptables -D INPUT -j SSHFILTER"
echo "iptables -F SSHFILTER"

# ADD CONNECTION
echo "iptables -N SSHFILTER"
for PORT in $PORTS; do
 for ip in $IPS; do
  echo "iptables -A SSHFILTER -p tcp --dport $PORT -s $ip -j RETURN"
 done
 echo "iptables -A SSHFILTER -p tcp --dport $PORT -j DROP"
done
echo "iptables -A INPUT -j SSHFILTER"
echo "iptables-save > /etc/iptables/rules.v4"
}

UPDATERULES(){
# CLEAR CONNECTION
iptables -D INPUT -j SSHFILTER
iptables -F SSHFILTER

# ADD CONNECTION
iptables -N SSHFILTER
for PORT in $PORTS; do
 for ip in $IPS; do
  iptables -A SSHFILTER -p tcp --dport $PORT -s $ip -j RETURN
 done
 iptables -A SSHFILTER -p tcp --dport $PORT -j DROP
done
iptables -A INPUT -j SSHFILTER
iptables-save > /etc/iptables/rules.v4
}

INJECTTEMP(){
cat << EOF > /tmp/sshfilter
$IPS
EOF
}

#if [ ! -f "/tmp/sshfilter" ]; then
# INJECTTEMP
#fi
if [[ "$TEMPIPS" != "$IPS" ]]; then
 UPDATERULESECHO
 UPDATERULES
 INJECTTEMP
 echo '[*] Rules Not Has Been Syncronize...'
else
 echo '[*] Rules Has Been Syncronize...'
fi

sleep 5
done
