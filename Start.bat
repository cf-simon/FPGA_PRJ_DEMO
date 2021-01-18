echo off

set VER=2018.2

call c:\Xilinx\Vivado\%VER%\settings64.bat

REM Below are not required for Vivado - just useful if you want to 
REM use the same shell for editing files and launching flows
REM http://www.mingw.org/wiki/HOWTO_Set_the_HOME_variable_for_cmd_exe

REM vim requires HOME environment variable to be set
set HOME=%USERPROFILE%

REM adding msys, git, and vim to the path env variable
SET PATH=C:\Xilinx\Vivado\%VER%\tps\win64\git-1.9.5\bin;%PATH%
SET PATH=C:\Xilinx\Vivado\%VER%\tps\share\vim\vim74;%PATH%
SET PATH=C:\Xilinx\Vivado_HLS\%VER%\msys\bin;%PATH%

REM some useful aliases to work better in linux
%SYSTEMROOT%\System32\doskey.exe ll=ls -altr $*
%SYSTEMROOT%\System32\doskey.exe vi=vim -N $*
%SYSTEMROOT%\System32\doskey.exe which=sh -c "which $*"

cd fpga

echo ************************************************************                 
echo *                                                          *
echo *    make ----  creat and compile the project              *
echo *    make clean ---- remove all compile files except rev   *
echo *    make distclean ---- remove all compile files          *
echo *    make release ---- release the image version           *
echo *    make flash ---- download the image to flash           *
echo *                                                          *
echo ************************************************************  

cmd.exe  
