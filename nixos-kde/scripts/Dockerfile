FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*
RUN curl -L -k -o publish.zip https://github.com/immisterio/Lampac/releases/latest/download/publish.zip
RUN unzip publish.zip
COPY init.conf .
EXPOSE 9118
CMD ["dotnet", "Lampac.dll"]
