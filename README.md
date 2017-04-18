# Deployment instruction
Install dependencies on the control host (Git and Ansible).

```
apt update
apt install -y git python-pip libssl-dev
pip install ansible
```

Clone deployment repo.

```
git clone https://github.com/kudlai/survey-deployment.git
cd survey-deployment/
```

Then you need to edit inventory file `ansible/hosts` and set there your host address and your user name.

```
nano ansible/hosts
```

Please, make sure that you have set up your ssh key on host, and you are able to connect to it without typing password.

You need to run the playbook `ansible/playbooks/environment.yml` to deploy the application.

To do this simply run:
```
ansible-playbook ansible/playbooks/environment.yml -i ansible/hosts -K
```
And type your user password.

If your user is root just omit -K parameter.

You can also run it locally with `ansible/hosts.local` inventory file.

Wait until Ansible finishes execution, and until dbmanager finishes database deployment (it takes about a minute).

# Testing
When deployment is done, you can access application by typing its address in browser address form, e.g. http://127.0.0.1/ .

On the route "/" application prints json list of fullnames of required emloyees.

On the route "/full" application prints json list of records containing all the fields of the emloyees table which fulfill the set requirements.


# System description
The whole system consists of 4 containers connected to internal bridge network "survey_net":
* MySQL container
* DBManager container
* Application container
* NGINX container


## MySQL container
The container uses official [mysql](https://hub.docker.com/_/mysql/) image.

It has one anonymous volume mounted to /var/lib/mysql in order to obtain persistency of data.

The container exposes port 3306 to internal network.

## DBManager container
[Image repo](https://github.com/kudlai/survey-dbmanager)

Image is stored on the docker hub [ikudlay/survey-dbmanager](https://hub.docker.com/r/ikudlay/survey-dbmanager/).

It contains simple self-developed Python + bash application for database deployment and migration, it ensures that each database change is applied to database instance only once, in the right order.

I decided to serve it as separate container, as normally migration should be taken care of by the application, but main application doesn't cover database management and is used only to show a single report.

The second option was to put this functionality to database instance, but it would be a really unflexible solution.

Initial migration is built with git checkout of test_db repo, then it gets rid of the unnecesary for our purposes .git directory, and compressed for images minimization sake.

The container consumes database parameters from environment variables which used by dbmanager python script directly.

## Application container
[Image repo](https://github.com/kudlai/survey-application)

Image is stored on the docker hub [ikudlay/survey-application](https://hub.docker.com/r/ikudlay/survey-application/)

It contains python uWSGI Flask application, that provides information about employees in json.

Application is run as noroot:noroot, image based on Alpine for size minimization purposes.

Application listens on port 8000 as http server, it is exposed by container to the internal network.

The container consumes database parameters from the environment variables and substitutes them to the application yaml configuration file with envsubst.

## NGINX container
Uses official [nginx](https://hub.docker.com/_/nginx/) image, with virtual host configuration file mounted to conf.d.

Container binds to the hosts 80 port, and proxies all requests to application container.
