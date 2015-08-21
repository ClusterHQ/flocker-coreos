
# Step 1: provision some CoreOS nodes

* Go to [CloudFormation](https://console.aws.amazon.com/cloudformation/home#/stacks?filter=active)
* Create a new stack
* Use this template: `https://raw.githubusercontent.com/ClusterHQ/flocker-coreos/master/coreos-stable-hvm.template`
* Follow the on-screen instructions and then wait for your nodes to appear in [EC2](https://console.aws.amazon.com/ec2/v2/home)

# Step 2: deploy Flocker to them

* Install [Unofficial Flocker Tools](https://docs.clusterhq.com/en/latest/labs/installer.html)
* Pick a node from EC2 to host the control service, label it as the master

* When you create a ``cluster.yml``, copy and paste the IP addresses from the AWS control panel like this:

![coreos-aws.png]

```
for X in 52.28.222.66 52.28.221.225 52.28.249.132; do
    ssh -i ~/Downloads/luke-frankfurt.pem core@$X \
        'sudo mkdir /root/.ssh && \
         sudo cp .ssh/authorized_keys /root/.ssh/authorized_keys'
done
```
