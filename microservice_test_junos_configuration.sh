# cd /
echo Ttest Junos configuration"

if [ -f "inputs/hosts.ini" ]
then
	ansible-playbook playbook.yml -i inputs/hosts.ini
else
	echo "No inventory file found, aborting"
fi

