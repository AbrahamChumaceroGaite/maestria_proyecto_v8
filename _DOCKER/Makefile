.PHONY: validate login build push init deploy remove services ps logs scale update backup restore setup teardown

validate:
	cd scripts && ./validate-env.sh

login:
	cd scripts && ./docker-login.sh

build:
	cd scripts && ./build-images.sh

push:
	cd scripts && ./push-images.sh

init:
	cd scripts && ./swarm-init.sh

deploy:
	cd scripts && ./stack-deploy.sh

remove:
	cd scripts && ./stack-remove.sh

services:
	cd scripts && ./stack-services.sh

ps:
	cd scripts && ./stack-ps.sh

logs:
	cd scripts && ./service-logs.sh

scale:
	cd scripts && ./service-scale.sh

update:
	cd scripts && ./service-update.sh

backup:
	cd scripts && ./backup-db.sh

restore:
	cd scripts && ./restore-db.sh

setup:
	cd scripts && ./complete-setup.sh

teardown:
	cd scripts && ./complete-teardown.sh
