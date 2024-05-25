@echo off


echo Changing directory ...
cd ../..
echo Now we are in project root Dir:  %cd% 
echo.
echo.


rem #Stop and remove existing containers, networks, and volumes
rem  docker compose down --volumes


rem Stop and remove existing containers and networks (excluding volumes)
docker compose down 

rem Build containers without caching 
docker compose build --no-cache

rem rem Build and recreate containers
rem docker compose up --build -d

rem  recreate containers
docker compose up  -d

@REM echo Rebuild completed!