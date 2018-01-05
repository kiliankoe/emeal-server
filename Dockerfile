FROM swiftdocker/swift:latest

COPY . ./

EXPOSE 9090

RUN swift build --configuration release

ENTRYPOINT [ ".build/release/Run" ]
CMD [ "serve" ]
