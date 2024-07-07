FROM mcr.microsoft.com/dotnet/sdk:9.0.100-preview.5 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:9.0.100-preview.5 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["BlogPreviewCard.Client/BlogPreviewCard.Client.csproj", "BlogPreviewCard/BlogPreviewCard.Client/"]
RUN dotnet restore "BlogPreviewCard/BlogPreviewCard.Client/BlogPreviewCard.Client.csproj"
COPY . .
WORKDIR "/src/BlogPreviewCard/BlogPreviewCard.Client"
RUN dotnet build "BlogPreviewCard.Client.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "BlogPreviewCard.Client.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "BlogPreviewCard.Client.dll"]
