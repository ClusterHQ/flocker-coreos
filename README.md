
# Step 1: provision some CoreOS nodes

Go to [CloudFormation](https://console.aws.amazon.com/cloudformation/home#/stacks?filter=active)
Use this template: 


```
for X in 52.28.222.66 52.28.221.225 52.28.249.132; do
    ssh -i ~/Downloads/luke-frankfurt.pem core@$X \
        'sudo mkdir /root/.ssh && \
         sudo cp .ssh/authorized_keys /root/.ssh/authorized_keys'
done
```
