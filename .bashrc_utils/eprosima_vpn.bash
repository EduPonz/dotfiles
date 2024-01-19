function eprosima_vpn ()
{
    local arg=${1};
    local connection_id=eprosima;
    if [[ ${arg} == 'up' ]]; then
        if nmcli -f GENERAL.STATE connection show ${connection_id} | grep --color=auto -q activated; then
            echo "${connection_id} VPN is already up";
            return 0;
        fi;
        nmcli connection up id ${connection_id};
        local ip_address=$(nmcli -f IP4.ADDRESS connection show ${connection_id} | awk '{print $2}' | awk '{split($0,a,"/"); print a[1]}');
        local interface=$(ifconfig | grep -B1 ${ip_address} | grep -o "^\w*");
        echo "- Interface:   ${interface}";
        echo "- IP address:  ${ip_address}";
        local routes="192.168.1.2 192.168.1.4 192.168.1.6 192.168.1.16 192.168.1.17 192.168.1.21";
        for route in ${routes};
        do
            echo "Adding route for ${route} to ${connection_id}";
            nmcli connection modify ${connection_id} +ipv4.routes ${route};
        done;
    else
        if [[ ${arg} == 'down' ]]; then
            if ! nmcli -f GENERAL.STATE connection show ${connection_id} | grep --color=auto -q activated; then
                echo "${connection_id} VPN is already down";
                return 0;
            fi;
            nmcli connection down id ${connection_id};
        else
            echo "------------------------------";
            echo "Connect to eProsima VPN";
            echo "------------------------------";
            echo "POSSITIONAL ARGUMENTS:";
            echo "   up       Connect to VPN";
            echo "   down     Disconnect from VPN";
            echo "";
            echo "EXAMPLE: eprosima_vpn up";
            echo "";
        fi;
    fi
}
