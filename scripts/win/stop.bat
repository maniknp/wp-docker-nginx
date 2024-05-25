@echo off

echo Changing directory ...
cd ../..
echo Now we are in project root Dir:  %cd% 
echo.
echo.


rem Stop and remove existing containers and networks (excluding volumes)
docker compose stop 

@REM echo containers stopped Successfuly