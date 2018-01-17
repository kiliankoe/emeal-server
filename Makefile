test:
	swift test --parallel

release:
	swift build --configuration release

serve:
	swift run Run serve --env=testing

docker_build:
	docker build -t swift:emeal .

docker_run:
	docker run --name emeal -d -p 9090:8080 swift:emeal

.PHONY: test, serve, docker_build, docker_run
