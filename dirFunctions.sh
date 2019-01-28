function ensureDirExist()
{
  local dir=$1
  mkdir -p ${dir}
}

function createDir()
{
  local dir=$1
  mkdir ${dir}
}

function removeDir()
{
  local dir=$1
  rm -r ${dir}
}

function checkIfCommandIsAvailable()
{
  local commandToCheck=$1

  command -v ${commandToCheck} &> /dev/null; ERR=$?
  if [ $ERR -ne 0 ]; then printf "${commandToCheck} is not available.\\n"; fi
  return $ERR
}

function compressDir()
{
  local sourceDirFullPath="$1"
  local targetArchiveFullPath="$2"
  local compressCommand="$3"

  checkIfCommandIsAvailable ${compressCommand} || return 1

  local sourceDir=$(basename "${sourceDirFullPath}")
  local sourceDirParent=$(dirname "${sourceDirFullPath}")

  ensureDirExist ${sourceDirParent}

  startingPwd=${PWD}
  cd ${sourceDirParent}

  ${compressCommand} ${targetArchiveFullPath} ${sourceDir} > /dev/null; ERR=$?
  if [ $ERR -ne 0 ]; then
    printf "Unable to generate ${targetArchiveFullPath}\\n";
  else
    printf "Generated: ${targetArchiveFullPath} successfully.\\n"
    sync
  fi

  cd ${startingPwd}
  return $ERR
}

function compressDirWithTar()
{
  local sourceDirFullPath=$1
  local targetArchiveFullPath="${2}.tar.gz"

  local compressCommand="tar zcf"
  compressDir "${sourceDirFullPath}" "${targetArchiveFullPath}" "$compressCommand"
  return $?
}

function compressDirWithZip()
{
  local sourceDirFullPath=$1
  local targetArchiveFullPath="${2}.zip"

  local compressCommand="zip -r"
  compressDir "${sourceDirFullPath}" "${targetArchiveFullPath}" "$compressCommand"
  return $?
}

function isDirUnderSvn()
{
  local dir=$1

  startingPwd=${PWD}
  cd ${dir}

  svn info &> /dev/null; ERR=$?

  cd ${startingPwd}
  if [ $ERR -ne 0 ]; then echo "0"; else echo "1"; fi
}

function isCurrentDirUnderSvn()
{
  isDirUnderSvn ${PWD}
}

function isDirUnderGit()
{
  local dir=$1

  startingPwd=${PWD}
  cd ${dir}

  git status &> /dev/null; ERR=$?

  cd ${startingPwd}
  if [ $ERR -ne 0 ]; then echo "0"; else echo "1"; fi
}

function isCurrentDirUnderGit()
{
  isDirUnderGit ${PWD}
}
