docker_build:
	sudo docker build -t swift:emeal .

docker_deploy:
	sudo docker stop emeal
	sudo docker run --name emeal -d -p 9090:8080 swift:emeal

.PHONY: docker_build, docker_deploy
