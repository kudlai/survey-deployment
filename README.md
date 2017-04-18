# Deployment instruction:
Install dependencies on the control host (git and ansible)

```
apt update
apt install -y git python-pip libssl-dev
pip install ansible
```

clone deployment repo:

```
git clone https://github.com/kudlai/survey-deployment.git
cd survey-deployment/
```

## localhost run:
if you want to apply playbook to localhost and you are root just run:

```
ansible-playbook ansible/playbooks/environment.yml -i ansible/hosts.local
```

if you are working under non-priveleged user which is in sudoers list, run:
```
ansible-playbook ansible/playbooks/environment.yml -i ansible/hosts.local -K
```
and type the users password

## remote root run:
if you want to apply playbook to remote host and it accessible by ssh with a root user,
then edit file: "ansible/hosts", and replace ip in it with your remote host address.
when this is done, simple run:
```
ansible-playbook ansible/playbooks/environment.yml -i ansible/hosts
```
Or if you have ssh access of unprivileged user who is in sudoers list, run it so:
```
ansible-playbook ansible/playbooks/environment.yml -i ansible/hosts -K
```
and type the users password

# Testing:
When ansible is done, you can access application by typing it's adrress in browsers address form, 
on the route "/" application prints json list of fullnames of required emloyees,
on the route "/full" application prints json list of records containing all fields of emloyees of employees table, of required employees


# System description
The whole system consists of 4 containers, connected to internal bridge network "survey_net":
* mysql container
* dbmanager container
* application container
* nginx container


## mysql container
Uses default mysql image, have one anonymous volume, mounted to /var/lib/mysql, for !providing! persistancy of data, exposes port 3306 to internal network.

## dbmanager container
https://github.com/kudlai/survey-dbmanager
Contains simple self-developed python + bash application for database deployment and migration, it ensures that each database change applied to database instance only once, in right order.
I decided to serve it as separate container, as migration should be cared by application, but main application doesn't covers database management and used only to show single report.
The second option was to put this functionality to database instance, but it would be really unflexible solution.
Image is stored on the docker hub (ikudlay/survey-dbmanager).
Initial migration built with git checkout of test_db repo, then it gets rid of unnecesary for our purposes .git directory, and compressed for images minimization sake.


## application container
https://github.com/kudlai/survey-application
Contains python uwsgi flask application, that proveds information about employees in json.
Application is run as noroot:noroot, image based on alpine for size minimization purposes.

## nginx container
Uses default nginx image, with virtual host configuration file mounted to conf.d.
