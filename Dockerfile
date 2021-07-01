FROM nimlang/nim:latest as build-image

WORKDIR /work
COPY ./ ./

RUN nimble build --app:staticlib -d:release --gc:arc
RUN mv main bootstrap
RUN chmod +x bootstrap

FROM public.ecr.aws/lambda/provided:al2

COPY --from=build-image /work/bootstrap /var/runtime/

CMD ["dummyHandler"]
