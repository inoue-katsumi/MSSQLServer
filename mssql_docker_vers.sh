#!/usr/bin/env bash
# This assumes that Microsoft SQL Server Linux version docker image was
# started like $ docker run .. -e 'SA_PASSWORD=your_password'
docker image ls -a --format "{{.Repository}}" | grep mssql |
while read mssqlimg; do
  container_id=$(docker container ls --filter ancestor=$mssqlimg --format "{{.ID}}")
  if ! [ -z $container_id ]; then
    echo "Image: $mssqlimg, Container: $container_id"
    passw=$(docker container inspect $container_id | jq -r '.[0].Config.Env[]|select(test(.|"SA_PASSWORD"))[12:]')
    docker exec -t $container_id /opt/mssql-tools/bin/sqlcmd -U sa -P $passw -h -1 -y 256 -Y 256 -Q \
      "set nocount on; select @@version"
  fi
done
