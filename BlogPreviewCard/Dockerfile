FROM mcr.microsoft.com/dotnet/sdk:9.0.100-preview.5 AS publish
RUN dotnet workload install wasm-tools
WORKDIR /app

COPY ./publish /app

EXPOSE 8080
EXPOSE 8081

CMD ["dotnet", "BlogPreviewCard.dll"]