#!/bin/bash

# a utility script that will create a "wrapped" command
# meaning it will run under
# nsenter --mount=/host/prox/1/ns/mnt -- $@

# usage: wrap_command.sh <dir> <cmd> <mode>
# e.g.
# wrap_command.sh /sbin mount 4755

# when running the container (e.g. control-node)
# set the DEBUG env to true and mount /tmp/flocker-command-log 
# onto the host to get a list of the commands run in this way


dir=$1
cmd=$2
mode=$3

cat > ${dir}/ns${cmd} <<EOF
#!/bin/bash

nsentercmd="/bin/nsenter --mount=/host/proc/1/ns/mnt -- ${dir}/${cmd} \$@"

if [ -n \$DEBUG ]; then
echo \$nsentercmd >> /tmp/flocker-command-log
fi

exec \$nsentercmd
EOF

chmod ${mode} ${dir}/ns${cmd}
mv ${dir}/${cmd} ${dir}/linux${cmd}
ln -s ${dir}/ns${cmd} ${dir}/${cmd}