#!/bin/bash
export TERM=xterm

# this script requires sendmail, for instructions to set that up see:
# https://www.digitalocean.com/community/questions/setting-up-email-with-sendmail
# you need an smtp server: I use https://sendinblue.com

# this will only work on Linux - I am working on a Mac version

DESTINATION_EMAIL="richardwhatever@gmail.com"

# temp directory for holding html output - *you will need to create this manually*
PLOTBOT_DIR="/home/richard/plotbot"

write_html_block() {
    echo "<h3>$1</h3><pre>" >> "$PLOTBOT_DIR/plotbot_output.html"
    echo "$2" >> "$PLOTBOT_DIR/plotbot_output.html"
    echo "</pre>" >> "$PLOTBOT_DIR/plotbot_output.html"
}

cd ~/chia-blockchain && . ./activate
#(cd ~/chia-blockchain && . ./activate) || (exit "Could not load the Chia application"; exit 1)


cd "$PLOTBOT_DIR"

> plotbot_output.html
echo  "<html><body><h2>$(hostname)</h2>" >> plotbot_output.html

# first argument is the friendly description, second argument is the linux CLI command to output
# we use cut -c-$(tput cols)) to make text columns work nicely in email
write_html_block "chia farm summary" "$(chia farm summary)"

write_html_block "plotman status" "$(plotman status)"

write_html_block "chia & plotman processes running" "$(ps -a  | grep -e 'plotman' -e 'chia')"

write_html_block "free memory" "$(free -h)"

write_html_block "disk space" "$(df)"

write_html_block "chia plot directories" "$(chia plots show)"

# needs mpstat - sudo apt install sysstat
write_html_block "cpu usage" "$(mpstat)"

write_html_block "chia error log" "$(cat ~/.chia/mainnet/log/debug.log | grep 'ERR' |  tail -n 20)"

write_html_block "chia warn log" "$(cat ~/.chia/mainnet/log/debug.log | grep 'WARN' | tail -n 20)"

write_html_block "chia info log" "$(cat ~/.chia/mainnet/log/debug.log | grep 'INFO' | tail -n 20)"

write_html_block "chia harvester farm ip connections" "$(cat ~/.chia/mainnet/log/debug.log | grep '192.168' |  tail -n 20)"

write_html_block "chia plots found log" "$(cat ~/.chia/mainnet/log/debug.log  | grep '1 plots were' |  tail -n 20)"

write_html_block "chia proofs found log" "$(cat ~/.chia/mainnet/log/debug.log  | grep 'Found 1 proof' |  tail -n 20)"

write_html_block "syslog" "$(tail -n 20 /var/log/syslog)"

# needs mailutils - sudo apt install mailutils
mail -a 'Content-Type: text/html' -s "chia update : $(hostname) : $(date +%F) $(date +%T)" -r plotbot@domain.com $DESTINATION_EMAIL < plotbot_out>

exit
