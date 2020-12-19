FROM nimlang/nim:latest as build-image

WORKDIR /work
COPY ./ ./

RUN nimble build --passL:-static -d:release
RUN mv main bootstrap
RUN chmod +x bootstrap

FROM public.ecr.aws/lambda/provided:al2

COPY --from=build-image /work/ /var/runtime/

CMD ["command"]
