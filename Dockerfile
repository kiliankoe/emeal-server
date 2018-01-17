FROM swiftdocker/swift:latest

COPY . ./

EXPOSE 8080

RUN swift build --configuration release

ENTRYPOINT [ ".build/release/Run" ]
CMD [ "serve", "--env=production" ]
