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

function compressDir()
{
  local compressedDirFullPath="${1}.tar.gz"
  local targetDirParentDir=$2
  local targetDirName=$3
  tar -zcf ${compressedDirFullPath} -C ${targetDirParentDir} ${targetDirName}
  sync
  printf "Generated: ${compressedDirFullPath} successfully.\\n"
}

function removeDir()
{
  local dir=$1
  rm -r ${dir}
}

